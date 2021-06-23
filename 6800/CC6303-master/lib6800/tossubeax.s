;
;	Subtract sreg:d from the top of stack
;

	.export tossubeax

	.code

tossubeax:
	tsx
	staa @tmp
	stab @tmp+1		; save the low 16bits to subtract
	ldaa 4,x
	ldab 5,x		; low 16 of TOS
	subb @tmp+1		; subtract the low 16
	sbca @tmp
	staa @tmp		; remember it
	stab @tmp+1
	ldaa 2,x		; top 16 of TOS
	ldab 3,x
	sbcb @sreg+1		; no sbcd so do this in 8bit chunks
	sbca @sreg		; D is now sreg - 3,X
	staa @sreg		; save the new top 16bits
	stab @sreg+1
	ldaa @tmp		; recover the value for D
	ldab @tmp+1
	jmp pop4		; and fix up the stack
