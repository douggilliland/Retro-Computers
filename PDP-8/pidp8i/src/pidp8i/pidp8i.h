/* pidp8i.h: Interface between PiDP-8/I additions and the stock SIMH PDP-8
   simulator

   Copyright © 2015-2017 by Oscar Vermeulen and Warren Young

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

#if !defined(PIDP8I_H)
#define PIDP8I_H

#include "gpio-common.h"

#include <stdint.h>
#include <stdlib.h>

typedef enum {
    pft_normal,
    pft_halt,
    pft_stop,
} pidp8i_flow_t;

extern char *build_pidp8i_scp_cmd (char* cbuf, size_t cbufsize); 

extern int32_t get_switch_register (void);
extern size_t get_pidp8i_initial_max_skips (size_t updates_per_sec);

extern pidp8i_flow_t handle_flow_control_switches (uint16_t* pM,
        uint32_t *pPC, uint32_t *pMA, int32_t *pMB, int32_t *pLAC, int32_t *pIF,
        int32_t *pDF, int32_t* pint_req);

extern void set_pidp8i_leds (uint32_t sPC, uint32_t sMA, uint32_t sMB,
        uint16_t sIR, int32_t sLAC, int32_t sMQ, int32_t sIF, int32_t sDF,
        int32_t sSC, int32_t int_req, int Pause);

#endif // !defined(PIDP8I_H)
