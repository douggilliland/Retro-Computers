
		.export _labs

		.setcpu 6803
		.code

_labs:
		tsx
		ldd 3,x
		std @sreg
		bita #$80
		beq labsdone
		ldd 5,x
		jmp negeax
labsdone:
		ldd 5,x	
		rts
