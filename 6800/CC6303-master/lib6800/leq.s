
	.code
	.export toseqeax

toseqeax:
	jsr toslcmp
	jsr booleq
	jmp pop4

