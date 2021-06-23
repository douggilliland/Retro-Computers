;
;	Signed 32bit divide TOS by sreg:d
;
;	The result shall be negative if the signs differ
;

		.export tosdiveax
		.code

tosdiveax:
		; make work room
		psha
		; Arrange stack for the divide helper. TOS is already right
		; so push the other 4 bytes we need. The divide helper knows
		; about the fact there is junk (return address) between the
		; two
		clr @tmp4		; sign tracking
		ldaa @sreg
		bpl nosignfix
		pula
		jsr negeax
		inc @tmp4		; remember how many negations
		bra signfixed
nosignfix:
		;	Stack the 32bit working register
		pula
signfixed:
		pshb
		psha
		ldaa @sreg
		ldab @sreg+1
		pshb
		psha
		;
		;	Sign rules
		;
		ldaa 9,x		; sign of TOS
		bpl nosignfix2
		inc @tmp4
		ldaa 8,x
		ldab 9,x
		subb #1
		sbca #0
		staa 8,x
		stab 9,x
		ldaa 6,x
		ldab 7,x
		sbcb #0
		sbca #0
		coma
		comb
		staa 6,x
		stab 7,x
		com 8,x
		com 9,x
nosignfix2:
		tsx
		jsr div32x32
		; We now have the positive result. Bit 0 of @tmp4 tells us
		; if we need to negate the answer
		ldab @tmp4
		anda #1
		beq nosignfix3
		pula
		pulb
		staa @sreg
		stab @sreg+1
		pula
		pulb
		jsr negeax
		jmp pop4
nosignfix3:
		pula
		pulb
		staa @sreg
		stab @sreg+1
		pula
		pulb
		jmp pop4

