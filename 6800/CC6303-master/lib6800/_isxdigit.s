
		.export _isxdigit

		.code

_isxdigit:
		clra
		tsx
		ldab 3,x
		cmpb #'0'
		bls fail
		cmpb #'9'
		ble good
		cmpb #'A'
		bls fail
		cmpb #'F'
		ble good
		cmpb #'a'
		bls fail
		cmpb #'f'
		bls good
fail:		clrb
		; any non zero is 'good'
good:		jmp ret2
