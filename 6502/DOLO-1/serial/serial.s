;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  SERIAL.S
;*  Serial input/output handler - driving a 6551 ACIA.
;*
;**********************************************************

	; ROM code
	code


;****************************************
;* get_byte
;* Get a byte (wait forever or just check)
;* Input : C = 1 for synchronous, 0 for async
;* Output : A = Byte code, C = 0 means A is invalid
;* Regs affected : P, A
;****************************************
get_byte
	lda SER_STATUS			; Check status register
	and #SER_RDRF			; Is Receive Data Register Full bit set?
	bne got_byte
	bcs get_byte			; If C then keep waiting
	sec						; Indicate byte was not got
	rts						; If not C then return immediately
got_byte
	clc						; Indicate byte was got
	lda SER_DATA			; Read data
	
	rts

;****************************************
;* put_byte
;* Put a byte out
;* Input : A = Byte to put
;* Output : None
;* Regs affected : None
;****************************************
put_byte
	pha						; Remember the byte to put
put_byte_wait
	lda SER_STATUS			; Check status
	and #SER_TDRE			; Is transmit register empty
	beq put_byte_wait		; wait if not
	pla						; Pull byte to write
	sta SER_DATA			; Write the data
	rts


;****************************************
;* init_acia
;* ACIA initialisation (this is IO_2)
;* Input : None
;* Output : None
;* Regs affected : X
;****************************************
init_acia
	ldx #0b00011111			; 19200 baud, 8 bits, 1 stop bit, internal clock		
	stx SER_CTL
	ldx #0b00001011			; No parity, no TX int plus RTS low, no RX int, DTR
	stx SER_CMD
	ldx SER_STATUS			; Read status reg to clear stuff

	rts
