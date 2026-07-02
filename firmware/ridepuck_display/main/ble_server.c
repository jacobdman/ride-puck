#include "ble_server.h"

#include "esp_bt.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_gap_ble_api.h"
#include "esp_gatt_common_api.h"
#include "esp_gatts_api.h"
#include "esp_log.h"
#include "nvs_flash.h"

#include <string.h>

static const char *TAG = "ble_server";

#define GATTS_APP_ID           0xFE00
#define GATTS_SERVICE_UUID     0xFE00
#define GATTS_CHAR_UUID        0xFE01
#define GATTS_NUM_HANDLE       3
#define GATTS_DASHBOARD_MAX_LEN 512

#define ADV_CONFIG_FLAG        (1 << 0)
#define SCAN_RSP_CONFIG_FLAG   (1 << 1)

static ble_dashboard_state_cb_t s_dashboard_cb = NULL;
static ble_connection_cb_t s_connection_cb = NULL;
static bool s_connected = false;
static uint16_t s_conn_id = 0;
static esp_gatt_if_t s_gatts_if = ESP_GATT_IF_NONE;
static uint16_t s_service_handle = 0;
static uint16_t s_char_handle = 0;

static uint8_t s_adv_config_done = 0;

static char s_write_buf[GATTS_DASHBOARD_MAX_LEN];
static uint16_t s_write_len = 0;

static const uint16_t primary_service_uuid = ESP_GATT_UUID_PRI_SERVICE;
static const uint16_t character_declaration_uuid = ESP_GATT_UUID_CHAR_DECLARE;
static const uint8_t char_prop_read_write = ESP_GATT_CHAR_PROP_BIT_WRITE |
                                            ESP_GATT_CHAR_PROP_BIT_WRITE_NR;

static const uint8_t service_uuid128[16] = {
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80,
    0x00, 0x10, 0x00, 0x00, 0x00, 0xfe, 0x00, 0x00,
};

static const uint8_t char_uuid128[16] = {
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80,
    0x00, 0x10, 0x00, 0x00, 0x01, 0xfe, 0x00, 0x00,
};

static const esp_ble_adv_data_t adv_data = {
    .set_scan_rsp = false,
    .include_name = true,
    .include_txpower = true,
    .min_interval = 0x0006,
    .max_interval = 0x0010,
    .appearance = 0x00,
    .manufacturer_len = 0,
    .p_manufacturer_data = NULL,
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = sizeof(service_uuid128),
    .p_service_uuid = (uint8_t *)service_uuid128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

static const esp_ble_adv_data_t scan_rsp_data = {
    .set_scan_rsp = true,
    .include_name = true,
    .include_txpower = true,
    .appearance = 0x00,
    .manufacturer_len = 0,
    .p_manufacturer_data = NULL,
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = 0,
    .p_service_uuid = NULL,
    .flag = 0,
};

static esp_ble_adv_params_t adv_params = {
    .adv_int_min = 0x20,
    .adv_int_max = 0x40,
    .adv_type = ADV_TYPE_IND,
    .own_addr_type = BLE_ADDR_TYPE_PUBLIC,
    .channel_map = ADV_CHNL_ALL,
    .adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

static const esp_gatts_attr_db_t gatt_db[GATTS_NUM_HANDLE] = {
    {
        {ESP_GATT_AUTO_RSP},
        {ESP_UUID_LEN_16, (uint8_t *)&primary_service_uuid, ESP_GATT_PERM_READ,
         sizeof(service_uuid128), sizeof(service_uuid128), (uint8_t *)service_uuid128},
    },
    {
        {ESP_GATT_AUTO_RSP},
        {ESP_UUID_LEN_16, (uint8_t *)&character_declaration_uuid, ESP_GATT_PERM_READ,
         sizeof(uint8_t), sizeof(uint8_t), (uint8_t *)&char_prop_read_write},
    },
    {
        {ESP_GATT_AUTO_RSP},
        {ESP_UUID_LEN_128, (uint8_t *)char_uuid128,
         ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
         GATTS_DASHBOARD_MAX_LEN, 0, NULL},
    },
};

static void start_advertising(void)
{
    esp_ble_gap_start_advertising(&adv_params);
}

static void gap_event_handler(esp_gap_ble_cb_event_t event, esp_ble_gap_cb_param_t *param)
{
    switch (event) {
    case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
        s_adv_config_done |= ADV_CONFIG_FLAG;
        if (s_adv_config_done == (ADV_CONFIG_FLAG | SCAN_RSP_CONFIG_FLAG)) {
            start_advertising();
        }
        break;
    case ESP_GAP_BLE_SCAN_RSP_DATA_SET_COMPLETE_EVT:
        s_adv_config_done |= SCAN_RSP_CONFIG_FLAG;
        if (s_adv_config_done == (ADV_CONFIG_FLAG | SCAN_RSP_CONFIG_FLAG)) {
            start_advertising();
        }
        break;
    case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
        if (param->adv_start_cmpl.status != ESP_BT_STATUS_SUCCESS) {
            ESP_LOGE(TAG, "Advertising start failed");
        } else {
            ESP_LOGI(TAG, "Advertising as RidePuck");
        }
        break;
    default:
        break;
    }
}

static void deliver_dashboard_payload(void)
{
    if (s_dashboard_cb != NULL && s_write_len > 0) {
        s_write_buf[s_write_len < GATTS_DASHBOARD_MAX_LEN ? s_write_len : GATTS_DASHBOARD_MAX_LEN - 1] =
            '\0';
        s_dashboard_cb(s_write_buf, s_write_len);
    }
    s_write_len = 0;
}

static void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if,
                                esp_ble_gatts_cb_param_t *param)
{
    switch (event) {
    case ESP_GATTS_REG_EVT:
        if (param->reg.status == ESP_GATT_OK) {
            s_gatts_if = gatts_if;
            esp_ble_gap_set_device_name("RidePuck");
            esp_ble_gap_config_adv_data((esp_ble_adv_data_t *)&adv_data);
            esp_ble_gap_config_adv_data((esp_ble_adv_data_t *)&scan_rsp_data);
            esp_ble_gatts_create_attr_tab(gatt_db, gatts_if, GATTS_NUM_HANDLE, 0);
        }
        break;
    case ESP_GATTS_CREAT_ATTR_TAB_EVT:
        if (param->add_attr_tab.status == ESP_GATT_OK) {
            s_service_handle = param->add_attr_tab.handles[0];
            s_char_handle = param->add_attr_tab.handles[2];
            esp_ble_gatts_start_service(s_service_handle);
        }
        break;
    case ESP_GATTS_CONNECT_EVT:
        s_connected = true;
        s_conn_id = param->connect.conn_id;
        ESP_LOGI(TAG, "Phone connected");
        esp_ble_conn_update_params_t conn_params = {0};
        memcpy(conn_params.bda, param->connect.remote_bda, sizeof(esp_bd_addr_t));
        conn_params.latency = 0;
        conn_params.max_int = 0x20;
        conn_params.min_int = 0x10;
        conn_params.timeout = 400;
        esp_ble_gap_update_conn_params(&conn_params);
        if (s_connection_cb != NULL) {
            s_connection_cb(true);
        }
        break;
    case ESP_GATTS_DISCONNECT_EVT:
        s_connected = false;
        ESP_LOGI(TAG, "Phone disconnected");
        if (s_connection_cb != NULL) {
            s_connection_cb(false);
        }
        start_advertising();
        break;
    case ESP_GATTS_WRITE_EVT:
        if (!param->write.is_prep && param->write.handle == s_char_handle) {
            uint16_t len = param->write.len;
            if (len > 0) {
                if (len >= GATTS_DASHBOARD_MAX_LEN) {
                    len = GATTS_DASHBOARD_MAX_LEN - 1;
                }
                memcpy(s_write_buf, param->write.value, len);
                s_write_len = len;
                deliver_dashboard_payload();
            }
        }
        break;
    default:
        break;
    }
}

esp_err_t ble_server_init(void)
{
    esp_err_t ret;

    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    ret = esp_bt_controller_init(&bt_cfg);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "BT controller init failed: %s", esp_err_to_name(ret));
        return ret;
    }

    ret = esp_bt_controller_enable(ESP_BT_MODE_BLE);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "BT controller enable failed: %s", esp_err_to_name(ret));
        return ret;
    }

    ret = esp_bluedroid_init();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Bluedroid init failed: %s", esp_err_to_name(ret));
        return ret;
    }

    ret = esp_bluedroid_enable();
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Bluedroid enable failed: %s", esp_err_to_name(ret));
        return ret;
    }

    ret = esp_ble_gatts_register_callback(gatts_event_handler);
    if (ret != ESP_OK) {
        return ret;
    }

    ret = esp_ble_gap_register_callback(gap_event_handler);
    if (ret != ESP_OK) {
        return ret;
    }

    ret = esp_ble_gatts_app_register(GATTS_APP_ID);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "GATT app register failed: %s", esp_err_to_name(ret));
        return ret;
    }

    ret = esp_ble_gatt_set_local_mtu(512);
    if (ret != ESP_OK) {
        ESP_LOGW(TAG, "Failed to set local MTU: %s", esp_err_to_name(ret));
    }

    ESP_LOGI(TAG, "BLE GATT server initialized");
    return ESP_OK;
}

void ble_server_set_dashboard_callback(ble_dashboard_state_cb_t cb)
{
    s_dashboard_cb = cb;
}

void ble_server_set_connection_callback(ble_connection_cb_t cb)
{
    s_connection_cb = cb;
}

bool ble_server_is_connected(void)
{
    return s_connected;
}
