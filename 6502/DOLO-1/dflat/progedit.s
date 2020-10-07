;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  PROGEDIT.S
;*  dflat module to enable editing of a dflat program.
;*  dflat bascially starts here - waiting for user input
;*  when a line is entered, if it is not preceeded by a
;*  line number it is tokenised and attempted to be run
;*  immediatly.  If it is preceeded by a line number, that
;*  number is used to save the tokenised line in the right
;*  position in memory.
;*  So this is just like a good old editing session using
;*  nearly any common flavour of 80s basic. However dflat
;*  tokenises everything except whitespace and string
;*  constants - even when saving.  Unlike my trust Oric-1
;*  where I could type in any garbage and it would be
;*  saved with the line number, dflat needs to be able to
;*  tokenise the line.  So it's actually a bit more like
;*  Atari 8 bit BASIC.
;*
;**********************************************************


;****************************************
;* df_pg_find_line
;* Find a line number in X(L), A(H)
;* Return X(L), A(H) of line, Y = Length
;* C=1 Exact match not found, C=0 Exact Found
;* If not exact match then next highest line address
;* Will be in X and A
;****************************************
df_pg_find_line
	stx num_a
	sta num_a+1
	lda df_prgstrt
	sta num_tmp
	lda df_prgstrt+1
	sta num_tmp+1
df_pg_check_next_line
	lda num_tmp
	cmp df_prgend
	bne df_pg_check_line
	lda num_tmp+1
	cmp df_prgend+1
	bne df_pg_check_line
df_pr_line_gt_target	
	; End of program or line > target
	; Load Y with the length
	lda (num_tmp)
	tay
	ldx num_tmp
	lda num_tmp+1
	sec
	rts
df_pg_check_line
	ldy #DFTK_LINNUM
	lda num_a
	cmp (num_tmp),y
	bne df_pr_line_nomatch
	iny
	lda num_a+1
	cmp (num_tmp),y
	bne df_pr_line_nomatch
	; Got an exact match
	lda (num_tmp)
	tay
	ldx num_tmp
	lda num_tmp+1
	clc
	rts
df_pr_line_nomatch
	; Check if this line > target
	sec
	ldy #DFTK_LINNUM
	lda num_a
	sbc (num_tmp),y
	iny
	lda num_a+1
	sbc (num_tmp),y
	bcc df_pr_line_gt_target
df_pr_line_next
	; Else we go to next line
	clc
	lda num_tmp
	adc (num_tmp)
	sta num_tmp
	lda num_tmp+1
	adc #0
	sta num_tmp+1
	bra df_pg_check_next_line
	
;****************************************
;* df_pg_insert_block
;* Insert a block at adr (X, A) of size Y
;* df_prgend updated
;* C=1 Error, C=0 Ok
;****************************************
df_pg_insert_block
	; Inserting requires a block copy from
	; end of program space to the insert address
	
	; Save address as this is the lowest address
	stx num_a
	sta num_a+1
	; End of program space is the first byte to move
	lda df_prgend
	sta num_x
	lda df_prgend+1
	sta num_x+1	
df_pg_insert_byte
	; Move a byte from the current top
	lda (num_x)
	; To the new top (+Y)
	sta (num_x),y
	; Compare current address with lowest
	lda num_x
	cmp num_a
	bne df_pg_insert_next_byte
	lda num_x+1
	cmp num_a+1
	bne df_pg_insert_next_byte
	; Finished, update program end pointer
	clc
	tya
	adc df_prgend
	sta df_prgend
	lda df_prgend+1
	adc #0
	sta df_prgend+1
	clc
	rts
df_pg_insert_next_byte
	; Decrement current address
	sec
	lda num_x
	sbc #1
	sta num_x
	lda num_x+1
	sbc #0
	sta num_x+1
	bra df_pg_insert_byte

;****************************************
;* df_pg_delete_block
;* Delete a block at adr (X, A) of size Y
;* df_prgend updated
;* C=1 Error, C=0 Ok
;****************************************
df_pg_delete_block
	; Deleting requires a block copy from
	; deletion address to end of program
	
	; Save address as this is the start address
	stx num_a
	sta num_a+1
df_pg_delete_byte
	; Move a byte from current+Y
	lda (num_a),y
	; Down to current
	sta (num_a)
	; Compare current address with lowest
	lda num_a
	cmp df_prgend
	bne df_pg_delete_next_byte
	lda num_a+1
	cmp df_prgend+1
	bne df_pg_delete_next_byte
	; Finished, update program end pointer
	sty num_a
	sec
	lda df_prgend
	sbc num_a
	sta df_prgend
	lda df_prgend+1
	sbc #0
	sta df_prgend+1
	clc
	rts
df_pg_delete_next_byte
	; Decrement current address
	clc
	lda num_a
	adc #1
	sta num_a
	lda num_a+1
	adc #0
	sta num_a+1
	bra df_pg_delete_byte


;****************************************
;* Get a line of input
;* Input: C=1 for echo, 0 for no echo
;* Output: C=0 means linbuff is valid
;****************************************
df_pg_inputline
	; C is set on input for echo or not
	; Read a line of input
	jsr io_read_line
	; If nothing entered then sec
	cpy #0
	bne df_pg_inputline_ok
	sec
	rts
df_pg_inputline_ok
	; Copy input bytes to line buffer
	; for lexical analysis
df_pg_copyinputtolinbuff
	lda (buf_lo),y
	sta df_linbuff,y
	dey
	bpl df_pg_copyinputtolinbuff
	clc
	rts

;****************************************
;* Tokenise line buffer
;* Set line to 0x0000 if immediate line
;****************************************
df_pg_tokeniseline
	jsr df_lexer_line
	bcc df_pg_tokeniseline_ok
	rts
df_pg_tokeniseline_ok
	clc
	rts

;****************************************
;* df_pg_dflat
;* Start a dflat editing session
;****************************************
df_pg_dflat
	; stack pointer
	tsx
	stx df_sp
	; error handler address
	lda #lo(df_trap_error)
	sta df_pc
	lda #hi(df_trap_error)
	sta df_pc+1
	
	; make sure normal I/O is resumed
	jsr io_init_default
df_pg_prompt
	ldx #lo(df_pg_prompt_msg)
	lda #hi(df_pg_prompt_msg)
	jsr io_print_line
	stz df_immed
df_pg_getcommand
	; current line is the token buffer when editing
	lda #lo(df_tokbuff)
	sta df_currlin
	lda #hi(df_tokbuff)
	sta df_currlin+1
	sec
	jsr df_pg_inputline
	bcs df_pg_done
	jsr df_pg_tokenise
	lda df_immed
	beq df_pg_getcommand
	; run from tokbuff
	ldx #lo(df_tokbuff)
	lda #hi(df_tokbuff)
	; always skip length and line number
	ldy #3
	sty df_exeoff
	; init currlin
	jsr df_rt_init_stat_ptr
	; start execution
	jsr df_rt_exec_stat
	; Go and get another line of input
	bra df_pg_prompt
	; if blank line then return to cmd
df_pg_done
	clc
	rts

	; tokenise the line
df_pg_tokenise
	stz errno
	jsr df_pg_tokeniseline
	jsr df_initrun
	; check if line number == 0
	ldy #DFTK_LINNUM
	lda df_tokbuff,y
	bne df_pg_line_number
	ldy #DFTK_LINNUM+1
	lda df_tokbuff,y
	bne df_pg_line_number
	
	; line number == 0 so in immediate mode from tokbuff
	; don't zero out the line length as some routines use it
	; run the line in immediate mode
	lda #1
	sta df_immed
	rts

	; put the numbered line in to the right bit of memory
df_pg_line_number
	; Check if this line exists
	ldy #DFTK_LINNUM
	lda df_tokbuff,y
	tax
	iny
	lda df_tokbuff,y
	jsr df_pg_find_line
	; Save line address for later
	phx
	pha
	; If line exists then it needs deleting
	bcs df_pg_skip_del_line

	; delete line from program
	jsr df_pg_delete_block
df_pg_skip_del_line
	; If line length is zero
	; then nothing else to do (i.e. line was deleted)
	ldy #DFTK_LINLEN
	lda df_tokbuff,y
	tay
	; save the tokenised line length
	phy
	bne df_pg_insertline
	; Length was zero, so get temp stuff off stack
	ply
	pla
	plx
	rts

	; insert a program line unless it is immediate
df_pg_insertline
	; Restore previously saved length
	ply
	; Restore previously saved address to reinsert to
	pla
	plx
	; And save it all back to stack again
	phx
	pha
	phy
	; We now have insert address and length
	jsr df_pg_insert_block
	; Restore length and sub 1 to get index in to this line
	ply
	dey
	; Restore address to a pointer
	pla
	sta num_a+1
	plx
	stx num_a
	; num_a is destination, tokbuff is source, Y is size-1
df_pg_insertlinbyte
	lda df_tokbuff,y
	sta (num_a),y
	dey
	bpl df_pg_insertlinbyte
	rts
	
df_pg_prompt_msg
	db "Ready",UTF_CR,0
