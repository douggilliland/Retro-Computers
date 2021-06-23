
		.export _atoi

		.setcpu 6803
		.code

_atoi:
		tsx
		ldx 2,x
		clra
		clrb
		std @tmp
		std @tmp2
_atoil:		ldab ,x
		cmpb #'0'		; in range ?
		blt done
		cmpb #'9'
		bgt done
		subb #'0'		; make digit
		stab @tmp2+1		; tmp2 is now the 16bit value
		ldd @tmp		; existing value
		std @tmp3		; save d
		asld			; x 2
		asld			; x 4
		addd @tmp		; x 5
		asld			; x 10
		addd @tmp2		; + new
		std @tmp		; save
		inx			; next char
		bra _atoil
done:		rts
