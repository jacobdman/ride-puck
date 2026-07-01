#pragma once

#include "dashboard_state.h"
#include "esp_err.h"

typedef enum {
    UI_SCREEN_WAITING,
    UI_SCREEN_NO_ROUTE,
    UI_SCREEN_RIDE,
    UI_SCREEN_ERROR,
} ui_screen_t;

/// Initialize LVGL and display driver.
esp_err_t ui_manager_init(void);

/// Route to the appropriate screen based on connection and dashboard state.
void ui_manager_update(bool ble_connected, bool had_connection, const dashboard_state_t *state);
