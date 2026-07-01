#include "screen_error.h"

#include "../ui_theme.h"

static lv_obj_t *s_title_label = NULL;
static lv_obj_t *s_subtitle_label = NULL;

lv_obj_t *screen_error_create(void)
{
    lv_obj_t *screen = lv_obj_create(NULL);
    ui_apply_screen_style(screen);

    s_title_label = lv_label_create(screen);
    lv_label_set_text(s_title_label, "Connection Lost");
    lv_obj_set_style_text_color(s_title_label, UI_COLOR_ACCENT, 0);
    lv_obj_set_style_text_font(s_title_label, &lv_font_montserrat_24, 0);
    lv_obj_align(s_title_label, LV_ALIGN_CENTER, 0, -20);

    s_subtitle_label = lv_label_create(screen);
    lv_label_set_text(s_subtitle_label, "Reconnecting...");
    lv_obj_set_style_text_color(s_subtitle_label, UI_COLOR_MUTED, 0);
    lv_obj_set_style_text_font(s_subtitle_label, &lv_font_montserrat_16, 0);
    lv_obj_align(s_subtitle_label, LV_ALIGN_CENTER, 0, 20);

    return screen;
}

void screen_error_update(void)
{
    /* Static screen — nothing to refresh. */
}
