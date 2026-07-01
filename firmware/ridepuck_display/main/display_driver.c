#include "display_driver.h"

#include "board_config.h"

#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_check.h"
#include "esp_lcd_gc9a01.h"
#include "esp_lcd_panel_io.h"
#include "esp_lcd_panel_ops.h"
#include "esp_lcd_panel_vendor.h"
#include "esp_log.h"
#include "esp_lvgl_port.h"

static const char *TAG = "display";

static esp_lcd_panel_io_handle_t s_io_handle = NULL;
static esp_lcd_panel_handle_t s_panel_handle = NULL;

esp_err_t display_driver_init(void)
{
    ESP_LOGI(TAG, "Initializing round GC9A01 display (%dx%d)", BOARD_LCD_H_RES, BOARD_LCD_V_RES);

    gpio_config_t bl_cfg = {
        .pin_bit_mask = 1ULL << BOARD_PIN_LCD_BL,
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_RETURN_ON_ERROR(gpio_config(&bl_cfg), TAG, "backlight gpio config failed");
    gpio_set_level(BOARD_PIN_LCD_BL, BOARD_LCD_BL_ON_LEVEL);

    spi_bus_config_t bus_cfg = {
        .sclk_io_num = BOARD_PIN_LCD_SCLK,
        .mosi_io_num = BOARD_PIN_LCD_MOSI,
        .miso_io_num = BOARD_PIN_LCD_MISO,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = BOARD_LCD_H_RES * BOARD_LCD_V_RES * sizeof(uint16_t),
    };
    ESP_RETURN_ON_ERROR(spi_bus_initialize(BOARD_LCD_HOST, &bus_cfg, SPI_DMA_CH_AUTO), TAG,
                        "spi bus init failed");

    esp_lcd_panel_io_spi_config_t io_cfg = {
        .dc_gpio_num = BOARD_PIN_LCD_DC,
        .cs_gpio_num = BOARD_PIN_LCD_CS,
        .pclk_hz = BOARD_LCD_PIXEL_CLOCK,
        .lcd_cmd_bits = 8,
        .lcd_param_bits = 8,
        .spi_mode = 0,
        .trans_queue_depth = 10,
    };
    ESP_RETURN_ON_ERROR(esp_lcd_new_panel_io_spi((esp_lcd_spi_bus_handle_t)BOARD_LCD_HOST, &io_cfg,
                                                 &s_io_handle),
                        TAG, "panel io init failed");

    esp_lcd_panel_dev_config_t panel_cfg = {
        .reset_gpio_num = BOARD_PIN_LCD_RST,
        .rgb_ele_order = LCD_RGB_ELEMENT_ORDER_BGR,
        .bits_per_pixel = 16,
    };
    ESP_RETURN_ON_ERROR(esp_lcd_new_panel_gc9a01(s_io_handle, &panel_cfg, &s_panel_handle), TAG,
                        "gc9a01 panel init failed");

    ESP_RETURN_ON_ERROR(esp_lcd_panel_reset(s_panel_handle), TAG, "panel reset failed");
    ESP_RETURN_ON_ERROR(esp_lcd_panel_init(s_panel_handle), TAG, "panel init failed");
    ESP_RETURN_ON_ERROR(esp_lcd_panel_invert_color(s_panel_handle, true), TAG,
                        "panel invert failed");
    ESP_RETURN_ON_ERROR(esp_lcd_panel_mirror(s_panel_handle, true, false), TAG,
                        "panel mirror failed");
    ESP_RETURN_ON_ERROR(esp_lcd_panel_disp_on_off(s_panel_handle, true), TAG,
                        "panel display on failed");

    const lvgl_port_cfg_t lvgl_cfg = ESP_LVGL_PORT_INIT_CONFIG();
    ESP_RETURN_ON_ERROR(lvgl_port_init(&lvgl_cfg), TAG, "lvgl port init failed");

    const lvgl_port_display_cfg_t disp_cfg = {
        .io_handle = s_io_handle,
        .panel_handle = s_panel_handle,
        .buffer_size = BOARD_LCD_H_RES * 20,
        .double_buffer = true,
        .hres = BOARD_LCD_H_RES,
        .vres = BOARD_LCD_V_RES,
        .monochrome = false,
        .rotation =
            {
                .swap_xy = false,
                .mirror_x = true,
                .mirror_y = false,
            },
        .flags =
            {
                .buff_dma = true,
                .buff_spiram = true,
            },
    };

    lv_disp_t *disp = lvgl_port_add_disp(&disp_cfg);
    if (disp == NULL) {
        ESP_LOGE(TAG, "Failed to add LVGL display");
        return ESP_FAIL;
    }

    ESP_LOGI(TAG, "Display and LVGL ready");
    return ESP_OK;
}

bool display_driver_lock(int timeout_ms)
{
    return lvgl_port_lock(timeout_ms);
}

void display_driver_unlock(void)
{
    lvgl_port_unlock();
}
