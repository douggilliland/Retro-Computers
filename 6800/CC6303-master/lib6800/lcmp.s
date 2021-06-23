	.code
	.export toslcmp

;
;	Compare the 4 bytes stack top with the 32bit accumulator
;	We are always offset because we are called with a jsr from
;	the true helper
;
toslcmp:
	tsx
	staa @tmp	; Save the low 16bits
	stab @tmp+1
	; Compare the high word byte by byte
	ldaa 4,x
	suba @sreg
	bne chkdone
	ldab 5,x
	sbcb @sreg+1
	bne chkdone
	; The high word matched, so compare the low word the same way
	ldaa 6,x
	sbca @tmp
	bne chkdone
	ldab 7,x
	sbcb @tmp+1
chkdone:
	rts
