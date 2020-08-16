; uart306a.s
; Copyright 1994 by Sierra Systems.  All rights reserved.

    .opt    proc=68000

MR1A	= 0xfffff7e1
MR2A	= 0xfffff7e1
CSRA	= 0xfffff7e3
CRA	= 0xfffff7e5
ACR	= 0xfffff7e9
CUR	= 0xfffff7ed
MR1B	= 0xfffff7f1
MR2B	= 0xfffff7f1
CSRB	= 0xfffff7f3
CRB	= 0xfffff7f5

    .globl  __reset_a
    .globl  __reset_b
    .globl  __change_baud_set
    .globl  __change_baud_a
    .globl  __change_baud_b
    .globl  __change_length_parity_stop_a
    .globl  __change_length_parity_stop_b

    .text
    .align  2

;------------------------------- _reset_a() ----------------------------------
;
; _reset_a(short enabled)

__reset_a:
    move.b  #0x20,CRA	    ; reset receiver
    move.b  #0x30,CRA	    ; reset transmitter
    tst.w   4(sp)	    ; enable the port if enable is non-zero
    beq.s   return_a	    ; no
    move.b  #0x15,CRA	    ; reset mode register pointer -- enable Tx Rx
return_a:
    rts

;------------------------------- _reset_b() ----------------------------------
;
; _reset_b(short enabled)

__reset_b:
    move.b  #0x20,CRB	    ; reset receiver
    move.b  #0x30,CRB	    ; reset transmitter
    tst.w   4(sp)	    ; enable the port if enable is non-zero
    beq.s   return_b	    ; no
    move.b  #0x15,CRB	    ; reset mode register pointer -- enable Tx Rx
return_b:
    rts

;---------------------------- _change_baud_set() -----------------------------
;
; _change_baud_set(short set)

__change_baud_set:
    move.w  4(sp),d0
    cmpi.b  #2,d0
    beq.s   set_2
    move.b  #0x30,ACR
    rts
set_2:
    move.b  #0xb0,ACR
    rts

;----------------------------- _change_baud_a() ------------------------------
;
; _change_baud_a(short baud_code)

__change_baud_a:
    move.w  4(sp),d0
    move.b  d0,CSRA
    rts

;----------------------------- _change_baud_b() ------------------------------
;
; _change_baud_b(short baud_code)

__change_baud_b:
    move.w  4(sp),d0
    move.b  d0,CSRB
    rts

;------------------------ _change_length_parity_stop_a() ---------------------
;
; _change_length_parity_stop_a(short len_parity_code, short stop_bits_code)

__change_length_parity_stop_a:
    move.w  4(sp),d0		; len_parity_code argument
    move.w  6(sp),d1		; stop_bits_code argument
    move.b  #0x15,CRA		; reset mode register pointer and enable Tx Rx
    move.b  d0,MR1A		; set parity and length
    move.b  d1,MR2A		; set stop bits
    rts
    
;------------------------ _change_length_parity_stop_b() ---------------------
;
; _change_length_parity_stop_b(short len_parity_code, short stop_bits_code)

__change_length_parity_stop_b:
    move.w  4(sp),d0		; len_parity_code argument
    move.w  6(sp),d1		; stop_bits_code argument
    move.b  #0x15,CRB		; reset mode register pointer and enable Tx Rx
    move.b  d0,MR1B		; set parity and length
    move.b  d1,MR2B		; set stop bits
    rts
    
