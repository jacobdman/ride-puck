#include "ble_server.h"

#include "esp_log.h"

static const char *TAG = "ble_server";

esp_err_t ble_server_init(void)
{
    // TODO: configure Bluedroid BLE GATT server
    // - Service UUID: 0000FE00-0000-1000-8000-00805F9B34FB
    // - Characteristic UUID: 0000FE01-0000-1000-8000-00805F9B34FB
    // - Advertise as "RidePuck"
    ESP_LOGI(TAG, "BLE server init (stub)");
    return ESP_OK;
}

void ble_server_set_dashboard_callback(ble_dashboard_state_cb_t cb)
{
    (void)cb;
}
