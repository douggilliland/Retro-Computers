
		.export _isascii

		.code

_isascii:
		clra
		tsx
		ldab 3,x
		cmpb #127
		bhs fail
		ldab #1
		rts
fail:		clrb
		rts
