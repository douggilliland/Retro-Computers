/* test.c - Front panel LED and switch testing program, built as pidp8i-test

   Copyright © 2016-2017 Paul R. Bernard and Warren Young

   Permission is hereby granted, free of charge, to any person obtaining a
   copy of this software and associated documentation files (the "Software"),
   to deal in the Software without restriction, including without limitation
   the rights to use, copy, modify, merge, publish, distribute, sublicense,
   and/or sell copies of the Software, and to permit persons to whom the
   Software is furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
   THE AUTHORS LISTED ABOVE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
   DEALINGS IN THE SOFTWARE.

   Except as contained in this notice, the names of the authors above shall
   not be used in advertising or otherwise to promote the sale, use or other
   dealings in this Software without prior written authorization from those
   authors.
*/

#define _POSIX_C_SOURCE 200809L

#include <pidp8i.h>

#include <assert.h>
#include <ctype.h>
#include <curses.h>
#include <pthread.h>
#include <signal.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef unsigned int uint32;
typedef unsigned char uint8;

uint8 path[] = {
    0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x11, 0x12, 0x13, 0x14, 0x15,
    0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x2c, 0x2b, 0x2a, 0x29,
    0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x31, 0x32, 0x33,
    0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x4c, 0x4b,
    0x4a, 0x49, 0x48, 0x47, 0x46, 0x45, 0x44, 0x43, 0x42, 0x41, 0x87,
    0x76, 0x77, 0x78, 0x79, 0x7a, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56,
    0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x68, 0x67, 0x66, 0x65, 0x64,
    0x63, 0x62, 0x61, 0x69, 0x6a, 0x6b, 0x6c, 0x71, 0x72, 0x75, 0x74,
    0x73
};

static int auto_advance = 1;

#define KEY_CHECK \
        switch (getch()) { \
            case KEY_DOWN: \
            case KEY_LEFT:  auto_advance = 0; return step - 1; \
            case KEY_UP: \
            case KEY_RIGHT: auto_advance = 0; return step + 1; \
            case 'r': \
            case 'R':       auto_advance = 1; return step + 1; \
            case 'x': \
            case 'X': \
            case 3:         exit (1); \
        }
#define DISPLAY_HOLD_ITERATIONS 20
#define DISPLAY_HOLD \
        sleep_us (250 * 1000); \
        if (auto_advance) { putchar('.'); } else { dhi = 0; } \
        KEY_CHECK


typedef int (*action_handler)(int, int);
struct action {
    action_handler ph;
    int step;
    int arg;
};


static void banner (const char* b, ...)
{
    va_list ap;
    va_start (ap, b);

    if (!auto_advance) {
        clear();
        refresh();
        printf ("Manual mode: Press x or Ctrl-C to exit, "
                "arrows to step, r to resume.");
    }

    printf ("\r\n");
    vprintf (b, ap);
    va_end (ap);
}


int all_leds_on (int step, int ignored)
{
    puts ("\r");
    banner ("Turn on ALL LEDs");

    for (int row = 0; row < NLEDROWS; ++row) ledstatus[row] = 07777;

    for (int dhi = 0; dhi < DISPLAY_HOLD_ITERATIONS; ++dhi) {
        DISPLAY_HOLD;
    }

    return step + 1;
}


int all_leds_off (int step, int ignored)
{
    puts ("\r");
    banner ("Turn off ALL LEDs");

    memset (ledstatus, 0, sizeof(ledstatus));
    for (int dhi = 0; dhi < DISPLAY_HOLD_ITERATIONS; ++dhi) {
        DISPLAY_HOLD;
    }

    return step + 1;
}


int led_row_on (int step, int row)
{
    if (row == 0) puts ("\r");
    memset (ledstatus, 0, sizeof(ledstatus));

    banner ("Turning on LED row %d", row + 1);

    for (int dhi = 0; dhi < DISPLAY_HOLD_ITERATIONS / 4; ++dhi) {
        ledstatus[row] = 07777;
        DISPLAY_HOLD;
    }
    ledstatus[row] = 0;
    
    return step + 1;
}


int led_col_on (int step, int col)
{
    if (col == 0) puts ("\r");
    memset (ledstatus, 0, sizeof(ledstatus));

    banner ("Turning on LED col %d", col + 1);

    for (int dhi = 0; dhi < DISPLAY_HOLD_ITERATIONS / 4; ++dhi) {
        for (int row = 0; row < NLEDROWS; ++row)
            ledstatus[row] |= 1 << col;
        DISPLAY_HOLD;
    }
    ledstatus[col] = 0;
    
    return step + 1;
}


int switch_scan (int step, int ignored)
{
    int path_idx = 0, led_row = 0, debouncing = 1;
    uint16_t last_ss[NROWS];
    uint16_t stable_ss[NROWS];

    puts ("\r");
    banner ("Reading the switches.  Toggle any pattern desired.  "
            "Ctrl-C to quit.\r\n");

    memset (ledstatus, 0, sizeof(ledstatus));
    assert (sizeof   (last_ss) == sizeof (switchstatus));
    assert (sizeof (stable_ss) == sizeof (switchstatus));
    for (int i = 0; i < NROWS; ++i) {
        last_ss[i] = switchstatus[i];
    }

    for (;;) {
        ledstatus[led_row] = 0;
        ledstatus[led_row = (path[path_idx] >> 4) - 1] =
                04000 >> ((path[path_idx] & 0x0F) - 1);
        sleep_us (1);
        if (++path_idx >= sizeof (path) / sizeof (path[0]))
            path_idx = 0;

        if (debouncing) {
            if (    last_ss[0]   != switchstatus[0] ||
                    last_ss[1]   != switchstatus[1] ||
                    last_ss[2]   != switchstatus[2] ||
                    stable_ss[0] != switchstatus[0] ||
                    stable_ss[1] != switchstatus[1] ||
                    stable_ss[2] != switchstatus[2]) {
                // Switches aren't stable yet, so clock the states
                // through by one step.
                memcpy (stable_ss, last_ss, sizeof (stable_ss));
                memcpy (last_ss, switchstatus, sizeof (last_ss));
            }
            else {
                // The switches have remained in their new state for two
                // cycles, so we can consider the switches debounced.
                // Report the new stable state.
                debouncing = 0;
                for (int i = 0; i < NROWS; ++i) {
                    printf ("%04o ", ~switchstatus[i] & 07777);
                }
                printf ("\r\n");
            }
        }
        else if (   last_ss[0] != switchstatus[0] ||
                    last_ss[1] != switchstatus[1] ||
                    last_ss[2] != switchstatus[2]) {
            // Switch state change detected.  Wait for stabilization.
            memcpy (last_ss, switchstatus, sizeof (last_ss));
            debouncing = 1;
        }

        KEY_CHECK;
        sleep_us (30000);
    }

    return step + 1;
}


void start_gpio (void)
{
    // Tell the GPIO thread we're updating the display via direct
    // ledstatus[] manipulation instead of set_pidp8i_leds calls.
    pidp8i_simple_gpio_mode = 1;

    // Create GPIO thread
    if (start_pidp8i_gpio_thread ("test program") != 0) {
        exit (EXIT_FAILURE);
    }
}


// Tell ncurses we want character-at-a-time input without echo,
// non-blocking reads, and no input interpretation.
void init_ncurses (void)
{
    initscr ();
    nodelay (stdscr, TRUE);
    keypad  (stdscr, TRUE);
    noecho ();
    cbreak ();
    clear ();
    refresh ();
}


void run_actions (void)
{
    // Define action sequence
    struct action actions[] = {
        { all_leds_on,  0,  0 },
        { all_leds_off, 1,  0 },

        { led_row_on,   2,  0 },
        { led_row_on,   3,  1 },
        { led_row_on,   4,  2 },
        { led_row_on,   5,  3 },
        { led_row_on,   6,  4 },
        { led_row_on,   7,  5 },
        { led_row_on,   8,  6 },
        { led_row_on,   9,  7 },

        { led_col_on,  10,  0 },
        { led_col_on,  11,  1 },
        { led_col_on,  12,  2 },
        { led_col_on,  13,  3 },
        { led_col_on,  14,  4 },
        { led_col_on,  15,  5 },
        { led_col_on,  16,  6 },
        { led_col_on,  17,  7 },
        { led_col_on,  18,  8 },
        { led_col_on,  19,  9 },
        { led_col_on,  20, 10 },
        { led_col_on,  21, 11 },

        { switch_scan, 22, 0 },
    };
    const size_t num_actions = sizeof(actions) / sizeof(actions[0]);

    // Run actions
    int i = 0;
    while (i < num_actions) {
        i = (actions[i].ph)(i, actions[i].arg);
        if (i == num_actions) i = 0;
        if (i == -1)          i = num_actions - 1;
    }
}


static void emergency_shut_down (int signum)
{
    // Shut ncurses down before we call printf, so it's down at the
    // bottom.  This duplicates part of the graceful shutdown path,
    // which is why it checks whether it's necessary.
    endwin ();

    printf ("\r\nExiting pidp8i-test, signal %d: %s\n\n", signum,
            strsignal (signum));

    exit (2);       // continues in graceful_shut_down
}


static void graceful_shut_down ()
{
    if (!isendwin()) endwin ();
    turn_off_pidp8i_leds ();
}


static void register_shut_down_handlers ()
{
    struct sigaction sa;
    memset (&sa, 0, sizeof (sa));
    sa.sa_handler = emergency_shut_down;
    sigaction (SIGINT, &sa, 0);
    atexit (graceful_shut_down);
}


int main (int argc, char *argv[])
{
    start_gpio ();

    if ((argc < 2) || (strcmp (argv[1], "-v") != 0)) {
        register_shut_down_handlers ();
        init_ncurses ();
        run_actions ();
    }

    return 0;
}
