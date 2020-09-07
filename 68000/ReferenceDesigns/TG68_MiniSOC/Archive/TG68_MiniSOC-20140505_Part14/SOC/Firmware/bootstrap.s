*-----------------------------------------------------------
* Program    : TG68SerialBootstrap
* Written by : Alastair M. Robinson
* Date       : 2012-06-23
* Description: Program to bootstrap the TG68 project over RS232.  Receives an S-Record.
*-----------------------------------------------------------

STACK equ $7ffffe

PERREGS equ $81000000 ; Peripheral registers
SERPER equ $81000002
PER_CAP_FREQ equ $2A
HEX equ $81000006 ; HEX display
CHARBUF equ $80000800

	ORG	$0
	dc.l	STACK		; Initial stack pointer
	dc.l	START

START:				; first instruction of program
	lea	STACK,a7
	moveq.l	#0,d0
	move.w	PERREGS+PER_CAP_FREQ,d0	; Calculate serial speed from system clock frequency
	mulu	#1000,d0	; Freq is in Mhz/10, cancel out 100 from baud rate.
	divu	#1152,d0	; 115,200 baud.
	move.w	d0,SERPER
	move.w	#$2700,SR	; Disable all interrupts

	move.w	#0,SREC_COLUMN
	lea	CHARBUF,a5
.mainloop
	move.w	PERREGS,d0
	btst	#9,d0		; Rx intterupt?
	beq.b	.mainloop
	move.w	#$55aa,HEX
	move.b	d0,(a5)+
	bsr.b	HandleByte
	bra.b	.mainloop

	
Crash
	rte

	; FIXME - move these into character RAM for safe keeping?
SREC_BYTECOUNT	equ $ffff8
SREC_COLUMN equ $ffff6
SREC_ADDR equ $ffff2
SREC_TYPE equ $fffee
SREC_ADDRSIZE equ $fffea
SREC_COUNTER equ $fffe8 ; counts from 7 down to 0 to count the shifts required for each longword before bumping the address.


	; Stores temporary value in d6 and d7 to avoid having to read from overlaid RAM.
	
DoDecode		; Takes address of longword in A0, rotates 4 bits left and ors in the decoded nybble.
	and.l	#$df,d0	; To upper case, if necessary - numbers are now 16-25
	sub.b	#55,d0	; Map 'A' onto decimal 10.
	bpl.b	.washex		; If negative, then digit was a number.
	add.b	#39,d0	; map '0' onto 0.
.washex
	lsl.l	#4,d6
	or.b	d0,d6
	move.l	d6,(a0)
	rts

DoDecodeByte	; Takes address of longword in A0, rotates 4 bits left and ors in the decoded nybble.
	and.l	#$df,d0	; To upper case, if necessary - numbers are now 16-25
	sub.b	#55,d0	; Map 'A' onto decimal 10.
	bpl.b	.washex		; If negative, then digit was a number.
	add.b	#39,d0	; map '0' onto 0.
.washex

	lsl.b	#4,d7
	or.b	d0,d7
	move.b	d7,(a0)
	rts


HandleByte
;	move.w	PERREGS,d0	; Read data - low byte contains character from UART
	addq.w	#1,SREC_COLUMN

	cmp.b	#'S',d0		; First byte of a record is S - reset column counter.
	bne.b	.nots
	move.w	#$FFFF,HEX	; Debug
	moveq.l	#0,d1
	move.l	d1,d7		; Accumulator for byte values
	move.l	d1,d6		; Accumulator for longword values
	move.w	d1,SREC_COLUMN
	move.l	d1,SREC_ADDR
	move.l	d1,SREC_BYTECOUNT
	move.l	d1,SREC_TYPE
	bra.w	.end

.nots
	cmp.w	#1,SREC_COLUMN	; record type, high nybble
	move.b	#'C',(a5)+
	move.b	SREC_COLUMN+1,(a5)
	add.b	#'0',(a5)+
	move.b	#' ',(a5)+

	bne.b	.nottype
	move.w	#$FFFE,HEX	; Debug
	lea	SREC_TYPE+3,a0

	move.b	#'T',(a5)+
	move.b	d0,(a5)+

	bsr.s	DoDecodeByte	; Called once, should result in type being in the lowest nybble bye of SREC_TYPE
	move.l	SREC_TYPE,d1

	move.b	#'0',(a5)
	add.b	#1,(a5)+

	cmp.l	#3,d1
	ble.s	.dontinvert
	moveq.l	#10,d1
	sub.l	SREC_TYPE,d1 ; Just to be awkward, S7 has 32-bit addr, S8 has 24 and S9 has 16!
.dontinvert
	addq.l	#1,d1
	lsl.l	#1,d1
	move.l	d1,SREC_ADDRSIZE ; Addr_Size is now 4, 6 or 8, depending on whether the address field is 16, 24 or 32 bits long.
	bra.w	.end

.nottype
	move.w	SREC_TYPE+2,HEX	; Debug

	tst.l	SREC_TYPE
	beq.w	.end	; Ignore type 0 records
	cmp.l	#9,SREC_TYPE ; Ignore record types greater than 9.
	bgt.w	.nottype1 ; Type 1 2 or 3 have data.  Types 7, 8 and 9 have address. 

	cmp.w	#3,SREC_COLUMN	; Byte count
	bgt.b	.notbc
	lea	SREC_BYTECOUNT+3,a0
	bsr.w	DoDecodeByte	; Called twice, should result in bytecount being in the low byte of SREC_BYTECOUNT
	move.w	SREC_BYTECOUNT+2,HEX
	bra.w	.end
	
.notbc	; extract the address
	move.l	SREC_ADDRSIZE,d1
	addq.w	#3,d1
	move.w	SREC_COLUMN,d2
	cmp.w	d1,d2
	bgt.b	.notaddr
	lea	SREC_ADDR,a0
	bsr.w	DoDecode	; Called 2, 3 or 4 times, depending upon the number of address bits.
	move.w	SREC_ADDR+2,HEX
	move.w	#1,SREC_COUNTER
	bra.w	.end
.notaddr
	; Now for the actual data....
	cmp.l	#3,SREC_TYPE	; Only types 1, 2 and 3 have data...
	bgt.b	.nottype1

	move.l	SREC_BYTECOUNT,d1
	lsl.l	#1,d1	; Two characters for each output byte
	addq.l	#1,d1
	move.w	SREC_COLUMN,d2
	cmp.w	d1,d2
	bgt.b	.finishtype1

	move.l	SREC_ADDR,a0
	bsr.w	DoDecodeByte
	move.w	d7,HEX
	move.w	SREC_COUNTER,d1
	subq.w	#1,SREC_COUNTER
	subq.w	#1,d1
	bpl		.end
	addq.l	#1,SREC_ADDR
	move.w	#1,SREC_COUNTER
	bra.b	.end	

.finishtype1
	move.w	#$FFEF,HEX	; Debug
	move.w	SREC_COUNTER,d0
	addq.w	#1,d0
	and.w	#1,d0
	beq.b	.end
	move.l	SREC_ADDR,a0
	lsl.l	#2,d0
;	move.l	(a0),d1
;	lsl.l	d0,d1
;	move.l	d1,(a0)
	lsl.b	d0,d7
	move.b	#'W',(a5)+
	move.b	#' ',(a5)+
	move.b	d7,(a0)
	
.nottype1
	move.b	#'z',(a5)+
	move.w	#$FFEE,HEX	; Debug
	cmp.l	#7,SREC_TYPE
	blt.b	.end
	move.b	#'Z',(a5)+
	move.w	#$FFED,HEX	; Debug
	cmp.l	#9,SREC_TYPE
	bgt.b	.end
	move.b	#'T',(a5)+
	move.b	#'9',(a5)+
	move.w	#$FFEC,HEX	; Debug
	move.l	SREC_ADDR,(a7)	; Jump to the newly downloaded address...
	bclr	#0,PERREGS+4	; Disable ROM overlay
	rts			; Should be in prefetch, so will be executed even though the ROM's vanished.

.end
	rts

	END	START		; last line of source
