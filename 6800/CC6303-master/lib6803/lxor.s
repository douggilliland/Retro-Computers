;
;	Based on the 6502 runtime. CC68 is a bit different as we've got
;	better operations
;

	.code
	.setcpu 6803

	.export tosxor0ax
	.export tosxoreax

tosxor0ax:
	clr	sreg
	clr	sreg+1
;
;	xor D and @sreg with the top of stack (3,X as called)
;
tosxoreax:
	tsx
	eora	4,x
	eorb	5,x
	std	@tmp
	ldd	@sreg
	eora	2,x
	eorb	3,x
	jmp	swap32pop4
