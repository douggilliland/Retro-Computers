#ifndef DEMOFONT_H
#define DEMOFONT_H

#include "ExFont.h"

#ifdef __cplusplus
extern "C" {
#endif

void install_ansi_16x16_font(draw_pixel_func my_draw_pixel);
void install_unicode_32x32_font(draw_pixel_func my_draw_pixel);

void InstallFont(draw_pixel_func my_draw_pixel, void* ctx);
void TestDrawText(draw_pixel_func draw_pixel, void* draw_pixel_ctx);

#ifdef __cplusplus
};
#endif

#endif//DEMOFONT_H

