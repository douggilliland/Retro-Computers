;
;	There isn't a nice way to do this on 680x/630x.
;
;
	.export _memcpy

	.code

_memcpy:
	tsx
	ldaa	7,x
	ldab	8,x
	staa	@tmp		; destination
	stab	@tmp+1
	ldaa	3,x		; length
	ldab	4,x
	ldx	5,x		; src
	bsr	nextblock
	tsx
	ldaa	7,x
	ldab	8,x
	jmp	ret6

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
	stx	@tmp2
	ldx	@tmp
	staa	,x
	inx
	stx	@tmp
	ldx	@tmp2
	decb
	bne	tailcopy
	rts
