#include "mock_data.h"

#include "ble_server.h"
#include "sdkconfig.h"
#include "ui/ui_manager.h"

#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include <string.h>

static const char *TAG = "mock_data";

static TaskHandle_t s_mock_task = NULL;
static bool s_running = false;

dashboard_state_t mock_data_ride_state(void)
{
    dashboard_state_t state = dashboard_state_default();
    state.version = 1;
    state.timestamp = 0;
    state.ride.speed_mph = 47.0f;
    state.ride.heading_deg = 82.0f;
    state.ride.has_heading = true;
    state.navigation.active = true;
    state.navigation.maneuver = MANEUVER_RIGHT;
    state.navigation.distance_meters = 640.0f;
    strncpy(state.navigation.instruction, "Turn right", sizeof(state.navigation.instruction) - 1);
    strncpy(state.navigation.street_name, "Main St", sizeof(state.navigation.street_name) - 1);
    state.navigation.eta_minutes = 14;
    state.has_device = true;
    state.device.phone_battery = 82;
    strncpy(state.device.gps_signal, "good", sizeof(state.device.gps_signal) - 1);
    return state;
}

static dashboard_state_t mock_data_no_route_state(void)
{
    dashboard_state_t state = mock_data_ride_state();
    state.navigation.active = false;
    state.navigation.maneuver = MANEUVER_NONE;
    state.navigation.distance_meters = 0.0f;
    state.navigation.instruction[0] = '\0';
    state.navigation.street_name[0] = '\0';
    state.navigation.eta_minutes = 0;
    return state;
}

static void mock_data_task(void *arg)
{
    (void)arg;

    dashboard_state_t state = mock_data_ride_state();
    bool show_ride = true;
    int tick = 0;

    ESP_LOGI(TAG, "Mock data task started");

    while (s_running) {
        if (ble_server_is_connected()) {
            vTaskDelay(pdMS_TO_TICKS(1000));
            continue;
        }

#if CONFIG_RIDEPUCK_MOCK_CYCLE_SCREENS
        if ((tick % 10) == 0) {
            show_ride = !show_ride;
            state = show_ride ? mock_data_ride_state() : mock_data_no_route_state();
            ESP_LOGI(TAG, "Mock screen cycle -> %s", show_ride ? "ride" : "no-route");
        }
#endif

        state.timestamp++;
        state.ride.speed_mph = 47.0f + (tick % 5);

        ui_manager_update(true, false, &state);

        tick++;
        vTaskDelay(pdMS_TO_TICKS(1000));
    }

    s_mock_task = NULL;
    vTaskDelete(NULL);
}

esp_err_t mock_data_start(void)
{
#if !CONFIG_RIDEPUCK_MOCK_DATA
    ESP_LOGI(TAG, "Mock data disabled in Kconfig");
    return ESP_OK;
#else
    if (s_mock_task != NULL) {
        return ESP_OK;
    }

    s_running = true;
    BaseType_t created =
        xTaskCreate(mock_data_task, "mock_data", 4096, NULL, 5, &s_mock_task);
    if (created != pdPASS) {
        s_running = false;
        ESP_LOGE(TAG, "Failed to create mock data task");
        return ESP_FAIL;
    }

    return ESP_OK;
#endif
}

void mock_data_stop(void)
{
    s_running = false;
}
