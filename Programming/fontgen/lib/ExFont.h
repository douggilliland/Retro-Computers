
#ifndef XJ_EX_FONT_H
#define XJ_EX_FONT_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef CONST
#define CONST
#endif/*CONST*/

#ifndef wchar_t
#define wchar_t unsigned short
#endif
/*
 * Font data
 */
typedef struct _EXFONT_DATA_ITEM {
	unsigned short value;
	unsigned char* data;
}EXFONT_DATA_ITEM, *PEXFONT_DATA_ITEM;

typedef struct _EXFONT_DATA {
	unsigned char     width;
	unsigned char     height;
	unsigned short    nr;
	PEXFONT_DATA_ITEM items;
}EXFONT_DATA, *PEXFONT_DATA;

/*
 * Call back funtion, used to display a pixel.
 */
typedef void (*draw_pixel_func)(void* ctx, int x, int y, int color);

/*
 * Background mode
 *  BKMODE_OPAQUE: Fill the background with background color.
 *  BKMODE_TRANSPARENT: Keep the background.
 */
enum {
	BKMODE_OPAQUE = 0,
	BKMODE_TRANSPARENT
};

typedef struct _EXFONT {
	/*
	 * Name of the font, used for retrieving purpose.
	 */
	char* name;

	/*
	 * Background mode: BKMODE_OPAQUE or BKMODE_TRANSPARENT
	 */
	unsigned char bk_mode;

	/*
	 * Color of the char.
	 */
	int foreground_color;
	int background_color;

	/*
	 * Font data:
	 *   thin_font_data: font data of ASCII chars.
	 *   wide_font_data: font data of multibytes chars.
	 */
	PEXFONT_DATA   thin_font_data;
	PEXFONT_DATA   wide_font_data;

	/*
	 * Output function.
	 */
	draw_pixel_func  draw_pixel;
	void* draw_pixel_ctx;

}EXFONT, *PEXFONT;

#define EXFONT_data_init(font_data, _width, _height, _nr, _items) \
	(font_data)->width = _width; \
	(font_data)->height = _height; \
	(font_data)->nr = _nr; \
	(font_data)->items = _items; 
	
#define EXFONT_name(font)             (font)->name
#define EXFONT_width(font)            (font)->width
#define EXFONT_height(font)           (font)->height
#define EXFONT_bkmode(font)           (font)->bk_mode

/*
 * Functions to initialize the struct font.
 */
int EXFONT_init(PEXFONT font,  char* name, int foreground_color, int background_color, 
				 unsigned char bk_mode);
int EXFONT_set_draw_func(PEXFONT font, draw_pixel_func draw_pixel, void* draw_pixel_ctx);
int EXFONT_set_thin_font_data(PEXFONT font, PEXFONT_DATA thin_font_data);
int EXFONT_set_wide_font_data(PEXFONT font, PEXFONT_DATA wide_font_data);

/*
 * Functions to draw string.
 */
int EXFONT_draw_w(CONST PEXFONT font, int x, int y, CONST wchar_t* text);
int EXFONT_draw_a(CONST PEXFONT font, int x, int y, CONST char* text);

/*
 * Function to find the font data of of char.
 */
int EXFONT_font_index(CONST PEXFONT_DATA font_data, unsigned short cChar);

#ifdef __cplusplus
};
#endif

#endif/*XJ_EX_FONT_H*/
