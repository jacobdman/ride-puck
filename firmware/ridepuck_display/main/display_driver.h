#pragma once

#include "esp_err.h"
#include "lvgl.h"

/// Initialize SPI panel, backlight, and LVGL port task.
esp_err_t display_driver_init(void);

/// Lock LVGL before calling LVGL APIs from non-LVGL tasks.
bool display_driver_lock(int timeout_ms);

/// Unlock LVGL after display_driver_lock().
void display_driver_unlock(void);
