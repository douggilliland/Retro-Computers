*-----------------------------------------------------------
* Program    : TG68RAMTest
* Written by : Alastair M. Robinson
* Date       : 2012-12-08
* Description: Program to diagnose RAM problems.  Reports over RS232.
*-----------------------------------------------------------

STACK equ $7ffffe

PERREGS equ $81000000 ; Peripheral registers
SERPER equ $81000002
HEX equ $81000006 ; HEX display

PER_SPI equ $20
PER_SPI_BLOCKING equ $24
PER_SPI_CS equ $22
PER_CAP_FREQ equ $2A
PER_CAP_SPISPEED equ $2C
PER_SPI_PUMP equ $100
PER_TIMER_DIV7 equ $1e

CHARBUF equ $80000800

	ORG	$0
	dc.l	STACK		; Initial stack pointer
	dc.l	START

START:				; first instruction of program
	lea 	STACK,a7
	moveq	#0,d0
	move.w	PERREGS+PER_CAP_FREQ,d0	; Calculate serial speed from system clock frequency
	mulu	#1000,d0	; Freq is in Mhz/10, cancel out 100 from baud rate.
	divu	#1152,d0	; 115,200 baud.
	move.w	d0,SERPER
	move.w	#$2700,SR	; Disable all interrupts

	lea	startmessage,a0
	bsr	Writeserial

mainloop
	move.b	#'a',PERREGS;
	bsr	TestRAM_b
	move.b	#'b',PERREGS
	bsr	TestRAM_l
	move.b	#'c',PERREGS
	bsr	TestRAM_byte
	move.b	#'d',PERREGS
	bsr	TestRAM_AddWord
	move.b	#'e',PERREGS
	bsr	TestRAM_AddByte

	bra	mainloop


TestRAM_b
	lea	$0ffff2,a0
	lea $15a5aa,a1
	move.l	#$7fff,d0
.mainloop
	move.l	d0,a2
	move.l	#$003c0089,d7
	move.l	#$004d009a,d6
	move.l	#$005a005a,d5
	move.l	#$00c300c3,d4
	movem.l	d4-d7,(a0)
	movem.l	d4-d7,$33c8(a1)
	movem.l	d4-d7,$153c(a0)
	movem.l	d4-d7,$124(a1)
	movem.l	d4-d7,$7c8(a0)
	movem.l	d4-d7,$(a1)

	movem.l	(a0),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail

	movem.l	$33c8(a1),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail


	movem.l	$153c(a0),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail

	movem.l	$124(a1),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail


	movem.l	$7c8(a0),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail

	movem.l	$(a1),d0-d3
	and.l	#$ff00ff,d0
	cmp.l	d0,d4
	bne	.fail
	and.l	#$ff00ff,d1
	cmp.l	d1,d5
	bne	.fail
	and.l	#$ff00ff,d2
	cmp.l	d2,d6
	bne	.fail
	and.l	#$ff00ff,d3
	cmp.l	d3,d7
	bne	.fail

	add.l	#$539c,a0
	add.l	#$75aa,a1
	move.l	a2,d0
	dbf	d0,.mainloop
	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.l	#$ff,d0
	move.w	#$ffff,HEX
	lea	failmessage_b,a0
	bsr	Writeserial
	tst.w d0
	rts


TestRAM_l
	lea	$0ffff2,a0
	lea $15a5aa,a1
	move.l	#$1e3c5a789,d7
	move.l	#$2f4d6b89a,d6
	move.l	#$5a5a5a5a5,d5
	move.l	#$c3c3c3c3c,d4
	move.l	#$7fff,d0
.mainloop
	move.l	d0,a2
	movem.l	d4-d7,(a0)
	movem.l	d4-d7,$33c8(a1)
	movem.l	d4-d7,$153c(a0)
	movem.l	d4-d7,$124(a1)
	movem.l	d4-d7,$7c8(a0)
	movem.l	d4-d7,$(a1)

	movem.l	(a0),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail

	movem.l	$33c8(a1),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail


	movem.l	$153c(a0),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail

	movem.l	$124(a1),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail


	movem.l	$7c8(a0),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail

	movem.l	$(a1),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail

	add.l	#$18,a0
	add.l	#$18,a1
	move.l	a2,d0
	dbf	d0,.mainloop

	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.w	#$ffff,HEX
	lea	failmessage_l,a0
	bsr	Writeserial
	move.l	#$ff,d0
	tst.w 	d0
	rts


TestRAM_byte
	lea	$100000,a0
	lea	$180002,a1
	move.l	#$ffff,d0
.mainloop
	move.b	#$12,(a0)
	move.b	#$34,2(a0)
	move.b	#$56,2(a1)
	move.b	#$78,1(a1)
	move.b	#$ab,1(a0)
	move.b	#$cd,3(a0)
	move.b	#$ef,(a1)
	move.b	#$90,3(a1)
	move.l	(a0)+,d1
	move.l	(a1)+,d2
	cmp.l	#$12ab34cd,d1
	bne	.fail
	cmp.l	#$ef785690,d2
	bne	.fail

	dbf	d0,.mainloop

	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.w	#$ffff,HEX
	lea	failmessage_byte,a0
	bsr	Writeserial
	move.l	#$ff,d0
	tst.w 	d0
	rts


TestRAM_byte2
	lea	$100000,a0
	lea	$180002,a1
	move.l	#$ffff,d0
.mainloop
	move.l	#$12345678,(a0)
	move.l	#$fedcba98,(a1)
	move.b	#$fe,(a0)
	move.l	(a0),d1
	move.b	#$78,(a0)
	move.b	#$fe,3(a0)
	move.l	(a0),d2

	move.b	#$45,(a1)
	move.l	(a1),d3
	move.b	#$78,(a1)
	move.b	#$78,3(a1)
	move.l	(a1),d4

	cmp.l	#$fe345678,d1
	bne	.fail
	cmp.l	#$783456fe,d2
	bne	.fail

	cmp.l	#$45fcba98,d3
	bne	.fail
	cmp.l	#$78dcba78,d2
	bne	.fail

	dbf	d0,.mainloop

	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.w	#$ffff,HEX
	lea	failmessage_byte2,a0
	bsr	Writeserial
	move.l	#$ff,d0
	tst.w 	d0
	rts


TestRAM_AddByte
	lea	$100000,a0
	lea	$180002,a1
	move.l	#$ffff,d0
.mainloop
	move.l	#$11112222,d3
	move.l	#$fedcba98,d4
	move.l	d3,(a0)
	move.l	d4,(a1)
	add.b	#$12,(a0)
	add.b	#$56,3(a0)
	add.b	#$12,2(a1)
	add.b	#$78,1(a1)
	add.b	#$56,d3
	add.l	#$12000000,d3
	add.w	#$1200,d4
	rol.l	#8,d4
	add.l	#$78000000,d4
	ror.l	#8,d4
	move.l	(a0)+,d1
	move.l	(a1)+,d2

	cmp.l	d3,d1
	bne	.fail
	cmp.l	d4,d2
	bne	.fail

	dbf	d0,.mainloop

	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.w	#$ffff,HEX
	lea	failmessage_addbyte,a0
	bsr	Writeserial
	move.l	#$ff,d0
	tst.w 	d0
	rts


TestRAM_AddWord
	lea	$100000,a0
	lea	$180002,a1
	move.l	#$ffff,d0
.mainloop
	move.l	#$11112222,d3
	move.l	#$fedcba98,d4
	move.l	d3,(a0)
	move.l	d4,(a1)
	add.w	#$1234,(a0)
	add.w	#$5678,2(a0)
	add.w	#$1234,(a1)
	add.w	#$5678,2(a1)
	add.w	#$5678,d3
	add.l	#$12340000,d3
	add.w	#$5678,d4
	add.l	#$12340000,d4
	move.l	(a0)+,d1
	move.l	(a1)+,d2

	cmp.l	d3,d1
	bne	.fail
	cmp.l	d4,d2
	bne	.fail

	dbf	d0,.mainloop

	moveq	#0,d0
	tst.w	d0
	rts

.fail
	move.w	#$ffff,HEX
	lea	failmessage_addword,a0
	bsr	Writeserial
	move.l	#$ff,d0
	tst.w 	d0
	rts



_Putcserial
	swap	d0
.wait
	move.w	PERREGS,d0
	btst	#8,d0
	beq	.wait
	swap	d0
	move.w	d0,PERREGS
	rts

	btst	#9,PERREGS
Writeserial	; A0 - string to be written
	move.l	d0,-(a7)
	moveq	#0,d0
.wsloop
	move.w	PERREGS,d0
	btst	#8,d0
	beq		.wsloop
	move.b	(a0)+,d0
	beq .done
	move.w	d0,PERREGS
	bra	.wsloop
.done
	move.l (a7)+,d0
	rts

startmessage
	dc.b	"RAMTest firmware launching...\n\r",0
failmessage_l
	dc.b	"Longword test failed\n\r",0
failmessage_b
	dc.b	"Masked longword test failed\n\r",0
failmessage_byte
	dc.b	"Byte test failed\n\r",0
failmessage_byte2
	dc.b	"Byte2 test failed\n\r",0
failmessage_addword
	dc.b	"AddWord test failed\n\r",0
failmessage_addbyte
	dc.b	"AddByte test failed\n\r",0

