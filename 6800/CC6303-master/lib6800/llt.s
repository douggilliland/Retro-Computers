
	.code
	.export toslteax

toslteax:
	jsr toslcmp
	jsr boollt
	jmp pop4
