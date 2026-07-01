#include "screen_no_route.h"

#include "../ui_theme.h"

#include <stdio.h>

static lv_obj_t *s_speed_label = NULL;
static lv_obj_t *s_unit_label = NULL;
static lv_obj_t *s_status_label = NULL;

lv_obj_t *screen_no_route_create(void)
{
    lv_obj_t *screen = lv_obj_create(NULL);
    ui_apply_screen_style(screen);

    s_speed_label = lv_label_create(screen);
    lv_label_set_text(s_speed_label, "0");
    lv_obj_set_style_text_color(s_speed_label, UI_COLOR_TEXT, 0);
    lv_obj_set_style_text_font(s_speed_label, &lv_font_montserrat_48, 0);
    lv_obj_align(s_speed_label, LV_ALIGN_CENTER, 0, -30);

    s_unit_label = lv_label_create(screen);
    lv_label_set_text(s_unit_label, "MPH");
    lv_obj_set_style_text_color(s_unit_label, UI_COLOR_MUTED, 0);
    lv_obj_set_style_text_font(s_unit_label, &lv_font_montserrat_16, 0);
    lv_obj_align(s_unit_label, LV_ALIGN_CENTER, 0, 10);

    s_status_label = lv_label_create(screen);
    lv_label_set_text(s_status_label, "No Route");
    lv_obj_set_style_text_color(s_status_label, UI_COLOR_ACCENT, 0);
    lv_obj_set_style_text_font(s_status_label, &lv_font_montserrat_20, 0);
    lv_obj_align(s_status_label, LV_ALIGN_CENTER, 0, 50);

    return screen;
}

void screen_no_route_update(const dashboard_state_t *state)
{
    if (state == NULL) {
        return;
    }

    char speed_buf[8];
    snprintf(speed_buf, sizeof(speed_buf), "%.0f", state->ride.speed_mph);
    lv_label_set_text(s_speed_label, speed_buf);
}
