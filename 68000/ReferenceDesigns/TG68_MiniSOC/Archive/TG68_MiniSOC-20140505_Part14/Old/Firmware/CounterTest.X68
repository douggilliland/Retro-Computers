*-----------------------------------------------------------
* Program    :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$10000
HEX equ	$810006

START:				; first instruction of program
	addq.l	#1,d0
	move.w	d0,HEX
	bra	START

	END	START		; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
