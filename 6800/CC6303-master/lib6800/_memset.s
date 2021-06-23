
	.export _memset

	.code

_memset:
	tsx
	ldaa	4,x
	ldab	5,x
	stab	@tmp		; destination
	ldaa	2,x		; length
	ldab	3,x
	ldx	6,x		; destination
	bsr	nextblock
	tsx
	ldaa	7,x
	ldab	8,x
	jmp	ret6

nextblock:
	tsta
	beq	tailset
	; Set 256 bytes
	pshb
	psha
	clrb
	bsr	tailset
	pula
	pulb
	deca
	bra	nextblock

tailset:
	ldaa	@tmp
clearloop:
	staa	,x
	inx
	decb
	bne	clearloop
	rts
