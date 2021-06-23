
		.export _abs

		.setcpu 6803
		.code

_abs:
		tsx
		ldd 2,x
		bita #$80
		beq absdone
		coma
		comb
		addd @one
absdone:
		rts
