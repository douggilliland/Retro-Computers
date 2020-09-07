*-----------------------------------------------------------
* Program    : TG68TestFirmware
* Written by : Alastair M. Robinson
* Date       : 2012-05-22
* Description: Simple program to test the TG68 processor.
*-----------------------------------------------------------

TEXTBUFFERPTR equ $ffff6	; Word
FRAMECOUNTER equ $ffff8
RANDOMSEED equ $ffffa
PEN equ $ffffe
FRAMEBUFFER equ	$100000
FB_WIDTH equ 640
FB_HEIGHT equ 960

STACK equ $7ffffe

VGAREGS equ $800000
TEXTBUFFER equ $800800	; 2048 bytes

PERREGS equ $810000 ; Peripheral registers
HEX equ $810006
TIMERCON equ $81000e ; Timer control reg
TIMER0DIV equ $810010
TIMER1DIV equ $810012
TIMER2DIV equ $810014
TIMER3DIV equ $810016

SPRITEBUFFER equ $ff000	; Sprite data (can't reference from ROM unless we copy the ROM to RAM at startup...)

FBPTH equ $0000	; Framebuffer pointer - must be 64-bit aligned.
FBPTL equ $0002

SP0PTH equ $0100 ; Pointer to sprite 0's data - must be 64-bit aligned.
SP0PTL equ $0102
SP0XPOS	equ $0104
SP0YPOS equ $0106


	ORG	$0
	jmp	START
	
	ORG	$0060
	dc.l	Crash
	dc.l	Int1
	dc.l	Int2
	dc.l	Int3
	dc.l	Int4
	dc.l	Int5
	dc.l	Int6	
	dc.l	Int7

	ORG	$10000
MyMessage
	dc.b	'Hello World!  Just a quick test to see whether loading the character RAM from the processor is working properly!',0,0

START:				; first instruction of program
	lea	STACK,a7
	
	move.w	#$4000,TIMER1DIV
	move.w	#$5000,TIMER2DIV
	move.w	#$0060,TIMERCON	; Enable interrupt for Timer 1

	lea	TextBuffer,a1
	lea	MyMessage,a0
	bsr	_strcpy

	lea	FRAMEBUFFER,a0	; Set initial framebuffer pointer.
	lea	VGAREGS,a6
	move.l	a0,(FBPTH,a6)

	move.w	#0,FRAMECOUNTER
	move.w	#0,TEXTBUFFERPTR

	bsr	CopySprite

	move.w	#$2000,SR	; Enable all interrupts

	move.w	#$0,pen
	bsr	FillScreen

	move.l	#0,d0
	move.l	#1,d1
.mainloop
	add.w	#1,pen
	bsr	Random
	move.l	d0,d3
	bsr	Random
	move.l	d0,d2
	bsr	Random
	move.l	d0,d1
	bsr	Random

	divu	#FB_WIDTH-1,d0
	clr.w	d0
	swap	d0

	divu	#FB_HEIGHT-1,d1
	clr.w	d1
	swap	d1
	
	move.l	#FB_WIDTH-1,d4
	sub.l	d0,d4
	divu	d4,d2
	clr.w	d2
	swap	d2
	
	move.l	#FB_HEIGHT-1,d4
	sub.l	d1,d4
	divu	d4,d3
	clr.w	d3
	swap	d3
	
	addq	#1,d2
	addq	#1,d3
	lea	FrameBuffer,a0
	bsr	DrawRectangle
	bra	.mainloop

	MOVE.B	#9,D0
	TRAP	#15		; halt simulator


Plot				; X: d0, y: d1
	movem.l	a0/d0-d1,-(a7)
	lea	FRAMEBUFFER,a0
	mulu	#FB_WIDTH*2,d1
	asl.l	#1,d0
	add.l	d1,d0
	add.l	d0,a0
	move.w	pen,(a0)
	movem.l	(a7)+,a0/d0-d1
	rts


Random
	movem.l	d1-d2,-(a7)
	move.l	#16807,d0
        move.l  d0,d2
        mulu    RANDOMSEED+2,d0

        move.l  d0,d1
        sub.w	d1,d1
        swap    d1
        mulu    RANDOMSEED,d2
        add.l   d1,d2

        move.l 	d2,d1
        add.l	d1,d1
        clr.w	d1
        swap    d1

        and.l   #$0000FFFF,d0
        and.l   #$7FFFFFFF,d0
        and.l   #$00007FFF,d2
        swap    D2
        add.l   D1,D2
        add.l   D2,D0

        bpl	.upd
        add.l   #$7FFFFFFF,d0
.upd	move.l  d0,RANDOMSEED
	swap	d0
	move.w	#0,d0
	swap	d0
	movem.l	(a7)+,d1-d2
        rts
        
	nop	; longword align inner loop

DrawRectangle	; d0: x, d1: y, d2: w, d3: h, a0: framebuffer
	movem.l	d1-d5,-(a7)
	add.l	d1,d1
	mulu	#FB_WIDTH,d1	; y offset
	add.l	d1,a0
	add.l	d0,d0
	add.l	d0,a0		; x offset
	move.l	#FB_WIDTH,d0
	sub.l	d2,d0		; modulo
	add.l	d0,d0
	
	move.w	pen,d4
.yloop
	move.l	d2,d1
.xloop
	move.w	d4,(a0)+
	subq.w	#1,d1
	bne	.xloop

	add.l	d0,a0		; Add modulo

	subq.w	#1,d3
	bne	.yloop

	movem.l	(a7)+,d1-d5
	rts


FillScreen
	movem.l	a0-a4/d1-d4,-(a7)
	lea	FRAMEBUFFER,a0
	move.l	#FB_HEIGHT,d0
	mulu	#FB_WIDTH,d0
	add.l	d0,a0
	add.l	d0,a0		; Point to end of buffer
	lsr.l	#4,d0		; We're moving 16 bytes at a time
	move.w	pen,d1
	swap	d1
	move.w	pen,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
.fillloop
	movem.l	a1-a4/d1-d4,-(a0)
	sub.l	#1,d0
	bne	.fillloop
	movem.l	(a7)+,a0-a4/d1-d4
	rts


CopySprite:	; Copy sprite data
	movem.l	a0-a1/d0,-(a7)
	lea	SpriteData,a0
	lea	SPRITEBUFFER,a1
	moveq.l	#15,d0
.cpyloop
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.cpyloop
	lea	VGAREGS,a0
	lea	SPRITEBUFFER,a1
	move.l	a1,(SP0PTH,a0)
	movem.l	(a7)+,a0-a1/d0
	rts


SpriteData:
	dc.l	$CF000000,$00000000
	dc.l	$8CFFF000,$00000000
	dc.l	$08CCFFF0,$00000000
	dc.l	$08CCCCFF,$FF000000
	dc.l	$088CCCCC,$CFFF0000
	dc.l	$008CCCCC,$CCC80000
	dc.l	$0088CCCC,$CC800000
	dc.l	$0008CCCC,$CF000000
	dc.l	$0008CCCC,$CCF00000
	dc.l	$00088CC8,$CCCF0000
	dc.l	$00008C80,$8CCCF000
	dc.l	$00008800,$08CCCF00
	dc.l	$00000000,$008CCCF0
	dc.l	$00000000,$0008CCC8
	dc.l	$00000000,$00008C80
	dc.l	$00000000,$00000800


Crash
	rte

int1	; Vertical Blank Interrupt
	movem.l	a0-a1/d0-d1,-(a7)

	move.w	FRAMECOUNTER,d0
	addq.w	#1,d0
	cmp.w	#960,d0
	bne	.skip
	move.w	#0,d0
.skip
	move.w	d0,FRAMECOUNTER
	cmp.w	#480,d0
	blt	.skip2
	sub.w	#960,d0
	neg.w	d0
.skip2
	move.w	d0,d1
	mulu	#(FB_WIDTH*2),d0
	add.l	#FRAMEBUFFER,d0
	lea	VGAREGS,a0
	move.l	d0,(FBPTH,a0)

	move.w	d1,(SP0XPOS,a0)
	move.w	d1,(SP0YPOS,a0)

	lea	SPRITEBUFFER,a1
	move.l	a1,(SP0PTH,a0)

	movem.l	(a7)+,a0-a1/d0-d1
	rte


_strcpy	; A0: src, A1: dst
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	bne	_strcpy
	rts
	

int2	; UART interrupt
	movem.l	d0-d1/a0,-(a7)
	move.w	PERREGS,d0	; Read data - low byte contains character from UART
	btst	#9,d0		; Rx intterupt?
	beq	.skip
	moveq.l	#0,d1
	move.w	TEXTBUFFERPTR,d1
	lea	TEXTBUFFER,a0
	move.b	d0,(a0,d1)
	addq.w	#1,d1
	and.w	#$7ff,d1	; 2048 byte buffer
	move.w	d1,TEXTBUFFERPTR
	move.w	d0,PERREGS	; Echo received byte back to terminal.
.skip
	movem.l	(a7)+,d0-d1/a0
	rte

int3
	move.w	d0,-(a7)
	move.w	TIMERCON,d0
	move.w	d0,HEX
	btst	#1,d0
	beq	.skip
	neg.w	PEN
.skip
	move.w	(a7)+,d0
	rte

int4
	rte

int5
	rte

int6
	rte

int7
	rte


	END	START		; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
