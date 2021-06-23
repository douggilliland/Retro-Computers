		.export _puts
		.code

_puts:		tsx
		ldx 2,x
putl:
		ldab ,x
		beq putsdone
		jsr __putc
		inx
		bra putl
putsdone:	ldab #10
		jsr __putc
		jmp ret2


