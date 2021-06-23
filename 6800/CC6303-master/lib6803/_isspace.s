
		.export _isspace

		.code

_isspace:
		clra
		tsx
		ldab 3,x
		cmpb #' '
		beq good
		cmpb #9		; tab
		bls fail
		cmpb #13	; line feed
		ble good
fail:		clrb
		; any non zero is 'good
good:		rts
