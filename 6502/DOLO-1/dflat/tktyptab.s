;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  RTJUMPTAB.S
;*  Runtime token jump table.
;*  dflat uses four key tables to tokenise and run programs:
;*  - df_tokensyms    - table of token symbols
;*  - df_tk_tokentype - table of token types
;*  - df_tk_tokenjmp  - table of tokenising routines
;*  - df_rt_tokenjmp  - table of runtime routines
;*  The key is the token symbols.  When a line is entered
;*  in to the raw (untokenised) buffer, df_tokensyms is
;*  used to identify tokens.  The position of the found
;*  token is used to then look up type and jump vectors
;*  in the other tables.
;*
;**********************************************************

	; ROM code
	code  

; Tokeniser type table (is it a keyword, function, operator)
; In token order of df_tokensyms
df_tk_tokentype
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW
	db	DFTK_KW

	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_STR
	db 	DFTK_FN | DFTK_STR
	db 	DFTK_FN | DFTK_STR
	db 	DFTK_FN | DFTK_STR
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	db 	DFTK_FN | DFTK_INT | DFTK_BYT
	;* Operators add the order of precedence (0=high, 7=low)
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 0
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 0
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 0
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 1
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 1
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 2
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 2

	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 5
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 6
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 3
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 3
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 3
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 3
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 3
	db 	DFTK_OP | DFTK_INT | DFTK_BYT + 7

	db 	DFTK_STROP | DFTK_STR
	db 	DFTK_OP | DFTK_STR + 3
	db 	DFTK_OP | DFTK_STR + 3
	db 	DFTK_OP | DFTK_STR + 3
	db 	DFTK_OP | DFTK_STR + 3
	db 	DFTK_OP | DFTK_STR + 3
	db 	DFTK_OP | DFTK_STR + 7

	
	
	
	
