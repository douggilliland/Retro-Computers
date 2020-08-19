*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$0
	dc.l	$7ffffe
	dc.l	START
	org	$100
START:				; first instruction of program
	lea	$7ffffe,a7
	moveq.l	#0,d0
.outerloop
	move.l	d0,d1
	move.l	#$7ffff,d3
	lea	$100000,a0
.innerloop
	move.w	d1,(a0)+
	addq.w	#1,d1
	sub.l	#1,d3
	bne	.innerloop
	addq.l	#1,d0
	bra	.outerloop

	END	START		; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
