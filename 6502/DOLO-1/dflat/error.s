;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  ERROR.S
;*  Error handling module.
;*  Whan an error is thrown using BRK, this module handles
;*  displaying the error plus any associated line number
;*  if it was running a program.  It then resets necessary
;*  settings and takes the system back to program edit
;*  mode.  The message uses the general IO handler, thus
;*  output will be to either screen or serial depending on
;*  the BBC keyboard DIP switch.
;*
;**********************************************************

	; ROM code
	code  
	include "dflat\error.i"

	
	
	
	
; Error message table, each msg null terminated
df_tk_errortab
	db	"Ok", 0
	db	"General", 0
	db	"Syntax", 0
	db	"Runtime", 0
	db	"Type mismatch", 0
	db	"Re-Dim", 0
	db	"No repeat", 0
	db	"Proc not found", 0
	db	"Proc parm mismatch", 0
	db	"Unexpected end", 0
	db	"Unclosed if", 0
	db	"No if", 0
	db	"No For", 0
	db	"Filename", 0
	db	"String too long", 0
	db	"Break", 0
	db	"Out of data", 0
	db	"No while", 0
	db	"No line", 0
	db	"No return value"
	db	0

df_tk_error_inline
	db	" in line ", 0
df_tk_error_atpos
	db	" pos ", 0
df_tk_error_error
	db	" error", 0

;****************************************
;* df_trap_error
;* Show an error message
;* errno is error number
;* currlin = Line number
;* exeoff = offset
;* at the end jump to program editor
;****************************************
df_trap_error
	; reset SP
	ldx df_sp
	txs
	; set IO back to normal
	jsr io_init_default
	
	lda #lo(df_tk_errortab)
	sta df_tmpptra
	lda #hi(df_tk_errortab)
	sta df_tmpptra+1
	ldx errno
df_show_err_find
	cpx #0
	beq df_show_err_found
df_show_err_skip
	_incZPWord df_tmpptra
	lda (df_tmpptra)
	bne df_show_err_skip
	_incZPWord df_tmpptra
	dex
	bra df_show_err_find
df_show_err_found
	ldx df_tmpptra
	lda df_tmpptra+1
	jsr io_print_line
	ldx #lo(df_tk_error_error)
	lda #hi(df_tk_error_error)
	jsr io_print_line
	; if line number <> 0 then print it
	ldy #DFTK_LINNUM
	lda (df_currlin),y
	tax
	iny
	lda (df_currlin),y
	cmp #0x00
	bne df_show_err_linnum
	cpx #0x00
	bne df_show_err_linnum
	bra df_show_err_fin
df_show_err_linnum
	_println df_tk_error_inline
	clc
	jsr print_a_to_d
df_show_err_fin
	ldy df_exeoff
	beq df_show_err_done
	_println df_tk_error_atpos
	tya
	tax
	lda #0
	clc
	jsr print_a_to_d	
df_show_err_done
	lda #UTF_CR
	jsr io_put_ch
	clc
	; back to editor
	jmp df_pg_dflat
	