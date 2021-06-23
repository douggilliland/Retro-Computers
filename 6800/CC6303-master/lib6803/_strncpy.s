;
;	Another one that's really hard to do nicely
;

	.export _strncpy

	.setcpu 6303
	.code

_strncpy:
	tsx
	ldd	2,x		; size
	beq	end3		; size 0 - silly
	addd	6,x		; dest end mark
	std	@tmp2
	ldd	6,x
	std	@tmp		; destination
	ldx	4,x		; src
	;
	;	Copy bytes up to the size limit given
	;
copyloop:
	ldaa	,x
	inx
	pshx
	ldx	@tmp
	staa	,x
	inx
	stx	@tmp
	cpx	@tmp2
	beq	end1
	pulx
	tsta
	bne copyloop
	ldx	@tmp
	;
	;	Wipe the remainder of the target buffer
	;
wipeloop:
	cpx	@tmp2
	beq	end2
	clr	,x
	inx
	bra	wipeloop
end1:
	pulx
end2:
	tsx
end3:
	ldd	4,x
	rts

