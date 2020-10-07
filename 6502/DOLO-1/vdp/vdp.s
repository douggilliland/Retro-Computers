;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  VDP.S
;*  This module implements the drivers of the VDP, which is
;*  a TMS9918a.  The VDP is interfaced to the 6502 bus
;*  through a memory mapped IO (that's how the 6502 likes it).
;*  There are only two bytes in the IO space that are used
;*  and the 6502 needs to poke or read from these with enough
;*  delay to allow the VDP to detect and respond to the
;*  request.  It's interesting that delays are needed - the
;*  MSX computer also used a TMS9918a but with Z80a as the
;*  CPU, which actually didn't need delays.  The 6502 is
;*  a simple processor but a write instruction only needs
;*  4 cycles, hence needing delays.
;*  Considering it came out in the late 70s, the TMS9900
;*  series of VDP are pretty impressive - 2 text modes and
;*  a hires mode too ('a' variant).  Plus 32 hardware
;*  sprites and 15 colours - very good indeed. Also the VDP
;*  uses its own memory so doesn't eat 6502 space.
;*  Downside to having its own memory is that it can be
;*  slow to do large updates e.g. scrolling.  Ok sure a 40
;*  column screen can be scrolled and it looks ok, but
;*  no way would I try to scroll a hires screen.  Hence
;*  why many games on the MSX didn't do smooth scrolling. 
;*
;**********************************************************


	; ROM code
	code
	include "vdp\font.s"

;****************************************
;* int_vdp_handler
;* VDP interrupt handler
;****************************************
int_vdp_handler
	lda vdp_st
	and #0x80			; Check if it is the VDP interrupt
	beq int_vdp_fin
	jsr update_timers	; If it is then update system timers (kernel routine)
	lda vdp_curoff		; Is cursor enabled?
	bne int_vdp_fin		; Skip if so
	lda #0x20			; Check bit 5 of low timer
	and vdp_cnt
	cmp vdp_curstat		; Same as curent state?
	beq int_vdp_fin		; If so no change required
	sta vdp_curstat		; Save new state
	ldx gr_scrngeom+gr_screen_ptr
	lda gr_scrngeom+gr_screen_ptr+1
	tay					; Save address high for later
	jsr vdp_rd_addr		; Read current screen position
	jsr vdp_rd_vram
	eor	#0x80			; EOR top bit (inverse)
	sta vdp_curval		; Save cursor value
	tya					; Get address hi back, X and A contain address still
	jsr vdp_wr_addr		; Write current screen position
	lda vdp_curval		; Write cursor value
	jsr vdp_wr_vram
int_vdp_fin	
	rts

;****************************************
;* vdp_rd_stat
;* Read status register value in A
;* Input : None
;* Output : A - VDP Status Register Contents
;* Regs affected : P, A
;****************************************
vdp_rd_stat_old
	lda VDP_STATUS
	rts
	

;****************************************
;* vdp_wr_reg
;* Write to Register A the value X
;* Input : A - Register Number, X - Data
;* Output : None
;* Regs affected : P
;****************************************
vdp_wr_reg
	stx VDP_MODE1
	ora #0x80
	sta VDP_MODE1
	eor #0x80
	rts
	
;****************************************
;* vdp_wr_addr
;* Write to address in X (low) and A (high) - for writing
;* Input : A - Address high byte, X - Address low byte
;* Output : None
;* Regs affected : P
;****************************************
vdp_wr_addr
	stx VDP_MODE1
	ora #0x40		; Required by VDP
	sta VDP_MODE1
	eor #0x40		; Undo that bit
	
	rts

;****************************************
;* vdp_rd_addr
;* Write to address in X (low) and A (high) - for reading
;* Input : A - Address high byte, X - Address low byte
;* Output : None
;* Regs affected : None
;****************************************
vdp_rd_addr
	stx VDP_MODE1
	sta VDP_MODE1
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	rts
;* Fast version of the above
vdp_rd_addr_fast
	stx VDP_MODE1
	sta VDP_MODE1

	rts
	
;****************************************
;* vdp_rd_vram
;* Read VRAM byte, result in A
;* Input : None
;* Output : A - Byte from VRAM
;* Regs affected : P
;****************************************
vdp_rd_vram
	lda VDP_VRAM;

	nop
	nop
	nop
	nop
	nop

	rts
;* Fast version of the above
vdp_rd_vram_fast
	lda VDP_VRAM;

	rts

	
;****************************************
;* vdp_wr_vram
;* Write VRAM byte in A
;* Input : A - Byte to write
;* Output : None
;* Regs affected : None
;****************************************
vdp_wr_vram
	sta VDP_VRAM

	nop
	nop
	nop
	nop
	nop
	
	rts
;* Fast version of the above
vdp_wr_vram_fast
	sta VDP_VRAM

	rts

;****************************************
;* vdp_poke
;* Write VRAM byte in A, X = Low Add,Y = High Address
;* Input : A - Byte to write
;* Output : None
;* Regs affected : None
;****************************************
vdp_poke
	pha
	tya
	sei
	jsr vdp_wr_addr
	pla
	jsr vdp_wr_vram
	cli
	rts

;****************************************
;* vdp_peek
;* Get VRAM byte in X = Low Add,A = High Address
;* Output : A = byte read
;* Regs affected : None
;****************************************
vdp_peek
	sei
	jsr vdp_rd_addr
	jsr vdp_rd_vram
	cli
	rts

;****************************************
;* vdp_set_base
;* Copy vdp addresses
;* Input : X = Offset in to tables
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_base
	ldy #0
vdp_set_base_copy
	lda vdp_base_table,x
	sta vdp_base,y
	inx
	iny
	cpy #vdp_addr_struct
	bne vdp_set_base_copy
	rts

;****************************************
;* vdp_translate_addr
;* Shift an address X,A by Y bits to the right
;* Result in tmp_alo,tmp_ahi
;****************************************
vdp_translate_addr
	stx tmp_alo
	sta tmp_ahi
vdp_translate_addr_bit
	lsr tmp_ahi
	ror tmp_alo
	dey
	bne vdp_translate_addr_bit
	rts

;****************************************
;* vdp_init_mode
;* Initialise video processor to required mode and addresses
;* Input : Y = Register 0 value, X = Register 1 value
;* Output : None
;* Regs affected : All
;****************************************
vdp_init_mode
	sei
	; use mode value in X for reg 1
	lda #1
	jsr vdp_wr_reg

	; Reg 0 is taken from Y
	tya
	tax
	lda #0
	jsr vdp_wr_reg

	; vdp_addr_nme >> 10
	ldx vdp_base+vdp_addr_nme
	lda vdp_base+vdp_addr_nme+1
	ldy #10
	jsr vdp_translate_addr
	lda #2
	ldx tmp_alo
	jsr vdp_wr_reg

	; vdp_addr_col >> 6
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	ldy #6
	jsr vdp_translate_addr
	lda #3
	ldx tmp_alo
	jsr vdp_wr_reg

	; vdp_addr_pat >> 11
	ldx vdp_base+vdp_addr_pat
	lda vdp_base+vdp_addr_pat+1
	ldy #11
	jsr vdp_translate_addr
	lda #4
	ldx tmp_alo
	jsr vdp_wr_reg

	; vdp_addr_spa >> 7
	ldx vdp_base+vdp_addr_spa
	lda vdp_base+vdp_addr_spa+1
	ldy #7
	jsr vdp_translate_addr
	lda #5
	ldx tmp_alo
	jsr vdp_wr_reg
	
	; vdp_addr_spp >> 11
	ldx vdp_base+vdp_addr_spp
	lda vdp_base+vdp_addr_spp+1
	ldy #11
	jsr vdp_translate_addr
	lda #6
	ldx tmp_alo
	jsr vdp_wr_reg
	
	ldx vdp_base+vdp_bord_col
	lda #7
	jsr vdp_wr_reg

	cli
	rts

;****************************************
;* vdp_set_txt_mode
;* Set up text mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_txt_mode

	ldx #vdp_base_table_txt-vdp_base_table
	jsr vdp_set_base

	ldy #0				; VDP R0
	ldx #%11110000		; 16k, enable display, interrupts enabled, text mode (VDP R1)
	jsr vdp_init_mode
	
	jmp init_fonts
	
;****************************************
;* vdp_set_g1_mode
;* Set up G1 mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_g1_mode
	ldx #vdp_base_table_g1-vdp_base_table
	jsr vdp_set_base

	ldy	#0				; VDP R0
	ldx #%11100000		; 16k, enable display, interrupts enabled, graphics mode 1 (VDP R1)
	jsr vdp_init_mode
	jmp init_fonts

;****************************************
;* vdp_set_hires
;* Set up HI mode
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
vdp_set_hires
	ldx #vdp_base_table_hi-vdp_base_table
	jsr vdp_set_base
	
	sei

	; Point at name table
	ldx vdp_base+vdp_addr_nme
	lda vdp_base+vdp_addr_nme+1
	jsr vdp_wr_addr
	
	; set name for 3 pages (768)
	ldx #0
	ldy #3
vdp_set_hires_fill_nme
	txa						; Name table is 0..255 for 3 pages
	jsr vdp_wr_vram
	inx
	bne vdp_set_hires_fill_nme
	dey
	bne vdp_set_hires_fill_nme
	
	cli

	ldy	#%00000010		; VDP R0
	ldx #%11100000		; 16k, enable display, interrupts enabled, graphics mode 1 (VDP R1)
	jsr vdp_init_mode

	; Override colour table with 0xFF else hires doesn't work right
	; Override pattern table with 0x03 else hires doesn't work right
	sei
	lda #3
	ldx #0xff
	jsr vdp_wr_reg
	lda #4
	ldx #0x03
	jsr vdp_wr_reg
	cli
	
	rts

	
;****************************************
;* init_vdp_g1
;* Initialise video processor graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_g1
	jsr vdp_set_g1_mode
	jsr init_sprtpat_g1
	jsr init_colours_g1
	jsr init_sprites_g1
	rts

;****************************************
;* init_vdp_hires
;* Initialise video processor graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_hires
	jsr vdp_set_hires
	jsr init_sprtpat_g1
	jmp init_sprites_g1


;****************************************
;* init_vdp_txt
;* Initialise video processor text mode
;* Input : None
;* Output : None
;* Regs affected : All
;***************************************
init_vdp_txt
	jmp vdp_set_txt_mode
	

;****************************************
;* fill_vram
;* Fill a number of VRAM bytes with a value
;* Input : X,Y = Fill length (lo,hi), A = Value
;* Output : None
;* Regs affected : All
;* ASSUMES vdp_wr_vram already called
;* Works for < 256 bytes as long as Y=1
;* Else only use for WHOLE pages at a time so X must be ZERO
;* INTERRUPTS MUST HAVE BEEN DISABLED BY THE CALLER!!!!
;****************************************
vdp_fill_vram
	jsr vdp_wr_vram_fast
	dex
	bne vdp_fill_vram
	dey
	bne vdp_fill_vram
	rts

;****************************************
;* clear_vram
;* Set all 16k VDP vram to 0x00
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
clear_vram
	sei
	ldx #0x00			; Low byte of address
	lda #0x00			; High byte of address
	jsr vdp_wr_addr		; Write address to VDP

	ldy #0x40			; 0x40 pages = 16k (X already zero)
	jsr vdp_fill_vram
	cli
	rts
	
;****************************************
;* init_colours_g1
;* Initialise colour table for graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_colours_g1
	sei
	ldx vdp_base+vdp_addr_col
	lda vdp_base+vdp_addr_col+1
	jsr vdp_wr_addr				; Set VDP address
	
	ldx #0x20					; 32 bytes to fill	
	ldy #0x01					; Only 1 pass through
	lda vdp_base+vdp_bord_col	; Border colour
	jsr vdp_fill_vram
	cli
	rts

;****************************************
;* init_sprites_g1
;* Initialise sprite attribute table for graphics 1
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_sprites_g1
	sei
	ldx vdp_base+vdp_addr_spa
	lda vdp_base+vdp_addr_spa+1
	jsr vdp_wr_addr				; Set VDP address
	
	ldx #0x80					; 128 bytes of attribute to fill
	ldy #0x01					; Only 1 pass
	lda #0xd0					; Sprite terminator
	jsr vdp_fill_vram
	cli
	rts

;****************************************
;* init_fonts
;* Initialise fonts 
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_fonts
	sei
	ldx vdp_base+vdp_addr_pat
	lda vdp_base+vdp_addr_pat+1
	jsr vdp_wr_addr				; Write the address
	jsr init_fonts_sub
	cli
	rts

;****************************************
;* init_sprtpat_g1
;* Initialise fonts for sprites
;* Input : None
;* Output : None
;* Regs affected : All
;****************************************
init_sprtpat_g1
	sei
	ldx vdp_base+vdp_addr_spp
	lda vdp_base+vdp_addr_spp+1
	jsr vdp_wr_addr				; Write the address
	jsr init_fonts_sub
	cli
	rts
	
;****************************************
;* init_fonts_sub
;* Initialise fonts common subroutine
;* Input : None
;* Output : None
;* Regs affected : All
;* INTERRUPTS MUST HAVE BEEN DISABLED BY CALLER!!!
;****************************************
init_fonts_sub
	lda #0x00				; XOR with zero = no change
	sta tmp_a
init_write_fonts
	lda #lo(vdp_font)		; Low byte of fonts source
	sta tmp_alo
	lda #hi(vdp_font)		; High byte of fonts source
	sta tmp_ahi
	ldx #0x04				; 4 pages = 1024 bytes
init_pattern
	lda (tmp_alo),y			; Get byte from font table
	eor tmp_a				; Invert if tmp_a is 0xff
	jsr vdp_wr_vram			; Write the byte to VRAM
	iny
	bne init_pattern		; keep going for 1 page
	inc tmp_ahi				; only need to increment high byte of font ptr
	dex						; page counter
	bne init_pattern		; keep going for 4 pages
	lda tmp_a				; get the current eor mask
	eor	#0xff				; Invert the EOR mask
	sta tmp_a				; And save for next go around
	bne init_write_fonts
	
	rts

;**** BASE TABLES ****
vdp_base_table
vdp_base_table_g1
	dw	0x1000			; Name table
	dw	0x1380			; Colour table
	dw	0x0000			; Pattern table
	dw	0x1300			; Sprite attribute table
	dw	0x0800			; Sprite pattern table
	db	%11110100		; White f/gnd, blue background
vdp_base_table_hi
	dw	0x3800			; Name table
	dw	0x2000			; Colour table
	dw	0x0000			; Pattern table
	dw	0x3b00			; Sprite attribute table
	dw	0x1800			; Sprite pattern table
	db	%11110100		; White f/gnd, blue background
vdp_base_table_txt
	dw	0x0800			; Name table
	dw	0				; Colour table NA
	dw	0x0000			; Pattern table
	dw	0				; Sprite attribute table NA
	dw	0				; Sprite pattern table NA
	db	%11110100		; White f/gnd, blue background
