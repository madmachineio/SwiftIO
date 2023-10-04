/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li(lgl88911@163.com)
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_LCD_H_
#define _SWIFT_LCD_H_

#include <stdint.h>
#include <sys/types.h>

/** @brief lcd pixel color format */
enum swift_lcd_pixel_format {
	SWIFT_LCD_PIXEL_FORMAT_RGB_888,
	SWIFT_LCD_PIXEL_FORMAT_ARGB_8888,
	SWIFT_LCD_PIXEL_FORMAT_RGB_565,
	SWIFT_LCD_PIXEL_FORMAT_RGB_8RAW,
};

typedef enum swift_lcd_pixel_format swift_lcd_pixel_format_t;

/** @brief lcd control signal level active status */
enum swift_lcd_active_mode {
	SWIFT_LCD_ACTIVE_LEVEL_LOW,
	SWIFT_LCD_ACTIVE_LEVEL_HIGH,
	SWIFT_LCD_ACTIVE_EDGE_RISING,
	SWIFT_LCD_ACTIVE_EDGE_FALLING,
};

typedef enum swift_lcd_active_mode swift_lcd_active_mode_t;

/**
 * @brief lcd panel paramater
 *
 * @param total_width  Total width of panel
 * @param total_hight  Total hight of panel
 * @param active_width Visible width of panel
 * @param active_hight Visible hight of panel
 * @param hsw Pulse width of hsync
 * @param hbp Back porch of hsync
 * @param vsw Pulse width of wsync
 * @param vbp Back porch of wsync
 * @param color_format pixceil color format, use @ref swift_lcd_pixel_format
 * @param vsync_active vsync signal active mode, use @ref swift_lcd_active_mode
 * @param hsync_active hsync signal active mode, use @ref swift_lcd_active_mode
 * @param de_active DE signal active mode, use @ref swift_lcd_active_mode
 * @param data_active Data signal active mode, use @ref swift_lcd_active_mode
 * @param refresh_rate Panel fresh rate in fps
 */
struct swift_lcd_panel_param {
	int total_width;
	int total_hight;
	int active_width;
	int active_hight;
	int hsw;
	int hbp;
	int vsw;
	int vbp;
	swift_lcd_pixel_format_t color_format;

	swift_lcd_active_mode_t vsync_active;
	swift_lcd_active_mode_t hsync_active;
	swift_lcd_active_mode_t de_active;
	swift_lcd_active_mode_t data_active;

	int refresh_rate;
};

typedef struct swift_lcd_panel_param swift_lcd_panel_param_t;

/**
 * @brief Open and config lcd controller
 *
 * @param param Panel paramater, refer to the spec of panel,use @ref swift_lcd_panel_param
 * @return LCD handle
 */
void *swifthal_lcd_open(const swift_lcd_panel_param_t *param);

/**
 * @brief Close lcd controller
 *
 * @param lcd LCD handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_close(void *lcd);

/**
 * @brief Start refresh panel
 *
 * @param lcd LCD Handle
 * @param buf Pointer to frame buffer
 * @param size frame buffer size
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_start(void *lcd, void *buf, unsigned int size);

/**
 * @brief Stop refresh panel
 *
 * @param lcd LCD handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_stop(void *lcd);

/**
 * @brief Update frame buffer pointer
 *
 * @param lcd LCD Handle
 * @param buf Pointer to frame buffer
 * @param size frame buffer size
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_fb_update(void *lcd, void *buf, unsigned int size);

/**
 * @brief Get screen information
 *
 * @param lcd LCD handle
 * @param width Visible width of panel
 * @param height Visible height of panel
 * @param format Color format of pixel
 * @param bpp Byte per pixel
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_screen_param_get(void *lcd,
				  int *width,
				  int *height,
				  swift_lcd_pixel_format_t *format,
				  int *bpp);
/**
 * @brief Stop refresh panel
 *
 * @param lcd LCD handle
 *
 * @retval Positive indicates the refresh rate of panel.
 * @retval Negative errno code if failure.
 */
int swifthal_lcd_refresh_rate_get(void *lcd);

#endif /* _SWIFT_LCD_H_ */

