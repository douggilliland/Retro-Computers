;
;	Add top of stack to 32bit working accumulator, removing it from
;	the stack
;

	.code
	.export tosadd0ax
	.export tosaddeax

tosadd0ax:
	clr	sreg
	clr	sreg+1
tosaddeax:
	tsx
	addb	5,x
	adca	4,x
	staa	@tmp
	stab	@tmp+1
	ldab	3,x
	adcb	@sreg+1
	ldaa	2,x
	adca	@sreg
	staa	@sreg
	stab	@sreg+1
	ldaa	@tmp
	ldab	@tmp+1
	jmp	pop4
