
		.export _isupper

		.code

_isupper:
		clra
		tsx
		ldab 3,x
		cmpb #'A'
		blo fail
		cmpb #'Z'
		bhi fail
		; Any non zero value is valid
		jmp ret2
fail:		clrb
		jmp ret2
