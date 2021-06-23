
		.export _fputc

		.code

_fputc:
_putc:
		tsx
		ldaa 4,x
doputc:
		ldx 2,x		; FILE (and thus FCB) pointer
		tst ,x
		beq fms
		; actually we are a fake logical device
		; for now just console
		cmpa #10
		beq putnl
		jsr $AD18
		clra
		tsx
		ldab 4,x
		rts
fms:
		inx
		inx
		clr ,x
		clr 1,x
		jmp fms_and_errno

_putchar:
		tsx
		ldaa 2,x
		cmpa #10
		beq putnl
		jsr $AD18
putcdone:
		clra
		ldab 2,x
		rts
putnl:		jsr $AD24
		clra
		ldab #10
		rts
