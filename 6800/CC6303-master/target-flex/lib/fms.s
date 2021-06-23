;
;	Flex has two chunks of OS interface. The disk interface via FMS
;	which works by passing file control blocks in a very standard
;	fashion, and the rest which is more like a glorified monitor.
;
;	We expose FMS as fms_call with an FCB. The only oddity we deal with
;	is that FMS returns an error indicator as flags, so we translate
;	that into a C visible fms_error variable.
;
;

		.export _fms_close
		.export _fms_call
		.export _fms_setverify
		.export _fms_getverify
		.export _fms_error

		.code

_fms_close:
		jmp $B403
_fms_call:
		tsx
		ldaa 4,x
		ldab 5,x
		ldx 2,x		; FCB
		clr _fms_error
		jsr $BE06
		beq fmsgood
		inc _fms_error
fmsgood:
		rts
		

_fms_setverify:
		tsx
		ldab 2,x
		stab $B435
		rts
_fms_getverify:
		ldab $B435
		clra
		rts

		.data
_fms_error:	.byte 0

;
;	FMS related system routines
;

		.export _flex_getfspec
		.export _flex_load
		.export _flex_setext
		.export _flex_perror
		.export _flex_docmnd

		.code

_flex_getfspec:
		tsx
		ldx 2,x
		jsr $AD2D
		ldab #0
		sbcb #0		; make C into 0 or -1 for error
		tba
		rts

_flex_load:
		jmp $AD30

_flex_setext:
		tsx
		ldx 2,x
		ldaa 3,x
		jmp $AD33

_flex_perror:
		tsx
		ldx 2,x
		jmp $AD3F

_flex_docmnd:
		jsr $AD4B
		clra
		rts
