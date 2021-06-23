
	.code
	.export tosgteax

tosgteax:
	jsr toslcmp
	jsr boolgt
	jmp pop4
