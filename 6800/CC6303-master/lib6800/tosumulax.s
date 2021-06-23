;
;	D = top of stack * D
;	Unlike the later variants the 6800 has no MUL instruction so do
;	the classic bit shift version instead
;
		.export tosmulax
		.export tosumulax
		.code
tosmulax:
tosumulax:
		pshb
		psha
		tsx
		; ,x and 1,x are D
		; 3,x and 4,x are the top of stack value
		ldab #16
		stab @tmp		; iteration count

		clra			; AB now becomes our 16bit
		clrb			; work register

		; Rotate through the number
nextbit:
		ror ,x
		ror 1,x
		bcc noadd
		addb 4,x
		adca 3,x
noadd:		rora
		rorb
		bne nextbit
		; For a 16x16 to 32bit just store 3-4,x into sreg
		jmp pop4
