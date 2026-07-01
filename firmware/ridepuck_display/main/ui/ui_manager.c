#include "ui_manager.h"

#include "esp_log.h"

static const char *TAG = "ui_manager";
static ui_screen_t s_current_screen = UI_SCREEN_WAITING;

esp_err_t ui_manager_init(void)
{
    // TODO: init LVGL, display driver, and round panel
    ESP_LOGI(TAG, "UI manager init (stub) — showing waiting screen");
    s_current_screen = UI_SCREEN_WAITING;
    return ESP_OK;
}

void ui_manager_update(bool ble_connected, const dashboard_state_t *state)
{
    ui_screen_t next = UI_SCREEN_WAITING;

    if (!ble_connected) {
        next = UI_SCREEN_ERROR;
    } else if (state != NULL && state->navigation.active) {
        next = UI_SCREEN_RIDE;
    } else if (ble_connected) {
        next = UI_SCREEN_NO_ROUTE;
    }

    if (next != s_current_screen) {
        ESP_LOGI(TAG, "Screen transition: %d -> %d", s_current_screen, next);
        s_current_screen = next;
        // TODO: swap LVGL screen objects
    }
}
