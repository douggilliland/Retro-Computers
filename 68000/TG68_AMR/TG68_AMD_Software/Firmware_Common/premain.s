; Minimalist pre-main code.
_premain:
	pea 1
	pea	.name
	jmp main
.name
	dc.b	"Bootrom",0

	XDEF _premain

