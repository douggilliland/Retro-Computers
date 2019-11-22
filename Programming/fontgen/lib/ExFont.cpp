#include <stdlib.h>
#include <string.h>
#include "ExFont.h"

int EXFONT_init(PEXFONT font,  char* name, int foreground_color, int background_color, 
				 unsigned char bk_mode)
{
	if(font != NULL)
	{
		memset(font, 0x00, sizeof(*font));

		font->name = name;
		
		font->foreground_color = foreground_color;
		font->background_color = background_color;
		font->bk_mode = bk_mode;
		
		return 0;
	}

	return -1;
}

int EXFONT_set_draw_func(PEXFONT font, draw_pixel_func draw_pixel, void* draw_pixel_ctx)
{
	font->draw_pixel = draw_pixel;
	font->draw_pixel_ctx = draw_pixel_ctx;

	return 0;
}

int EXFONT_set_thin_font_data(PEXFONT font, PEXFONT_DATA thin_font_data)
{
	if(font != NULL)
	{
		font->thin_font_data = thin_font_data;	

		return 0;
	}
	else
	{
		return -1;
	}
}

int EXFONT_set_wide_font_data(PEXFONT font, PEXFONT_DATA wide_font_data)
{
	if(font != NULL)
	{
		font->wide_font_data = wide_font_data;

		return 0;
	}
	else
	{
		return -1;
	}
}

int EXFONT_font_index(CONST PEXFONT_DATA font_data, unsigned short cChar)
{
	int low = 0;
	int hign = font_data->nr;
	int mid = (low + hign) / 2;

	if(font_data == NULL) return -1;
	
	if(font_data != NULL)
	{
		while(low <= hign)
		{
			if(font_data->items[mid].value == cChar)
			{
				return mid;
			}

			if(font_data->items[mid].value > cChar)
			{
				hign = mid - 1;
			}
			else
			{
				low = mid + 1;
			}

			mid = (low + hign) / 2;
		}
	}

	return -1;
}

#define is_thin_char(c) (c < 128)

static void EXFONT_draw_one_char(CONST PEXFONT font, int x, int y, int index, unsigned char is_thin_char)
{
	PEXFONT_DATA thin_wide_font_data = is_thin_char ? font->thin_font_data : font->wide_font_data;

	int w;
	int h;
	int max_w = x + thin_wide_font_data->width;
	int max_h = y + thin_wide_font_data->height;
	unsigned char* font_data = thin_wide_font_data->items[index].data;

	unsigned short i = 0;
	unsigned char byte = 0;
	unsigned char bit = 0;

	for(h = y; h < max_h; h++)
	{
		for(w = x; w < max_w; w++)
		{
			bit = 7 - (w - x) % 8;

			if(byte & (1 << bit))
			{
				font->draw_pixel(font->draw_pixel_ctx, w, h, font->foreground_color);
			}
			else if(font->bk_mode == BKMODE_OPAQUE)
			{
				font->draw_pixel(font->draw_pixel_ctx, w, h, font->background_color);
			}

			if(bit == 0)
			{
				i++;
				byte = font_data[i];
			}
		}
	}

	return;
}

int EXFONT_draw_w(CONST PEXFONT font, int x, int y, CONST wchar_t* text)
{ 
	if(font != NULL && text != NULL)
	{
		unsigned short i = 0;
		int index = 0;
		unsigned char  thin_char = 0;
		int left = x;
		int top = y;

		while(text[i])
		{
			thin_char = is_thin_char(text[i]);
			if(thin_char)
			{
				index = EXFONT_font_index(font->thin_font_data, text[i]);
				if(index > font->thin_font_data->nr)
				{
					return -1;
				}
			}
			else
			{
				index = EXFONT_font_index(font->wide_font_data, text[i]);
				if(index > font->wide_font_data->nr)
				{
					return -1;
				}
			}

			EXFONT_draw_one_char(font, left, top, index, thin_char);
			left += thin_char ? font->thin_font_data->width : font->wide_font_data->width;

			i++;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}

int EXFONT_draw_a(CONST PEXFONT font, int x, int y, CONST char* text)
{
	if(font != NULL && text != NULL)
	{
		unsigned short i = 0;
		unsigned short index = 0;
		unsigned char  thin_char = 0;
		int left = x;
		int top = y;

		while(text[i])
		{
			thin_char = is_thin_char((unsigned char)text[i]);
			if(thin_char)
			{
				index = EXFONT_font_index(font->thin_font_data, text[i]);
				if(index > font->thin_font_data->nr)
				{
					return -1;
				}
				i++;
			}
			else
			{
				index = EXFONT_font_index(font->wide_font_data, *(unsigned short*)(text+i));
				if(index > font->wide_font_data->nr)
				{
					return -1;
				}
				i += 2;
			}

			EXFONT_draw_one_char(font, left, top, index, thin_char);
			left += thin_char ? font->thin_font_data->width : font->wide_font_data->width;
		}

		return 0;
	}
	else
	{
		return -1;
	}
}

