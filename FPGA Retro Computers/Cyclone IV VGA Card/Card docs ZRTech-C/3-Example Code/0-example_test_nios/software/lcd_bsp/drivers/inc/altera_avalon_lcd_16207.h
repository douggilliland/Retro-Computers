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

#ifndef __ALTERA_AVALON_LCD_16207_H__
#define __ALTERA_AVALON_LCD_16207_H__

#include <stddef.h>

#include "sys/alt_alarm.h"
#include "os/alt_sem.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 * The altera_avalon_lcd_16207_dev structure is used to hold device specific 
 * data. This includes the transmit and receive buffers.
 *
 * An instance of this structure is created in the auto-generated 
 * alt_sys_init.c file for each UART listed in the systems PTF file. This is
 * done using the ALTERA_AVALON_LCD_16207_STATE_INSTANCE macro given below.
 */

#define ALT_LCD_HEIGHT         2
#define ALT_LCD_WIDTH         16
#define ALT_LCD_VIRTUAL_WIDTH 80

typedef struct altera_avalon_lcd_16207_state_s 
{
  int            base;

  alt_alarm      alarm;
  int            period;

  char           broken;

  unsigned char  x;
  unsigned char  y;
  char           address;
  char           esccount;

  char           scrollpos;
  char           scrollmax;
  char           active;    /* If non-zero then the foreground routines are
                             * active so the timer call must not update the
                             * display. */

  char           escape[8];

  struct
  {
    char         visible[ALT_LCD_WIDTH];
    char         data[ALT_LCD_VIRTUAL_WIDTH+1];
    char         width;
    unsigned char speed;

  } line[ALT_LCD_HEIGHT];

  ALT_SEM       (write_lock)/* Semaphore used to control access to the
                             * write buffer in multi-threaded mode */
} altera_avalon_lcd_16207_state;

/*
 * Called by alt_sys_init.c to initialize the driver.
 */
extern void altera_avalon_lcd_16207_init(altera_avalon_lcd_16207_state* sp);

/* 
 * The LCD panel driver is not trivial, so leave it out in the small
 * drivers case.  Also leave it out in simulation because there is no
 * simulated hardware for the LCD panel.  These two can be overridden
 * by defining ALT_USE_LCE_16207 if you really want it.
 */

#if (!defined(ALT_USE_SMALL_DRIVERS) && !defined(ALT_SIM_OPTIMIZE)) || defined ALT_USE_LCD_16207

/*
 * Used by the auto-generated file
 * alt_sys_init.c to create an instance of this device driver.
 */
#define ALTERA_AVALON_LCD_16207_STATE_INSTANCE(name, state)   \
  altera_avalon_lcd_16207_state state =                  \
    {                                                    \
      name##_BASE                                        \
    }

/*
 * The macro ALTERA_AVALON_LCD_16207_INIT is used by the auto-generated file
 * alt_sys_init.c to initialize an instance of the device driver.
 */
#define ALTERA_AVALON_LCD_16207_STATE_INIT(name, state) \
  altera_avalon_lcd_16207_init(&state)

#else /* exclude driver */

#define ALTERA_AVALON_LCD_16207_STATE_INSTANCE(name, state) extern int alt_no_storage
#define ALTERA_AVALON_LCD_16207_STATE_INIT(name, state) while (0)

#endif /* exclude driver */

/*
 * Include in case non-direct version of driver required.
 */
#include "altera_avalon_lcd_16207_fd.h"

/*
 * Map alt_sys_init macros to direct or non-direct versions.
 */
#ifdef ALT_USE_DIRECT_DRIVERS

#define ALTERA_AVALON_LCD_16207_INSTANCE(name, state) \
   ALTERA_AVALON_LCD_16207_STATE_INSTANCE(name, state)
#define ALTERA_AVALON_LCD_16207_INIT(name, state) \
   ALTERA_AVALON_LCD_16207_STATE_INIT(name, state)

#else /* !ALT_USE_DIRECT_DRIVERS */

#define ALTERA_AVALON_LCD_16207_INSTANCE(name, dev) \
   ALTERA_AVALON_LCD_16207_DEV_INSTANCE(name, dev)
#define ALTERA_AVALON_LCD_16207_INIT(name, dev) \
   ALTERA_AVALON_LCD_16207_DEV_INIT(name, dev)

#endif /* ALT_USE_DIRECT_DRIVERS */

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALTERA_AVALON_LCD_16207_H__ */
