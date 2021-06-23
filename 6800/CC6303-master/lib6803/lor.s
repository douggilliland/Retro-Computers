;
;	Based on the 6502 runtime. CC68 is a bit different as we've got
;	better operations
;

	.code
	.setcpu 6803

	.export tosor0ax
	.export tosoreax

tosor0ax:
	clr	sreg
	clr	sreg+1
;
;	or D and @sreg with the top of stack (3,X as called)
;
tosoreax:
	tsx
	oraa	4,x
	orab	5,x
	std	@tmp
	ldd	@sreg
	oraa	2,x
	orab	3,x
	jmp	swap32pop4
