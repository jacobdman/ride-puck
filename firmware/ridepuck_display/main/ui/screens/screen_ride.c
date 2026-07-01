#include "screen_ride.h"

#include "../ui_theme.h"

#include <stdio.h>
#include <string.h>

static lv_obj_t *s_speed_label = NULL;
static lv_obj_t *s_unit_label = NULL;
static lv_obj_t *s_maneuver_label = NULL;
static lv_obj_t *s_distance_label = NULL;
static lv_obj_t *s_street_label = NULL;
static lv_obj_t *s_eta_label = NULL;

static const char *maneuver_symbol(maneuver_type_t maneuver)
{
    switch (maneuver) {
    case MANEUVER_LEFT:
    case MANEUVER_SLIGHT_LEFT:
        return LV_SYMBOL_LEFT;
    case MANEUVER_RIGHT:
    case MANEUVER_SLIGHT_RIGHT:
        return LV_SYMBOL_RIGHT;
    case MANEUVER_STRAIGHT:
        return LV_SYMBOL_UP;
    case MANEUVER_U_TURN:
        return LV_SYMBOL_REFRESH;
    case MANEUVER_ARRIVE:
        return LV_SYMBOL_OK;
    case MANEUVER_MERGE:
        return LV_SYMBOL_SHUFFLE;
    case MANEUVER_ROUNDABOUT:
        return LV_SYMBOL_LOOP;
    default:
        return LV_SYMBOL_UP;
    }
}

static void format_distance(float meters, char *buf, size_t buf_len)
{
    if (meters >= 1609.0f) {
        snprintf(buf, buf_len, "%.1f mi", meters / 1609.0f);
    } else {
        snprintf(buf, buf_len, "%.0f ft", meters * 3.28084f);
    }
}

lv_obj_t *screen_ride_create(void)
{
    lv_obj_t *screen = lv_obj_create(NULL);
    ui_apply_screen_style(screen);

    s_maneuver_label = lv_label_create(screen);
    lv_label_set_text(s_maneuver_label, LV_SYMBOL_RIGHT);
    lv_obj_set_style_text_color(s_maneuver_label, UI_COLOR_ACCENT, 0);
    lv_obj_set_style_text_font(s_maneuver_label, &lv_font_montserrat_28, 0);
    lv_obj_align(s_maneuver_label, LV_ALIGN_TOP_MID, 0, 16);

    s_speed_label = lv_label_create(screen);
    lv_label_set_text(s_speed_label, "0");
    lv_obj_set_style_text_color(s_speed_label, UI_COLOR_TEXT, 0);
    lv_obj_set_style_text_font(s_speed_label, &lv_font_montserrat_48, 0);
    lv_obj_align(s_speed_label, LV_ALIGN_CENTER, 0, -10);

    s_unit_label = lv_label_create(screen);
    lv_label_set_text(s_unit_label, "MPH");
    lv_obj_set_style_text_color(s_unit_label, UI_COLOR_MUTED, 0);
    lv_obj_set_style_text_font(s_unit_label, &lv_font_montserrat_14, 0);
    lv_obj_align(s_unit_label, LV_ALIGN_CENTER, 0, 28);

    s_distance_label = lv_label_create(screen);
    lv_label_set_text(s_distance_label, "--");
    lv_obj_set_style_text_color(s_distance_label, UI_COLOR_TEXT, 0);
    lv_obj_set_style_text_font(s_distance_label, &lv_font_montserrat_18, 0);
    lv_obj_align(s_distance_label, LV_ALIGN_BOTTOM_MID, 0, -52);

    s_street_label = lv_label_create(screen);
    lv_label_set_text(s_street_label, "");
    lv_obj_set_style_text_color(s_street_label, UI_COLOR_MUTED, 0);
    lv_obj_set_style_text_font(s_street_label, &lv_font_montserrat_14, 0);
    lv_obj_set_width(s_street_label, 200);
    lv_label_set_long_mode(s_street_label, LV_LABEL_LONG_DOT);
    lv_obj_set_style_text_align(s_street_label, LV_TEXT_ALIGN_CENTER, 0);
    lv_obj_align(s_street_label, LV_ALIGN_BOTTOM_MID, 0, -28);

    s_eta_label = lv_label_create(screen);
    lv_label_set_text(s_eta_label, "");
    lv_obj_set_style_text_color(s_eta_label, UI_COLOR_MUTED, 0);
    lv_obj_set_style_text_font(s_eta_label, &lv_font_montserrat_12, 0);
    lv_obj_align(s_eta_label, LV_ALIGN_BOTTOM_MID, 0, -8);

    return screen;
}

void screen_ride_update(const dashboard_state_t *state)
{
    if (state == NULL) {
        return;
    }

    char buf[32];

    snprintf(buf, sizeof(buf), "%.0f", state->ride.speed_mph);
    lv_label_set_text(s_speed_label, buf);

    lv_label_set_text(s_maneuver_label, maneuver_symbol(state->navigation.maneuver));

    if (state->navigation.distance_meters > 0.0f) {
        format_distance(state->navigation.distance_meters, buf, sizeof(buf));
        lv_label_set_text(s_distance_label, buf);
    } else {
        lv_label_set_text(s_distance_label, "--");
    }

    if (state->navigation.street_name[0] != '\0') {
        lv_label_set_text(s_street_label, state->navigation.street_name);
    } else if (state->navigation.instruction[0] != '\0') {
        lv_label_set_text(s_street_label, state->navigation.instruction);
    } else {
        lv_label_set_text(s_street_label, "");
    }

    if (state->navigation.eta_minutes > 0) {
        snprintf(buf, sizeof(buf), "ETA %d min", state->navigation.eta_minutes);
        lv_label_set_text(s_eta_label, buf);
    } else {
        lv_label_set_text(s_eta_label, "");
    }
}
