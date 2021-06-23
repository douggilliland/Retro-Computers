
		.export _islower

		.code

_islower:
		clra
		tsx
		ldab 3,x
		cmpb #'a'
		blo fail
		cmpb #'z'
		bhi fail
		; Any non zero value is valid
		rts
fail:		clrb
		rts
