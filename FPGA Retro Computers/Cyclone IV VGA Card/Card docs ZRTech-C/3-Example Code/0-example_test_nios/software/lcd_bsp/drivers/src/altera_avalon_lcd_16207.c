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

/* ===================================================================== */

/*
 * This file provides the implementation of the functions used to drive a
 * LCD panel.
 *
 * Characters written to the device will appear on the LCD panel as though
 * it is a very small terminal.  If the lines written to the terminal are
 * longer than the number of characters on the terminal then it will scroll
 * the lines of text automatically to display them all.
 *
 * If more lines are written than will fit on the terminal then it will scroll
 * when characters are written to the line "below" the last displayed one - 
 * the cursor is allowed to sit below the visible area of the screen providing
 * that this line is entirely blank.
 *
 * The following control sequences may be used to move around and do useful
 * stuff:
 *    CR    Moves back to the start of the current line
 *    LF    Moves down a line and back to the start
 *    BS    Moves back a character without erasing
 *    ESC   Starts a VT100 style escape sequence
 *
 * The following escape sequences are recognised:
 *    ESC [ <row> ; <col> H   Move to row and column specified (positions are
 *                            counted from the top left which is 1;1)
 *    ESC [ K                 Clear from current position to end of line
 *    ESC [ 2 J               Clear screen and go to top left
 *
 */

/* ===================================================================== */

#include <string.h>
#include <ctype.h>

#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include "sys/alt_alarm.h"

#include "altera_avalon_lcd_16207_regs.h"
#include "altera_avalon_lcd_16207.h"

/* --------------------------------------------------------------------- */

/* Commands which can be written to the COMMAND register */

enum /* Write to character RAM */
{
  LCD_CMD_WRITE_DATA    = 0x80
  /* Bits 6:0 hold character RAM address */
};

enum /* Write to character generator RAM */
{
  LCD_CMD_WRITE_CGR     = 0x40
  /* Bits 5:0 hold character generator RAM address */
};

enum /* Function Set command */
{
  LCD_CMD_FUNCTION_SET  = 0x20,
  LCD_CMD_8BIT          = 0x10,
  LCD_CMD_TWO_LINE      = 0x08,
  LCD_CMD_BIGFONT       = 0x04
};

enum /* Shift command */
{
  LCD_CMD_SHIFT         = 0x10,
  LCD_CMD_SHIFT_DISPLAY = 0x08,
  LCD_CMD_SHIFT_RIGHT   = 0x04
};

enum /* On/Off command */
{
  LCD_CMD_ONOFF         = 0x08,
  LCD_CMD_ENABLE_DISP   = 0x04,
  LCD_CMD_ENABLE_CURSOR = 0x02,
  LCD_CMD_ENABLE_BLINK  = 0x01
};

enum /* Entry Mode command */
{
  LCD_CMD_MODES         = 0x04,
  LCD_CMD_MODE_INC      = 0x02,
  LCD_CMD_MODE_SHIFT    = 0x01
};

enum /* Home command */
{
  LCD_CMD_HOME          = 0x02
};

enum /* Clear command */
{
  LCD_CMD_CLEAR         = 0x01
};

/* Where in LCD character space do the rows start */
static char colstart[4] = { 0x00, 0x40, 0x20, 0x60 };

/* --------------------------------------------------------------------- */

static void lcd_write_command(altera_avalon_lcd_16207_state* sp, 
  unsigned char command)
{
  unsigned int base = sp->base;

  /* We impose a timeout on the driver in case the LCD panel isn't connected.
   * The first time we call this function the timeout is approx 25ms 
   * (assuming 5 cycles per loop and a 200MHz clock).  Obviously systems
   * with slower clocks, or debug builds, or slower memory will take longer.
   */
  int i = 1000000;

  /* Don't bother if the LCD panel didn't work before */
  if (sp->broken)
    return;

  /* Wait until LCD isn't busy. */
  while (IORD_ALTERA_AVALON_LCD_16207_STATUS(base) & ALTERA_AVALON_LCD_16207_STATUS_BUSY_MSK)
    if (--i == 0)
    {
      sp->broken = 1;
      return;
    }

  /* Despite what it says in the datasheet, the LCD isn't ready to accept
   * a write immediately after it returns BUSY=0.  Wait for 100us more.
   */
  usleep(100);

  IOWR_ALTERA_AVALON_LCD_16207_COMMAND(base, command);
}

/* --------------------------------------------------------------------- */

static void lcd_write_data(altera_avalon_lcd_16207_state* sp, 
  unsigned char data)
{
  unsigned int base = sp->base;

  /* We impose a timeout on the driver in case the LCD panel isn't connected.
   * The first time we call this function the timeout is approx 25ms 
   * (assuming 5 cycles per loop and a 200MHz clock).  Obviously systems
   * with slower clocks, or debug builds, or slower memory will take longer.
   */
  int i = 1000000;

  /* Don't bother if the LCD panel didn't work before */
  if (sp->broken)
    return;

  /* Wait until LCD isn't busy. */
  while (IORD_ALTERA_AVALON_LCD_16207_STATUS(base) & ALTERA_AVALON_LCD_16207_STATUS_BUSY_MSK)
    if (--i == 0)
    {
      sp->broken = 1;
      return;
    }

  /* Despite what it says in the datasheet, the LCD isn't ready to accept
   * a write immediately after it returns BUSY=0.  Wait for 100us more.
   */
  usleep(100);

  IOWR_ALTERA_AVALON_LCD_16207_DATA(base, data);

  sp->address++;
}

/* --------------------------------------------------------------------- */

static void lcd_clear_screen(altera_avalon_lcd_16207_state* sp)
{
  int y;

  lcd_write_command(sp, LCD_CMD_CLEAR);

  sp->x = 0;
  sp->y = 0;
  sp->address = 0;

  for (y = 0 ; y < ALT_LCD_HEIGHT ; y++)
  {
    memset(sp->line[y].data, ' ', sizeof(sp->line[0].data));
    memset(sp->line[y].visible, ' ', sizeof(sp->line[0].visible));
    sp->line[y].width = 0;
  }
}

/* --------------------------------------------------------------------- */

static void lcd_repaint_screen(altera_avalon_lcd_16207_state* sp)
{
  int y, x;

  /* scrollpos controls how much the lines have scrolled round.  The speed
   * each line scrolls at is controlled by its speed variable - while
   * scrolline lines will wrap at the position set by width
   */

  int scrollpos = sp->scrollpos;

  for (y = 0 ; y < ALT_LCD_HEIGHT ; y++)
  {
    int width  = sp->line[y].width;
    int offset = (scrollpos * sp->line[y].speed) >> 8;
    if (offset >= width)
      offset = 0;

    for (x = 0 ; x < ALT_LCD_WIDTH ; x++)
    {
      char c = sp->line[y].data[(x + offset) % width];

      /* Writing data takes 40us, so don't do it unless required */
      if (sp->line[y].visible[x] != c)
      {
        unsigned char address = x + colstart[y];

        if (address != sp->address)
        {
          lcd_write_command(sp, LCD_CMD_WRITE_DATA | address);
          sp->address = address;
        }

        lcd_write_data(sp, c);
        sp->line[y].visible[x] = c;
      }
    }
  }
}

/* --------------------------------------------------------------------- */

static void lcd_scroll_up(altera_avalon_lcd_16207_state* sp)
{
  int y;

  for (y = 0 ; y < ALT_LCD_HEIGHT ; y++)
  {
    if (y < ALT_LCD_HEIGHT-1)
      memcpy(sp->line[y].data, sp->line[y+1].data, ALT_LCD_VIRTUAL_WIDTH);
    else
      memset(sp->line[y].data, ' ', ALT_LCD_VIRTUAL_WIDTH);
  }

  sp->y--;
}

/* --------------------------------------------------------------------- */

static void lcd_handle_escape(altera_avalon_lcd_16207_state* sp, char c)
{
  int parm1 = 0, parm2 = 0;

  if (sp->escape[0] == '[')
  {
    char * ptr = sp->escape+1;
    while (isdigit(*ptr))
      parm1 = (parm1 * 10) + (*ptr++ - '0');

    if (*ptr == ';')
    {
      ptr++;
      while (isdigit(*ptr))
        parm2 = (parm2 * 10) + (*ptr++ - '0');
    }
  }
  else
    parm1 = -1;

  switch (c)
  {
  case 'H': /* ESC '[' <y> ';' <x> 'H'  : Move cursor to location */
  case 'f': /* Same as above */
    if (parm2 > 0)
      sp->x = parm2 - 1;
    if (parm1 > 0)
    {
      sp->y = parm1 - 1;
      if (sp->y > ALT_LCD_HEIGHT * 2)
        sp->y = ALT_LCD_HEIGHT * 2;
      while (sp->y > ALT_LCD_HEIGHT)
        lcd_scroll_up(sp);
    }
    break;

  case 'J':
    /*   ESC J      is clear to beginning of line    [unimplemented]
     *   ESC [ 0 J  is clear to bottom of screen     [unimplemented]
     *   ESC [ 1 J  is clear to beginning of screen  [unimplemented]
     *   ESC [ 2 J  is clear screen
     */
    if (parm1 == 2)
      lcd_clear_screen(sp);
    break;

  case 'K':
    /*   ESC K      is clear to end of line
     *   ESC [ 0 K  is clear to end of line
     *   ESC [ 1 K  is clear to beginning of line    [unimplemented]
     *   ESC [ 2 K  is clear line                    [unimplemented]
     */
    if (parm1 < 1)
    {
      if (sp->x < ALT_LCD_VIRTUAL_WIDTH)
        memset(sp->line[sp->y].data + sp->x, ' ', ALT_LCD_VIRTUAL_WIDTH - sp->x);
    }
    break;
  }
}

/* --------------------------------------------------------------------- */

int altera_avalon_lcd_16207_write(altera_avalon_lcd_16207_state* sp, 
  const char* ptr, int len, int flags)
{
  const char* end = ptr + len;

  int y;
  int widthmax;

  /* When running in a multi threaded environment, obtain the "write_lock"
   * semaphore. This ensures that writing to the device is thread-safe.
   */

  ALT_SEM_PEND (sp->write_lock, 0);

  /* Tell the routine which is called off the timer interrupt that the
   * foreground routines are active so it must not repaint the display. */
  sp->active = 1;

  for ( ; ptr < end ; ptr++)
  {
    char c = *ptr;

    if (sp->esccount >= 0)
    {
      unsigned int esccount = sp->esccount;

      /* Single character escape sequences can end with any character
       * Multi character escape sequences start with '[' and contain
       * digits and semicolons before terminating
       */
      if ((esccount == 0 && c != '[') ||
          (esccount > 0 && !isdigit(c) && c != ';'))
      {
        sp->escape[esccount] = 0;

        lcd_handle_escape(sp, c);

        sp->esccount = -1;
      }
      else if (sp->esccount < sizeof(sp->escape)-1)
      {
        sp->escape[esccount] = c;
        sp->esccount++;
      }
    }
    else if (c == 27) /* ESC */
    {
      sp->esccount = 0;
    }
    else if (c == '\r')
    {
      sp->x = 0;
    }
    else if (c == '\n')
    {
      sp->x = 0;
      sp->y++;

      /* Let the cursor sit at X=0, Y=HEIGHT without scrolling so the user
       * can print two lines of data without losing one.
       */
      if (sp->y > ALT_LCD_HEIGHT)
        lcd_scroll_up(sp);
    }
    else if (c == '\b')
    {
      if (sp->x > 0)
        sp->x--;
    }
    else if (isprint(c))
    {
      /* If we didn't scroll on the last linefeed then we might need to do
       * it now. */
      if (sp->y >= ALT_LCD_HEIGHT)
        lcd_scroll_up(sp);

      if (sp->x < ALT_LCD_VIRTUAL_WIDTH)
        sp->line[sp->y].data[sp->x] = c;

      sp->x++;
    }
  }

  /* Recalculate the scrolling parameters */
  widthmax = ALT_LCD_WIDTH;
  for (y = 0 ; y < ALT_LCD_HEIGHT ; y++)
  {
    int width;
    for (width = ALT_LCD_VIRTUAL_WIDTH ; width > 0 ; width--)
      if (sp->line[y].data[width-1] != ' ')
        break;

    /* The minimum width is the size of the LCD panel.  If the real width
     * is long enough to require scrolling then add an extra space so the
     * end of the message doesn't run into the beginning of it.
     */
    if (width <= ALT_LCD_WIDTH)
      width = ALT_LCD_WIDTH;
    else
      width++;

    sp->line[y].width = width;
    if (widthmax < width)
      widthmax = width;
    sp->line[y].speed = 0; /* By default lines don't scroll */
  }

  if (widthmax <= ALT_LCD_WIDTH)
    sp->scrollmax = 0;
  else
  {
    widthmax *= 2;
    sp->scrollmax = widthmax;

    /* Now calculate how fast each of the other lines should go */
    for (y = 0 ; y < ALT_LCD_HEIGHT ; y++)
      if (sp->line[y].width > ALT_LCD_WIDTH)
      {
        /* You have three options for how to make the display scroll, chosen
         * using the preprocessor directives below
         */
#if 1
        /* This option makes all the lines scroll round at different speeds
         * which are chosen so that all the scrolls finish at the same time.
         */
        sp->line[y].speed = 256 * sp->line[y].width / widthmax;
#elif 1
        /* This option pads the shorter lines with spaces so that they all
         * scroll together.
         */
        sp->line[y].width = widthmax / 2;
        sp->line[y].speed = 256/2;
#else
        /* This option makes the shorter lines stop after they have rotated
         * and waits for the longer lines to catch up
         */
        sp->line[y].speed = 256/2;
#endif
      }
  }

  /* Repaint once, then check whether there has been a missed repaint
   * (because active was set when the timer interrupt occurred).  If there
   * has been a missed repaint then paint again.  And again.  etc.
   */
  for ( ; ; )
  {
    int old_scrollpos = sp->scrollpos;

    lcd_repaint_screen(sp);

    /* Let the timer routines repaint the display again */
    sp->active = 0;

    /* Have the timer routines tried to scroll while we were painting?
     * If not then we can exit */
    if (sp->scrollpos == old_scrollpos)
      break;

    /* We need to repaint again since the display scrolled while we were
     * painting last time */
    sp->active = 1;
  }

  /* Now that access to the display is complete, release the write
   * semaphore so that other threads can access the buffer.
   */

  ALT_SEM_POST (sp->write_lock);

  return len;
}

/* --------------------------------------------------------------------- */

/* This should be in a top level header file really */
#define container_of(ptr, type, member) ((type *)((char *)ptr - offsetof(type, member)))

/*
 * Timeout routine is called every second
 */

static alt_u32 alt_lcd_16207_timeout(void* context) 
{
  altera_avalon_lcd_16207_state* sp = (altera_avalon_lcd_16207_state*)context;

  /* Update the scrolling position */
  if (sp->scrollpos + 1 >= sp->scrollmax)
    sp->scrollpos = 0;
  else
    sp->scrollpos = sp->scrollpos + 1;

  /* Repaint the panel unless the foreground will do it again soon */
  if (sp->scrollmax > 0 && !sp->active)
    lcd_repaint_screen(sp);

  return sp->period;
}

/* --------------------------------------------------------------------- */

/*
 * Called at boot time to initialise the LCD driver
 */
void altera_avalon_lcd_16207_init(altera_avalon_lcd_16207_state* sp)
{
  unsigned int base = sp->base;

  /* Mark the device as functional */
  sp->broken = 0;

  ALT_SEM_CREATE (&sp->write_lock, 1);

  /* The initialisation sequence below is copied from the datasheet for
   * the 16207 LCD display.  The first commands need to be timed because
   * the BUSY bit in the status register doesn't work until the display
   * has been reset three times.
   */

  /* Wait for 15 ms then reset */
  usleep(15000);
  IOWR_ALTERA_AVALON_LCD_16207_COMMAND(base, LCD_CMD_FUNCTION_SET | LCD_CMD_8BIT);

  /* Wait for another 4.1ms and reset again */
  usleep(4100);  
  IOWR_ALTERA_AVALON_LCD_16207_COMMAND(base, LCD_CMD_FUNCTION_SET | LCD_CMD_8BIT);

  /* Wait a further 1 ms and reset a third time */
  usleep(1000);
  IOWR_ALTERA_AVALON_LCD_16207_COMMAND(base, LCD_CMD_FUNCTION_SET | LCD_CMD_8BIT);

  /* Setup interface parameters: 8 bit bus, 2 rows, 5x7 font */
  lcd_write_command(sp, LCD_CMD_FUNCTION_SET | LCD_CMD_8BIT | LCD_CMD_TWO_LINE);
  
  /* Turn display off */
  lcd_write_command(sp, LCD_CMD_ONOFF);

  /* Clear display */
  lcd_clear_screen(sp);
  
  /* Set mode: increment after writing, don't shift display */
  lcd_write_command(sp, LCD_CMD_MODES | LCD_CMD_MODE_INC);

  /* Turn display on */
  lcd_write_command(sp, LCD_CMD_ONOFF | LCD_CMD_ENABLE_DISP);

  sp->esccount = -1;
  memset(sp->escape, 0, sizeof(sp->escape));

  sp->scrollpos = 0;
  sp->scrollmax = 0;
  sp->active = 0;

  sp->period = alt_ticks_per_second() / 10; /* Call every 100ms */

  alt_alarm_start(&sp->alarm, sp->period, &alt_lcd_16207_timeout, sp);
}
