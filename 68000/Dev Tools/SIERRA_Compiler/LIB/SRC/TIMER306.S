; timer306.s
; Copyright 1994 by Sierra Systems.  All rights reserved.

    .opt    proc=68000

CTUR	=   0xfffff7ed
CTLR	=   0xfffff7ef
START	=   0xfffff7fd
STOP	=   0xfffff7ff

    .extern __overflow

    .globl  __start_timer
    .global __stop_timer

    .text
    .align  2

;------------------------------- _start_timer() ------------------------------
;
; void _start_timer(void)

__start_timer:

    tst.b   STOP

; load the upper and lower timer preset registers

    move.b  #255,CTUR
    move.b  #255,CTLR

; clear the overflow word and start the counter

    moveq   #0,d0
 .ifdef A5_16
    move.l  d0,__overflow(a5)
 .else
    move.l  d0,__overflow
 .endif
    tst.b   START
    rts	

;-------------------------------- _stop_timer() ------------------------------
;
; unsigned long _stop_timer(int resolution)
;
; resolution == 0 --> elapsed time returned in microseconds
; resolution == 1 --> elapsed time returned in milliseconds
; resolution == 2 --> elapsed time returned in seconds
;
; total_ticks = overflow * 65535 + (0xffff - current_counter)
;
; elapsed time in microseconds = total_ticks * 16 / 3.6864
;
; which approximates to:
;
; seconds:	total_ticks * 4660 / 0x40000000
; milliseconds: total_ticks * 4551 / 0x100000
; microseconds: total_ticks * 17778 / 0x1000

__stop_timer:
    movem.l d2-d5,-(sp)
 .ifdef INT_16
    move.w  20(sp),d2		; resolution
 .else
    move.l  20(sp),d2		; resolution
 .endif
    tst.b   STOP		; stop the counter
    move.b  CTUR,d0		; upper counter
    lsl.w   #8,d0		; move to upper byte
    move.b  CTLR,d0		; lower counter to lower byte
    eori.w  #0xffff,d0		; subtract from 0xffff
    swap    d0
 .ifdef A5_16
    move.w  __overflow+2(a5),d0	; lower word of count
    swap    d0
    clr.l   d1
    move.w  __overflow(a5),d1	; upper word of count
 .else
    move.w  __overflow+2,d0	; lower word of count
    swap    d0
    clr.l   d1
    move.w  __overflow,d1	; upper word of count
 .endif
; 48 bit number in d1:d0

    btst    #1,d2		; is answer needed in seconds
    beq.s   check_milli		; no	  

; compute elapse time in seconds

; multiply value in d1:d0 by 4660

    move.l  #2,d5
    bsr.w   lsl_d1d0
    move.l  d1,d3
    move.l  d0,d2
    move.l  #2,d5
    bsr.w   lsl_d1d0
    add.l   d0,d2
    addx.l  d1,d3
    add.l   d0,d0
    addx.l  d1,d1
    add.l   d0,d2
    addx.l  d1,d3
    move.l  #4,d5   
    bsr.w   lsl_d1d0
    add.l   d0,d2
    addx.l  d1,d3
    move.l  #3,d5   
    bsr.w   lsl_d1d0
    add.l   d2,d0
    addx.l  d3,d1

; right shift d1:d0 by 30 leaving result in d0

    lsl.l   #2,d1
    rol.l   #2,d0
    andi.l  #0x3,d0
    or.l    d1,d0
    bra.w   done

check_milli:
    btst    #0,d2	; is answer needed in milliseconds
    beq.w   in_micro	; no

; compute elapse time in milliseconds

; multiply value in d1:d0 by 4551

    clr.l   d3
    clr.l   d2
    sub.l   d0,d2
    subx.l  d1,d3
    move.l  #3,d5   
    bsr.w   lsl_d1d0
    sub.l   d0,d2
    subx.l  d1,d3
    add.l   d0,d0
    addx.l  d1,d1
    sub.l   d0,d2
    subx.l  d1,d3
    add.l   d0,d0
    addx.l  d1,d1
    sub.l   d0,d2
    subx.l  d1,d3
    move.l  #4,d5   
    bsr.w   lsl_d1d0
    add.l   d0,d2
    addx.l  d1,d3
    move.l  #3,d5   
    bsr.w   lsl_d1d0
    add.l   d2,d0
    addx.l  d3,d1

; right shift d1:d0 by 20 leaving result in d0

    move.l  #12,d5
    lsl.l   d5,d1
    rol.l   d5,d0
    andi.l  #0xfff,d0
    or.l    d1,d0
    bra.s   done

in_micro:

; compute elapse time in microseconds

; multiply value in d1:d0 by 17778

    add.l   d0,d0
    addx.l  d1,d1
    move.l  d0,d2
    move.l  d1,d3
    move.l  #3,d5
    bsr.w   lsl_d1d0
    sub.l   d0,d2
    subx.l  d1,d3
    move.l  #3,d5
    bsr.w   lsl_d1d0
    add.l   d0,d2
    addx.l  d1,d3
    add.l   d0,d0
    addx.l  d1,d1
    add.l   d0,d2
    addx.l  d1,d3
    move.l  #2,d5
    bsr.w   lsl_d1d0
    add.l   d0,d2
    addx.l  d1,d3
    move.l  #4,d5
    bsr.w   lsl_d1d0
    add.l   d2,d0
    addx.l  d3,d1

; right shift d1:d0 by 12 leaving result in d0

    move.l  #12,d5
    lsr.l   d5,d0
    move.l  #20,d5
    lsl.l   d5,d1
    or.l    d1,d0

done:
    movem.l (sp)+,d2-d5
    rts

;----------------------------------- lsl_d1d0 --------------------------------
;
; left shift double word in d1:d0 by shift count in d5

lsl_d1d0:
    lsl.l   d5,d1	; left shift high word
    rol.l   d5,d0	; left rotate low word

    moveq   #-1,d4	; create 1's mask the width of the shift count	    
    lsl.l   d5,d4
    not.l   d4

    and.l   d0,d4	; bits from low word to inserteded into high word
    or.l    d4,d1	; inserted shifted out bits from low word into high
    eor.l   d4,d0	; clear the low shift count bits in the low word
    rts


