;
;	Use the ROM
;
;	The MC-10 provides vectors
;	FFDC poll keyboard
;	FFDE print a char
;	FFE0 start tape
;	FFE2 read tape block
;	FFE4 write tape block
;	FFE6 play sound
;	FFE8 write tape leader
;	FFEA int ->basic
;	FFEC basic->int
;
	.export __getc
	.export __putc

	.setcpu 6803
	.code

__getc:
	pshx
getc_wait:
	ldx $FFDC			; poll keyboard
	jsr ,x
	beq getc_wait
	pulx
	tab
	rts

__putc:
	pshx
	ldx $FFDE
	jsr ,x
	pulx
	rts
