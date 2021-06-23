

	.code
	.export _strlen


_strlen:
	tsx
	ldx 3,x
	clra
	clrb
cl:	tst ,x
	beq to_rts
	inx
	addd @one
	bra cl
to_rts:
	jmp ret2
