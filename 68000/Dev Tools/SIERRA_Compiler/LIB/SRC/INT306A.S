; int306a.s
; Copyright 1994 by Sierra Systems.  All rights reserved.
;
; When using the 68306 specific timer and I/O functions, call init_tm_duart
; while in supervisor mode before calling the application proogram's main
; routine.

    .opt    proc=68000

    .globl  __putch_a
    .globl  __putch_b
    .globl  init_tm_duart

START	=   0xfffff7fd
STOP	=   0xfffff7ff
TBA	=   0xfffff7e7
TBB	=   0xfffff7f7
SRA	=   0xfffff7e3
SRB	=   0xfffff7f3
ISR	=   0xfffff7eb
RBB	=   0xfffff7f7
RBA	=   0xfffff7e7
ACR	=   0xfffff7e9
IVR	=   0xfffff7f9
IMR	=   0xfffff7eb

    .comm   __overflow,4,2

    .text
    .align  2

;------------------------------- init_tm_duart -------------------------------
;
; initialize the vector table for DUART and TIMER

init_tm_duart:
    move.l  #timer_int,65*4	; load TIMER interrupt handler
    move.b  #65,0xffffffff	; load TIMER vector with vector number
    ori.w   #0x8000,0xfffffffa	; enable TIMER interrupt
    move.l  #duart_int,64*4	; load DUART interrupt handler
    move.b  #64,IVR		; set DUART interrupt vector number
    move.b  #0x22,IMR		; enable port A and B interrupts
    move.b  #0x30,ACR		; set to counter mode -- crystal clock
    rts

;---------------------------------- timer_int --------------------------------
;
; interrupt handler for timer

timer_int:
    tst.b   STOP		; stop the counter
 .ifdef A5_16
    addq.l  #1,__overflow(a5)	; increment the count
 .else
    addq.l  #1,__overflow	; increment the count
 .endif
    tst.b   START		; restart the counter
    rte

;-------------------------------- duart_int ----------------------------------
;
; interrupt handler for duart

duart_int:
    movem.l d0-d2/a0-a1,-(sp)	; save registers
    btst.b  #1,ISR		; check if char on channel A
    beq.s   channel_b	
    move.w  #0,-(sp)		; channel A
    move.b  RBA,d0		; get the character
    bra.s   put_in_q
channel_b:
    move.w  #1,-(sp)		; channel B
    move.b  RBB,d0		; get the character
put_in_q:
    move.w  d0,-(sp)
    bsr.w   __put_in_buf	; put the character in the buffer
    addq.l  #4,sp
    movem.l (sp)+,d0-d2/a0-a1	; restore registers
    rte

;-------------------------------- _putch_a() ---------------------------------
;
; _putch_a(short ch, char *p_xoff_rcvd)

__putch_a:
    move.l  6(sp),a0	    ; xoff_rcvd pointer
putch_a:
    tst.b   (a0)
    bne.s   putch_a	    ; wait for xon
wait_for_tx_a:
    btst.b  #2,SRA
    beq.s   wait_for_tx_a   ; wait for xmit ready
    move.b  5(sp),TBA	    ; xmit character
    rts	

;-------------------------------- _putch_b() ---------------------------------
;
; _putch_b(short ch, char *p_xoff_rcvd)

__putch_b:
    move.l  6(sp),a0	    ; xoff_rcvd pointer
putch_b:
    tst.b   (a0)
    bne.s   putch_b	    ; wait for xon
wait_for_tx_b:
    btst.b  #2,SRB
    beq.s   wait_for_tx_b   ; wait for xmit ready
    move.b  5(sp),TBB	    ; xmit character
    rts	
