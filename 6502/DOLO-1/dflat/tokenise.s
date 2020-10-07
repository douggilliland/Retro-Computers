;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  TOKENISE.S
;*  Controlling module for tokenisation.  Basically this
;*  module is given a raw input buffer, which it will then
;*  attempt to tokenise fully.  Any syntax errors are
;*  thrown at the first point of detection.  If all goes
;*  well, the parsed input will be in a tokenised buffer
;*  which can be executed in immediate mode or save in the
;*  line number order to memory.
;*  dflat syntax is very simple - every statement must start
;*  with a keyword.  The only exception is assignment and
;*  procedure invocation - but even these scenarios are
;*  tokenised so during runtime we just execute tokens.
;*  The raw buffer is consumed one byte at a time and the
;*  tokenised buffer is written one byte at a time.  The
;*  syntax means there is no need to undo reads of the raw
;*  or tokenised buffer.  The only refinement is that we are
;*  allowed to peek a character in the raw buffer without
;*  consuming it.
;*
;**********************************************************

	; ROM code
	code  

;****************************************
;* df_tk_peek_buf
;* Return next char in A but no change to pointer
;****************************************
df_tk_peek_buf
	ldy df_linoff
	lda df_linbuff,y
	rts

;****************************************
;* df_tk_get_buf
;* Return next char in A and inc pointer
;* Don't advance if null char found
;****************************************
df_tk_get_buf
	ldy df_linoff
	lda df_linbuff,y
	beq df_tk_get_buf_null
	iny
	sty df_linoff
df_tk_get_buf_null
	rts

;****************************************
;* df_tk_put_tok
;* Put A in token buffer and inc pointer
;****************************************
df_tk_put_tok
	ldy df_tokoff
	sta df_tokbuff,y
	iny
	sty df_tokoff
	rts
	
;****************************************
;* df_tk_isnum
;* Check char in A for number 0-9
;* Return: CC = False, CS = True
;****************************************
df_tk_isnum
	cmp #'0'
	bcc df_tk_isnum_false
	cmp #'9'+1
	bcs df_tk_isnum_false
	sec
	rts
df_tk_isnum_false
	clc
	rts
	
;****************************************
;* df_tk_isbin
;* Check char in A for binary digit
;* Return: CC = False, CS = True
;****************************************
df_tk_isbin
	cmp #'0'
	beq df_tk_isbin_true
	cmp #'1'
	beq df_tk_isbin_true
	clc
	rts
df_tk_isbin_true
	sec
	rts

;****************************************
;* df_tk_ishex
;* Check char in A for number 0-9, A-F, a-f
;* Return: CC = False, CS = True
;****************************************
df_tk_ishex
	pha
	jsr df_tk_isnum
	bcs df_tk_ishex_truep
	ora #0x20
	cmp #'a'
	bcc df_tk_ishex_false
	cmp #'f'+1
	bcs df_tk_ishex_false
df_tk_ishex_true
	sec
df_tk_ishex_truep
	pla
	rts
df_tk_ishex_false
	clc
	pla
	rts
	
;****************************************
;* df_tk_isalpha
;* Check next char in A alpha a-z, A-Z
;* Return: CC = False, CS = True
;****************************************
df_tk_isalpha
	pha
	ora #0x20					; Convert to lower case for checking
	cmp #'a'
	bcc df_tk_isalpha_false
	cmp #'z'+1
	bcs df_tk_isalpha_false
	pla
	sec
	rts
df_tk_isalpha_false
	pla
	clc
	rts

;****************************************
;* df_tk_isalphanum
;* Check next char A for a-z,A-Z,0-9
;* Return: CC = False, CS = True
;****************************************
df_tk_isalphanum
	jsr df_tk_isalpha
	bcc df_tk_try_num
	rts
df_tk_try_num
	jsr df_tk_isnum
	rts
	
;****************************************
;* df_tk_isnvar
;* Check next char A for ^ or %
;* Return: CC = False, CS = True
;****************************************
df_tk_isnvar
	cmp #'^'
	beq df_tk_isnvar_true
	cmp #'%'
	beq df_tk_isnvar_true
	clc
	rts
df_tk_isnvar_true
	sec
	rts

;****************************************
;* df_tk_issvar
;* Check next char A for $
;* Return: CC = False, CS = True
;****************************************
df_tk_issvar
	cmp #'%'
	beq df_tk_issvar_true
	clc
	rts
df_tk_issvar_true
	sec
	rts

;****************************************
;* df_tk_isproc
;* Check next char A for _
;* Return: CC = False, CS = True
;****************************************
df_tk_isproc
	cmp #'_'
	beq df_tk_isproc_true
	clc
	rts
df_tk_isproc_true
	sec
	rts

;****************************************
;* df_tk_skip_ws
;* Skip ws in linbuff
;* Return: linoff updated to next non-ws, A = char
;****************************************
df_tk_skip_ws
df_tk_ws_loop1
	jsr df_tk_peek_buf
	jsr df_tk_isws
	bcc df_tk_ws_done
	inc df_linoff
	jsr df_tk_put_tok
	bra df_tk_ws_loop1
df_tk_ws_done
	rts

;****************************************
;* df_tk_isws
;* Check char is ws (only space is counted)
;* Return: CC = False, CS = True
;****************************************
df_tk_isws
	cmp #' '
	bne df_tk_isws_false
	sec
	rts
df_tk_isws_false	
	clc
	rts

;****************************************
;* Find a character expected ignoring ws
;* Input A = expected char
;* CC = found, CS = Error
;****************************************
df_tk_expect
	pha
	; skip ws
	jsr df_tk_skip_ws
	; peek the buffer
	pla
	ldy df_linoff
	cmp df_linbuff,y
	; if not expected char then error
	bne df_tk_expecterr
	clc
	rts
df_tk_expecterr
	sec
	rts

;****************************************
;* Find a character expected ignoring ws
;* Input A = expected char
;* Tokenises the character as well
;* CC = found, CS = Error
;****************************************
df_tk_expect_tok
	jsr df_tk_expect
	bcs df_tk_expecttokret
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	clc
df_tk_expecttokret
	rts

;****************************************
;* Find a character expected ignoring ws
;* Input A = expected char
;* Tokenises the character as well
;* FATAL IF NOT FOUND
;****************************************
df_tk_expect_tok_err
	jsr df_tk_expect_tok
	bcs df_tk_expect_tok_fatal
	clc
	rts
df_tk_expect_tok_fatal
	SWBRK DFERR_SYNTAX

;****************************************
;* Tokenise a constant number
;****************************************
df_tk_num
	; X,A = address, linbuff must be on page boundary
	clc
	lda #lo(df_linbuff)
	adc df_linoff
	tax
	lda #hi(df_linbuff)
	adc #0
	ldy #0				; any numeric format
	jsr con_n_to_a
	bcs df_tk_num_err
	; A = format
	; X = how many digits processed
	; Jump over that many chars
	tay
	clc
	txa
	adc df_linoff
	sta df_linoff
	; Now tokenise an integer
	tya
	cmp #NUM_DEC
	bne df_tk_num_hexbin
	lda #DFTK_INTDEC	; decimal always an int
	bra df_tk_num_put
df_tk_num_hexbin
	clc
	adc #4				; Default to BYT
	cmp #NUM_BIN+4
	beq df_tk_num_bin
	cpx #4				; 4 chars processed = byte
	beq df_tk_num_put
df_tk_num_makeint
	clc
	adc #4				; now make INT
	bra df_tk_num_put
df_tk_num_bin
	cpx #0x0a			; 10 chars processed = byte
	bne df_tk_num_makeint
df_tk_num_put
	jsr df_tk_put_tok
	lda num_a
	jsr df_tk_put_tok
	lda num_a+1
	jsr df_tk_put_tok
	clc
	rts
df_tk_num_err
	sec
	rts

;****************************************
;* Tokenise a constant char
;****************************************
df_tk_char
	; skip the first quote
	jsr df_tk_get_buf
	; put in the token
	lda #DFTK_CHR
	jsr df_tk_put_tok
	; get the char value and save
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	; always put two bytes in, even for a BYTE type
	lda #0
	jsr df_tk_put_tok
	; next byte must be single quote
	jsr df_tk_get_buf
	cmp #0x27
	bne df_tk_char_err
	clc
	rts
df_tk_char_err
	sec
	rts

;****************************************
;* Tokenise a constant string
;****************************************
df_tk_str
	; skip the first quote
	jsr df_tk_get_buf
	; put in the token
	lda #DFTK_STRLIT
	jsr df_tk_put_tok
df_tk_str_ch
	; copy string chars in to token buffer
	; until another quote or end of line
	jsr df_tk_get_buf
	cmp #0
	beq df_tk_str_err
	cmp #0x22
	beq df_tk_str_don
	jsr df_tk_put_tok
	bra df_tk_str_ch
df_tk_str_don
	; zero terminated strings
	lda #0
	jsr df_tk_put_tok
	clc
	rts
df_tk_str_err
	SWBRK DFERR_SYNTAX
	
;****************************************
;* Tokenise a constant (num, string, char)
;****************************************
df_tk_const
	jsr df_tk_skip_ws
	; Check what constant it is
	jsr df_tk_peek_buf
	jsr df_tk_isnum
	bcc df_tk_const_try_str
	jmp df_tk_num
df_tk_const_try_str
	; check for double quote
	cmp #0x22
	bne df_tk_const_try_char
	jmp df_tk_str
df_tk_const_try_char
	; check for single apostrophe
	cmp #0x27
	bne df_tk_const_err
	jmp df_tk_char
df_tk_const_err
	SWBRK DFERR_SYNTAX
	
;****************************************
;* Tokenise a variable - A = mask
;* Return : A = variable index
;****************************************
df_tk_var
	; Find or create variable, index in A
	jsr df_var_findcreate
	bcc df_tk_var_cont
	rts
df_tk_var_cont
	; Save variable index for later
	pha
	; Put VAR escape in token buffer
	lda #DFTK_VAR					
	jsr df_tk_put_tok
	; Get variable index and put in token buffer
	pla
	pha
	jsr df_tk_put_tok
	; count of any array indices
df_tk_var_ck
	; check if array procesing needed
	jsr df_tk_peek_buf
	cmp #'['
	bne df_tk_var_noarry
	; get the bracket and put in token buffer
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	; process numeric expression in bracket
	jsr df_tk_narry
df_tk_var_noarry
	; restore var index
	pla
	clc
	rts

;****************************************
;* Tokenise a parameter in proc definition
;* Return : A = variable index
;****************************************
df_tk_parm
	; if preceeding with non-local qualifier DFTK_VARPARM
	jsr df_tk_peek_buf
	cmp #DFTK_VARPARM
	bne df_tk_parm_skip_var
	; get the qualifier and put in token buffer
	jsr df_tk_get_buf
	jsr df_tk_put_tok	
df_tk_parm_skip_var
	; don't have a certain type of var
	lda #0
	jmp df_tk_var
	
	
;****************************************
;* Tokenise a variable to localise
;* Return : A = variable index
;****************************************
df_tk_localvar
	; Find or create variable, index in A
	jsr df_var_findcreate
	bcc df_tk_localvar_cont
	rts
df_tk_localvar_cont
	; Save variable index for later
	pha
	; Put VAR escape in token buffer
	lda #DFTK_VAR					
	jsr df_tk_put_tok
	; Get variable index and put in token buffer
	pla
	jsr df_tk_put_tok
	clc
	rts

;****************************************
;* Tokenise call or def of proc
;* Mode : A = 0 means def, else call
;****************************************
df_tk_proc
	sta df_procmode
	jsr df_tk_skip_ws
	jsr df_tk_isproc
	bcc df_tk_proc_err
	; Find or create variable, index in A
	lda #DFVVT_PROC
	jsr df_var_findcreate
	bcs df_tk_proc_err
	; Save variable index for later
	pha
	; Put PROC escape in token buffer
	lda #DFTK_PROC					
	jsr df_tk_put_tok
	; Get variable index and put in token buffer
	pla
	pha
	jsr df_tk_put_tok

	; initially assume no args
	stz df_procargs
	
	; Must have an open bracket
	lda #'('
	jsr df_tk_expect_tok_err
	; if immediately followed by close bracket then no parms
	jsr df_tk_peek_buf
	cmp #')'
	beq df_tk_proc_noparm
	; else tokenise parm variables
df_tk_proc_parms
	jsr df_tk_skip_ws
	; call appropriate routine for mode
	lda df_procmode
	bne df_tk_proc_call
	; tokenise parameter variable in def mode
	jsr df_tk_parm
	bra df_tk_proc_skip_call
df_tk_proc_call
	; tokenise expression in call mode
	jsr df_tk_expression
df_tk_proc_skip_call
	bcs df_tk_proc_errp
	; increment number of args
	inc df_procargs
	; what is next non ws char
	jsr df_tk_skip_ws
	cmp #','
	beq df_tk_proc_comma
	cmp #')' 
	bne df_tk_proc_errp
	bra df_tk_proc_noparm
	; comma found, more parms to process
df_tk_proc_comma
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	bra df_tk_proc_parms
df_tk_proc_noparm
	; consume the close bracket
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	
	; restore var index
	pla
	; update arg count if def mode
	ldx df_procmode
	bne df_tk_proc_skip_args
	; get address of proc
	jsr df_var_addr
	; put arg count in dim2
	ldy #DFVVT_DIM2
	lda df_procargs
	sta (df_tmpptra),y
df_tk_proc_skip_args	
	clc
	rts
df_tk_proc_errp
	pla
df_tk_proc_err
	SWBRK DFERR_SYNTAX

;****************************************
;* Parse array index
;****************************************
df_tk_narry
	; if array open bracket encountered
	; then tokenise a numeric expression
	jsr df_tk_expression
	; If a comma is next, then another expression
	lda #','
	jsr df_tk_expect_tok
	bcs df_tk_narry_end
	; copy the comman in to buffer
	jsr df_tk_expression
df_tk_narry_end
	; after the second dimension, must be close sq brak
	lda #']'
	jsr df_tk_expect_tok_err
	rts

;****************************************
;* Parse bracket
;****************************************
df_tk_nbrkt
	; if  open bracket encountered
	; then tokenise a numeric expression
	jsr df_tk_expression
	; skip any ws, copying in to tokbuff
	sec
	jsr df_tk_skip_ws
	; get char, which must be ')'
	jsr df_tk_get_buf
	cmp #')'
	bne df_tk_nbrkt_err
	jsr df_tk_put_tok
	clc
	rts
df_tk_nbrkt_err
	SWBRK DFERR_SYNTAX
	
;****************************************
;* Parse call to numeric proc
;****************************************
df_tk_nterm_proc
	; call mode
	lda #1
	jsr df_tk_proc
	rts

;****************************************
;* Parse numeric term
;****************************************
df_tk_nterm
	; skip any ws first, copying in to tokbuff
	jsr df_tk_skip_ws
	jsr df_tk_peek_buf
	cmp #0
	bne df_tk_nterm_cont
	sec
	rts
df_tk_nterm_cont
	; if open bracket then process it
	cmp #'('
	bne df_tk_nterm_tryfn
	; get the bracket and put in token buffer
	jsr df_tk_get_buf
	jsr df_tk_put_tok
	; go process the open bracket
	jsr df_tk_nbrkt
	rts
df_tk_nterm_tryfn
	pha
	; try decoding a built-in function
	lda #DFTK_FN
	jsr df_tk_matchtok
	bcs df_tk_nterm_try_proc
	; pull old A in to Y but don't use
	ply
	; put the token with MSB set
	ora #0x80
	jsr df_tk_put_tok
	jsr df_tk_exec_parser 
	bcs df_tk_nterm_err
	rts
df_tk_nterm_try_proc
	pla
	; if it's not a func then try proc
	jsr df_tk_isproc
	bcc df_tk_nterm_try_var
	jsr df_tk_nterm_proc
	bcs df_tk_nterm_err
	rts
df_tk_nterm_try_var
	; Non-zero mask means var must be this type
	lda #0
	jsr df_tk_var
	bcs df_tk_nterm_try_const
	rts
df_tk_nterm_try_const
	; Try decoding a constant
	jsr df_tk_const
	bcs df_tk_nterm_err
	rts
df_tk_nterm_err
	SWBRK DFERR_SYNTAX

;****************************************
;* Parse numeric operator
;****************************************
df_tk_nop
	jsr df_tk_skip_ws
	jsr df_tk_peek_buf
	cmp #0
	beq df_tk_nop_false
	; must be an operator token for numeric
	lda #DFTK_OP | DFTK_STROP
	jsr df_tk_matchtok
	bcs df_tk_nop_false
	; got a token
	ora #DFTK_TOKEN
	jsr df_tk_put_tok
	clc
	rts
df_tk_nop_false
	sec
	rts

;****************************************
;* Parse numeric expression
;****************************************
df_tk_expression
	; Tokenise a numeric term
	jsr df_tk_nterm
	; Try and tokenise a numeric operator
	jsr df_tk_nop
	; If an operator was tokenised
	; then loop back for another term
	bcc df_tk_expression
	; If no operator was found then
	; expression is done
	clc
	rts

;****************************************
;* Check end of statement
;****************************************
df_tk_isEOS
	jsr df_tk_skip_ws
	jsr df_tk_peek_buf
	cmp #':'
	beq df_tk_eos
	clc
	rts
df_tk_eos
	; eat the separator
	jsr df_tk_get_buf
	; put in to token buffer
	jsr df_tk_put_tok
	; this is the position of the next statement
	lda df_tokoff
	; put it in the last statement offset slot
	ldy df_tokstidx
	sta df_tokbuff,y
	sec
	rts
	
	
;****************************************
;* Parse user defined proc
;****************************************
df_tk_parse_user_proc
	; put proc token in as a call
	lda #0x81
	jsr df_tk_put_tok
	lda #1
	jsr df_tk_proc
	rts


;****************************************
;* Parse a command
;* Do not fatal error if this fails
;****************************************
df_tk_parse_command
	; only looking for keywords
	lda #DFTK_KW
	jsr df_tk_matchtok
	bcs df_tk_parse_command_err
	; if match then store token in the line buffer
	; Set MSB
	ora #0x80
	jsr df_tk_put_tok
	; call the parser to do tokenise based on the statement token
	lda df_symoff
	jsr df_tk_exec_parser
	bcs df_tk_parse_command_err
	; [1] ignore white space but keep it
	jsr df_tk_skip_ws
	; No error in parsing this command
	clc
df_tk_parse_command_err
	rts

;****************************************
;* lexer
;****************************************
df_lexer_line
	; start at the beginning of the line buffer
	stz df_linoff
	; start at the beginning of the tokenised buffer
	stz df_tokoff
	; set current line to the token buffer
	lda #lo(df_tokbuff)
	sta df_currlin
	lda #hi(df_tokbuff)
	sta df_currlin+1
	; Set the line length to 0
	lda #0
	jsr df_tk_put_tok
	
	; any leading white space, ignore and discard
	jsr df_tk_skip_ws

	; if peek next character is a number then assume line number
	; else assume a statement
	jsr df_tk_isnum
	bcc df_lexer_skip_lnum
	; if line number then capture the line number and advance line buffer pointer
	jsr df_tk_linenum
	bra df_tk_body
df_lexer_skip_lnum
	; if no line number then zero out the line number in the token buffer
	; line zero will indicate an immediate mode command
	lda #0
	jsr df_tk_put_tok				; Line num low byte
	jsr df_tk_put_tok				; Line num high byte
df_tk_body
	; Offset for next statement
	lda df_tokoff
	sta df_tokstidx
	lda #0
	jsr df_tk_put_tok				; Offset to next statement
	; [1] capture white space from line buffer in to tokenised buffer
	jsr df_tk_skip_ws
	; If next non ws is zero then this is an empty line
	; so return with length zero but line number filled in the
	; token buffer
	cmp #0
	beq df_tk_line_empty
	; if next char is _ then parse a user defined proc call
	jsr df_tk_isproc
	bcc df_tk_try_command
	jsr df_tk_parse_user_proc
	bra df_tk_done
df_tk_try_command
	; try  a keyword
	jsr df_tk_parse_command
	bcs	df_tk_try_assign
	bra df_tk_done
df_tk_try_assign
	; nothing but to try an assignment operation
	jsr df_tk_assign
	bcs	df_tk_parseerror
	bra df_tk_done
df_tk_done
	; put statement index stuff here in case of multi-statement line
	; check for : and if present tokenise plus update last statement index
	; then go back to try and process another statement
	jsr df_tk_isEOS
	bcs df_tk_body
	; if not at end of line, then must be error
	jsr df_tk_peek_buf
	cmp #0
	bne df_tk_parseerror
	; Get line length length
	ldy df_tokoff
	; ensure there is always a zero after the last tokenised byte
	lda #0
	sta df_tokbuff,y
	; save the line length
	tya
	sta df_tokbuff
df_tk_line_empty
	clc
	rts
df_tk_parseerror
	SWBRK DFERR_SYNTAX

;****************************************
;* df_tk_parsestatement
;* Execute parse routine for this statement
;* Input: df_tokoff is the token found
;* Return: CC = Parsed ok, CS = Error
;****************************************
df_tk_exec_parser
	asl a
	tax
	jmp (df_tk_tokenjmp,x)
	

;****************************************
;* df_tk_linenum
;* Tokenise line number
;****************************************
df_tk_linenum
	; Convert line number to 16 bit number
	; Save the line number
	; Increment the buffer pointer
	clc
	lda #lo(df_linbuff)
	adc df_linoff
	tax
	lda #hi(df_linbuff)
	adc #0
	ldy #1			; Decimal format only
	jsr con_n_to_a
	clc
	txa
	adc df_linoff
	sta df_linoff
	; Now save line number
	lda num_a
	jsr df_tk_put_tok
	lda num_a+1
	jsr df_tk_put_tok
	rts

;****************************************
;* df_tk_matchtok
;* Try and find a token match against the table df_tokensyms
;* Input:
;*			Current df_linbuff and df_linoff
;* Return: 	CC = No Error, CS = Error
;*			df_linoff points to next char if CC else unchanged
;****************************************
df_tk_matchtok
	; save the mask to check types against
	pha
	; Start at token symbols beginning
	lda #lo(df_tokensyms)
	sta df_symtab
	lda #hi(df_tokensyms)
	sta df_symtab+1
	stz df_symoff
df_tk_checknexttok
	; check this token type first
	pla
	pha
	ldx df_symoff
	and df_tk_tokentype,x
	beq df_tk_symnomatch
	; From the line buffer current pointer
	; Check for a token match
	ldy df_linoff
df_tk_checktokch
	; Get symtable char
	; and mask off MSB
	lda (df_symtab)
	; Save the value and mask off MSB
	pha
	and #0x7f
	; Compare with current line buffer char
	cmp df_linbuff,y
	; If chars not match then this symbol fails
	bne df_tk_symnomatchp
	; If match and symbol has MSB then
	; all of the symbol matched
	pla 
	bmi df_tk_symfound
	; else more chars to match
	; so increment line buffer pointers
	_incZPWord df_symtab
	iny
	bra df_tk_checktokch
df_tk_symnomatchp
	pla
df_tk_symnomatch
	; Increment symbol counter to next symbol
	inc df_symoff
df_tk_symnextentry
	lda (df_symtab)
	; End of symbol is MSB
	bmi  df_tk_foundsymend
	_incZPWord df_symtab
	bra df_tk_symnextentry
df_tk_foundsymend
	; Increment char to point to new symbol
	; for matching with line buffer
	_incZPWord df_symtab
	; If next char is not zero then
	; try and match with line buffer
	lda (df_symtab)
	bne df_tk_checknexttok
	; else symbol table exhausted
	; so no match found
	; Zero symbol counter
	stz df_symoff
	; forget about mask
	pla	
	lda #0
	; Set C to indicate error (no match)
	sec
	rts
df_tk_symfound
	; forget about mask
	pla
	; Save line buffer pointer (points to next char)
	; Clear C to indicate success (match)
	iny
	sty df_linoff
	lda df_symoff
	clc
	rts

	include "dflat\tksymtab.s"
	include "dflat\tkjmptab.s"
	include "dflat\tktyptab.s"
	include "dflat\toksubs.s"
