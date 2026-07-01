#pragma once

#include "lvgl.h"

#define UI_COLOR_BG         lv_color_hex(0x1A1A1A)
#define UI_COLOR_TEXT       lv_color_hex(0xFFFFFF)
#define UI_COLOR_MUTED      lv_color_hex(0xAAAAAA)
#define UI_COLOR_ACCENT     lv_color_hex(0xC41E3A)

static inline void ui_apply_screen_style(lv_obj_t *screen)
{
    lv_obj_set_style_bg_color(screen, UI_COLOR_BG, 0);
    lv_obj_set_style_bg_opa(screen, LV_OPA_COVER, 0);
    lv_obj_clear_flag(screen, LV_OBJ_FLAG_SCROLLABLE);
}
