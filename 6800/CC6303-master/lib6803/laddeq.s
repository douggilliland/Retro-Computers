;
;	On entry X points to the object
;
;	FIXME: need a review and rewrite as we sort out the 680x calling
;	conventions for this versus 6502
;
	.code
	.export laddeqa
	.export laddeqysp
	.export laddeq

	.setcpu 6803

; In this form X is the stack offset. Turn that into X is a pointer and
; fall into the static form
laddeqysp:
	stx @tmp
	sts @tmp2
	ldd @tmp2
	addd @tmp
	inx
laddeqa:
	std @tmp
	ldd 2,x		; do the low 16bits
	addd @tmp
	bcc l1
	inc sreg	; carry - we don't have abcd
l1:
	std 2,x
	ldd ,x
	addd @sreg
	std ,x
	rts

;
;	Add the 32bit sreg/d to the variable at X
;
laddeq:
	addd 2,x		; Add the low word
	std 2,x
	; No adcd
	ldd ,x			; High word
	adcb @sreg+1		; 1,x + sreg+1 (byte 3)
	adca @sreg		; ,x + sreg (byte 4)
	std ,x
	rts
