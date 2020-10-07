;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  ZEROPAGE.S
;*  This module name is misleading it is not only zero page
;*  allocations, but also page 2, 3, 4, 5, 6, 7 and beyond
;*  Basically, this module defines:
;*  - All zero page variables for system and dflat
;*  - Page 1 is stack so no need to worry about that here
;*  - Page 2 is the serial IO buffer for the 6551 ACIA
;*  - Page 3 and 4 is a 512 buffer for SD card sector IO
;*  - Page 5 onwards is mainly for dflat working storage
;*    but also non-zero page storage for general IO, file
;*    system and scratch usage.
;*  memstart is a handy label that indicates the first
;*  location that we can store dflat programs from.
;*  Zero page is a valuable asset as the 6502 can access
;*  this page one cycle quicker than the rest of memory
;*  and infact some addressing modes can only use ZP.
;*  Due to the value of zero page, a lot of system and
;*  dflat variables are put here.  But we don't have the
;*  luxury for single use variables - so you will also
;*  see a lot of temporary sounding names which are
;*  have multiple used across the code base.
;*
;**********************************************************

	; Zero page declarations
	bss
	org 0x0000
vdp_st		ds	1		; VDP status
cia0_ifr 	ds	1		; CIA0 ICR status
cia1_ifr 	ds	1		; CIA1 ICR status
acia_st		ds	1		; ACIA status

vdp_cnt		ds	1		; VDP interrupt counter
vdp_cnt_hi 	ds	1		; VDP counter high
vdp_cnt_hi2	ds	1		; VDP counter high 2
vdp_curoff	ds	1		; Cursor off (0 = On)
vdp_curstat	ds	1		; Cursor status
vdp_curval	ds	1		; Cursor value on screen
vdp_blank	ds	1		; Screen blank value normally 32

kb_raw  	ds	1		; Raw keyboard code
kb_last		ds	1		; Raw code of last key
kb_code 	ds	1		; Converted keyboard code
kb_stat		ds	1		; Keyboard status for caps and shift lock
kb_deb		ds	1		; VB periods since last KB spike
kb_rep		ds	1		; Keyboard repeat timer
kb_rep_tim 	ds	1		; Default repeat speed
kb_rep_del 	ds	1		; Default repeat delay timing
kb_debounce ds	1		; Default repeat debounce

tmp_alo 	ds	1		; VDP addresses lo
tmp_ahi 	ds	1		; VDP addresses hi
tmp_blo 	ds	1		; Temp address lo
tmp_bhi		ds	1		; Temp address hi
tmp_clo		ds	1		; Temp address lo
tmp_chi		ds	1		; Temp address hi
tmp_a		ds	1		; Temp storage a


buf_lo		ds	1		; Line buffer address low
buf_hi		ds	1		; Line buffer address high
buf_sz		ds	1		; Buffer size
buf_ef		ds	1		; End file / line marker

sd_slo		ds	1		; Sector pointer low
sd_shi		ds	1		; Sector pointer high
; SD card driver parameters
sd_sect		ds 4		; SD Card sector address
sd_addr		ds 4		; SD Card byte address

; File system parameters
fs_bootsect	ds 4		; Start of partition (usually 0x0000)
fs_fatsect	ds 4		; Start of FAT tables
fs_rootsect	ds 4		; Start of Root Directory
fs_datasect	ds 4		; Start of Data Area
fs_dirsect	ds 4		; Current directory

cmd_lo		ds	1		; Command address lo
cmd_hi		ds	1		; Command address hi
cmd_mem		ds	1		; Command memory type
cmd_tmplo	ds	1		; Command temp pointer/storage
cmd_tmphi	ds	1		; Command temp pointer/storage

fh_temp		ds	4		; File handling temporary storage

; ** Integer function storage **
num_a		ds	4		; 4 byte primary accumulator
num_b		ds	4		; 4 byte secondary accumulator
num_x		ds	4		; 4 byte x register
num_tmp		ds	4		; 4 byte temp space
num_buf		ds	8		; 8 byte string buffer

;
; **** INTERPRETER ZERO PAGE ****
;
errno		ds	1		; General error condition status
df_immed	ds	1		; Immediate mode (0 = not immediate)
df_sp		ds	1		; Stack pointer after error to restore to
df_pc		ds	2		; PC after error to return to
df_brkpc	ds	2		; PC pushed on the stack for BRK
df_brkval	ds	1		; Byte after BRK instruction
df_prgstrt	ds	2		; Start of program code
df_prgend	ds	2		; End of program code
df_vntstrt	ds	2		; Variable name table start
df_vntend	ds	2		; Variable name table end
df_vvtstrt	ds	2		; Variable value table start
df_vvtend	ds	2		; Variable value table end
df_varcnt	ds	1		; Variable counter
df_starstrt	ds	2		; String and array table start
df_starend	ds	2		; String and array table end
df_rtstop	ds	1		; Runtime stack pointer
df_parmtop	ds	1		; Top of parameter stack (grows up)
df_strbuff	ds	1		; String expression buffer
df_stridx	ds	1		; Top of string buffer (grows down)
df_sevalptr	ds	2		; Pointer to next free char in string eval

df_linoff	ds	1		; Offset in to line buffer
df_tokoff	ds	1		; Offset in to tokenised buffer
df_eolidx	ds	1		; End of line index (i.e length)
df_tokstidx	ds	1		; Offset to the next statement offset
df_curstidx	ds	1		; Offset to the start of currently executing statement
df_symtab	ds	2		; Pointer to next free symtab entry
df_symoff	ds	1		; Offset in to token table
df_symini	ds	2		; Start of symtab
df_currlin	ds	2		; Execution current line pointer
df_exeoff	ds	1		; Execution line buffer offset
df_nextlin	ds	2		; Next line to execute
df_tmpptra	ds	2		; Temp pointer a
df_tmpptrb	ds	2		; Temp pointer b
df_tmpptrc	ds	2		; Temp pointer c
df_tmpptrd	ds	2		; Temp pointer d
df_tmpptre	ds	2		; Temp pointer e
df_procmode	ds	1		; Only used during tokenisation
df_procargs	ds	1		; Only used during tokenisation
df_procloc	ds	1		; Counts the number of local parameters
df_procptr	ds	2		; Pointer to proc vvt slot
df_lineptr	ds	2		; Pointer to line during searches
df_lineidx	ds	1		; Pointer to line index during searches
df_ifnest	ds	1		; Global nested if counter
df_currdat	ds	2		; Data current line pointer
df_datoff	ds	1		; Data line buffer offset
df_rnd		ds	1		; Random number seed

; File handle parameters
fh_handle	ds	FileHandle

; vdp settings
vdp_base	ds	vdp_addr_struct

; Screen geometry
gr_scrngeom	ds	gr_screen



;***** END OF ZERO PAGE *****
_end_zero_page

	org 0x0200			; Non-zero page (page 2 onwards)
ser_buf		ds	256		; Serial input / output line buffer

	org 0x0300			; SD Card data buffer (page 3 and 4)
sd_buf		ds	512

	org 0x0500			; Page 5 = dflat space
df_linbuff
df_raw		ds	128		; untokenised input line
df_tokbuff
df_tok		ds 	128		; tokenised output line

	org 0x0600			; Page 6 = fixed space for runtime stack
df_rtstck
df_rtspace	ds	256

	org 0x0700			; Page 7 = 1/2 page fixed space for operator stack
df_opstck
df_opspace	ds	128

;***** NON-ZERO PAGE VARIABLES *****

; Acticve IO device settings
io_block	ds	io_struct

; File entry current dir entry
fh_dir		ds	FileHandle

; Scratch area
scratch		ds	256

;***** THIS IS THE START OF FREE SPACE **
mem_start

