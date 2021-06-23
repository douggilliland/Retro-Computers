
		.export _ispunct

		.code

_ispunct:
		clra
		tsx
		ldab 3,x
		cmpb #' '
		bls fail
		cmpb #'z'
		bhi good
		cmpb #'a'
		bhs fail
		cmpb #'Z'
		bhi good
		cmpb #'A'
		bhs fail
		cmpb #'0'
		bhi good
		cmpb #'9'
		bhi good
fail:		clrb
		rts
		; any non zero is 'good
good:		rts
