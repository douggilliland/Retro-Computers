;
;	6803 lacks xgdx... 6800 lacks pulx
;
;	Swap top of stack and AB
;
	.code
	.export swapstk

swapstk:
	tsx		; This 4 instruction sequence
	ldx ,x		; is effectively pulx
	ins
	ins
	stx @tmp
	psha
	pshb
	ldaa @tmp
	ldab @tmp+1
	rts
