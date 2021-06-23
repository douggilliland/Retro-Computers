;
;	Unsigned 32bit remainder TOS by sreg:d
;

		.export tosumodeax
		.setcpu 6803
		.code

tosumodeax:
		; Arrange stack for the divide helper. TOS is already right
		; so push the other 4 bytes we need. The divide helper knows
		; about the fact there is junk (return address) between the
		; two
		ldx @sreg
		pshb
		psha
		pshx
		tsx
		jsr div32x32
		pulx
		pulx
		ldd @tmp2
		std @sreg
		ldd @tmp3
		jmp pop4
