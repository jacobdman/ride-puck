#pragma once

#include "dashboard_state.h"
#include "lvgl.h"

lv_obj_t *screen_ride_create(void);
void screen_ride_update(const dashboard_state_t *state);
