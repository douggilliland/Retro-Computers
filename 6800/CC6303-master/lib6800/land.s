;
;	Based on the 6502 runtime. CC68 is a bit different as we've got
;	better operations
;

	.code

	.export tosand0ax
	.export tosandeax

tosand0ax:
	clr	sreg
	clr	sreg+1
;
;	and D and @sreg with the top of stack (3,X as called)
;
tosandeax:
	tsx
	anda	4,x
	andb	5,x
	staa	@tmp
	ldaa	@sreg
	stab	@tmp+1
	ldab	@sreg+1
	anda	2,x
	andb	3,x
	jmp	swap32pop4
