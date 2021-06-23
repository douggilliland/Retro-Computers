
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
		jmp ret2
fail:		clrb
		jmp ret2
