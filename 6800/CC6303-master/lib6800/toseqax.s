;
;	Compare top of stack with D
;

		.export toseqax
		.code
toseqax:
		tsx
		cmpb 3,x
		bne noteq
		cmpa 2,x
noteq:		jsr booleq
		jmp pop2
