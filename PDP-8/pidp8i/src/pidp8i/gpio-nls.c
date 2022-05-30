/*
 * gpio-nls.c: implements gpio_core () with the original simple LED driver
 *
 * This file differs from gpio.c in that it does not include the
 * incandescent lamp simulator feature by Ian Schofield.  It is
 * more directly descended from the original gpio.c by Oscar Vermeulen.
 * 
 * Copyright © 2015-2017 Oscar Vermeulen and Warren Young
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS LISTED ABOVE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the names of the authors above shall
 * not be used in advertising or otherwise to promote the sale, use or other
 * dealings in this Software without prior written authorization from those
 * authors.
 *
 * www.obsolescenceguaranteed.blogspot.com
*/

#include "pidp8i.h"


//// gpio_core  ////////////////////////////////////////////////////////
// The GPIO module's main loop core, called from thread entry point in
// gpio-common.c.

void gpio_core (struct bcm2835_peripheral* pgpio, int* terminate)
{
    // Light each row of LEDs 1.2 ms.  With 8 rows, that's an update
    // rate of ~100x per second.  Not coincidentally, this is the human
    // persistence of vision limit: changes faster than this are
    // difficult for humans to perceive visually.
    const us_time_t intervl = 1200;  

    // This is a simplified version of what's in the gpio-ils.c version
    // of this function, so if you want more comments, read them there.
    while (*terminate == 0) {
        for (size_t i = 0; i < NCOLS; ++i) OUT_GPIO(cols[i]);
        swap_displays ();
        update_led_states (intervl);
        read_switches (intervl * 1000 / 100);
#if defined(HAVE_SCHED_YIELD)
        sched_yield ();
#endif
    }
}
