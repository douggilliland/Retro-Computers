/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

#ifndef __ALTERA_AVALON_LCD_16207_FD_H__
#define __ALTERA_AVALON_LCD_16207_FD_H__

#include "sys/alt_dev.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * Externally referenced routines
 */
extern int altera_avalon_lcd_16207_write_fd(alt_fd* fd, const char* ptr,
  int len);

/*
 * Device structure definition. This is needed by alt_sys_init in order to 
 * reserve memory for the device instance.
 */

typedef struct altera_avalon_lcd_16207_dev_s
{
    alt_dev dev;
    altera_avalon_lcd_16207_state state;
} altera_avalon_lcd_16207_dev;

/* 
 * The LCD panel driver is not trivial, so leave it out in the small
 * drivers case.  Also leave it out in simulation because there is no
 * simulated hardware for the LCD panel.  These two can be overridden
 * by defining ALT_USE_LCE_16207 if you really want it.
 */

#if (!defined(ALT_USE_SMALL_DRIVERS) && !defined(ALT_SIM_OPTIMIZE)) || defined ALT_USE_LCD_16207

/*
 * Macros used by alt_sys_init when the ALT file descriptor facility is used.
 */
#define ALTERA_AVALON_LCD_16207_DEV_INSTANCE(name, d)    \
  static altera_avalon_lcd_16207_dev d =                 \
    {                                                    \
      {                                                  \
        ALT_LLIST_ENTRY,                                 \
        name##_NAME,                                     \
        NULL, /* open */                                 \
        NULL, /* close */                                \
        NULL, /* read */                                 \
        altera_avalon_lcd_16207_write_fd,                \
        NULL, /* lseek */                                \
        NULL, /* fstat */                                \
        NULL, /* ioctl */                                \
      },                                                 \
      {                                                  \
        name##_BASE                                      \
      },                                                 \
    }

#define ALTERA_AVALON_LCD_16207_DEV_INIT(name, d)                            \
  {                                                                          \
    ALTERA_AVALON_LCD_16207_STATE_INIT(name, d.state);                       \
                                                                             \
    /* make the device available to the system */                            \
    alt_dev_reg(&d.dev);                                                     \
  }

#else /* exclude driver */

#define ALTERA_AVALON_LCD_16207_DEV_INSTANCE(name, d) extern int alt_no_storage
#define ALTERA_AVALON_LCD_16207_DEV_INIT(name, d) while (0)

#endif

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALTERA_AVALON_LCD_16207_FD_H__ */
