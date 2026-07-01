#include "ui_manager.h"

#include "display_driver.h"
#include "screens/screen_error.h"
#include "screens/screen_no_route.h"
#include "screens/screen_ride.h"
#include "screens/screen_waiting.h"

#include "esp_check.h"
#include "esp_log.h"

static const char *TAG = "ui_manager";

static ui_screen_t s_current_screen = UI_SCREEN_WAITING;
static lv_obj_t *s_screen_waiting = NULL;
static lv_obj_t *s_screen_no_route = NULL;
static lv_obj_t *s_screen_ride = NULL;
static lv_obj_t *s_screen_error = NULL;

static ui_screen_t resolve_screen(bool ble_connected, bool had_connection,
                                  const dashboard_state_t *state)
{
    if (!ble_connected) {
        return had_connection ? UI_SCREEN_ERROR : UI_SCREEN_WAITING;
    }

    if (state != NULL && state->navigation.active) {
        return UI_SCREEN_RIDE;
    }

    return UI_SCREEN_NO_ROUTE;
}

static lv_obj_t *screen_obj_for(ui_screen_t screen)
{
    switch (screen) {
    case UI_SCREEN_WAITING:
        return s_screen_waiting;
    case UI_SCREEN_NO_ROUTE:
        return s_screen_no_route;
    case UI_SCREEN_RIDE:
        return s_screen_ride;
    case UI_SCREEN_ERROR:
        return s_screen_error;
    default:
        return s_screen_waiting;
    }
}

static void refresh_screen(ui_screen_t screen, const dashboard_state_t *state)
{
    switch (screen) {
    case UI_SCREEN_WAITING:
        screen_waiting_update();
        break;
    case UI_SCREEN_NO_ROUTE:
        screen_no_route_update(state);
        break;
    case UI_SCREEN_RIDE:
        screen_ride_update(state);
        break;
    case UI_SCREEN_ERROR:
        screen_error_update();
        break;
    default:
        break;
    }
}

esp_err_t ui_manager_init(void)
{
    ESP_RETURN_ON_FALSE(display_driver_init() == ESP_OK, ESP_FAIL, TAG, "display init failed");

    if (!display_driver_lock(-1)) {
        ESP_LOGE(TAG, "Failed to lock LVGL for UI init");
        return ESP_FAIL;
    }

    s_screen_waiting = screen_waiting_create();
    s_screen_no_route = screen_no_route_create();
    s_screen_ride = screen_ride_create();
    s_screen_error = screen_error_create();

    lv_scr_load(s_screen_waiting);
    s_current_screen = UI_SCREEN_WAITING;

    display_driver_unlock();

    ESP_LOGI(TAG, "UI manager ready");
    return ESP_OK;
}

void ui_manager_update(bool ble_connected, bool had_connection, const dashboard_state_t *state)
{
    ui_screen_t next = resolve_screen(ble_connected, had_connection, state);

    if (!display_driver_lock(100)) {
        ESP_LOGW(TAG, "LVGL lock timeout — skipping UI update");
        return;
    }

    if (next != s_current_screen) {
        ESP_LOGI(TAG, "Screen transition: %d -> %d", s_current_screen, next);
        lv_scr_load(screen_obj_for(next));
        s_current_screen = next;
    }

    refresh_screen(s_current_screen, state);
    display_driver_unlock();
}
