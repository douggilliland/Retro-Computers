;
;	Another one that's really hard to do nicely
;

	.export _strcpy

	.code

_strcpy:
	tsx
	ldaa	7,x
	ldab	8,x
	staa	@tmp
	stab	@tmp+1		; destination
	ldaa	3,x		; length
	ldab	4,x
	ldx	5,x		; src
copyloop:
	ldaa	,x
	inx
	stx	@tmp2
	ldx	@tmp
	staa	,x
	inx
	stx	@tmp
	ldx	@tmp2
	tsta
	bne copyloop
	tsx
	ldaa	7,x
	ldab	8,x
	jmp	ret4
