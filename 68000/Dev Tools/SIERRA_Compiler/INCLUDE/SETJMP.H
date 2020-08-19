/*--------------------------------- setjmp.h --------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#ifdef _FP_REGS
typedef long jmp_buf[31];	/* room for pc, d2-d7, a2-a7, fp2-fp7 */
#else
typedef long jmp_buf[13];	/* room for pc, d2-d7, a2-a7	      */
#endif

int setjmp(jmp_buf environment);
void longjmp(jmp_buf environment, int value);
