
		.export _putchar
		.code

_putchar:
		tsx
		ldab 3,x
		jsr __putc
		jmp ret2

