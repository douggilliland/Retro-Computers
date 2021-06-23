;
;	This algorithm is taken from the manual
;
;	This is the classic division algorithm
;
;	On entry D holds the divisor and X holds the dividend
;
;	work = 0
;	loop for each bit in size (tracked in tmp)
;		shift dividend left (X)
;		rotate left into work (D)
;		set low bit of dividend (X)
;		subtract divisor (@tmp1) from work
;		if work < 0
;			add divisor (@tmp1) back to work
;			clear lsb of X
;		end
;	end loop
;
;	On exit X holds the quotient, D holds the remainder
;
;
	.export div16x16
	.setcpu 6303

	.code

div16x16:
	; TODO - should be we spot div by 0 and trap out ?
	std @tmp1		; divisor
	ldaa #16		; bit count
	staa @tmp		; counter
	clra
	clrb
loop:
	xgdx
	asld			; shift X left one bit at a time (dividend)
	xgdx
	rolb
	rola
	inx
	subd @tmp1		; divisor
	bcc skip
	addd @tmp1
	dex
skip:
	dec tmp
	bne loop
	rts
