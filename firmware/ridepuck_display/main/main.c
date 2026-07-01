#include <stdio.h>

#include "ble_server.h"
#include "dashboard_state.h"
#include "esp_log.h"
#include "esp_err.h"
#include "nvs_flash.h"
#include "ui/ui_manager.h"

static const char *TAG = "ridepuck";
static dashboard_state_t s_state;
static bool s_ble_connected = false;

static void on_dashboard_state_received(const char *json, size_t len)
{
    dashboard_state_t parsed;
    if (dashboard_state_parse(json, len, &parsed)) {
        s_state = parsed;
        ui_manager_update(s_ble_connected, &s_state);
    }
}

void app_main(void)
{
    ESP_LOGI(TAG, "RidePuck display firmware starting");

    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    s_state = dashboard_state_default();

    ESP_ERROR_CHECK(ui_manager_init());
    ESP_ERROR_CHECK(ble_server_init());
    ble_server_set_dashboard_callback(on_dashboard_state_received);

    ui_manager_update(s_ble_connected, &s_state);

    ESP_LOGI(TAG, "Ready — waiting for phone connection");
}
