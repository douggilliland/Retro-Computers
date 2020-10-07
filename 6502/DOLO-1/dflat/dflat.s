;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  DFLAT.S
;*  This is the main controller code file for dflat.
;*  This file includes all the required dflat source files
;*  needed:
;*  - error.s is the error handling module
;*  - var.s is the variable handling module
;*  - tokenise.s is the tokenisation module
;*  - progedit.s is the program editing module
;*  - runtime.s is the runtime module
;*  - stack.s is the stack handling module
;*  The above modules include further source files as
;*  needed.
;*
;**********************************************************

	; ROM code
	code  

	include "dflat\error.s"
	include "dflat\var.s"
	include "dflat\tokenise.s"
	include "dflat\progedit.s"
	include "dflat\runtime.s"
	include "dflat\stack.s"

;****************************************
;* df_init
;* Initialise dflat language settings
;****************************************
df_init
	; Init program space
	jsr df_clear
	
	rts
	
	
;****************************************
;* df_clear
;* Initialise program space
;****************************************
df_clear
	; Start of program space
	lda #lo(DF_PROGSTART)
	sta df_prgstrt
	sta df_prgend
	lda #hi(DF_PROGSTART)
	sta df_prgstrt+1
	sta df_prgend+1
	; Terminal value in prog space
	lda #0
	sta (df_prgstrt)

	; Variable name table
	; Grows down from hi mem
	lda #lo(DF_MEMTOP)
	sta df_vntstrt
	sta df_vntend
	lda #hi(DF_MEMTOP)
	sta df_vntstrt+1
	sta df_vntend+1

	; Variable value table
	; Grows down from vnt
	lda df_vntstrt
	sta df_vvtstrt
	sta df_vvtend
	lda df_vntstrt+1
	sta df_vvtstrt+1
	sta df_vvtend+1
	
	; No variables - zero the count
	stz df_varcnt
	
	; String accumulator
	lda #lo(df_raw)
	sta df_sevalptr
	lda #hi(df_raw)
	sta df_sevalptr+1

	rts
	
