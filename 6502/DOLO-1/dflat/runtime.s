;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  RUNTIME.S
;*  This module is the runtime coordinator.  When the user
;*  wants to run a program, execution of statements from the
;*  required procedure starts and proceeds from there
;*  according to normal program flow.
;*  This module also contains critical routines for the
;*  evaluation of expressions (numeric and string).
;*  Whilst the code to implement a specific command is in
;*  rtsubs.s, this is the key module that controls everything.
;*
;**********************************************************

	; ROM code
	code  

;****************************************
;* df_initrun
;* Initialise program space for runtime
;****************************************
df_initrun
	; String and array heap initialisation
	; Grows up from end of prog space PLUS 1
	; Initially empty (dim will allocate)
	lda df_prgend
	sta df_starstrt
	lda df_prgend+1
	sta df_starstrt+1
	_incZPWord df_starstrt
	_cpyZPWord df_starstrt,df_starend
	
	; Reset runtime stack (grows up)
	stz df_rtstop

	; Reset parameter stack (grows up)
	stz df_parmtop
	
	; Reset data pointer high byte
	stz df_currdat+1
	
	; clear proc addresses
	jsr df_rt_init_vvt

	; if nest counter zeroed
	stz df_ifnest

;	clc
	rts

;****************************************
;* Initialise vvt
;****************************************
df_rt_init_vvt
	; starting at beginning of vvt
	_cpyZPWord df_vvtstrt,df_tmpptra
	ldx df_varcnt
	beq df_rt_init_done
df_rt_init_vvt_slot
	; zero out first 3 bytes
	lda #0
	ldy #1
	sta (df_tmpptra),y
	iny
	sta (df_tmpptra),y
	iny
	sta (df_tmpptra),y
	iny
	; before doing dim2 check if proc
	; as we don't want to erase the parm count
	lda (df_tmpptra)
	and #DFVVT_PROC
	bne df_rt_init_vvt_skip
	; if not proc then zero dim2
	lda #0
	sta (df_tmpptra),y	
df_rt_init_vvt_skip
	; increment pointer to next slot
	_adcZPWord df_tmpptra,8
	dex
	bne df_rt_init_vvt_slot
df_rt_init_done
;	clc
	rts

;****************************************
;* Evaluate a numeric expression
;****************************************
df_rt_neval
	; push terminator on cpu stack
	; so we know where we are
	lda #0
	pha

	; find escape token or keyword token
	; if escape token push on to operand stack
	; if keyword token push on to operator stack
df_rt_neval_optk
	lda df_exeoff
	; check end of line
	cmp df_eolidx
	beq df_rt_neval_process
	cmp df_tokstidx
	beq df_rt_neval_process
	tay
	lda (df_currlin),y
	bmi df_rt_neval_tk
	cmp #DFTK_ESCVAL
	bcc df_rt_neval_esc
	; check for evaluation terminators
	; specifically ',' and ']'
	cmp #','
	beq df_rt_neval_process
	cmp #']'
	beq df_rt_neval_process
	; check for brackets
	; if close bracket then process
	cmp #')'
	beq df_rt_neval_process
	; if bracket then evaluate expression recursively
	cmp #'('
	bne df_rt_neval_nextbyte
	; move past open bracket
	inc df_exeoff
	; call evaluation function recursively
	jsr df_rt_neval
	bra df_rt_neval_nextbyte
df_rt_neval_esc
	jsr df_rt_eval_esc
	bra df_rt_neval_nextbyte
	; if a token then push on operator stack
df_rt_neval_tk
	sty df_exeoff
	and #0x7f
	; check if op (look up type using X as index)
	; X contains the current operator index
	tax
	lda df_tk_tokentype,x
	; A contains token type
	sta df_tmpptrb
	bit #DFTK_OP
	bne df_rt_neval_tk_op
	; check if fn
	bit #DFTK_FN
	bne df_rt_neval_tk_fn

	; If got here then something wrong
	SWBRK DFERR_TYPEMISM
	
df_rt_neval_tk_op
	; if this op < current top of op stack
	; then do the op as it is higher priority so should
	; not be pushed
	; what is top of the op stack?
	; save current op token value
	; C=0 means process the op now, else don't
	; save current operator index
	stx df_tmpptra
	; mask off to keep priority
	and #DFTK_OPMSK
	sta df_tmpptrb
	; peek top of op stack - pull and push A
	pla
	pha
	; if 0 then nothing so push op
	beq df_rt_neval_pushOp
	; use it to index in to type table
	tax
	lda df_tk_tokentype,x
	; mask off to keep priority
	and #DFTK_OPMSK
	; compare with the saved token type which includes priority
	cmp df_tmpptrb
	; if top of stack >= current then C=1
	; else C=0
	; what is the state of C?
	; if 1 then just pushOp
	beq df_rt_neval_donow
	bcs df_rt_neval_pushOp
df_rt_neval_donow
	; was C=0 so process now before pushing the new op
	; get operator off cpu stack
	pla
	; save the current op on cpu stack
	ldx df_tmpptra
	phx
	; now run the token that came off the stack
	jsr df_rt_run_token
	; get current op off cpu stack in to X
	plx
	; get the token type in to Y
	lda df_tk_tokentype,x
	; now go back around again to check whether to push the op or exec it
	bra df_rt_neval_tk_op
df_rt_neval_pushOp
	; push the operator
	lda df_tmpptra
	pha
	bra df_rt_neval_nextbyte

df_rt_neval_tk_fn
	txa
	; run a fn token - returns a value on stack
	jsr df_rt_run_token
	; move to next byte
df_rt_neval_nextbyte
	inc df_exeoff
	bra df_rt_neval_optk
	; keep going until non-ws char found or end of line / statement

df_rt_neval_process	
	; pop operator off stack and execute
	; keep popping until reached the terminator
	pla
	beq df_rt_neval_done
	; run the token code
	jsr df_rt_run_token
	; top two bytes on stack is the result
	bra df_rt_neval_process
df_rt_neval_done
;	clc
	rts

	
; jump to escape evaluation routine
df_rt_eval_esc
	asl a
	tax
	jmp (df_rt_eval_esc_tab,x)
	
df_rt_eval_esc_tab
	dw df_rt_eval_chr
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved	
	dw df_rt_eval_reserved	; no such thing as bytdec
	dw df_rt_eval_bythex
	dw df_rt_eval_bytbin
	dw df_rt_eval_reserved	
	dw df_rt_eval_intdec
	dw df_rt_eval_inthex
	dw df_rt_eval_intbin
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved
	dw df_rt_eval_reserved	
	dw df_rt_eval_strlit
	dw df_rt_eval_var
	dw df_rt_eval_proc


;****************************************
;* Evaluate a numeric expression and get
;* the result back off the stack in A,X
;****************************************
df_rt_getnval
	; evaluate the expression
	jsr df_rt_neval
	; expecting an int/byte back
	jmp df_st_popInt


;****************************************
;* Evaluate a string expression
;* X, A = Destination buffer / space
;****************************************
df_rt_seval
	; keep X,A on the stack - will be modified
	pha
	phx
	; push original destination
	jsr df_st_pushStr
	; Push the destination to the 6502 stack
	; hi byte first then lo
	; push string idx so we know our starting position
	; in the string buffer
	; this limits all evaluations to 255 bytes
;	lda df_stridx
;	jsr df_st_pushOp

	; find escape token or keyword token
	; if escape token push on to operand stack
	; if keyword operator token push on to operator stack
	; if keyword function token run it

df_rt_seval_optk
	ldy df_exeoff
	; check end of line
	cpy df_eolidx
	beq df_rt_seval_done
	cpy df_tokstidx
	beq df_rt_seval_done
	lda (df_currlin),y
	bmi df_rt_seval_tk
	cmp #DFTK_ESCVAL
	bcc df_rt_seval_esc
	; check for evaluation terminators
	; specifically ',' and ')'
	cmp #','
	beq df_rt_seval_done
	cmp #')'
	beq df_rt_seval_done
	bra df_rt_seval_nextbyte
df_rt_seval_esc
	; the only escape char is STRLIT, VAR or PROC
	cmp #DFTK_STRLIT
	beq	df_rt_seval_esc_strlit
	cmp #DFTK_VAR
	beq	df_rt_seval_esc_var
	cmp #DFTK_PROC
	beq	df_rt_seval_esc_proc

	; error if got here
	SWBRK DFERR_SYNTAX

	; if a token then push on operator stack
df_rt_seval_tk
	sty df_exeoff
	and #0x7f
	; check if op
	tax
	lda df_tk_tokentype,x
	and #DFTK_STROP
	bne df_rt_seval_tk_op
	; check if fn
	lda df_tk_tokentype,x
	and #DFTK_FN
	bne df_rt_seval_tk_fn	
	
	; token type mismatch if got here
	SWBRK DFERR_TYPEMISM

df_rt_seval_tk_op
	; the only op is $+
	; so just ignore!
	txa
	bra df_rt_seval_nextbyte

df_rt_seval_tk_fn
	txa
	jsr df_rt_run_token
	bra df_rt_seval_copy

df_rt_seval_esc_var
	; go process the variable as a normal RVAL
	clc
	jsr df_rt_eval_var
	; copy source off rt stack to destination
df_rt_seval_copy
	; pull destination pointer
	pla
	sta df_tmpptra
	pla
	sta df_tmpptra+1
	; pop source string pointer off stack
	jsr df_st_popStr
	stx df_tmpptrb
	sta df_tmpptrb+1
	; go and copy the string
	jsr df_rt_copyStr
	; now save the destination
	lda df_tmpptra+1
	pha
	lda df_tmpptra
	pha
	
	bra df_rt_seval_nextbyte
	
df_rt_seval_esc_strlit
	; evaluate string literal
	jsr df_rt_eval_strlit
	bra df_rt_seval_copy
	
df_rt_seval_esc_proc
	; not yet suported *******
	SWBRK DFERR_RUNTIME
	
df_rt_seval_nextbyte
	inc df_exeoff
	bra df_rt_seval_optk
	; keep going until non-ws char found or end of line / statement
df_rt_seval_done
	; 
	pla
	pla
	
	clc
	rts


; Copy string from ptrb to ptra
df_rt_copyStr
	ldy #0
df_rt_copyStr_ch
	lda (df_tmpptrb),y
	sta (df_tmpptra),y
	beq df_rt_copyStr_done
	iny
	bra df_rt_copyStr_ch
df_rt_copyStr_done
	tya
	clc
	adc df_tmpptra
	sta df_tmpptra
	lda df_tmpptra+1
	adc #0
	sta df_tmpptra+1
	clc
	rts
	
;****************************************
;* Evaluate and push numeric value
;****************************************
df_rt_eval_intdec
df_rt_eval_bytdec
df_rt_eval_inthex
df_rt_eval_bythex
df_rt_eval_intbin
df_rt_eval_bytbin
df_rt_eval_chr
	; numeric constant
	iny
	lda (df_currlin),y
	tax
	iny
	lda (df_currlin),y
	; save offset before calling any routine
	sty df_exeoff
	; push number on to stack
	jmp df_st_pushInt

df_rt_eval_reserved
	; should not get here
	SWBRK DFERR_RUNTIME

;****************************************
;* Evaluate and push string constant
;****************************************
df_rt_eval_strlit
	sty df_exeoff
	; calculate the effective address
	; y + currlin
	tya
	; set carry to add one extra
	sec
	adc df_currlin
	sta df_tmpptra
	tax
	lda df_currlin+1
	adc #0
	sta df_tmpptra+1
	
	; push string on to stack
	jsr df_st_pushStr
	; now proceed until end of string found
	ldy df_exeoff
df_rt_eval_strlit_ch
	lda (df_currlin),y
	beq df_rt_eval_strlit_done
	iny
	bra df_rt_eval_strlit_ch
df_rt_eval_strlit_done
	sty df_exeoff
	rts

;****************************************
;* Return array parameter
;* A has parm
;****************************************
df_rt_arry_parm
	; move past open bracket or comma
	inc df_exeoff
	; evaluate expression inside bracket
	jsr df_rt_getnval
	txa
;	clc
	rts
	
;****************************************
;* Return double array parameter
;* X = dim1, Y = dim2
;****************************************
df_rt_arry_parm2
	; go get array parm 1
	jsr df_rt_arry_parm
	pha
	ldx #0
	ldy df_exeoff
df_rt_arry_parm2_term
	lda (df_currlin),y
	cmp #']'
	beq df_rt_arry_parm2_skiparry2
	cmp #','
	beq df_rt_arry_parm2_arry2
	sty df_exeoff
	iny
	bra df_rt_arry_parm2_term
df_rt_arry_parm2_arry2
	; get second dimension and put in Y
	jsr df_rt_arry_parm
	tay
	plx
;	clc
	rts
df_rt_arry_parm2_skiparry2
	ldy #0
	plx
;	clc
	rts

	
;****************************************
;* Evaluate and push variable
;* The actual value is pushed if numeric
;* The pointer is pushed if string
;* Carry Set = LVAR else normal RVAR
;* LVAR : Y = line index, A=vvt type, tmpptra = vvt slot address
;****************************************
df_rt_eval_var
	; save carry bit
	php
	; if lvar mode then already passed escape token
	bcs df_rt_eval_lvskip
	; move past var escape token
	iny
	sty df_exeoff
	; get var index and convert to vvt address
	lda (df_currlin),y
	jsr df_var_addr
	; push vvt type first as this is the last thing we need
	lda (df_tmpptra)
df_rt_eval_lvskip
	pha
	; Test A
	tax
	; simple variable
	bpl df_rt_eval_var_notarry
	; even if an array if no dimensions then return base pointer
	; if at end of statement or line then simple copy
	cpy df_eolidx
	beq df_rt_eval_var_simple
	cpy df_tokstidx
	beq df_rt_eval_var_simple
	; if next ch is not [ then simple copy
	iny
	lda (df_currlin),y
	dey
	cmp #'['
	bne df_rt_eval_var_simple
	; go do array handling
	bra df_rt_eval_var_do_arry
df_rt_eval_var_notarry
	; pull the type but not needed here
	pla
	; check if lvar wanted rather than rvar
	plp
	bcs df_rt_eval_lvar
	; just push the vvt lo,hi value
	ldy #DFVVT_LO
	lda (df_tmpptra),y
	tax
	ldy #DFVVT_HI
	lda (df_tmpptra),y
	jmp df_st_pushInt

df_rt_eval_lvar
	; it's not an array, push the address of DFVVT_LO
	; add DFVVT_LO offset to slot address in X,A
	clc
	lda #DFVVT_LO
	adc df_tmpptra
	tax
	lda df_tmpptra+1
	adc #0

	; push pointer to lo,hi
	jmp df_st_pushPtr
	
df_rt_eval_var_simple
;	clc
	; simply get lo,hi and push ptr on stack
	ldy #DFVVT_LO
	lda (df_tmpptra),y
	tax
	ldy #DFVVT_HI
	lda (df_tmpptra),y
	; hi val saved in Y
	tay
	; get the type and discard P
	pla
	pla
	; move Y to A
	tya
	jmp df_st_pushPtr
	
df_rt_eval_var_do_arry
	; move past var index
	inc df_exeoff
	; zero out x,y as they have dimension info
	ldx #0
	ldy #0
	
	; ** Array handling routine **
	; A on stack = type
	; save vvt address
	lda df_tmpptra+1
	pha
	lda df_tmpptra
	pha
	
	; get array parms in X,Y
	jsr df_rt_arry_parm2
	; restore vvt address
	pla
	sta df_tmpptra
	pla
	sta df_tmpptra+1
	; save dimension indices for later
	; save x last as needed first
	phy
	phx
	; if y is zero then need to decide some stuff
	cpy #0
	bne df_rt_eval_var_dim2adj
	; if dim2 > 0 then swap x,y
	ldy #DFVVT_DIM2
	lda (df_tmpptra),y
	ldy #0
	cmp #0
	beq df_rt_eval_var_dim2adj
	; pop from stack in swapped order
	ply
	plx
	; save back on stack
	phy
	phx
	
df_rt_eval_var_dim2adj
	; don't let y=0
	cpy #0
	bne df_rt_eval_var_dim2adjy
	iny
df_rt_eval_var_dim2adjy
	; don't let x=0
	cpx #0
	bne df_rt_eval_var_dim2adjx
	inx
df_rt_eval_var_dim2adjx
	;calculate offset
	;(y-1)*dim1 + (x-1)
	dex
	dey
	; (y-1)
	sty num_a
	stz num_a+1
	; if y is 0 then no need to multiply
	beq df_rt_eval_var_nomult
	; (dim1)
	ldy #DFVVT_DIM1
	lda (df_tmpptra),y
	sta num_b
	stz num_b+1
	; (y-1)*dim1 num_a has result
	jsr int_fast_mult
df_rt_eval_var_nomult
	; move x to a
	txa
	; add x to num_a
	clc
	adc num_a
	sta num_a
	lda num_a+1
	adc #0
	sta num_a+1
	; now have element offset in num_a
	; dimensions in x and y
	plx
	ply
	; get type of variable originally found
	pla
	pha
	and #DFVVT_INT
	beq df_rt_eval_var_push
	; if it is int then multiply offset by 2
	asl num_a
	rol num_a+1
df_rt_eval_var_push
	; add pointer in lo,hi to num_a
	clc
	ldy #DFVVT_LO
	lda (df_tmpptra),y
	adc num_a
	sta num_a
	ldy #DFVVT_HI
	lda (df_tmpptra),y
	bne df_rt_array_exists
	; if vvt address hi is zero then array not dimensioned
	SWBRK DFERR_DIM
df_rt_array_exists
	adc num_a+1
	sta num_a+1	
	; get the type
	pla
	; if not int or byte then push string
	and #DFVVT_INT|DFVVT_BYT
	beq df_rt_eval_var_str
	; get LVAR preference
	plp
	bcs df_rt_eval_ptr
	; need to load lo and hi for int
	; but only lo for byt
	and #DFVVT_INT
	beq df_rt_eval_byt
	; push the contents pointed to by num_a
	lda (num_a)
	tax
	ldy #1
	lda (num_a),y
	jmp df_st_pushInt
df_rt_eval_byt
	lda (num_a)
	tax
	lda #0
	jmp df_st_pushInt
df_rt_eval_var_str
	plp
df_rt_eval_ptr
;	clc
	; put num_a not contents
	ldx num_a
	lda num_a+1
	jmp df_st_pushPtr
	
df_rt_eval_proc
	lda df_parmtop				; Save current position of parameter stack
	pha
	jsr df_rt_proc				; Go and call the user function
	pla							; Get back the original parameter stack position
	cmp df_parmtop				; if it is the same, then no return value!
	beq df_rt_eval_proc_err
	clc
	rts
df_rt_eval_proc_err
	; if no return value then report an errror
	SWBRK DFERR_RETURN



;****************************************
;* get two ints off the runtime stack
;* first parm in ptrb, second in ptra
;****************************************
df_rt_get2Ints
	; the first int popped is actually the second parm
	jsr df_st_popInt
	stx df_tmpptrb
	sta df_tmpptrb+1

	jsr df_st_popInt
	stx df_tmpptra
	sta df_tmpptra+1
	rts

;****************************************
;* get two strings off the runtime stack
;* first parm in ptrb, second in ptra
;****************************************
df_rt_get2Strs
	; the first int popped is actually the second parm
	jsr df_st_popStr
	stx df_tmpptrb
	sta df_tmpptrb+1

	jsr df_st_popStr
	stx df_tmpptra
	sta df_tmpptra+1
	rts

;****************************************
; common code for 2 ints runtime parsing
;****************************************
df_rt_parm_2ints
	; evaluate 1st parm
	jsr df_rt_neval
	; jump over comma
	inc df_exeoff
	; evaluate the 2nd parm
	jsr df_rt_neval

	; pop 2nd parm
	jsr df_st_popInt
	stx df_tmpptrb
	sta df_tmpptrb+1
	; pop 1st parm
	jsr df_st_popInt
	stx df_tmpptra
	sta df_tmpptra+1
	rts

;****************************************
; common code for 3 ints runtime parsing
;****************************************
df_rt_parm_3ints
	; evaluate 1st parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 2nd parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 3rd parm
	jsr df_rt_neval

	; pop 3rd parm
	jsr df_st_popInt
	stx df_tmpptrc
	sta df_tmpptrc+1
	; pop 2nd parm
	jsr df_st_popInt
	stx df_tmpptrb
	sta df_tmpptrb+1
	; pop 1st parm
	jsr df_st_popInt
	stx df_tmpptra
	sta df_tmpptra+1
	rts

;****************************************
; common code for 4 ints runtime parsing
;****************************************
df_rt_parm_4ints
	; evaluate 1st parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 2nd parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 3rd parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 4th parm
	jsr df_rt_neval

	; pop 4th parm
	jsr df_st_popInt
	stx df_tmpptrd
	sta df_tmpptrd+1
	; pop 3rd parm
	jsr df_st_popInt
	stx df_tmpptrc
	sta df_tmpptrc+1
	; pop 2nd parm
	jsr df_st_popInt
	stx df_tmpptrb
	sta df_tmpptrb+1
	; pop 1st parm
	jsr df_st_popInt
	stx df_tmpptra
	sta df_tmpptra+1
	rts

;****************************************
; common code for 5 ints runtime parsing
;****************************************
df_rt_parm_5ints
	; evaluate 1st parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 2nd parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 3rd parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 4th parm
	jsr df_rt_neval
	inc df_exeoff
	; evaluate the 5th parm
	jsr df_rt_neval

	; pop 5th parm
	jsr df_st_popInt
	stx df_tmpptre
	sta df_tmpptre+1
	; pop 4th parm
	jsr df_st_popInt
	stx df_tmpptrd
	sta df_tmpptrd+1
	; pop 3rd parm
	jsr df_st_popInt
	stx df_tmpptrc
	sta df_tmpptrc+1
	; pop 2nd parm
	jsr df_st_popInt
	stx df_tmpptrb
	sta df_tmpptrb+1
	; pop 1st parm
	jsr df_st_popInt
	stx df_tmpptra
	sta df_tmpptra+1

	rts

;****************************************
;* initialise statement to be executed
;* X,A = line pointer, Y=statement offset
;****************************************
df_rt_init_stat_ptr
	; save current line
	stx df_currlin
	sta df_currlin+1
	sty df_curstidx
	sty df_exeoff
	lda (df_currlin)
	sta df_eolidx
	lda (df_currlin),y
	sta df_tokstidx
	rts
	
;****************************************
;* Execute from a statement pointed to
;* by currlin and exeoff
;****************************************
df_rt_exec_stat
	ldx df_currlin
	lda df_currlin+1
	ldy df_exeoff
df_rt_exec_init_ptr
	jsr df_rt_init_stat_ptr
	; assume normal flow of control if next line hi = 0
	; this means no line can execute below page 1, no loss
	stz df_nextlin+1

	; find first token in statement
df_rt_exec_find_tok
	iny
	lda (df_currlin),y
	bpl df_rt_exec_find_tok
df_rt_exec_found_tok
	; skip past token to next byte in readiness
	iny
	sty df_exeoff
	; *** CHECK FOR ENDDEF TOKEN IF SO DONE ***
;	cmp #DFRT_ENDDEF
;	bne df_rt_exec_notend
;	cmp #DFRT_RETURN
;	bne df_rt_exec_notend
;	jmp df_rt_enddef
;	rts
df_rt_exec_notend
	; save the token
	pha
	; Run that statement
	jsr df_rt_run_token
	; what token was run, if it was enddef or return then we are done
	pla
	cmp #DFRT_ENDDEF
	beq df_rt_exec_end
	cmp #DFRT_RETURN
	beq df_rt_exec_end
	
	; check for break, asynch get
	clc
	jsr io_get_ch
	cmp #UTF_ETX					; CTRL-C?
	bne df_rt_exec_cont
	SWBRK DFERR_BREAK
df_rt_exec_cont
	; check if normal flow of control
	lda df_nextlin+1
	bne df_rt_exec_jump
	; try and execute another statement
	ldy df_tokstidx
	sty df_exeoff
	bne df_rt_exec_stat

	; reached end of line, move to next
	clc
	lda (df_currlin)
	adc df_currlin
	sta df_currlin
	lda df_currlin+1
	adc #0
	sta df_currlin+1
	
	; start from first statement in new line
	ldy #3
	sty df_exeoff

	; check if this line has any content (length >0)
	lda (df_currlin)
	sta df_eolidx
	; no more lines (len = 0), program done
	bne df_rt_exec_stat
	; else done
	; normally wouldn't get here except immediate mode
	; if line number <> 0 then error
	lda df_immed
	beq df_rt_unexpected_end
df_rt_exec_end
	clc
	rts
df_rt_unexpected_end
	SWBRK DFERR_IMMEDIATE

	; if hi byte of nextline is not zero then
	; current line = next line
df_rt_exec_jump
	; initialise statement pointer from nextlin,tokstidx
	ldx df_nextlin
	lda df_nextlin+1
	ldy df_tokstidx
	bra df_rt_exec_init_ptr

	
;****************************************
;* Run statement in A
;****************************************
df_rt_run_token
	; mask off MSB
;	and #0x7f
	; multiply by 2
	asl a
	tax
	; execution code finishes with rts
	jmp (df_rt_tokenjmp,x)


;****************************************
;* X,A : Line Address, Y = Index
;* C=0 Found next statement
;* C=1 No statement found
;****************************************
df_rt_nextstat
	; save pointer
	stx df_lineptr
	sta df_lineptr+1
	; if end of program then err
	lda (df_lineptr)
	beq df_rt_nextstat_err
	; if next statement idx 0
	lda (df_lineptr),y
	; then go to next line
	beq df_rt_nextstat_ln
	; else make this Y
	tay
	; X = line low
	ldx df_lineptr
	; A = line high
	lda df_lineptr+1
	clc
	rts
df_rt_nextstat_ln
	; for next line, add line length to ptr
	clc
	lda (df_lineptr)
	adc df_lineptr
	sta df_lineptr
	lda df_lineptr+1
	adc #0
	sta df_lineptr+1
	; if end of program set C
	lda (df_lineptr)
	bne df_rt_nextstat_dn
df_rt_nextstat_err
	ldy #0
	sec
	rts
df_rt_nextstat_dn
	ldx df_lineptr
	lda df_lineptr+1
	; always skip line number and length for start of 1st stat
	ldy #3
	clc
	rts

;****************************************
;* Push current line and statement to runtime stack
;****************************************
df_rt_push_stat
	lda df_curstidx
	jsr df_st_pushByte
	lda df_currlin+1
	ldx df_currlin
	jmp df_st_pushWord
;	clc
;	rts

;****************************************
;* Pop line and statement from runtime stack
;* And transfer control to next statement
;****************************************
df_rt_pop_stat
	jsr df_st_popWord
	stx	df_nextlin
	sta df_nextlin+1
	jsr df_st_popByte
	tay
	ldx df_nextlin
	lda df_nextlin+1
	jsr df_rt_nextstat
	stx df_nextlin
	sta df_nextlin+1
	sty df_tokstidx
;	clc
	rts

;****************************************
;* Find proc definition with var index A
;* Only call if proc not found before
;****************************************
df_rt_findproc
	; save the search index
	sta tmp_a
	; start at program beginning
	_cpyZPWord df_prgstrt,df_lineptr
	ldy #3
	sty df_lineidx
	lda (df_lineptr)
	beq df_rt_findproc_err
df_rt_findproc_cmd
	iny
	lda (df_lineptr),y
	bpl df_rt_findproc_cmd
	cmp #DFRT_DEF
	bne df_rt_findproc_nextstat
	; skip def token
	iny
	; skip proc escape token
	iny
	; now check the proc var number
	lda (df_lineptr),y
	cmp tmp_a
	bne df_rt_findproc_nextstat
	; found it, return AXY with line details
	ldx df_lineptr
	lda df_lineptr+1
	ldy df_lineidx
	clc
	rts
df_rt_findproc_nextstat
	; restore AXY line details and find next statement
	ldx df_lineptr
	lda df_lineptr+1
	ldy df_lineidx
	jsr df_rt_nextstat
	bcs df_rt_findproc_err
	stx df_lineptr
	sta df_lineptr+1
	sty df_lineidx
	bra df_rt_findproc_cmd
	; error
df_rt_findproc_err
	SWBRK DFERR_NOPROC
	
;****************************************
;* Find an escape value
;* Does not check for end of line or statement
;****************************************
df_rt_findescval
	ldy df_exeoff
	dey
df_rt_findescval_loop
	iny
	lda (df_currlin),y
	cmp #DFTK_ESCVAL
	bcs df_rt_findescval_loop
	sty df_exeoff
	rts

;****************************************
;* Get an lvar
;* Assumes next token will be escape DFTK_VAR
;* tmpptra contains vvt slot address
;* X,A is the lvar pointer
;****************************************
df_rt_getlvar
	jsr df_rt_findescval
	; move past the escape value
	iny
	; pointing to variable index
	lda (df_currlin),y
	sty df_exeoff
	; get the vvt address
	jsr df_var_addr
	; get the type
	lda (df_tmpptra)
	; set carry flag to return pointer (lvar)
	sec
	jsr df_rt_eval_var
	jmp df_st_popPtr
;	rts

;****************************************
;* Pop stat from rt stack and continue
;* Y MUST BE ON THE CPU STACK AS IT GETS PLYed HERE
;****************************************
df_rt_pop_stat_go
	jsr df_rt_pop_stat
	; restore stack pointer so we don't lose this entry
	ply
	sty df_rtstop
	clc
	rts

	include "dflat\rtjmptab.s"
	include "dflat\rtsubs.s"
	include "dflat\proc.s"
	
