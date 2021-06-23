;
;	Signed 32bit remainder TOS by sreg:d
;
;	C99 says that the sign of the remainder shall be the sign of the
;	dividend, older C says nothing but it seems unwise to do other
;	things
;

		.export tosmodeax
		.setcpu 6803
		.code

tosmodeax:
		; make working space
		psha
		; Arrange stack for the divide helper. TOS is already right
		; so push the other 4 bytes we need. The divide helper knows
		; about the fact there is junk (return address) between the
		; two
		ldaa @sreg
		staa @tmp4
		bpl nosignfix
		jsr negeax
nosignfix:
		pula
		pshb
		psha
		ldx @sreg
		pshx
		;
		;	Sign rules
		;
		ldaa 9,x		; sign of TOS
		bpl nosignfix2
		ldd 8,x
		subd #1
		std 8,x
		ldd 6,x
		sbcb #0
		sbca #0
		coma
		comb
		std 6,x
		com 8,x
		com 9,x
nosignfix2:
		tsx
		jsr div32x32
		pulx
		pulx
		;
		;	At this point @tmp2/@tmp3 hold the positive signed
		;	dividend
		;
		ldd @tmp2
		std @sreg
		ldaa @tmp4
		bita #0x80		; check if negative dividend
		beq nonega
		ldd @tmp3
		jsr negeax
		jmp pop4
nonega:
		ldd @tmp3
		jmp pop4
