;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  NUMOP.S
;*	Dflat number AND string operators.
;*  Uses the operator stack to get parameters, leaving the
;*  result on the operator stack.
;*
;**********************************************************

	; ROM code
	code  

; common pushint code
df_rt_putintres
	ldx df_tmpptra
	lda df_tmpptra+1
	clc
	jmp df_st_pushInt

; add two numbers
df_rt_add
	jsr df_rt_get2Ints
	_addZPWord df_tmpptra,df_tmpptrb
	jmp df_rt_putintres
	
; subtract
df_rt_sub
	jsr df_rt_get2Ints
	_subZPWord df_tmpptra,df_tmpptrb
	jmp df_rt_putintres

; multiply
df_rt_mult
	jsr df_rt_get2Ints
	_cpyZPWord df_tmpptra,num_a
	_cpyZPWord df_tmpptrb,num_b
	jsr int_mult
	_cpyZPWord num_a,df_tmpptra
	jmp df_rt_putintres

; divide
df_rt_div
	jsr df_rt_get2Ints
	_cpyZPWord df_tmpptra,num_a
	_cpyZPWord df_tmpptrb,num_b
	jsr int_div
	_cpyZPWord num_a,df_tmpptra
	jmp df_rt_putintres

; mod
df_rt_mod
	jsr df_rt_get2Ints
	_cpyZPWord df_tmpptra,num_a
	_cpyZPWord df_tmpptrb,num_b
	jsr int_div
	_cpyZPWord num_x,df_tmpptra
	jmp df_rt_putintres

; shift left
df_rt_asl
	jsr df_rt_get2Ints
	; use low byte only for # of shifts
	ldx df_tmpptrb
	inx
df_rt_aslbit
	dex
	beq df_rt_asldone
	asl df_tmpptra
	rol df_tmpptra+1
	bra df_rt_aslbit
df_rt_asldone
	jmp df_rt_putintres

; shift right
df_rt_lsr
	jsr df_rt_get2Ints
	; use low byte only for # of shifts
	ldx df_tmpptrb
	inx
df_rt_lsrbit
	dex
	beq df_rt_lsrdone
	lsr df_tmpptra+1
	ror df_tmpptra
	bra df_rt_lsrbit
df_rt_lsrdone
	jmp df_rt_putintres

; common routine push true
df_rt_true
	ldx #0xff
	lda #0xff
	clc
	jmp df_st_pushInt

; common routine push false
df_rt_false
	ldx #0x00
	lda #0x00
	clc
	jmp df_st_pushInt

; a == b
df_rt_eq
	jsr df_rt_get2Ints
df_rt_eq_chk			; used by other internal routines
	lda df_tmpptra
	cmp df_tmpptrb
	bne df_rt_eq_false
	lda df_tmpptra+1
	cmp df_tmpptrb+1
	bne df_rt_eq_false
	jmp df_rt_true
df_rt_eq_false
	jmp df_rt_false

; a <> b
df_rt_ne
	jsr df_rt_get2Ints
	lda df_tmpptra
	cmp df_tmpptrb
	beq df_rt_ne_tryhi
df_rt_ne_true
	jmp df_rt_true
df_rt_ne_tryhi
	lda df_tmpptra
	cmp df_tmpptrb
	bne df_rt_ne_true
	jmp df_rt_false

; a <= b
df_rt_lte
	; a <=b == (a-b) <= 0
	jsr df_rt_get2Ints
df_rt_lte_calc
	sec
	lda df_tmpptra
	sbc df_tmpptrb
	lda df_tmpptra+1
	sbc df_tmpptrb+1
	bcc df_rt_lte_true
	jmp df_rt_eq_chk
df_rt_lte_true
	jmp df_rt_true

; a < b == (a-b) < 0
df_rt_lt
	jsr df_rt_get2Ints
	sec
	lda df_tmpptra
	sbc df_tmpptrb
	lda df_tmpptra+1
	sbc df_tmpptrb+1
	bcc df_rt_lt_true
	jmp df_rt_false
df_rt_lt_true
	jmp df_rt_true

; a >= b == (b-a) <= 0
df_rt_gte
	jsr df_rt_get2Ints
	sec
	lda df_tmpptrb
	sbc df_tmpptra
	lda df_tmpptrb+1
	sbc df_tmpptra+1
	bcc df_rt_gte_true
	jmp df_rt_eq_chk
df_rt_gte_true
	jmp df_rt_true

; a > b == (b-a) < 0
df_rt_gt
	jsr df_rt_get2Ints
	sec
	lda df_tmpptrb
	sbc df_tmpptra
	lda df_tmpptrb+1
	sbc df_tmpptra+1
	bcc df_rt_gt_true
	jmp df_rt_false
df_rt_gt_true
	jmp df_rt_true

; logical and
df_rt_and
	jsr df_rt_get2Ints
	lda df_tmpptra
	and df_tmpptrb
	tax
	lda df_tmpptra+1
	and df_tmpptrb+1
	jmp df_st_pushInt
	
; logical or
df_rt_or
	jsr df_rt_get2Ints
	lda df_tmpptra
	ora df_tmpptrb
	tax
	lda df_tmpptra+1
	ora df_tmpptrb+1
	jmp df_st_pushInt

;********** STRING OPS **********

; common string comparator
df_rt_str_comp
	jsr df_rt_get2Strs
	ldy #0
df_rt_str_comp_byte
	lda (df_tmpptra),y
	cmp (df_tmpptrb),y
	; if c=0 then <
	bcc df_rt_str_comp_lt
	; if c=1 and nz then >
	bne df_rt_str_comp_gt
	; if string end then ==
	lda (df_tmpptra),y
	beq df_rt_str_comp_eq
	iny
	bra df_rt_str_comp_byte
df_rt_str_comp_lt
	lda #0xff
	clc
	rts
df_rt_str_comp_gt
	lda #0x01
	clc
	rts
df_rt_str_comp_eq
	lda #0x00
	clc
	rts

; string less than or equal
df_rt_slte
	jsr df_rt_str_comp
	cmp #0xff
	beq df_rt_str_comp_true
	cmp #0x00
	beq df_rt_str_comp_true
df_rt_str_comp_false
	jmp df_rt_false
df_rt_str_comp_true
	jmp df_rt_true	

; string greater then or equal	
df_rt_sgte
	jsr df_rt_str_comp
	cmp #0xff
	beq df_rt_str_comp_true
	cmp #0x00
	beq df_rt_str_comp_true
	bra df_rt_str_comp_false

; string not equal
df_rt_sne
	jsr df_rt_str_comp
	cmp #0x00
	bne df_rt_str_comp_true
	bra df_rt_str_comp_false

; string less than
df_rt_slt
	jsr df_rt_str_comp
	cmp #0xff
	beq df_rt_str_comp_true
	bra df_rt_str_comp_false

; string greater than
df_rt_sgt
	jsr df_rt_str_comp
	cmp #0x01
	beq df_rt_str_comp_true
	bra df_rt_str_comp_false

; string equal
df_rt_seq
	jsr df_rt_str_comp
	cmp #0x00
	beq df_rt_str_comp_true
	bra df_rt_str_comp_false
