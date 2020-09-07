TEXTBUFFER equ $800800	; 2048 bytes

PERREGS equ $810000 ; Peripheral registers
SERPER equ 2

PLLCONF = $26	; Bit 0, nudge PLL phase for low byte by one notch
				; Bit 1, nudge PLL phase for high byte by once notch
				; Bit 15, direction of nudge.  0: Forward, 1: back


	org 0
	dc.l	TEXTBUFFER+2040	; Put the stack in the textbuffer; we don't want to write to SDRAM if we can avoid it.
	dc.l	Start

			; Need to check a few words of memory for reliability, and trim the PLLs for best phase alignment.
			; We have a separate PLL for the high and low bytes of each word, so test separately.

Count	equ TEXTBUFFER+2044

START:				; first instruction of program
	lea	TEXTBUFFER+2044,a7 -- Stack
	move.w	#$364,PERREGS+SERPER
	move.w	#$43,PERREGS
	move.w	#$2700,SR	; Disable all interrupts

Start
	move.w	#0,Count	; Clear counter
	move.l	#$1e3c5a789,d7
	move.l	d7,d3
	move.l	#$2f4d6b89a,d6
	move.l	d6,d2
	move.l	#$5a5a5a5a5,d5
	move.l	d5,d1
	move.l	#$c3c3c3c3c,d4
	move.l	d4,d0
lowmainloop
	move.w	PERREGS,d0	; Wait for serial port
	btst	#8,d0
	beq		lowmainloop

	lea	$100000,a0
	lea	$3ffffe,a1
	movem.l	d4-d7,(a0)
	movem.l	d4-d7,(a1)
	movem.l	(a0),d0-d3
	cmp.b	d0,d4
	bne	.fail
	cmp.b	d1,d5
	bne	.fail
	cmp.b	d2,d6
	bne	.fail
	cmp.b	d3,d7
	bne	.fail
	swap	d0
	swap	d4
	cmp.b	d0,d4
	bne	.fail
	swap	d1
	swap	d5
	cmp.b	d1,d5
	bne	.fail
	swap	d2
	swap	d6
	cmp.b	d2,d6
	bne	.fail
	swap	d3
	swap	d7
	cmp.b	d3,d7
	bne	.fail

	swap d4
	swap d5
	swap d6
	swap d7
	movem.l	(a1),d0-d3
	cmp.b	d0,d4
	bne	.fail
	cmp.b	d1,d5
	bne	.fail
	cmp.b	d2,d6
	bne	.fail
	cmp.b	d3,d7
	bne	.fail
	swap	d0
	swap	d4
	cmp.b	d0,d4
	bne	.fail
	swap	d1
	swap	d5
	cmp.b	d1,d5
	bne	.fail
	swap	d2
	swap	d6
	cmp.b	d2,d6
	bne	.fail
	swap	d3
	swap	d7
	cmp.b	d3,d7
	bne	.fail


	add.w	#1,Count	; Test was successful - increment counter and start again.
	move.w	#1,PERREGS+PLLCONF	; Nudge the PLL phase by one step
	move.w	#'A',PERREGS
	bra	lowmainloop

.fail
	cmp.w	#0,Count	; Test failed - have we found any settings that work yet?
	bne	.backtrack	; Yes?  Backtrack
					; No? Keep looking
	move.w	#1,PERREGS+PLLCONF	; Nudge the PLL phase by one step
	move.w	#'a',PERREGS
	bra lowmainloop
	
.backtrack					; Backtrack by 50%, so hopefully we'll park the PLL in the middle of the usable band.
	move.w	Count,d0
	lsr.l	#1,d0
.setloop_low
	move.w	#$8001,PERREGS+PLLCONF	; Nudge the PLL phase by one negative step.
	dbf d0,.setloop_low

						; The PLL for low bytes should now be well set up, so adjust the high byte PLL.

highmainloop
	move.w	PERREGS,d0	; Wait for serial port
	btst	#8,d0
	beq		highmainloop
	lea	$100000,a0
	lea	$3ffffe,a1
	movem.l	d4-d7,(a0)
	movem.l	d4-d7,(a1)
	movem.l	(a0),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail

	movem.l	(a1),d0-d3
	cmp.l	d0,d4
	bne	.fail
	cmp.l	d1,d5
	bne	.fail
	cmp.l	d2,d6
	bne	.fail
	cmp.l	d3,d7
	bne	.fail


	add.w	#1,Count	; Test was successful - increment counter and start again.
	move.w	#2,PERREGS+PLLCONF	; Nudge the PLL phase by one step
	move.w	#'B',PERREGS
	bra	highmainloop

.fail
	cmp.w	#0,Count	; Test failed - have we found any settings that work yet?
	bne		.backtrack	; Yes?  Backtrack
						; No?  Keep looking
	move.w	#2,PERREGS+PLLCONF	; Nudge the PLL phase by one step
	move.w	#'b',PERREGS
	bra	highmainloop

.backtrack					; Backtrack by 50%, so hopefully we'll park the PLL in the middle of the usable band.
	move.w	Count,d0
	lsr.l	#1,d0
.setloop_high
	move.w	#$8002,PERREGS+PLLCONF	; Nudge the PLL phase by one negative step.
	dbf d0,.setloop_high

.done
	bra .done

