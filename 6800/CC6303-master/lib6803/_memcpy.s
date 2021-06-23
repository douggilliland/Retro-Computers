;
;	There isn't a nice way to do this on 680x/630x.
;
;
	.export _memcpy

	.setcpu 6803
	.code

_memcpy:
	tsx
	ldd	6,x
	std	@tmp		; destination
	ldd	2,x		; length
	ldx	4,x		; src
	bsr	nextblock
	tsx
	ldd	6,x
	rts

nextblock:
	tsta
	beq	tailcopy
	; Copy 256 bytes repeatedly until we get to the leftovers
	pshb
	psha
	clrb
	bsr	tailcopy
	pula
	pulb
	deca
	bra	nextblock

tailcopy:
	ldaa	,x
	inx
	pshx
	ldx	@tmp
	staa	,x
	inx
	stx	@tmp
	pulx
	decb
	bne	tailcopy
	rts
