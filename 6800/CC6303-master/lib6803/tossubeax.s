;
;	Subtract sreg:d from the top of stack
;

	.export tossubeax

	.setcpu 6803
	.code

tossubeax:
	tsx
	std @tmp		; save the low 16bits to subtract
	ldd 4,x			; low 16 of TOS
	subd @tmp		; subtract the low 16
	std @tmp		; remember it
	ldd 2,x			; top 16 of TOS
	sbcb @sreg+1		; no sbcd so do this in 8bit chunks
	sbca @sreg		; D is now sreg - 3,X
	std @sreg		; save the new top 16bits
	ldd @tmp		; recover the value for D
	jmp pop4		; and fix up the stack
