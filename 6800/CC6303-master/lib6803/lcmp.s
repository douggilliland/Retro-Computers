	.setcpu 6803

	.code
	.export toslcmp

;
;	Compare the 4 bytes stack top with the 32bit accumulator
;	We are always offset because we are called with a jsr from
;	the true helper
;
toslcmp:
	tsx
	std @tmp	; Save the low 16bits
	ldd 4,x
	subd @sreg	; Check the high word
	bne done
	ldd 6,x		; High is same so compare low
	sbca @tmp
	bne done
	sbcb @tmp+1
done:
	rts
