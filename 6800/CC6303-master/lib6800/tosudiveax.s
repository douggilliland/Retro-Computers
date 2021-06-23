;
;	Unsigned 32bit divide TOS by sreg:d
;

		.export tosudiveax
		.code

tosudiveax:
		; Arrange stack for the divide helper. TOS is already right
		; so push the other 4 bytes we need. The divide helper knows
		; about the fact there is junk (return address) between the
		; two
		pshb
		psha
		ldab @sreg+1
		pshb
		ldaa @sreg
		psha
		tsx
		jsr div32x32
		ins
		ins
		pulb
		pula
		stx @sreg
		jmp pop4
