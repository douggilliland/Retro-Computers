;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  SDCARD.S
;*  Low level SD card driver routines.  This module implements
;*  software bit banging through VIA 2 port B of an SD card
;*  interface.  So the card is clocked in software which is
;*  not great for performance but fast enough for my
;*  purposes.  I think we can get around 8.5KB/s raw sector
;*  read/write speed, translating to around 5.5KB/s of useful
;*  throughput using the filesystem.
;*
;**********************************************************

	; ROM code
	code

;****************************************
;* init_sdcard
;* Initialise SD card interface after CIA2!
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
init_sdcard
	_println sd_msg_initialising

	lda #SD_CS						; Unselect device
	tsb SD_REG
	lda #SD_CLK						; Set clock low
	trb SD_REG
	lda #SD_MOSI					; DI/MOSI high
	tsb SD_REG
	ldx #8							; 8*0.125ms = 1ms
	jsr long_delay

	ldx #8							; 10 bytes of 0xff
	lda #0xff
init_sd_pulse
	jsr sd_sendbyte					; Send the 0xff byte
	dex
	bne init_sd_pulse
	lda #SD_CS						; Unselect device
	tsb SD_REG

init_cmd0
	jsr sd_sendcmd0
	cmp #0xff						; 0xff is not a valid response
	bne init_acmd41
	bra init_sdcard
	
init_acmd41

	jsr sd_sendcmd55

	jsr sd_sendcmd41
	
	cmp #0							; Was R1 = 0
	bne init_acmd41					; Retry if not
	
init_cmd16
	jsr sd_sendcmd16
	
	rts

;****************************************
;* sd_startcmd
;* Start a cmd frame by sending CS high to low
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_startcmd
	pha
	lda #0xff						; Send 0xff
	jsr sd_sendbyte					; Delay / synch pulses
	jsr sd_sendbyte					; With CS not asserted

	lda #SD_CS						; Chip select bit
	trb SD_REG						; Now set it low
	pla
	rts

;****************************************
;* sd_endcmd
;* End a cmd frame by sending CS high
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_endcmd
	pha
	lda #SD_CS						; Chip select bit
	tsb SD_REG						; First set it high
	pla
	rts

;****************************************
;* sd_sendbyte
;* Low level byte send routine
;* Input : A = byte to send
;* Output : None
;* Regs affected : None
;****************************************
sd_sendbyte
	pha
	phy

	sta tmp_a						; For shifting out
	ldy #8							; 8 bits to shift out
	lda SD_REG						; Load the SD register to A
sd_shiftoutbit
	ora #SD_MOSI					; And initially set output bit to '1'
	asl tmp_a						; Unless the bit to transmit is '0'
	bcs sd_shiftskiplo				; so then EOR the bit back to 0
	eor #SD_MOSI
sd_shiftskiplo
	sta SD_REG						; Save data bit first, it seems, before clocking
	
	inc SD_REG
	dec SD_REG

	dey								; Count bits
	bne sd_shiftoutbit				; Until no more bits to send

	ply
	pla

	rts

;****************************************
;* sd_getbyte
;* Low level get a byte
;* Input : A = response byte received
;* Output : None
;* Regs affected : None
;****************************************

sd_getbyte
	phy
	phx

	lda SD_REG
	ora #SD_MOSI					; Set MOSI high
	sta SD_REG
	tay								; Same as A with clock high
	iny
	tax								; Same as A with clock low
	
	; Unroll the code almost 20% faster than slow version
	; bit 7
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 6
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 5
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 4
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 3
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 2
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 1
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a
	; bit 0
	sty SD_REG
	lda SD_REG						; Sample SD card lines (MISO is the MSB)
	stx SD_REG
	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
	rol tmp_a						; Rotate carry state in to tmp_a

	lda tmp_a						; Return response in A

	plx
	ply

	rts

;sd_getbyte							; OLD and SLOW version
;	phy
;
;	lda SD_REG
;	ora #SD_MOSI					; Set MOSI high
;	sta SD_REG
;	
;	ldy #8							; Shift in the 8 bits
;sd_shiftinbit
;	inc SD_REG
;	lda SD_REG						; Sample SD card lines (MISO is the MSB)
;	dec SD_REG
;	cmp #SD_MISO					; Trial subtract A-MISO, C=1 if A >= MISO else C=0
;	rol tmp_a						; Rotate carry state in to tmp_a
;	dey								; Next bit
;	bne sd_shiftinbit
;
;	lda tmp_a						; Return response in A
;	
;	ply
;
;	rts

;****************************************
;* sd_getrespbyte
;* Low level get response routine
;* Input : A = response byte received
;* Output : None
;* Regs affected : None
;****************************************
sd_getrespbyte
	phx
	ldx #0							; Try up to 256 times
sd_respff
	inx								; Retry counter
	beq sd_resptimeout
	jsr sd_getbyte
	cmp #0xff						; Keep reading MISO until not FF
	beq sd_respff
sd_resptimeout
	plx
	rts

;****************************************
;* sd_busy
;* Low level busy check routine
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_busy
	pha
sd_isbusy
	jsr sd_getbyte
	cmp #0xff						; Keep reading MISO until FF
	bne sd_isbusy
	pla
	rts

;****************************************
;* sd_waitforn0byte
;* Low level routine waits for card to be ready
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_waitforn0byte
	jsr sd_getrespbyte
	beq sd_waitforn0byte					; Zero byte means not ready
	rts

;****************************************
;* sd_sendcmd0
;* Send CMD0
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd0
	jsr sd_startcmd

	; Send 0x40, 0x00, 0x00, 0x00, 0x00, 0x95
	lda #0x40
	jsr sd_sendbyte
	lda #0x00
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	lda #0x95						; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespR1				; Get the response

	jsr sd_endcmd
	
	rts

;****************************************
;* sd_sendcmd55
;* Send CMD55
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd55
	jsr sd_startcmd

	; Send 0x40+55, 0x00, 0x00, 0x00, 0x00, 0x95
	lda #0x40+55
	jsr sd_sendbyte
	lda #0x00
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	lda #0x95						; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespR1				; Get the response

	jsr sd_endcmd
	
	rts

;****************************************
;* sd_sendcmd41
;* Send ACMD41
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd41
	jsr sd_startcmd

	; Send 0x40+41, 0x00, 0x00, 0x00, 0x00, 0x95
	lda #0x40+41
	jsr sd_sendbyte
	lda #0x00
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	jsr sd_sendbyte
	lda #0x95						; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespR1				; Get the response

	jsr sd_endcmd
	
	rts

;****************************************
;* sd_sendcmd16
;* Send CMD16
;* Input : None
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd16
	jsr sd_startcmd

	; Send 0x40+16, 0x00, 0x00, 0x02, 0x00, 0x95
	lda #0x40+16
	jsr sd_sendbyte
	lda #0x00
	jsr sd_sendbyte
	jsr sd_sendbyte
	lda #0x02						; 0x200 block size = 512 bytes
	jsr sd_sendbyte
	lda #0x00
	jsr sd_sendbyte
	lda #0x95						; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespR1				; Get the response

	jsr sd_endcmd
	
	rts

;****************************************
;* sd_getrespR1
;* Low level get response R1
;* Input : A = response byte received
;* Output : None
;* Regs affected : None
;****************************************
sd_getrespR1
	jsr sd_getrespbyte
	rts

;****************************************
;* sd_sendcmd17
;* Send CMD17
;* Input : sd_sect = 4 bytes of sector offset little endian
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd17
	phx
	pha								; A is the page to write to
	
	jsr sd_startcmd

	; Convert sector address to byte address
	; Sector address is little endian
	; Byte address is big endian
	stz sd_addr+3					; LSB of address is always 0
	lda sd_sect+0					; LSB of sector goes to address+1
	sta sd_addr+2					; Equivalent of * 256
	lda sd_sect+1
	sta sd_addr+1
	lda sd_sect+2
	sta sd_addr+0
	clc								; Now addr*2 so equiv to sect*512
	asl sd_addr+3
	rol sd_addr+2
	rol sd_addr+1
	rol sd_addr+0

sd_cmd17addr
	; Send 0x40+17, 0xA3, 0xA2, 0xA1, 0xA0, 0x95
	lda #0x40+17
	jsr sd_sendbyte
	lda sd_addr+0
	jsr sd_sendbyte
	lda sd_addr+1
	jsr sd_sendbyte
	lda sd_addr+2
	jsr sd_sendbyte
	lda sd_addr+3
	jsr sd_sendbyte
	lda #0x95						; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespbyte
	tax								; Save response in X for return

	pla								; Get the A param
	jsr sd_getrespR17				; Get the response

	jsr sd_busy						; Wait for card to be ready
	
	jsr sd_endcmd

	txa								; Restore the response byte
	plx
	
	rts

;****************************************
;* sd_getrespR17
;* Low level get response R17
;* Input : A = R1 response byte received
;* Output : None
;* Regs affected : None
;****************************************
sd_getrespR17
	pha
	phy

	sta tmp_ahi						; Page to read in to
	stz tmp_alo						; Always a page boundary
sd_getrespR17token
	jsr sd_getbyte					; Get a byte
	cmp #0xfe						; Is it the token?
	bne sd_getrespR17token			; No
	
	ldy #0							; read 1st 256 bytes
sd_getrespR17block1
	jsr sd_getbyte					; get a byte
	sta (tmp_alo),y					; Save the byte
	iny								; Keep going
	bne sd_getrespR17block1			; Until all bytes read

	inc tmp_ahi						; Next page
sd_getrespR17block2
	jsr sd_getbyte					; get a byet
	sta (tmp_alo),y					; Save the byte
	iny								; Keep going
	bne sd_getrespR17block2			; Until all bytes read

	jsr sd_getbyte					; CRC
	jsr sd_getbyte					; CRC
	
	ply
	pla

	rts
	

;****************************************
;* sd_sendcmd24
;* Send CMD24
;* Input : sd_sect = 4 bytes of sector offset little endian
;* Output : None
;* Regs affected : None
;****************************************
sd_sendcmd24
	phy
	pha

	jsr sd_startcmd

	; Convert sector address to byte address
	; Sector address is little endian
	; Byte address is big endian
	stz sd_addr+3					; LSB of address is always 0
	lda sd_sect+0					; LSB of sector goes to address+1
	sta sd_addr+2					; Equivalent of * 256
	lda sd_sect+1
	sta sd_addr+1
	lda sd_sect+3
	sta sd_addr+0
	clc								; Now addr*2 so equiv to sect*512
	asl sd_addr+3
	rol sd_addr+2
	rol sd_addr+1
	rol sd_addr+0

	; Send 0x40+24, 0xA0, 0xA1, 0xA2, 0xA3, 0x95
	lda #0x40+24
	jsr sd_sendbyte
	lda sd_addr+0
	jsr sd_sendbyte
	lda sd_addr+1
	jsr sd_sendbyte
	lda sd_addr+2
	jsr sd_sendbyte
	lda sd_addr+3
	jsr sd_sendbyte
	lda #0x95					; Checksum needs to be right
	jsr sd_sendbyte

	jsr sd_getrespbyte			; Get response

	jsr sd_getbyte
	
	lda #0xfe					; Start of data token
	jsr sd_sendbyte

	pla							; Retrieve the address high byte
	sta tmp_ahi
	stz tmp_alo					; Address is always page boundary

	ldy #00
sd_writeblock_1					; Send first 256 bytes
	lda (tmp_alo), y
	jsr sd_sendbyte
	iny
	bne sd_writeblock_1
	inc tmp_ahi					; Next page for second 256 bytes
sd_writeblock_2					; Send second 256 bytes
	lda (tmp_alo), y
	jsr sd_sendbyte
	iny
	bne sd_writeblock_2

	lda #0xaa					; Arbitrary CRC bytes
	jsr sd_sendbyte
	jsr sd_sendbyte

	jsr sd_getbyte				; Get data response byte
	pha							; Save it to return

sd_waitforwritecomplete
	jsr sd_busy					; Wait for card to be ready
	
	jsr sd_endcmd				; Release the card

	pla
	ply
	rts

	
sd_msg_initialising
	db "\rInitialising SD Card\r", 0

sd_cmd55
	db (0x40+55), 0x00, 0x00, 0x00, 0x00, 0x95
sd_cmd58
	db (0x40+58), 0x00, 0x00, 0x00, 0x00, 0x95
sd_acmd41
	db (0x40+41), 0x00, 0x00, 0x00, 0x00, 0x95
	
