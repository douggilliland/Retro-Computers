
		.export _putchar
		.code

_putchar:
		tsx
		ldab 3,x
		jmp __putc

