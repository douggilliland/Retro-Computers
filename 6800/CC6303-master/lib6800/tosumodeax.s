;
;	Unsigned 32bit remainder TOS by sreg:d
;

		.export tosumodeax
		.code

tosumodeax:
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
		ins
		ins
		ldaa @tmp2
		staa @sreg
		ldab @tmp2+1
		stab @sreg+1
		ldaa @tmp3
		ldab @tmp3+1
		jmp pop4
