/*
 * gpio-common.h: public interface for the PiDP-8/I's GPIO module
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
*/

#if !defined(PIDP8I_GPIO_H)
#define PIDP8I_GPIO_H

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
 
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>


// GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x)
#define INP_GPIO(g)   *(pgpio->addr + ((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g)   *(pgpio->addr + ((g)/10)) |=  (1<<(((g)%10)*3))
#define SET_GPIO_ALT(g,a) *(pgpio->addr + (((g)/10))) |= (((a)<=3?(a) + 4:(a)==4?3:2)<<(((g)%10)*3))

#define GPIO_SET  *(pgpio->addr + 7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR  *(pgpio->addr + 10) // clears bits which are 1 ignores bits which are 0

#define GPIO_READ(g)  *(pgpio->addr + 13) &= (1<<(g))

#define GPIO_PULL *(pgpio->addr + 37) // pull up/pull down
#define GPIO_PULLCLK0 *(pgpio->addr + 38) // pull up/pull down clock


// Switch masks, SSn, used against switchstatus[n]
#define SS0_SR_B11 04000
#define SS0_SR_B10 02000
#define SS0_SR_B09 01000
#define SS0_SR_B08 00400
#define SS0_SR_B07 00200
#define SS0_SR_B06 00100
#define SS0_SR_B05 00040
#define SS0_SR_B04 00020
#define SS0_SR_B03 00010
#define SS0_SR_B02 00004
#define SS0_SR_B01 00002
#define SS0_SR_B00 00001

#define SS1_DF_B2  04000
#define SS1_DF_B1  02000
#define SS1_DF_B0  01000
#define SS1_DF_ALL (SS1_DF_B2 | SS1_DF_B1 | SS1_DF_B0)

#define SS1_IF_B2  00400
#define SS1_IF_B1  00200
#define SS1_IF_B0  00100
#define SS1_IF_ALL (SS1_IF_B2 | SS1_IF_B1 | SS1_IF_B0)

#define SS2_START  04000
#define SS2_L_ADD  02000
#define SS2_DEP    01000
#define SS2_EXAM   00400
#define SS2_CONT   00200
#define SS2_STOP   00100
#define SS2_S_STEP 00040
#define SS2_S_INST 00020

// Number of LED and switch rows and columns on the PiDP-8/I PCB
#define NCOLS    12
#define NLEDROWS 8
#define NROWS    3
 
// Info for accessing the GPIO peripheral on the SoC
struct bcm2835_peripheral {
    uint32_t addr_p;
    int mem_fd;
    void *map;
    volatile unsigned int *addr;
};

typedef uint64_t ns_time_t;
typedef uint64_t us_time_t;
typedef uint64_t ms_time_t;

typedef struct display {
    // Counters incremented each time the LED is known to be turned on,
    // in instructions since the last display paint.
    size_t on[NLEDROWS][NCOLS];

    // Most recent state for each LED, for use by NLS full-time and by
    // ILS in STOP mode.  (One bitfield per row.)
    uint16_t curr[NLEDROWS];

    // Number of instructions executed since this display was cleared
    int inst_count;
} display;
extern display* pdis_update, *pdis_paint;

// Compatibility interface for programs like src/test.c that depend on
// being able to modify the LED values directly.
#define ledstatus (pdis_update->curr)
extern int pidp8i_simple_gpio_mode;

// Simplified interface for single-threaded programs that don't use our
// GPIO thread, but do want to share some our implementation.
extern void init_pidp8i_gpio (void);
extern int map_gpio_for_pidp8i (int must_map);

extern uint16_t switchstatus[NROWS];
extern uint8_t cols[];
extern uint8_t ledrows[];
extern uint8_t rows[];
extern uint8_t pidp8i_gpio_present;

extern int start_pidp8i_gpio_thread (const char* must_map);
extern void stop_pidp8i_gpio_thread ();
extern void turn_on_pidp8i_leds ();
extern void turn_off_pidp8i_leds ();
extern void update_led_states (const us_time_t delay);

// Alternative to start_pidp8i_gpio_thread() for programs that run
// single-threaded and do their own GPIO scanning, like scanswitch.
extern void init_pidp8i_gpio (void);

extern void unmap_peripheral(struct bcm2835_peripheral *p);

extern void read_switches (ns_time_t delay);

extern void swap_displays ();

extern void sleep_ns(ns_time_t ns);
#define sleep_us(us) sleep_ns(us * 1000)
#define sleep_ms(ms) sleep_us(ms * 1000)
extern ms_time_t ms_time(ms_time_t* pt);
 
#endif // !defined(PIDP8I_GPIO_H)
