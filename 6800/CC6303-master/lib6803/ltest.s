;
;	Compare 32bit with 0. Should preserve D
;
	.export tsteax
	.export utsteax

	.setcpu 6803
	.code

tsteax:		; sign doesn't matter for equality
utsteax:
	subd	@zero	; we don't have a 'tstd' but this is the same
	bne	done	; flag set and nothing touched
	tst	@sreg
	bne	done
	tst	@sreg+1	; will set eq/ne for sreg being 0
done:
	rts
