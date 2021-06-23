
	.code
	.export tosneeax

tosneeax:
	jsr toslcmp
	jsr boolne
	jmp pop4
