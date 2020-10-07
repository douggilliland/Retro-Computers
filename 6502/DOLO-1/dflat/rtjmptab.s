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
;*  - df_rt_tokenjmp  - table of runtime token and escape routines
;*  The key is the token symbols.  When a line is entered
;*  in to the raw (untokenised) buffer, df_tokensyms is
;*  used to identify tokens.  The position of the found
;*  token is used to then look up type and jump vectors
;*  in the other tables.
;*
;**********************************************************

	; ROM code
	code  

; Tokeniser jump table
; In token order of df_tokensyms
df_rt_tokenjmp
	dw	df_rt_assign
	dw	df_rt_proc
	dw	df_rt_comment
	dw	df_rt_println
	dw	df_rt_print
	dw	df_rt_def			; 0x85
	dw	df_rt_enddef		; 0x86
	dw	df_rt_return		; 0x87
	dw	df_rt_local
	dw	df_rt_dim
	dw	df_rt_repeat		; 0x8a
	dw	df_rt_until
	dw	df_rt_for			; 0x8c
	dw	df_rt_next			; 0x8d
	dw	df_rt_while			; 0x8e
	dw	df_rt_wend			; 0x8f
	dw	df_rt_if			; 0x90
	dw	df_rt_else			; 0x91
	dw	df_rt_endif			; 0x92
	dw	df_rt_elseif		; 0x93
	dw	df_rt_data			; 0x94
	dw	df_rt_run
	dw	df_rt_list
	dw	df_rt_input
	dw	df_rt_mode
	dw	df_rt_plot
	dw	df_rt_cursor
	dw	df_rt_cls
	dw	df_rt_vpoke
	dw	df_rt_setvdp
	dw	df_rt_colour
	dw	df_rt_spritepat
	dw	df_rt_spritepos
	dw	df_rt_spritecol
	dw	df_rt_spritenme
	dw	df_rt_sprite
	dw	df_rt_poke
	dw	df_rt_doke
	dw	df_rt_sound
	dw	df_rt_music
	dw	df_rt_play
	dw	df_rt_save
	dw	df_rt_load
	dw	df_rt_dir
	dw	df_rt_del
	dw	df_rt_read
	dw	df_rt_new
	dw	df_rt_renum
	dw	df_rt_wait
	dw	df_rt_reset
	dw	df_rt_hires
	dw	df_rt_point
	dw	df_rt_line
	
	dw	df_rt_vpeek
	dw	df_rt_peek
	dw	df_rt_deek
	dw	df_rt_stick
	dw	df_rt_key
	dw	df_rt_chr
	dw	df_rt_left
	dw	df_rt_right
	dw	df_rt_mid
	dw	df_rt_len
	dw	df_rt_mem
	dw	df_rt_scrn
	dw	df_rt_rnd
	dw	df_rt_elapsed
	
	dw	df_rt_mult
	dw	df_rt_div
	dw	df_rt_mod
	dw	df_rt_asl
	dw	df_rt_lsr
	dw	df_rt_add
	dw	df_rt_sub
	
	dw	df_rt_and
	dw	df_rt_or
	dw	df_rt_lte
	dw	df_rt_gte
	dw	df_rt_ne
	dw	df_rt_lt
	dw	df_rt_gt
	dw	df_rt_eq

	dw	df_rt_sadd
	dw	df_rt_slte
	dw	df_rt_sgte
	dw	df_rt_sne
	dw	df_rt_slt
	dw	df_rt_sgt
	dw	df_rt_seq

; escape sequence handlers
; to do the reverse of tokenising during the listing
; command which is also used to save to disk.
df_rt_escjmp
	dw df_rt_lst_chr
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved	
	dw df_rt_lst_reserved	; no such thing as bytdec
	dw df_rt_lst_bythex
	dw df_rt_lst_bytbin
	dw df_rt_lst_reserved	
	dw df_rt_lst_intdec
	dw df_rt_lst_inthex
	dw df_rt_lst_intbin
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved
	dw df_rt_lst_reserved	
	dw df_rt_lst_strlit
	dw df_rt_lst_var
	dw df_rt_lst_proc
