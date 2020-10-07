;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  MAIN.S
;*  This is where the main user program is executed by
;*  the 'kernel' once the system is initialised and ready.
;*  Today, main does very little - first shows the system
;*  boot up message, and then passes control to dflat.
;*
;**********************************************************

	; ROM code
	code  

main
	_println msg_hello_world

infinity
	jsr df_pg_dflat
	jmp infinity

msg_hello_world
	;* build.s is generate by the assemble.bat file
	;* all it does is echo an assembler line to
	;* including the build date in the message.
	include "kernel\build.s"
	db "DOLO-1 Microcomputer\r"
	db "Hardware & Software Design\r"
	db "By Dolo Miah\r"
	db "Copyright (c) 2015-18\r\r",0
	
