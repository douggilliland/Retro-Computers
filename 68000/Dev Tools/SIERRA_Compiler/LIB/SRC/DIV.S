*   div.s
*
*   Copyright 1987, 1992 by Sierra Systems.  All rights reserved.

*   div_t div(int numerator, int denominator)
*
*   where div_t is a structure defined in the header <stdlib.h>
*
*	struct div_t {
*	    int quot;	    /* quotient	 */
*	    int	rem;	    /* remainder */
*	}
*
*   div computes the quotient and remainder of the division of the numerator
*   by the denominator.	 If the division is inexact, the resulting quotient
*   is the integer of lesser magnitude that is the nearest to the algebraic
*   quotient.  If the result can be represented, then:
*
*   numerator = quotient * denominator + remainder

*   scratch registers (M68000): d0, d1, a0, a1
*   return with a0 containing return structure

*   n -> numerator
*   d -> denominator
*   q -> quotient
*   m -> modulus
*   neg -> negative
*   pos -> positive

*   logic duplicates that of _ms32s32 and _ds32s32 in order to combine them.
*   A 4-way branch on signs is needed because each case is different.
*
*   numerator denominator quotient modulus
*	+	+	    +	    +
*	+	-	    -	    +
*	-	+	    -	    -
*	-	-	    +	    -

 .ifdef M68020
HIGH_END = 0
 .else
 .ifdef M68040
HIGH_END = 0
 .else
 .ifdef M68332
HIGH_END = 0
 .endif
 .endif
 .endif

    .text
    .align  2

    .opt    proc=68000

    .globl  _div
    .globl  div

_div:
div:

 .ifdef INT_16
    link    a6,#-0
    movea.l 8(a6),a0	    ; address of return structure
    move.w  12(a6),d1	    ; numerator	
    ext.l   d1
    divs.w  14(a6),d1	    ; divide denominator into numerator
    move.w  d1,(a0)	    ; quotient
    bvc.s   no_overflow
    moveq   #0,d1
no_overflow:
    swap    d1
    move.w  d1,2(a0)	    ; remainder	
    unlk    a6
    rts
 .else

 .ifdef HIGH_END
    .opt    proc=68020
    link    a6,#-0
    movea.l (8,a6),a0	    ; address of return structure
    move.l  (12,a6),d1	    ; numerator	
    divsl.l (16,a6),d0:d1   ; divide denominator into numerator
    move.l  d1,(a0)	    ; quotient
    bvc.s   no_overflow
    moveq   #0,d0
no_overflow:
    move.l  d0,(4,a0)	    ; remainder	
    unlk    a6
    rts
 .else

    link    a6,#-8
    movem.l d2/a2,-8(a6)	; save d2/a2
    move.l  12(a6),d1	    ; numerator
    move.l  16(a6),d0	    ; denominator
    tst.l   d1
    bmi.s   neg_numerator
    tst.l   d0
    bmi.s   npos_dneg
    lea	    qpos_mpos(pc),a0 ; numer +, denom +
			    ; on exit set quot +, mod +
divmod:			    ; common function for unsigned divide and modulus
    swap    d0
    movea.w d0,a1	    ; save high order of divisor (denominator)
    swap    d0
    move.w  a1,d2	    ; need full 32 by 32 divide?
    beq.s   div3216	    ; no -> do 32 by 16
 .ifdef HIGH_END
    bsr.l   __mod2
 .else
    move.l  #__mod2,a2
    suba.l  #jmp1,a2
jmp1:
    jmp	    jmp1(pc,a2.l)   ; yes
 .endif

neg_numerator:		    ; numerator is negative
    neg.l   d1
    tst.l   d0
    bmi.s   nneg_dneg
    lea	    qneg_mneg(pc),a0 ; numer -, denom + -> on exit set quot -, mod -
    bra.s   divmod

nneg_dneg:
    neg.l   d0
    lea	    qpos_mneg(pc),a0 ; numer -, denom - -> on exit set quot +, mod -
    bra.s   divmod

npos_dneg:
    neg.l   d0
    lea	    qneg_mpos(pc),a0 ; numer +, denom - -> on exit set quot -, mod +
    bra.s   divmod

*   __mod2, an entry point into separate module div32, takes following
*
*   d1: 32-bit dividend (numerator)
*   d0: 32-bit divisor (denominator)
*   d2.w and a1.w: high order 16 bits of divisor in the low order words of
*		   both d2 & a1
*   a0: address to return to (one of the sign-adjusting exits below)
*
*   and returns the following
*
*   d1: 16-bit quotient extended to 32 bits
*   d2: negation of 32-bit remainder

*   divisor only has 16 bits, do 32 by 16 divide, yielding 16 or 32-bit
*   quotient and 16-bit remainder, returning them the same way div32 does

div3216:
    divu.w  d0,d1	    ; see if quotient fits in 16 bits
    bvs.s   L1		    ; branch if it doesn't
    move.l  d1,d2	    ; save 16-bit remainder (in high order)
    swap    d1		    ; extend unsigned 16-bit quotient to 32 bits
    clr.w   d1
    swap    d1
    bra.s   L2
L1:
    move.w  d1,-(sp)	    ; save low order of dividend (numerator)
    clr.w   d1		    ; shift right 16
    swap    d1
    divu.w  d0,d1	    ; get high order 16 bits of quotient,
    move.l  d1,d2	    ; leaving it in low order of d1
    move.w  (sp)+,d2	    ; combine remainder (hi) with low word of dividend
    divu.w  d0,d2	    ; get low order of quotient and final remainder
    swap    d1
    move.w  d2,d1	    ; combine halves of quotient
L2:
    clr.w   d2		    ; extend unsigned 16-bit remainder from high order
    swap    d2		    ; to 32 bits
    neg.l   d2		    ; negate to match div32 note: swap/neg.w/ext.l
			    ; won't work, remainder may be >= 2**15
    jmp	    (a0)	    ; return to one of following sign-fiddling exits

*   common exits, come here either from div3216 or __mod2

qneg_mpos:		    ; quotient -, modulus +
    neg.l   d2		    ; negate negated modulus
qneg_mneg:		    ; quotient -, modulus -
    neg.l   d1		    ; negate quotient
    bra.s   done
qpos_mpos:		    ; quotient +, modulus +
    neg.l   d2		    ; negate negated modulus
qpos_mneg:		    ; quotient +, modulus -
done:
    movea.l 8(a6),a0	    ; address of return structure
    move.l  d1,(a0)	    ; quotient
    move.l  d2,4(a0)	    ; remainder
    movem.l -8(a6),d2/a2    ; restore d2/a2
    unlk    a6
    rts
 .endif
 .endif
