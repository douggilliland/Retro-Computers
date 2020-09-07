*-----------------------------------------------------------
* Program    : KbdTest
* Written by : Alastair M. Robinson
* Date       : 2012-06-30
* Description: Simple program to test the TG68 processor and surrounding SOC.
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

KBD equ $810008
MOUSE equ $81000A

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

START:				; first instruction of program
	lea	STACK,a7
	move.w	#$2000,SR	; Enable all interrupts
	move.w	#$f4,MOUSE	; Turn on mouse reporting

.mainloop
	bra	.mainloop


Crash
	rte

int1	; Vertical Blank Interrupt
	rte


_strcpy	; A0: src, A1: dst
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	bne	_strcpy
	rts
	

int2	; UART interrupt
	rte

int3
	rte

int4	; Keyboard / mouse interrupt
	movem.w	d0-d1,-(a7)
	move.w	MOUSE,d0
	lsl.w	#8,d0
	move.w	KBD,d1
	move.b	d1,d0
	move.w	d0,HEX
	movem.w	(a7)+,d0-d1
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
