

	.export pop2

	.code

pop2:
	tsx				; no pulx on original 6800
	ldx ,x				; so do it by hand
	ins
	ins
	ins
	ins
	jmp ,x
