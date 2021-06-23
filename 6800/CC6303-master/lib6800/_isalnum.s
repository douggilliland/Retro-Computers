
		.export _isalnum

		.code

_isalnum:
		clra
		tsx
		ldab 3,x
		cmpb #'0'
		bls fail
		cmpb #'9'
		ble good
		cmpb #'A'
		bls fail
		cmpb #'Z'
		ble good
		cmpb #'a'
		bls fail
		cmpb #'z'
		bls good
fail:		clrb
		; any non zero is 'good'
good:		jmp ret2
