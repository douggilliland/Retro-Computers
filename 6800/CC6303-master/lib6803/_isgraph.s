
		.export _isgraph

		.code

_isgraph:
		clra
		tsx
		ldab 3,x
		cmpb #' '
		bls fail
		cmpb #127
		bhs fail
		; Any non zero value is valid
		rts
fail:		clrb
		rts
