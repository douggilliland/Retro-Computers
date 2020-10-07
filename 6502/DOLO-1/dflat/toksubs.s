;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  TOKSUBS.S
;*  Module that implements the tokenisation of keywords.
;*  When a line is being parsed, the index of the keyword
;*  found in the symbol table is used to call a routine
;*  here.  The job of a routine here is then to further
;*  parse the raw input e.g. a command that takes two input
;*  parameters, need to do what it needs to identify those.
;*  Despite the number of keywords in dflat, this isn't
;*  anywhere near the size of rtsubs.s (the runtime
;*  equivalent of this) because there is so much in common
;*  synactically.
;*  The tokenised output is put in to its own buffer and
;*  if the whole input was tokenised successfully then
;*  dflat will either try and execute (if in immediate
;*  mode), or save it to program memory in line number
;*  order.
;*
;**********************************************************

	; ROM code
	code  

;****************************************
;* Parse assignment preamble
;****************************************
df_tk_preassign
	; Put assignment token
	; assume its a numeric int for now
	lda #0x80
	jsr df_tk_put_tok
	
	; first find or create a variable
	lda #0	
	jsr df_tk_var
	; next char sound be =
	lda #'='
	jsr df_tk_expect_tok_err
	; skip more ws
	jsr df_tk_skip_ws
	; should not be at end of line
	jsr df_tk_peek_buf
	beq df_tk_parse_ass_err
	clc
	rts
df_tk_parse_ass_err
	SWBRK DFERR_SYNTAX

;****************************************
;* Parse numeric assignment
;****************************************
df_tk_assign
	jsr df_tk_preassign
	; tokenise an expression (int or byte)
	jsr df_tk_expression
	clc
	rts


df_tk_comment
	; copy all subsequent chars to token
	jsr df_tk_peek_buf
	cmp #0
	beq df_tk_comment_done
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	bra df_tk_comment
df_tk_comment_done
	clc
	rts

df_tk_list
	; tokenise an expression
	jsr df_tk_expression
	jsr df_tk_peek_buf
	; if not at the end then keep going
	cmp #','
	bne df_tk_list_done
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	jsr df_tk_expression	
df_tk_list_done
	clc
	rts
	
df_tk_data
df_tk_println
df_tk_print
	; tokenise an expression
	jsr df_tk_expression
	jsr df_tk_peek_buf
	; if not at the end then keep going
	cmp #','
	bne df_tk_print_done
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	bra df_tk_print
df_tk_print_done
	clc
	rts

df_tk_input
	jsr df_tk_skip_ws
	; tokenise a variable
	lda #0
	jsr df_tk_var
	; either cc or cs depending on error condition
	rts
	
df_tk_read
df_tk_dim
	jsr df_tk_skip_ws
	; tokenise a variable
	lda #0
	jsr df_tk_var
	; if not at the end then keep going
	lda #','
	jsr df_tk_expect_tok
	bcc df_tk_dim
	clc
	rts

df_tk_local
	jsr df_tk_skip_ws
	; tokenise a variable
	lda #0
	jsr df_tk_localvar
	; if not at the end then keep going
	lda #','
	jsr df_tk_expect_tok
	bcc df_tk_local
	clc
	rts

; A = 0 : Def
; A = 1 : Call
df_tk_def
	lda #0
	jsr df_tk_proc
	rts


; syntax : for %a=1,10,1
df_tk_for
	jsr df_tk_skip_ws

	; tokenise the for variable
	lda #DFVVT_INT
	jsr df_tk_var

	; always expect '='
	lda #'='
	jsr df_tk_expect_tok_err

	; starting value
	jsr df_tk_expression
	
	; always expect ',' separator
	lda #','
	jsr df_tk_expect_tok_err

	; ending value
	jsr df_tk_expression
	
	; always expect ',' separator
	lda #','
	jsr df_tk_expect_tok_err
	
	; step value
	jsr df_tk_expression
df_tk_for_done
	clc
	rts
	
; call to proc should not occur by itself
df_tk_callproc
	sec
	rts

; timer reset expects an int variable only
df_tk_reset
	jsr df_tk_skip_ws

	; tokenise a variable
	lda #DFVVT_INT
	jsr df_tk_var
	rts

; These functions expect 1 numeric parmeter
df_tk_len
df_tk_chr
df_tk_key
df_tk_stick
df_tk_deek
df_tk_vpeek
df_tk_peek
df_tk_mem
df_tk_rnd
	jsr df_tk_expression
df_tk_closebrkt
	lda #')'
	jsr df_tk_expect_tok_err
	rts

; This function expects a variable only
df_tk_elapsed
	jsr df_tk_skip_ws

	; tokenise a variable
	lda #DFVVT_INT
	jsr df_tk_var
	; must have close braket
	jmp df_tk_closebrkt

; These functions expect 2 parameters
df_tk_left
df_tk_right
df_tk_scrn
	jsr df_tk_2parms
	jmp df_tk_closebrkt

; These functions expect 3 parameters
df_tk_mid
	jsr df_tk_3parms
	jmp df_tk_closebrkt

;all these commands require no parameters
df_tk_else
df_tk_endif
df_tk_enddef
df_tk_repeat
df_tk_next
df_tk_wend
df_tk_run
df_tk_add
df_tk_sadd
df_tk_dir
df_tk_cls
df_tk_new
df_tk_mult
df_tk_div
df_tk_mod
df_tk_asl
df_tk_lsr
df_tk_sub
df_tk_and
df_tk_or
df_tk_lte
df_tk_lt
df_tk_gte
df_tk_gt
df_tk_ne
df_tk_eq
df_tk_slte
df_tk_sgte
df_tk_sne
df_tk_slt
df_tk_sgt
df_tk_seq
	clc
	rts

; These commands expect 1 parameter	
df_tk_while
df_tk_until
df_tk_if
df_tk_elseif
df_tk_wait
df_tk_cursor
df_tk_mode
df_tk_del
df_tk_hires
df_tk_return
	; first parm
	jsr df_tk_expression
	rts

; These commands expect 2 numeric parameters
df_tk_setvdp
df_tk_spritepat
df_tk_spritecol
df_tk_spritenme
df_tk_vpoke
df_tk_poke
df_tk_doke
df_tk_save
df_tk_load
df_tk_2parms
	; first parm
	jsr df_tk_expression
	lda #','
	jsr df_tk_expect_tok_err
	; tokenise second parm
	jsr df_tk_expression
	rts

; these commands expect 3 numeric parameters
df_tk_plot
df_tk_sound
df_tk_colour
df_tk_spritepos
df_tk_renum
df_tk_point
df_tk_3parms
	jsr df_tk_2parms
	lda #','
	jsr df_tk_expect_tok_err
	; tokenise third parm
	jsr df_tk_expression
	rts

; these commands expect 4 numeric parameters
df_tk_play
df_tk_music
df_tk_4parms
	jsr df_tk_2parms
	lda #','
	jsr df_tk_expect_tok_err
	jsr df_tk_2parms
	rts

; these commands expect 5 numeric parameters
df_tk_sprite
df_tk_line
df_tk_5parms
	jsr df_tk_4parms
	lda #','
	jsr df_tk_expect_tok_err
	jsr df_tk_expression
	rts

