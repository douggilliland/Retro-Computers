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

; In this form X is the stack offset. Turn that into X is a pointer and
; fall into the static form
laddeqysp:
	stx @tmp
	sts @tmp2
	ldaa @tmp2
	ldab @tmp2+1
	addb @tmp2+1
	adca @tmp
	inx
laddeqa:
	staa @tmp
	stab @tmp+1
	ldaa 2,x	; do the low 16bits
	ldab 3,x
	addb @tmp+1
	adca @tmp
	bcc l1
	inc sreg	; carry - we don't have abcd
l1:
	staa 2,x
	stab 3,x
	ldaa ,x
	ldab 1,x
	addb @sreg+1
	adca @sreg
	staa ,x
	stab 1,x
	rts

;
;	Add the 32bit sreg/d to the variable at X
;
laddeq:
	addb 3,x		; Add the low word
	stab 3,x
	adca 2,x
	staa 2,x
	ldaa ,x			; High word
	ldab 1,x
	adcb @sreg+1		; 1,x + sreg+1 (byte 3)
	adca @sreg		; ,x + sreg (byte 4)
	staa ,x
	stab 1,x
	rts
