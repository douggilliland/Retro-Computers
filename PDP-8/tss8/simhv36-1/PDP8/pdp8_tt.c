/* pdp8_tt.c: PDP-8 console terminal simulator

   Copyright (c) 1993-2005, Robert M Supnik

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
   ROBERT M SUPNIK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
   IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

   Except as contained in this notice, the name of Robert M Supnik shall not be
   used in advertising or otherwise to promote the sale, use or other dealings
   in this Software without prior written authorization from Robert M Supnik.

   tti,tto      KL8E terminal input/output

   22-Nov-05    RMS     Revised for new terminal processing routines
   28-May-04    RMS     Removed SET TTI CTRL-C
   29-Dec-03    RMS     Added console output backpressure support
   25-Apr-03    RMS     Revised for extended file support
   02-Mar-02    RMS     Added SET TTI CTRL-C
   22-Dec-02    RMS     Added break support
   01-Nov-02    RMS     Added 7B/8B support
   04-Oct-02    RMS     Added DIBs, device number support
   30-May-02    RMS     Widened POS to 32b
   07-Sep-01    RMS     Moved function prototypes
*/

#include "pdp8_defs.h"
#include <ctype.h>

extern int32 int_req, int_enable, dev_done, stop_inst;
extern int cycles;

int32 tti (int32 IR, int32 AC);
int32 tto (int32 IR, int32 AC);
t_stat tti_svc (UNIT *uptr);
t_stat tto_svc (UNIT *uptr);
t_stat tti_reset (DEVICE *dptr);
t_stat tto_reset (DEVICE *dptr);
t_stat tty_set_mode (UNIT *uptr, int32 val, char *cptr, void *desc);

/* TTI data structures

   tti_dev      TTI device descriptor
   tti_unit     TTI unit descriptor
   tti_reg      TTI register list
   tti_mod      TTI modifiers list
*/

DIB tti_dib = { DEV_TTI, 1, { &tti } };

#undef KBD_POLL_WAIT
#define KBD_POLL_WAIT 10

UNIT tti_unit = { UDATA (&tti_svc, TT_MODE_KSR, 0), KBD_POLL_WAIT };

REG tti_reg[] = {
    { ORDATA (BUF, tti_unit.buf, 8) },
    { FLDATA (DONE, dev_done, INT_V_TTI) },
    { FLDATA (ENABLE, int_enable, INT_V_TTI) },
    { FLDATA (INT, int_req, INT_V_TTI) },
    { DRDATA (POS, tti_unit.pos, T_ADDR_W), PV_LEFT },
    { DRDATA (TIME, tti_unit.wait, 24), REG_NZ + PV_LEFT },
    { NULL }
    };

MTAB tti_mod[] = {
    { TT_MODE, TT_MODE_KSR, "KSR", "KSR", &tty_set_mode },
    { TT_MODE, TT_MODE_7B,  "7b",  "7B",  &tty_set_mode },
    { TT_MODE, TT_MODE_8B,  "8b",  "8B",  &tty_set_mode },
    { TT_MODE, TT_MODE_7P,  "7b",  NULL,  NULL },
    { MTAB_XTD|MTAB_VDV, 0, "DEVNO", NULL, NULL, &show_dev, NULL },
    { 0 }
    };

DEVICE tti_dev = {
    "TTI", &tti_unit, tti_reg, tti_mod,
    1, 10, 31, 1, 8, 8,
    NULL, NULL, &tti_reset,
    NULL, NULL, NULL,
    &tti_dib, 0
    };

/* TTO data structures

   tto_dev      TTO device descriptor
   tto_unit     TTO unit descriptor
   tto_reg      TTO register list
*/

DIB tto_dib = { DEV_TTO, 1, { &tto } };

#undef SERIAL_OUT_WAIT
#define SERIAL_OUT_WAIT 0

UNIT tto_unit = { UDATA (&tto_svc, TT_MODE_KSR, 0), SERIAL_OUT_WAIT };

REG tto_reg[] = {
    { ORDATA (BUF, tto_unit.buf, 8) },
    { FLDATA (DONE, dev_done, INT_V_TTO) },
    { FLDATA (ENABLE, int_enable, INT_V_TTO) },
    { FLDATA (INT, int_req, INT_V_TTO) },
    { DRDATA (POS, tto_unit.pos, T_ADDR_W), PV_LEFT },
    { DRDATA (TIME, tto_unit.wait, 24), PV_LEFT },
    { NULL }
    };

MTAB tto_mod[] = {
    { TT_MODE, TT_MODE_KSR, "KSR", "KSR", &tty_set_mode },
    { TT_MODE, TT_MODE_7B,  "7b",  "7B",  &tty_set_mode },
    { TT_MODE, TT_MODE_8B,  "8b",  "8B",  &tty_set_mode },
    { TT_MODE, TT_MODE_7P,  "7p",  "7P",  &tty_set_mode },
    { MTAB_XTD|MTAB_VDV, 0, "DEVNO", NULL, NULL, &show_dev },
    { 0 }
    };

DEVICE tto_dev = {
    "TTO", &tto_unit, tto_reg, tto_mod,
    1, 10, 31, 1, 8, 8,
    NULL, NULL, &tto_reset, 
    NULL, NULL, NULL,
    &tto_dib, 0
    };

//#define FAKE_INPUT
#ifdef FAKE_INPUT
int tt_input_index;
char tt_input[] = "START\r01:01:85\r10:10\r";
int tt_input_count = sizeof(tt_input)-1;
int tt_refire;
#endif

/* Terminal input: IOT routine */

int32 tti (int32 IR, int32 AC)
{
switch (IR & 07) {                                      /* decode IR<9:11> */
    case 0:                                             /* KCF */
        dev_done = dev_done & ~INT_TTI;                 /* clear flag */
        int_req = int_req & ~INT_TTI;
        return AC;

    case 1:                                             /* KSF */
#ifdef FAKE_INPUT
	if (tt_input_index == 0 &&
	    (dev_done & INT_TTI) == 0)
	{
		void tt_set_event(void);
		tt_set_event();
	}
#endif
        return (dev_done & INT_TTI)? IOT_SKP + AC: AC;

    case 2:                                             /* KCC */
        dev_done = dev_done & ~INT_TTI;                 /* clear flag */
        int_req = int_req & ~INT_TTI;
#ifdef FAKE_INPUT
	{
		void tt_set_event(void);
		tt_set_event();
	}
#endif
        return 0;                                       /* clear AC */

    case 4:                                             /* KRS */
#ifdef FAKE_INPUT
	    printf("xxx rx input %o (%d/%d)\r\n",
		   tti_unit.buf, tt_input_index, tt_input_count);
#endif
        return (AC | tti_unit.buf);                     /* return buffer */

    case 5:                                             /* KIE */
        if (AC & 1) int_enable = int_enable | (INT_TTI+INT_TTO);
        else int_enable = int_enable & ~(INT_TTI+INT_TTO);
        int_req = INT_UPDATE;                           /* update interrupts */
        return AC;

    case 6:                                             /* KRB */
        dev_done = dev_done & ~INT_TTI;                 /* clear flag */
        int_req = int_req & ~INT_TTI;
#ifdef FAKE_INPUT
	{
		void tt_set_event(void);
		tt_set_event();
	}
	printf("xxx rx input %o (%d/%d)\r\n",
	       tti_unit.buf, tt_input_index, tt_input_count);
#endif
        return (tti_unit.buf);                          /* return buffer */

    default:
        return (stop_inst << IOT_V_REASON) + AC;
        }                                               /* end switch */
}

/* Unit service */

t_stat tti_svc (UNIT *uptr)
{
int32 c;

#ifdef FAKE_INPUT
return SCPE_OK;
#endif

sim_activate (uptr, uptr->wait);                        /* continue poll */
if ((c = sim_poll_kbd ()) < SCPE_KFLAG) return c;       /* no char or error? */
if (c & SCPE_BREAK) uptr->buf = 0;                      /* break? */
else uptr->buf = sim_tt_inpcvt (c, TT_GET_MODE (uptr->flags) | TTUF_KSR);
uptr->pos = uptr->pos + 1;
dev_done = dev_done | INT_TTI;                          /* set done */
int_req = INT_UPDATE;                                   /* update interrupts */
return SCPE_OK;
}

/* Reset routine */

t_stat tti_reset (DEVICE *dptr)
{
tti_unit.buf = 0;
dev_done = dev_done & ~INT_TTI;                         /* clear done, int */
int_req = int_req & ~INT_TTI;
int_enable = int_enable | INT_TTI;                      /* set enable */
sim_activate (&tti_unit, tti_unit.wait);                /* activate unit */
return SCPE_OK;
}

#ifdef FAKE_INPUT
char tt_buf[1024];
int tt_buf_count;

int tt_flag;
int tt_data;
int tt_countdown;
int tt_event;

void tt_set_event(void)
{
	tt_event = 1;
}

#if 0
#define R1 30000
#define R2 40000
#define R3 50000
#define R4 300000
#define R5 400000
#else
#define R1 110000
#define R2 120000
#define R3 130000
#define R4 300000
#define R5 400000
#endif

void tt_service(void)
{
	if (tt_refire == 0 && (tt_input_index == tt_input_count)) {
		if (cycles >= R1) {
			strcpy(tt_input, "\rLOGIN 2 LXHE\r\r");
			tt_input_count = strlen(tt_input);
			tt_input_index = 0;
			tt_refire++;
			printf("xxx boom 1; cycles %d\r\n", cycles);
		}
	}

	if (tt_refire == 1 && (tt_input_index == tt_input_count)) {
		if (cycles >= R2) {
			strcpy(tt_input, "\r");
			tt_input_count = strlen(tt_input);
			tt_input_index = 0;
			tt_refire++;
			printf("xxx boom 2; cycles %d\r\n", cycles);
		}
	}

	if (tt_refire == 2 && (tt_input_index == tt_input_count)) {
		if (cycles >= R3) {
			strcpy(tt_input, "\r");
			tt_input_count = strlen(tt_input);
			tt_input_index = 0;
			tt_refire++;
			printf("xxx boom 3; cycles %d\r\n", cycles);
		}
	}

	if (tt_refire == 3 && (tt_input_index == tt_input_count)) {
		if (cycles >= R4) {
			strcpy(tt_input, "R FOCAL\r");
			tt_input_count = strlen(tt_input);
			tt_input_index = 0;
			tt_refire++;
			printf("xxx boom 4; cycles %d\r\n", cycles);
		}
	}

	if (tt_refire == 4 && (tt_input_index == tt_input_count)) {
		if (cycles >= R5) {
			strcpy(tt_input, "\r");
			tt_input_count = strlen(tt_input);
			tt_input_index = 0;
			tt_refire++;
			printf("xxx boom 5; cycles %d\r\n", cycles);
		}
	}

	if (tt_input_index < tt_input_count &&
            (dev_done & INT_TTI) == 0 && tt_event)
	{
		tti_unit.buf = tt_input[tt_input_index++] & 0xff;
		tti_unit.pos++;
		dev_done |= INT_TTI;
		int_req = INT_UPDATE;
		tt_event = 0;
		if (tt_input_index == tt_input_count) {
			printf("xxx input exhausted %d cycles\r\n", cycles);
		}
	}

	if (tt_countdown > 0) {
		tt_countdown--;
		if (tt_countdown == 0) {
			int i;

			printf("xxx tx_data %o\r\n", tt_data);

			tt_flag = 1;

			dev_done |= INT_TTO;
			int_req = INT_UPDATE;

			tt_buf[tt_buf_count++] = tt_data;
			printf("xxx output: ");
			for (i = 0; i < tt_buf_count; i++) {
				char ch = tt_buf[i] & 0177;
if (ch == 0) ch = '@';
tt_buf[i] = ch;
				switch (ch) {
				case '\n': printf("\\n"); break;
				case '\r': printf("\\r"); break;
				default: printf("%c", ch); break;
				}
			}
			printf("\r\n");

tt_buf[tt_buf_count] = 0;

			if (tt_refire == 5) {
				extern int need_stop;
				if (strstr(tt_buf, "RETAIN")) {
					need_stop = 1;
					printf("xxx need stop %d cycles\r\n", cycles);
				}
			}
		}
	} else {
#if 0
        if (tt_flag && int_enable) {
            printf("tt_flag set; set int\n");
	    dev_done |= INT_TTO;
	    int_req = INT_UPDATE;
        }
#endif
    }
}

void check_output(int c);

void tt_output(int c)
{
	check_output(c & 0x7f);
	tt_data = c & 0xff;
	tt_countdown = 98/*100*/;
	tt_flag = 0;
}
#else
void tt_service(void) {}
#endif

/* Terminal output: IOT routine */

int32 tto (int32 IR, int32 AC)
{
switch (IR & 07) {                                      /* decode IR<9:11> */

    case 0:                                             /* TLF */
        dev_done = dev_done | INT_TTO;                  /* set flag */
        int_req = INT_UPDATE;                           /* update interrupts */
        return AC;

    case 1:                                             /* TSF */
        return (dev_done & INT_TTO)? IOT_SKP + AC: AC;

    case 2:                                             /* TCF */
        dev_done = dev_done & ~INT_TTO;                 /* clear flag */
        int_req = int_req & ~INT_TTO;                   /* clear int req */
        return AC;

    case 5:                                             /* SPI */
        return (int_req & (INT_TTI+INT_TTO))? IOT_SKP + AC: AC;

    case 6:                                             /* TLS */
        dev_done = dev_done & ~INT_TTO;                 /* clear flag */
        int_req = int_req & ~INT_TTO;                   /* clear int req */
    case 4:                                             /* TPC */
#ifdef FAKE_INPUT
        tt_output(AC);
#else
        sim_activate (&tto_unit, tto_unit.wait);        /* activate unit */
#endif
        tto_unit.buf = AC;                              /* load buffer */
        return AC;

    default:
        return (stop_inst << IOT_V_REASON) + AC;
        }                                               /* end switch */
}

/* Unit service */

#ifdef FAKE_INPUT
static int state;
extern int need_stop;

void check_output(int c)
{
	switch (state) {
	case 0:
		if (c == '\r')
			state = 1;
		break;
	case 1:
		state = c == '\n' ? 2 : 0;
		break;
	case 2:
		if (c == '.') {
			/*need_stop = 1*/;
#if 0
			if (tt_refire == 1) {
				printf("xxx boom 3\n");
				strcpy(tt_input, "R FOCAL\r");
				tt_input_count = strlen(tt_input);
				tt_input_index = 0;
				tt_refire++;
			}
#endif
		}

		state = 0;
		break;
	}
}
#endif

t_stat tto_svc (UNIT *uptr)
{
int32 c;
t_stat r;

c = sim_tt_outcvt (uptr->buf, TT_GET_MODE (uptr->flags));
if (c >= 0) {
    if ((r = sim_putchar_s (c)) != SCPE_OK) {           /* output char; error? */
        sim_activate (uptr, uptr->wait);                /* try again */
        return ((r == SCPE_STALL)? SCPE_OK: r);         /* if !stall, report */
        }
    }
#ifdef FAKE_INPUT
check_output(c);
#endif
dev_done = dev_done | INT_TTO;                          /* set done */
int_req = INT_UPDATE;                                   /* update interrupts */
uptr->pos = uptr->pos + 1;
return SCPE_OK;
}

/* Reset routine */

t_stat tto_reset (DEVICE *dptr)
{
tto_unit.buf = 0;
dev_done = dev_done & ~INT_TTO;                         /* clear done, int */
int_req = int_req & ~INT_TTO;
int_enable = int_enable | INT_TTO;                      /* set enable */
sim_cancel (&tto_unit);                                 /* deactivate unit */
return SCPE_OK;
}

t_stat tty_set_mode (UNIT *uptr, int32 val, char *cptr, void *desc)
{
tti_unit.flags = (tti_unit.flags & ~TT_MODE) | val;
tto_unit.flags = (tto_unit.flags & ~TT_MODE) | val;
return SCPE_OK;
}
