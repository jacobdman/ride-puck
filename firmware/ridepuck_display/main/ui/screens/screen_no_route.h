#pragma once

#include "dashboard_state.h"
#include "lvgl.h"

lv_obj_t *screen_no_route_create(void);
void screen_no_route_update(const dashboard_state_t *state);
