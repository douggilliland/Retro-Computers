;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  INTMATH.S
;*  Core module for integer maths supported by dflat.
;*  Uses the intmath registers: num_a, num_b, num_x, num_tmp
;*  Most inputs are through num_a and num_b, with result in
;*  num_a.
;*  Operations: add, sub, swap, 8 bit mult, mult, divide
;*
;**********************************************************

	; ROM code
	code

;****************************************
;* Add : A + B result in A
;****************************************
int_add
	clc
	lda num_a
	adc num_b
	sta num_a
	lda num_a+1
	adc num_b+1
	sta num_a+1
	rts
	
;****************************************
;* Sub : A - B result in A
;****************************************
int_sub
	sec
	lda num_a
	sbc num_b
	sta num_a
	lda num_a+1
	adc num_b+1
	sta num_a+1
	rts
	
;****************************************
;* Swp : A <-> B 
;****************************************
int_swp
	lda num_a
	ldx num_b
	sta num_b
	stx num_a
	lda num_a+1
	ldx num_b+1
	sta num_b+1
	stx num_a+1
	rts
	
;****************************************
;* Mult : A * B result in A
;* B assumed to be an 8 bit quantity 
;****************************************
int_fast_mult
	_cpyZPWord num_a,num_tmp
	stz num_a
	stz num_a+1
	ldy #8
int_fast_mult_cycle
	lsr num_b
	bcc int_fast_mult_next
	clc
	lda num_a
	adc num_tmp
	sta num_a
	lda num_a+1
	adc num_tmp+1
	sta num_a+1
int_fast_mult_next
	asl num_tmp
	rol num_tmp+1
	dey
	bne int_fast_mult_cycle
	rts
	
;****************************************
;* Mult : A * B result in A
;****************************************
int_mult
	_cpyZPWord num_a,num_tmp
	stz num_a
	stz num_a+1
	ldy #16
int_mult_cycle
	lsr num_b+1
	ror num_b
	bcc int_mult_next
	clc
	lda num_a
	adc num_tmp
	sta num_a
	lda num_a+1
	adc num_tmp+1
	sta num_a+1
int_mult_next
	asl num_tmp
	rol num_tmp+1
	dey
	bne int_mult_cycle
	rts

;****************************************
;* Mult : A / B result in A
;****************************************
int_div
	; x is the remainder
	stz num_x
	stz num_x+1
	; 16 bit division
	ldy #16
int_div_cycle
	; shift a left 1 bit
	asl num_a
	rol num_a+1
	; shift in to remainder
	rol num_x
	rol num_x+1
	; try and subtract b from remainder
	sec
	lda num_x
	sbc num_b
	tax
	lda num_x+1
	sbc num_b+1
	bcc int_div_skip
	; so b did fit in to remainder, save it
	stx num_x
	sta num_x+1
	inc num_a
int_div_skip
	; carry on for 16 bits
	dey
	bne int_div_cycle
	; result in a, remainder in x
	rts
	