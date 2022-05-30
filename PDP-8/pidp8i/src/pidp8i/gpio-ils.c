/*
 * gpio-ils.c: implements gpio_core () for Ian Schofield's incandescent
 *             lamp simulator
 * 
 * Copyright © 2015-2017 Oscar Vermeulen, Ian Schofield, and Warren Young
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

#include <pidp8i.h>

#include <sim_defs.h>


//// CONSTANTS /////////////////////////////////////////////////////////

// Brightness range is [0, MAX_BRIGHTNESS) truncated.
#define MAX_BRIGHTNESS 32

// On each iteration, we add or subtract a proportion of the LED's "on"
// time back to it as its new brightness, so that it takes several
// iterations at that same "on" time for the LED to achieve that
// brightness level.  Because the delta is based on the prior value, we
// get nonlinear asymptotic increase/decrease behavior.
//
// We use an asymmetric function depending on whether the LED is turning
// on or off to better mimic the behavior of an incandescent lamp, which
// reaches full brightness faster than it turns fully off.
#define RISING_FACTOR 0.012
#define FALLING_FACTOR 0.005


//// gpio_core  ////////////////////////////////////////////////////////
// The GPIO module's main loop core, called from thread entry point in
// gpio-common.c.

void gpio_core (struct bcm2835_peripheral* pgpio, int* terminate)
{
    // The ILS version uses an iteration rate 60x faster than the NLS
    // version because we have to get through 32 PWM steps, each of
    // which takes roughly 2 * intervl µs.  There's a bit of extra delay
    // over intervl in the NLS version, so the while loop iteration time
    // is about the same for both versions.
    const us_time_t intervl = 20;

    // Current brightness level for each LED.  It goes from 0 to
    // MAX_BRIGHTNESS, but we keep it as a float because the decay
    // function smoothly ramps from the current value to the ever-
    // changing target value.
    float brightness[NLEDROWS][NCOLS];
    memset(brightness, 0, sizeof (brightness));

    // Brightness target for each LED, updated at the start of each PWM
    // cycle when we get fresh "on" counts from the CPU thread.
    uint8 br_targets[NLEDROWS][NCOLS];
    memset(br_targets, 0, sizeof (br_targets));

    // Current PWM brightness step
    uint8 step = MAX_BRIGHTNESS;

    while (*terminate == 0) {
        // Prepare for lighting LEDs by setting col pins to output
        for (size_t i = 0; i < NCOLS; ++i) OUT_GPIO(cols[i]);

        // Restart PWM cycle if prior one is complete
        if (step == MAX_BRIGHTNESS) {
            // Reset PWM step counter
            step = 0;
      
            // Go get the current LED "on" times, and give the SIMH
            // CPU thread a blank copy to begin updating.  Because we're
            // in control of the swap timing, we don't need to copy the
            // pdis_paint pointer: it points to the same thing between
            // these swap_displays() calls.
            swap_displays();

            // Recalculate the brightness target values based on the
            // "on" counts in *pdis_paint and the quantized brightness
            // level, which is based on the number of instructions
            // executed for this display update.
            //
            // Handle the cases where inst_count is < 32 specially
            // because we don't want all LEDs to go out when the
            // simulator is heavily throttled.
            const size_t inst_count = pdis_paint->inst_count;
            size_t br_quant = inst_count >= 32 ? (inst_count >> 5) : 1;
            for (int row = 0; row < NLEDROWS; ++row) {
                size_t *prow = pdis_paint->on[row];
                for (int col = 0; col < NCOLS; ++col) {
                    br_targets[row][col] = prow[col] / br_quant;

                }
            }

            // Hard-code the Fetch and Execute brightnesses; in running
            // mode, they're both on half the instruction time, so we
            // just set them to 50% brightness.  Execute differs in STOP
            // mode, but that's handled in update_led_states () because
            // we fall back to NLS in STOP mode.
            br_targets[5][2] = br_targets[5][3] = MAX_BRIGHTNESS / 2;
        }
        ++step;

        // Update the brightness values.
        for (int row = 0; row < NLEDROWS; ++row) {
            size_t *prow = pdis_paint->on[row];
            for (int col = 0; col < NCOLS; ++col) {
                uint8 br_target = br_targets[row][col];
                float *p = brightness[row] + col;
                if (*p <= br_target) {
                    *p += (br_target - *p) * RISING_FACTOR;
                }
                else {
                    *p -= *p * FALLING_FACTOR;
                }
            }
        }

        // Light up LEDs
        extern int swStop, swSingInst, suppressILS;
        if (swStop || swSingInst || suppressILS) {
            // The CPU is in STOP mode or someone has suppressed the ILS,
            // so show the current LED states full-brightness using the
            // same mechanism NLS uses.  Force a display swap if the next
            // loop iteration won't do it in case this isn't STOP mode.
            update_led_states (intervl * 60);
            if (step != (MAX_BRIGHTNESS - 1)) swap_displays();
        }
        else {
            // Normal case: PWM display using the on-count values
            for (size_t row = 0; row < NLEDROWS; ++row) {
                // Output 0 (CLR) for LEDs in this row which should be on
                size_t *prow = pdis_paint->on[row];
                for (size_t col = 0; col < NCOLS; ++col) {
                    if (brightness[row][col] >= step) {
                        GPIO_CLR = 1 << cols[col];
                    }
                    else {
                        GPIO_SET = 1 << cols[col];
                    }
                }

                // Toggle this LED row on
                INP_GPIO(ledrows[row]);
                GPIO_SET = 1 << ledrows[row];
                OUT_GPIO(ledrows[row]);

                sleep_us(intervl);

                // Toggle this LED row off
                GPIO_CLR = 1 << ledrows[row]; // superstition
                INP_GPIO(ledrows[row]);

                sleep_ns(5);
            }
        }

#if 0   // debugging
        static time_t last = 0, now;
        if (time(&now) != last) {
            float* p = brightness[0];
            #define B(n) (p[n] / MAX_BRIGHTNESS * 100.0)
            printf("\r\nPC:"
                    " [%3.0f%%][%3.0f%%][%3.0f%%]"
                    " [%3.0f%%][%3.0f%%][%3.0f%%]"
                    " [%3.0f%%][%3.0f%%][%3.0f%%]"
                    " [%3.0f%%][%3.0f%%][%3.0f%%]",
                    B(11), B(10), B(9),
                    B(8),  B(7),  B(6),
                    B(5),  B(4),  B(3),
                    B(2),  B(1),  B(0));
            last = now;
        }
#endif

        // 625 = * 1000 / (100 / 60) where 60 is the difference in
        // iteration rate between ILS and NLS.  See the same call
        // in gpio-nls.c.
        read_switches(intervl * 625);      
#if defined(HAVE_SCHED_YIELD)
        sched_yield();
#endif
    }
}
