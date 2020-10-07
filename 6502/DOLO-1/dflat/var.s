;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  VAR.S
;*  This module handles all the variable management in dflat.
;*  When a new variable is detected during tokenisation, it
;*  is added to the variable tables.  Any subsequent used of
;*  that variable is tokenised as an index in to the variable
;*  table.  There are two variable tables:
;*  Variable name table (VNT) keeps track of variable names
;*  Variable value table (VVT) maintains variable properties
;*  including type, dimension (if array) and of course the
;*  actual values.  For an array, the value is a pointer to
;*  memory grabbed using the 'malloc' function (see stack.s).
;*  This approach to variable managemet is directly from the
;*  Atari 8 bit.  The disadvantage is that during a big edit
;*  session you may end up having a much larger variable
;*  table than you need.  Why?  Well because say you enter
;*  %a as a new variable, but then later change it to %b.
;*  In this case %a remains in the variable tables - dflat
;*  only ever adds to the table!  However it is easily
;*  solved - when you save and then reload from new a
;*  program, the variable table is built up as the program
;*  is loaded.
;*  The VNT grows down from the top of free memory, with
;*  the VVT growing down from just below the VNT.
;*
;**********************************************************


	; ROM code
	code  

;****************************************
;* Find VVT slot given VVT index
;* A = index
;* Return : df_tmpptra
;* CC = No error
;****************************************
df_var_addr
	; save index and multiply by 8
	sta df_tmpptra
	stz df_tmpptra+1

	asl df_tmpptra
	rol df_tmpptra+1

	asl df_tmpptra
	rol df_tmpptra+1

	asl df_tmpptra
	rol df_tmpptra+1

	; add in vvt start offset
	_addZPWord df_tmpptra,df_vvtstrt
	clc
	rts
	
;****************************************
;* Find a variable
;* CC if found, A has index
;****************************************
df_var_find
	; start at the beginning of the vnt table
	_cpyZPWord df_vntstrt,df_tmpptra
	; start at index 0
	stz df_tmpptrb
df_var_match_vnt
	; If reached the var count then not found
	lda df_varcnt
	cmp df_tmpptrb
	beq df_var_find_no_vnt
	; match each char in buffer with vnt
	ldy df_linoff
df_var_match_vnt_sym
	lda df_linbuff,y
	cmp (df_tmpptra)
	bne df_var_vnt_sym_nomatch
	; if single char match then increment
	; source and search
	iny
	_incZPWord df_tmpptra
	; if more chars in vnt entry then continue
	lda (df_tmpptra)
	bne df_var_match_vnt_sym
	; if no more chars in vnt entry but
	; but chars in buffer then try next vnt
	lda df_linbuff,y
	jsr df_tk_isalphanum
	bcc df_var_find_true
df_var_vnt_sym_nomatch
	; find the zero terminator
	lda (df_tmpptra)
	beq	df_var_vnt_entry_end
	_incZPWord df_tmpptra
	bra df_var_vnt_sym_nomatch
df_var_vnt_entry_end
	; increment index
	inc df_tmpptrb
	; check if got to the end of the VNT
	lda df_varcnt
	cmp df_tmpptrb
	bne df_var_match_next_vnt
	; if at end then no matches found
df_var_find_no_vnt
	lda #0
	sec
	rts
df_var_match_next_vnt
	; skip over zero terminator
	_incZPWord df_tmpptra
	bra df_var_match_vnt
df_var_find_true
	; Got a match
	lda df_tmpptrb
	sty df_linoff
	clc
	rts

	
;****************************************
;* General block move
;* tmpptra = start of old block
;* tmpptrb = block length
;* tmpptrc = start of new block
;****************************************
df_var_block_move
	; if block len = 0 then move nothing
	lda df_tmpptrb
	bne df_var_block_move_do
	lda df_tmpptrb+1
	bne df_var_block_move_do
	; damn zero block length
	clc
	rts
df_var_block_move_do
	ldx #0					; Bytes transferred counter hi
	ldy #0					; Bytes transferred counter lo
	; if tmpptrc < tmpptra then move from
	; old start to new start else
	; move from old end to new end
	sec
	lda df_tmpptra
	sbc df_tmpptrc
	lda df_tmpptra+1
	sbc df_tmpptrc+1
	bcc df_var_end_to_end
	; ok going from start to start c++ = a++
df_var_start_to_start_byte
	lda (df_tmpptra)
	sta (df_tmpptrc)
	_incZPWord df_tmpptra
	_incZPWord df_tmpptrc
	iny
	bne df_start_to_start_nowrap
	inx
df_start_to_start_nowrap
	cpy df_tmpptrb
	bne df_var_start_to_start_byte
	cpx df_tmpptrb+1
	bne df_var_start_to_start_byte
	; done
	rts
df_var_end_to_end
	; going end to end
	; need to adjust ptrc to be end
	; c = c + (b-a)
	; first copy b
	_cpyZPWord df_tmpptrb,df_tmpptrd
	; do d-a, result in d
	_subZPWord df_tmpptrd,df_tmpptra
	; now c + d, result in c
	_addZPWord df_tmpptrc, df_tmpptrd
	; ok do the copy from end c-- = d--
df_var_end_to_end_byte
	lda (df_tmpptrb)
	sta (df_tmpptrc)
	_decZPWord df_tmpptrc
	_decZPWord df_tmpptrb
	iny
	bne df_end_to_end_nowrap
	inx
df_end_to_end_nowrap
	cpy df_tmpptrb
	bne df_var_end_to_end_byte
	cpx df_tmpptrb+1
	bne df_var_end_to_end_byte
	; done
	rts
	
;****************************************
;* Insert a variable name in to vnt
;* X = number of bytes to make room
;* Requires a block move of everything
;* from vvt start to vnt end
;* ptrb is vnt free entry
;* ptrc is vvt free entry
;****************************************
df_var_insert_space
	; *** REMEMBER TO DO A SPACE CHECK EVENTUALLY! ***
	

	; Start from current vvt start
	_cpyZPWord df_vvtstrt,df_tmpptra

	; Length = vvt end - vvt start
	_cpyZPWord df_vvtend,df_tmpptrb
	_subZPWord df_tmpptrb,df_vvtstrt

	; *vvt move* vnt size + vt size
	txa
	clc
	adc #DFVVT_SZ
	sta df_tmpptrd
	stz df_tmpptrd+1

	; New block start = vvt start - size
	_cpyZPWord df_vvtstrt,df_tmpptrc
	_subZPWord df_tmpptrc,df_tmpptrd

	; vvt start = new block start
	_cpyZPWord df_tmpptrc,df_vvtstrt

	; Do a block move of vvt, save X first
	phx
	jsr df_var_block_move
	plx
	
	;*******************
	
	; *vnt move* vnt move size is just var name length
	stx df_tmpptrd
	stz df_tmpptrd+1

	; start from current vnt start
	_cpyZPWord df_vntstrt,df_tmpptra

	; Length = vnt end - vnt start
	_cpyZPWord df_vntend,df_tmpptrb
	_subZPWord df_tmpptrb,df_vntstrt

	; New block start = vnt start - size
	_cpyZPWord df_vntstrt,df_tmpptrc
	_subZPWord df_tmpptrc,df_tmpptrd

	; vnt start = same, vvt end = same
	_cpyZPWord df_tmpptrc,df_vntstrt
	_cpyZPWord df_tmpptrc,df_vvtend
	
	; Do a block move of vnt
	jsr df_var_block_move

	; ** SOME DEBUG PRINTING

	; Copy done increment variable count
	inc df_varcnt
	clc
	rts
	
	
;****************************************
;* Analyse variable name
;* Return type in A
;* X = Length including pre-fixes
;* Y = Offset to next char after var name
;****************************************
df_var_analyse	
	ldy df_linoff
	; check from beginning of type table
	ldx #0
df_var_analyse_type
	lda df_linbuff,y
	cmp df_var_type,x
	beq df_var_type_found
	inx
	inx
	lda df_var_type,x
	bne df_var_analyse_type
	; No type match, or perhaps is not a variable
	; So not a fatal error here
df_var_analyse_err
	sec
	rts
df_var_type_found
	; save the type found
	lda df_var_type+1,x
	sta df_tmpptra
	; cound the actual number of alpha nums
	ldx #0xff
df_var_type_countlen
	; count alpha nums
	iny
	inx
	lda df_linbuff,y
	jsr df_tk_isalphanum
	bcs df_var_type_countlen
	cpx #0
	bne df_var_analyse_chk_ary
	; if zero alphanums fatal error
	SWBRK DFERR_SYNTAX
df_var_analyse_chk_ary
	; Check for array type
	cmp #'['
	bne df_var_not_arry
	; array and proc type not compatible
	lda df_tmpptra
	cmp #DFVVT_PROC
	beq df_var_analyse_err
	ora #DFVVT_ARRY
	sta df_tmpptra
df_var_not_arry
	; Ok got everything
	; calculate length from y
	; y is next char after var name
	tya
	sec
	sbc df_linoff			; where we started
	; put len in X
	tax
	; put type in A
	lda df_tmpptra
	clc
	rts
df_var_type
	db '_', DFVVT_PROC
	db '%', DFVVT_INT
	db '^', DFVVT_BYT
	db '$', DFVVT_STR
;	db '#', DFVVT_FLT		; Should be # but not supported
	db 0

;****************************************
;* Find or create a variable
;* If found then type needs to match mask
;* Not a fatal error because could be part
;* of a trial of different parsing options
;****************************************
df_var_findcreate
	; save mask
	pha
	; save mask zero state
	cmp #0
	php
	jsr df_var_find
	bcs df_var_findcreate_create
	; If found then check type with mask
	; save var index in X
	tax
	; restore mask state
	plp
	; don't check mask if zero
	beq df_var_findcreate_found
	jsr df_var_addr
	; restore mask
	pla
	and (df_tmpptra)
	; but if mask is non zero then and must be non zero too
	beq df_var_findcreate_err
	pha
df_var_findcreate_found
	; discard mask
	pla	
	txa					; Put index in A
	clc
	rts
df_var_findcreate_create
	; find type (A) and length (X)
	jsr df_var_analyse
	; keep A temporarily
	sta df_tmpptra
	; if not a variable then return with C=1
	bcs df_var_findcreate_errp
	; check if mask needs to be applied
	plp
	beq df_var_analyse_okp
	; else pop the mask and check
	pla
	and df_tmpptra
	bne df_var_analyse_ok
df_var_findcreate_errp
	pla
	pla
df_var_findcreate_err
	sec
	rts
df_var_analyse_okp
	pla
df_var_analyse_ok
	lda df_tmpptra
	; extra space for zero terminator
	inx
	; save data in reverse order to when needed
	phy
	phx
	pha
	; insert space of X bytes
	jsr df_var_insert_space
	bcc df_var_initialise_var
	; error inserting space
	pla
	plx
	ply
	sec
	rts
	
df_var_initialise_var
	; vvt entry = vvt end - 8
	sec
	lda df_vvtend
	sbc #8
	sta df_tmpptra
	lda df_vvtend+1
	sbc #0
	sta df_tmpptra+1
	
	pla						; Get type back
	sta (df_tmpptra)		; put type in vvt slot
	lda #0					; zero the rest
	ldy #7
df_var_zero_vnt
	sta (df_tmpptra),y
	dey
	bne df_var_zero_vnt

	plx						; Get back variable name length
	stx df_tmpptrb
	; vnt entry = vnt end - var name length
	sec
	lda df_vntend
	sbc df_tmpptrb
	sta df_tmpptra
	lda df_vntend+1
	sbc #0
	sta df_tmpptra+1

	dex						; Copy one less from input buff
	ldy df_linoff			; Start at var name beginning
	; copy variable name to vnt slot
df_var_findcreate_copy
	lda df_linbuff,y
	sta (df_tmpptra)
	iny
	_incZPWord df_tmpptra
	dex
	bne df_var_findcreate_copy
	; put in zero terminator
	lda #0
	sta (df_tmpptra)

	ply						; Get back y
	; move offset to reflect comsumed chars
	sty df_linoff
	; index of new variable 1 less than count
	lda df_varcnt
	dec a
	
	clc
	rts
	
