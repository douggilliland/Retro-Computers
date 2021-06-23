;
;	Baed on the 6303 version except that we lack xgdx so it's a little
;	bit uglier
;
;	This is the classic division algorithm
;
;	On entry D holds the divisor and X holds the dividend
;
;	work = 0
;	loop for each bit in size (tracked in tmp)
;		shift dividend left (X/@tmp2)
;		rotate left into work (D)
;		set low bit of dividend (X/@tmp2)
;		subtract divisor (@tmp1) from work
;		if work < 0
;			add divisor (@tmp1) back to work
;			clear lsb of @tmp2/x
;		end
;	end loop
;
;	On exit X holds the quotient, D holds the remainder
;
;
	.export div16x16

	.code

div16x16:
	; TODO - should be we spot div by 0 and trap out ?
	staa @tmp1		; divisor
	stab @tmp2
	ldaa #16		; bit count
	staa @tmp		; counter
	clra
	clrb
	stx @tmp2
loop:
	asl @tmp2+1
	rol @tmp2
	rolb
	rola
	ldx @tmp2
	inx			; we know the low bit is currently 0
	subb @tmp1+1		; divisor
	sbca @tmp1
	bcc skip
	addb @tmp1+1
	adca @tmp1
	dex
skip:
	stx @tmp2
	dec tmp
	bne loop
	rts
