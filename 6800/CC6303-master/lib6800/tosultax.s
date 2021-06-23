;
;	Compare top of stack with D
;

		.export tosultax
		.code
tosultax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolult
		jmp pop2
