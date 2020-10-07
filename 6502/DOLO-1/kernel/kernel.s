;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  KERNEL.S
;*  This is the main controller of the entire system both
;*  at build and run time.  All core modules are included in
;*  the right order by this file, plus the 65c02 startup
;*  code.
;*  When the system starts up, it executes the initialisation
;*  code at the reset vector location.  This basically
;*  initialises all the devices, clears memory and enables
;*  interrupts.  The BBC keyboard DIP settings are read to
;*  determine whether the computer should use the serial port
;*  for IO (or keyboard / screen) and whether to start in 32
;*  or 40 column mode.
;*  It then passes control to the 'main' user program.
;*
;**********************************************************

	
;****************************************
;*	Set 6502 default vectors	*
;****************************************
	data			; Set vectors
	org 0xfffa		; Vectors like at addresses
	fcw nmi			; 0xfffa : NMI Vector
	fcw init		; 0xfffc : Reset Vector
	fcw irq			; 0xfffe : IRQ Vector
	
	; ROM code
	code			;  
	org 0xc000		; Start of ROM

;* Include all definition and code files in the right order
	include "inc\includes.i"
	include "inc\graph.i"
	include "io\io.i"
	include "dflat\dflat.i"
	include "kernel\zeropage.s"
	include "serial\serial.s"
	include "cia\cia.s"
	include "keyboard\keyboard.s"
	include "sound\sound.s"
	include "vdp\vdp.s"
	include "vdp\graph.s"
	include "kernel\misc.s"
	include "utils\utils.s"
	include "utils\intmath.s"
	include "kernel\main.s"
;	include "monitor\cmd.s"
	include "sdcard\sdcard.s"
	include "sdcard\sd_fs.s"
	include "io\io.s"
	include "dflat\dflat.s"

;* Reset vector points here - 6502 starts here
init	
	; First clear ram
	jmp init_ram		; jmp not jsr to ram initialiser
init_2					; init_ram will jump back to here
	ldx #0xff		; Initialise stack pointer
	txs
	cld
	sei
	
	jsr kernel_init

	jmp main

kernel_init
	jsr init_acia		; initialise the acia
	jsr init_cia0		; initialise the input cia
	jsr init_cia1		; initialise the output cia
	jsr init_keyboard	; initialise keyboard timer settings
	jsr init_snd		; initialise the sound chip
	jsr kb_scan_options	; Check options
	and #0x02			; Bit 1 = Graphics Mode
	jsr gr_init_screen
	jsr io_init_default	; Set default input/output
	jsr init_sdcard		; initialise the sd card interface
	jsr init_fs			; initialise the filesystem
	stz vdp_st
	stz vdp_cnt

	jsr df_init			; Initialise interpreter
	
	cli					; irq interrupts enable
	rts

init_ram
	lda #0x00			; Start at 0x0000
	sta 0x00
	sta 0x01
	ldy #0x02			; But Y initially at 2 to not overwrite pointer
	ldx #0xb0			; Page counter - 0xB000 is max write address
init_ram_1
	sta (0x00),y		; Zero a byte
	iny
	bne init_ram_1		; Do a whole page
	inc 0x01			; Increase page pointer
	dex					; Reduce page count
	bne init_ram_1		; Carry on if not finished
	
	jmp init_2			; Carry on initialisation
	
	
; 6502 jumps here on IRQ or BRK
irq
	_pushAXY

	; Check if IRQ or BRK
	; load P from stack in to A
	tsx
	lda 0x104,x
	; BRK?
	and #0x10
	bne irq_brk
	; if here then normal IRQ
	lda VDP_STATUS			; Read status register
	sta vdp_st
	lda IO_0 + IFR			; Check status register CIA0
	sta cia0_ifr
	lda IO_1 + IFR			; Check status register CIA1
	sta cia1_ifr
	lda SER_STATUS
	sta acia_st
	lda #0x7f				; Clear IFRs
	sta IO_0 + IFR
	sta IO_1 + IFR

	jsr int_vdp_handler		; Execute VDP handler also updates timers
	jsr int_kb_handler		; Execute keyboard handler
irq_done	
	_pullAXY
	rti

;* Handle BRK
irq_brk
	; Handle BRK
	; Get PCL,H minus 2 gives the BRK instruction address
	sec
	lda 0x0105,x
	sbc #2
	sta df_brkpc
	lda 0x0106,x
	sbc #0
	sta df_brkpc+1
	; Get the byte pointed to by old PC
	; which is 1 on from the BRK
	ldy #1
	lda (df_brkpc),y
	sta df_brkval
	sta errno
	; now update the return address
	lda df_pc
	sta 0x105,x
	lda df_pc+1
	sta 0x106,x
	
	_pullAXY
	; when RTI occurs:
	;  will return to error handler
	;  df_brkval will contain signature
	rti

; 6502 Non-maskable interrupt come here
nmi
	rti
	
; Update 24 bit timer and debounce counters
update_timers
	inc vdp_cnt
	bne inc_kb_timers
	inc vdp_cnt_hi
	bne inc_kb_timers
	inc vdp_cnt_hi2
inc_kb_timers
	ldx kb_deb			; Is debounce 0?
	beq skip_kb_deb
	dec kb_deb
skip_kb_deb
	ldx kb_rep			; Is repeat timer 0?
	beq skip_kb_rep
	dec kb_rep
skip_kb_rep
	rts

