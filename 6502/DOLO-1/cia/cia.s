;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  CIA.S
;*  Code to initialise and utilise the two WDC65c22 VIAs
;*  VIA1 is used to interface to the BBC keyboard
;*  VIA2 is used to interface to the AY-3-8910 sound chip
;*  This file is called cia.s because the original design
;*  used a MOS 6526 from a CMB64.  However I updated the HW
;*  design to use two 6522 chips, but never got around to
;*  renaming the file ;-)
;*
;**********************************************************


	; ROM code
	code
	
;********************************
;* set_leds
;* Set the LEDS
;* Input : A - Led pattern to set (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_leds
	pha							; Save A
	eor #0x0e					; Invert bits
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;********************************
;* set_led0
;* Set the LED0 (cassette motor)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led0
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED0					; Initially assume off
	bcc skip_led0_on
	eor #KB_LED0					; Switch on if C=1
skip_led0_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;********************************
;* set_led1
;* Set the LED1 (caps lock)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led1
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED1				; Initially assume off
	bcc skip_led1_on
	eor #KB_LED1				; Switch on if C=1
skip_led1_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;********************************
;* set_led2
;* Set the LED2 (caps lock)
;* Input : C = status (1 = on, 0 = off)
;* Output : None
;* Regs affected : None
;****************************************
set_led2
	pha							; Save A
	lda IO_0 + PRB				; Get current led status
	ora #KB_LED2				; Initially assume off
	bcc skip_led2_on
	eor #KB_LED2				; Switch on if C=1
skip_led2_on
	sta IO_0 + PRB				; Set the leds
	pla							; Restore A
	rts

;****************************************
;* init_cia0
;* Initialise cia 0, controls the BBC keyboard
;* Input : None
;* Output : None
;* Regs affected : A
;****************************************
init_cia0
	lda #0x7f					; Disable all interrupts
	sta IO_0 + IER
	lda #0x7f					; Clear IFR
	sta IO_0 + IFR				; Set IFR to clear flags
	

	lda #0xff			
	sta IO_0 + DDRA				; Port A all output

	lda #0x0e			
	sta IO_0 + DDRB				; Port B 3, 2, 1 output

	lda #0x00					; Init control register - nothing doing
	sta IO_0 + ACR
	lda #0x02					; CA2 independent interrupt
	sta IO_0 + PCR

	lda #KB_EN 					; Set KB_EN bit to allow h/w strobe
	sta IO_0 + PRA
	
	lda #KB_LED0				; Keep LED0 on but 1 and 2 off
	jsr set_leds

	rts							; return from sub
	
;****************************************
;* init_cia1
;* Initialise cia 1, controls the sound chip
;* Input : None
;* Output : None
;* Regs affected : A
;****************************************
init_cia1
	lda #0x7f					; Disable all interrupts
	sta IO_1 + IER
	
	lda #0xff					; Port A all output (AY-3 data bus)
	sta IO_1 + DDRA
	
	lda #0b01011011				; Set Port B output = PB0, PB1, PB3, PB4, PB6	
	sta IO_1+DDRB
	
	lda #0x00					; Init control register - nothing doing
	sta IO_1 + ACR
	sta IO_1 + PCR

	lda #0x7f					; Clear IFR
	sta IO_1 + IFR				; Read ICR to clear flags
	
	rts							; return from sub
