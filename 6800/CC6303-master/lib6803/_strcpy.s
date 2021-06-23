;
;	Another one that's really hard to do nicely
;

	.export _strcpy

	.setcpu 6303
	.code

_strcpy:
	tsx
	ldd	4,x
	std	@tmp		; destination
	ldx	2,x		; src
copyloop:
	ldaa	,x
	inx
	pshx
	ldx	@tmp
	staa	,x
	inx
	stx	@tmp
	pulx
	tsta
	bne copyloop
	tsx
	ldd	4,x
	rts
