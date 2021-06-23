		.export _strcmp
		.setcpu 6803
		.code
_strcmp:
		tsx
		ldd 2,x
		ldx 4,x
		std @tmp
loop:
		ldab ,x		; get *s1 into B
		stx @tmp2	; switch pointer
		ldx @tmp
		cmpb ,x		; compare with *s2
		blo ret1
		bhi retminus1
		inx		; move on
		stx @tmp
		ldx @tmp2	; switch pointer back
		inx
		bra loop	; rinse, repeat
ret1:
		ldd @one
		rts
retminus1:
		ldd #-1
		rts

		
