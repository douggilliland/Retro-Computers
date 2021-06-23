;
;	Console function helpers, and flex calls
;
		.export __putc
		.export __getc

		.export _flex_inch
		.export _flex_inch2
		.export _flex_outch
		.export _flex_outch2
		.export _flex_getchr
		.export _flex_putchr
		.export _flex_inbuff
		.export _flex_pstring
		.export _flex_class
		.export _flex_pcrlf
		.export _flex_nxtch
		.export _flex_rstrio
		.export _flex_outdec
		.export _flex_outhex
		.export _flex_gethex
		.export _flex_outadr
		.export _flex_indec
		.export _flex_stat

		.code

__getc:
		jsr $AD15
		tab
		clra
		rts

__putc:
		tba
		jmp $AD18

_flex_inch:
		jsr $AD09
		tab
		clra
		rts

_flex_inch2:
		jsr $AD0C
		tab
		clra
		rts

_flex_outch:
		tsx
		ldaa 2,x
		jmp $AD0F

_flex_outch2:
		tsx
		ldaa 2,x
		jmp $AD12

_flex_getchr:
		jsr $AD15
		tab
		clra
		rts

_flex_putchr:
		tsx
		ldaa 2,x
		jmp $AD18

_flex_inbuff:
		jmp $AD1B

_flex_pstring:
		tsx
		ldx 2,x
		jmp $AD1E

_flex_class:
		tsx
		ldaa 2,x
		jsr $AD21
		ldab #0
		sbca #0
		tba
		rts

_flex_pcrlf:
		jmp $AD24

_flex_nxtch:
		jsr $AD27
		tab		; Character
		ldaa #0		; Set high bits to 00 or FF by class
		sbca #0
		rts
_flex_rstrio:
		jmp $AD2A

_flex_outdec:
		tsx
		ldab 2,x
		ldx 4,x
		jmp $AD39

_flex_outhex:
		tsx
		ldx 2,x
		jmp $AD3C

;
;	This one is awkward as the return ABI is basically two values and
;	carry. We turn this into
;
;		flex_gethex(int *v)
;
;	and return 0 = separator,  > 0 valid, -1 not valid
;
_flex_gethex:
		jsr $AD42
		; this one needs some unpacking
		; carry clear, X is value B != 0
		; carry clear, B = 0, hit separator not number
		; carry set, not a hex number
_flex_getunpack:
		bcs nothex
		clra
		tstb
		beq novalue
		stx @tmp
		tsx
		ldx 2,x
		ldaa @tmp
		staa ,x
		ldaa @tmp
		staa ,x
		clra
novalue:	rts
nothex:		ldab #$FF
		tba
		rts

_flex_outadr:
		tsx
		ldx 2,x
		jmp $AD45

; Tanslated the same ways inhex
_flex_indec:
		jsr $AD48
		bra _flex_getunpack

_flex_docmnd:
		jsr $AD48
		clra
		rts

; flex_stat also happens to be kbhit() as we unpack the flags
_kbhit:
_flex_stat:
		clra
		clrb
		jsr $AD4E
		beq nothit
		incb
nothit:		rts
