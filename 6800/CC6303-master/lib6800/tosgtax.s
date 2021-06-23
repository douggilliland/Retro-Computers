;
;	Compare top of stack with D
;

		.export tosgtax
		.code
tosgtax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolgt
		jmp pop2
