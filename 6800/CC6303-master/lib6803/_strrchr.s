		.export _strrchr
		.setcpu 6803
		.code

_strrchr:
		tsx
		clra
		clrb
		std @tmp
		ldab 3,x
		ldx 4,x
		; Must do the compare before the end check, see the C
		; standard.
_strrchrl:
		cmpb ,x
		bne nomatch
		stx @tmp
nomatch:
		tst ,x
		beq retnull
		inx
		bra _strrchrl
retnull:
		; tmp holds last match or NULL
		ldd @tmp
		rts
