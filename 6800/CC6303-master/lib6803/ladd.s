;
;	Add top of stack to 32bit working accumulator, removing it from
;	the stack
;

	.setcpu 6803

	.code
	.export tosadd0ax
	.export tosaddeax

tosadd0ax:
	clr	sreg
	clr	sreg+1
tosaddeax:
	tsx
	addd	4,x
	std	@tmp
	ldab	3,x
	adcb	@sreg+1
	ldaa	2,x
	adca	@sreg
	std	@sreg
	ldd	@tmp
	jmp	pop4
