#pragma once

/// Waveshare ESP32-S3-Touch-LCD-1.28 (240×240 round, GC9A01, SPI).
/// Adjust these pins if using a different round display board.

#define BOARD_LCD_HOST          SPI2_HOST
#define BOARD_LCD_H_RES         240
#define BOARD_LCD_V_RES         240
#define BOARD_LCD_PIXEL_CLOCK   (80 * 1000 * 1000)

#define BOARD_PIN_LCD_SCLK      10
#define BOARD_PIN_LCD_MOSI      11
#define BOARD_PIN_LCD_MISO      (-1)
#define BOARD_PIN_LCD_CS        12
#define BOARD_PIN_LCD_DC        8
#define BOARD_PIN_LCD_RST       14
#define BOARD_PIN_LCD_BL        46

#define BOARD_LCD_BL_ON_LEVEL   1
