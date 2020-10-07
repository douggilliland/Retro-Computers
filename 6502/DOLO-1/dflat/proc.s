;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  PROC.S
;*  dflat module to handle procedures:
;*  - executing a procedure
;*  - find a proc, pass local and non-local parameters
;*  - return from a proc, unload locals
;*  - save the definition of a proc in the VNT and VVT
;*
;**********************************************************

	; ROM code
	code  

; executing a procedure in A
df_rt_exec_proc
	; get pointer to the procedure
	jsr df_var_addr
	; need to save all important vars
	lda df_currlin
	pha
	lda df_currlin+1
	pha
	lda df_exeoff
	pha
	lda df_tokstidx
	pha
	lda df_curstidx
	pha
	lda df_eolidx
	pha
	lda df_ifnest
	pha

	; now initialise the data
	ldy #DFVVT_LO
	lda (df_tmpptra),y
	sta df_currlin
	iny
	lda (df_tmpptra),y
	sta df_currlin+1
	iny
	lda (df_tmpptra),y
	sta df_exeoff
	sta df_curstidx
	lda (df_currlin)
	sta df_tokstidx
	; now execute statements
	jsr df_rt_exec_stat
;	bcs df_rt_exec_proc_err
	; now restore the position
	pla
	sta df_ifnest
	pla
	sta df_eolidx
	pla
	sta df_curstidx
	pla
	sta df_tokstidx
	pla
	sta df_exeoff
	pla
	sta df_currlin+1
	pla
	sta df_currlin
	; should be all restored, so return
	rts

; call procedure
df_rt_proc
	; move past escape token
	inc df_exeoff
	ldy df_exeoff
	lda (df_currlin),y
	; save index for later
	pha
	; get the address of procedure
	jsr df_var_addr
	_cpyZPWord df_tmpptra,df_procptr
	; is index 0 (dim1)
	; then find the procedure
	ldy #DFVVT_DIM1
	lda (df_procptr),y
	bne df_rt_proc_addr
	; find proc, AXY is returned
	pla
	pha
	jsr df_rt_findproc
	; save y (line index)
	sty tmp_a
	; now go and update the proc vvt address
	ldy #DFVVT_HI
	sta (df_procptr),y
	ldy #DFVVT_LO
	txa
	sta (df_procptr),y
	ldy #DFVVT_DIM1
	; get back line index in to A
	lda tmp_a
	sta (df_procptr),y
df_rt_proc_addr
	; move past proc idx and first open bracket
	inc df_exeoff
	inc df_exeoff
	
	; get parm count
	ldy #DFVVT_DIM2
	lda (df_procptr),y
	beq df_rt_proc_parm_none
	; push the right number of parms on
	pha

df_rt_proc_push_parm
	jsr df_rt_neval
;	bcs df_rt_proc_parmother
	ldy df_exeoff
	lda (df_currlin),y
	cmp #')'
	beq df_rt_proc_parm_done
	; move past comma
	inc df_exeoff
	; get parm count off stack
	pla
	; decrement
	dec a
	; and put back on stack
	pha
	; go back and do all required parms
	bne df_rt_proc_push_parm
	; remove parm counter from stack
df_rt_proc_parm_done
	pla
df_rt_proc_parm_none
	; should be at close bracket
	ldy df_exeoff
	lda (df_currlin),y
	cmp #')'
	bne df_rt_proc_parmerr
	; should be no more parms
	; ok, finally we have all parms on rt stack
	; now execute the procedure
	; get back the proc index
	pla
	jmp df_rt_exec_proc
	
df_rt_proc_parmerr
	SWBRK DFERR_PROCPARM


df_rt_def
	; line offset pointing at DFTK_PROC
	; skip over PROC id byte and open bracket
	inc df_exeoff
	inc df_exeoff
	; parms on stack in reverse order to parm list
	; so get each parm and type and save to scratch
	ldx #1									; actual # of parms is X-1
	ldy df_exeoff
df_rt_def_find_var
	iny
	lda (df_currlin),y
	; check if end of parm list
	cmp #')'
	beq df_rt_def_parm_done
	; else check if found a variable escape token (<32)
	cmp #DFTK_VAR
	beq df_rt_def_got_var
	; else check if non-local specifier
	cmp #DFTK_VARPARM						; This is a regular ASCII char
	beq df_rt_def_got_varparm
	bra df_rt_def_find_var
df_rt_def_got_varparm
	; set high bit
	ora #0x80
	; advance over non-local specifier
	iny
df_rt_def_got_var
	; when we get here either A contains DFTK_VAR token (MSB reset) or DFTK_VARPARM token (MSB set)
	; keep only the MSB
	and #0x80
	; skip over DFTK_VAR to var index
	iny
	; get var index and OR with A which will have MSB reset if DFTK_VARPARM was found
	ora (df_currlin),y
	; save the index in scratch
	sta scratch,x
	; increment count
	inx
	bra df_rt_def_find_var
df_rt_def_parm_done
	; save index that we got to
	sty df_exeoff
	; all var indices on the operator stack
	; now load up variables with parameters
	stx df_procargs
	; initially assume no locals
	stz df_procloc
df_rt_def_load_var
	dec df_procargs
	beq df_rt_def_load_var_done
	; get var index
	ldx df_procargs
	lda scratch,x
	
	; save this temporarily
	pha
	; mask off MSB in case it is set
	and #0x7f
	; get vvt slot address
	jsr df_var_addr
	; get the var index off the stack
	pla
	; if MSB is set then this is not a local variable
	bmi df_rt_def_initialise_parm
	; else call the local handling code
	; push the var index on to the runtime stack
	and #0x7f
	jsr df_rt_proc_parm_local
	; increment number of locals
	inc df_procloc
df_rt_def_initialise_parm
	; load type
	lda (df_tmpptra)
	; if array or string type then pop pointer from operator stack
	and #DFVVT_STR|DFVVT_ARRY
	beq df_rt_def_load_var_int
	jsr df_st_popPtr
	bra df_rt_def_load_var_int_skip
df_rt_def_load_var_int
	; must be int pop it from operator stack
	jsr df_st_popInt
df_rt_def_load_var_int_skip
	; update the variable
	ldy #DFVVT_HI
	sta (df_tmpptra),y
	ldy #DFVVT_LO
	txa
	sta (df_tmpptra),y	
	bra df_rt_def_load_var
df_rt_def_load_var_done
	; save the number of lcoal parameters found so they can
	; be unloaded when the proc ends
	lda df_procloc
	jsr df_st_pushByte
	; continue with next statement
	clc
	rts
	; def error - parameter problem
df_rt_def_err
	SWBRK DFERR_PROCPARM

	
; end def for a proc
df_rt_enddef
	; unload any locals
	jsr df_rt_proc_unlocal
	; nothing to do - main loop will terminate
	clc
	rts
	
; return a value
df_rt_return
	; evaluate the return and put on the parameter stack
	jsr df_rt_neval
	; process this like an end of procedure
	jsr df_rt_enddef
	rts
	
	
; unload any local variables from runtime stack
df_rt_proc_unlocal
	jsr df_st_popByte
	tax
	beq df_rt_proc_unload_done
df_rt_proc_unloadvar
	txa
	phx
	; var value is popped first then index
	; get a word and put in tmpb
	jsr df_st_popWord
	stx df_tmpptrb
	sta df_tmpptrb+1
	; get the var number
	jsr df_st_popByte
	; store address in tmpa
	jsr df_var_addr
	; store lo byte first
	ldy #DFVVT_LO
	lda df_tmpptrb
	sta (df_tmpptra),y
	; then hi
	iny
	lda df_tmpptrb+1
	sta (df_tmpptra),y
	; restore counter
	plx
	dex
	bne df_rt_proc_unloadvar
df_rt_proc_unload_done
	rts
	
; push a local variable to the runtime stack
; A = var index
; var index is pushed first, then value
df_rt_proc_local
	; save the var index on rt stack
	jsr df_st_pushByte
	; populate tmpa with var address
	jsr df_var_addr
df_rt_proc_local_load	
	; load x,a with var value lo,hi
	ldy #DFVVT_LO
	lda (df_tmpptra),y
	tax
	iny
	lda (df_tmpptra),y
	; push word on to rt stack
	jsr df_st_pushWord
	clc
	rts
	
df_rt_proc_parm_local				; Jsr to here in a def statement after df_var_addr already called
	; save the var index on rt stack
	jsr df_st_pushByte
	jmp df_rt_proc_local_load
		