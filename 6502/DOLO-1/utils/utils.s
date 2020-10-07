;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  UTILS.S
;*  This module implements various utility functions, mainly
;*  converting from ASCII to binary form for numbers and
;*  vice-versa to allow humans to actually be able to input
;*  and read numbers in their prefered form!
;*
;**********************************************************

	; ROM code
	code

jsrPrintA
	_printA
	rts

;****************************************
;* util_clr_mem
;* Clear a block of main ram
;* Input : X, A = Block start, Y = Block size
;* Regs affected : P
;****************************************
util_clr_mem
	pha
	phy
	stx tmp_alo
	sta tmp_ahi
mem_clr_byte
	dey
	sta (tmp_alo),y
	bne mem_clr_byte
	ply
	pla
	rts

;****************************************
;* str_a_to_x
;* Convert accumulator to hex string
;* Input : A = Byte to convert
;* Output : A = High Char, X = Low Char
;* Regs affected : P
;****************************************
str_a_to_x
	pha					; Save the byte using later on
	and #0x0f			; Mask low nibble
	clc
	adc #'0'			; Convert to UTF
	cmp #('9'+1)		; If A greater than '9' then
	bcc skip_a_f_1		; skip a-f adjustment
	adc #0x26			; Add 27 (6+C) to get in to A-F range
skip_a_f_1
	tax					; Low char is in X
	pla					; Get byte back
	lsr a				; Make high nibble low
	lsr a
	lsr a
	lsr a
	clc
	adc #'0'			; Convert to UTF
	cmp #('9'+1)		; If A greater than '9' then
	bcc skip_a_f_2		; skip a-f adjustment
	adc #0x26			; Add 27 (6+C) to get in to A-F range
skip_a_f_2

	clc					; No error
	rts					; A high nibble

;****************************************
;* str_x_to_a
;* Convert hex string to accumulator
;* Input : A = High Char, X = Low Char
;* Output : A = Value
;* Regs affected : P
;****************************************
str_x_to_a
	ora #0x20			; Make alpha in to lower case
	sec					; Process high char in A
	sbc #'0'			; Convert to hex nibble
	cmp #10				; If A < 10 then
	bcc skip_x_f_1		; skip a-f adjustment
	sbc #0x27			; Sub 7 to get in to A-F range
skip_x_f_1
	cmp #0x10			; Nibble should be <= 0x0f
	bcs	str_x_to_a_err	; Error if not

	asl a				; This is the high nibble
	asl a
	asl a
	asl a
	pha					; Save the high nibble
	txa					; Now process the low char in X
	ora #0x20			; Make alpha in to lower case
	sec
	sbc #'0'			; Convert to hex nibble
	cmp #10				; If A < 10 then
	bcc skip_x_f_2		; skip a-f adjustment
	sbc #0x27			; Sub 7 to get in to A-F range
skip_x_f_2
	cmp #0x10			; Nibble should be <= 0x0f
	bcs	str_x_to_a_errl	; Error if not

	sta num_a			; Store low nibble in temp
	pla					; Get high nibble
	ora num_a			; OR with low nibble

	clc					; No error
	rts					; A contains value

str_x_to_a_errl
	pla
str_x_to_a_err
	SWBRK CMD_ERR_VAL

;****************************************
;* con_n_to_a
;* Convert numeric string to accumulator (unsigned)
;* Input : Pointer to string (X=L, A=H), Y = Source type if not zero
;* Output : num_a, num_a+1 contains word, X=number of digits
;* A = Source type detected
;* Regs affected : CS = Error
;****************************************
con_n_to_a
	stx num_tmp
	sta num_tmp+1
	stz num_a
	stz num_a+1
	cpy #NUM_ANY
	beq con_n_to_a_detect
	dey
	bne con_n_not_dec
con_dec_jmp
	jmp con_dec_to_a_int
con_n_not_dec
	dey
	bne con_n_not_hex
con_hex_jmp
	jmp con_hex_to_a_int
con_n_not_hex
	dey
	bne con_n_err
con_bin_jmp
	jmp con_bin_to_a_int
con_n_err
	sec
	rts
con_n_to_a_detect
	lda (num_tmp)
	cmp #'0'
	bne con_dec_jmp
	ldy #1
	lda (num_tmp),y
	ora #0x20
	cmp #'x'
	beq con_hex_jmp
	cmp #'b'
	beq con_bin_jmp
	bra con_dec_jmp

;****************************************
;* con_hex_to_a
;* Convert hex string to accumulator (unsigned)
;* Input : Pointer to string (X=L, A=H)
;* Output : num_a, num_a+1 contains word, X=number of digits
;* Regs affected : CS = Error
;****************************************
con_hex_to_a
	stx num_tmp
	sta num_tmp+1
con_hex_to_a_int
	ldx #5			; > 4 digits will cause error
	ldy #2			; start at first digit
con_hex_digit
	lda (num_tmp),y
	ora #0x20					; Make alpha in to lower case
	sec							; Process high char in A
	sbc #'0'					; Convert to hex nibble
	cmp #10						; If A < 10 then
	bcc con_hex_skip_x_f_1		; skip a-f adjustment
	sbc #0x27					; Sub 7 to get in to A-F range
con_hex_skip_x_f_1
	cmp #0x10					; Nibble should be <= 0x0f
	bcs	con_hex_done			; Potentially done if not
	pha
	; make room for lo nibble
	asl num_a
	rol num_a+1
	asl num_a
	rol num_a+1
	asl num_a
	rol num_a+1
	asl num_a
	rol num_a+1
	; save in low nibble
	pla
	ora num_a
	sta num_a
	iny
	dex
	bne con_hex_digit
	; if got to a 5th digit then error
con_hex_err
	sec
	rts
	; found a non-hex digit
con_hex_done
	; if no digits processed then error
	cpy #2
	beq con_hex_err
	; move y to x for digits processed
	tya
	tax
	lda #NUM_HEX
	clc
	rts

;****************************************
;* con_bin_to_a
;* Convert hex string to accumulator (unsigned)
;* Input : Pointer to string (X=L, A=H)
;* Output : num_a, num_a+1 contains word, X=number of digits
;* Regs affected : CS = Error
;****************************************
con_bin_to_a
	stx num_tmp
	sta num_tmp+1
con_bin_to_a_int
	ldy #2
	ldx #17						; Max 16 binary digits allowed
con_bin_digit
	lda (num_tmp),y
	cmp #'0'
	bcc con_bin_done
	cmp #'1'+1
	bcs con_bin_done
	; sets C if '1' else resets C
	adc #0xff-'0'
	; shift in digit
	rol num_a
	rol num_a+1
	iny
	dex
	bne con_bin_digit
	; on the 17th digit is too much, error
	bra con_bin_err
con_bin_done
	; didn't process any digit = error
	cpy #2
	beq con_bin_err
	; put digits processed in to X
	tya
	tax
	lda #NUM_BIN
	clc
	rts
con_bin_err
	sec
	rts

;****************************************
;* con_d_to_a
;* Convert decimal string to accumulator (unsigned)
;* Input : Pointer to string (X=L, A=H)
;* Output : num_a, num_a+1 contains word, X=number of digits
;* Regs affected : CS = Error
;****************************************
con_dec_to_a
	stx num_tmp
	sta num_tmp+1
con_dec_to_a_int
	ldy #0
str_d_find_end
	lda (num_tmp),y
	cmp #'0'
	bcc str_d_found_end
	cmp #'9'+1
	bcs str_d_found_end
	iny
	bra str_d_find_end
str_d_found_end
	cpy #6
	bcs str_d_error
	sty num_tmp+3
	stz num_tmp+2
	stz num_a
	stz num_a+1
str_d_process_digit
	dey
	bmi str_d_digits_done
	sec
	lda (num_tmp),y
	sbc #'0'
	; Convert digit to number
	; and then offset in to
	; look up table of powers
	clc
	asl a
	adc num_tmp+2
	; X contains index to powers
	tax
	lda num_a
	adc str_d_powers,x
	sta num_a
	lda num_a+1
	adc str_d_powers+1,x
	sta num_a+1
	bcs str_d_error
	; Move to next power of 10 index
	lda num_tmp+2
	adc #20
	sta num_tmp+2
	bra str_d_process_digit
str_d_digits_done	
	ldx num_tmp+3
	lda #NUM_DEC
	clc
	rts
str_d_error
	sec
	rts

str_d_powers
	dw	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	dw	0, 10, 20, 30, 40, 50, 60, 70, 80, 90
	dw	0, 100, 200, 300, 400, 500, 600, 700, 800, 900
	dw	0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000
	dw	0, 10000, 20000, 30000, 40000, 50000, 60000, 65535, 65535, 65535
	


;****************************************
;* hex_to_bcd
;* Convert accumulator,X to BCD
;* Input : X = Low byte, A = High Byte to convert
;* Output : 3 bytes of num_a is updated
;* Regs affected : P
;****************************************
hex_to_bcd
	php
	pha
	phx
	
	stx num_tmp
	sta num_tmp+1
	stz num_a
	stz num_a+1
	stz num_a+2
	stz num_a+3
	ldx #16
	sed
bin_to_bcd_bit
	asl num_tmp
	rol num_tmp+1
	lda num_a
	adc num_a
	sta num_a
	lda num_a+1
	adc num_a+1
	sta num_a+1
	lda num_a+2
	adc num_a+2
	sta num_a+2
	dex
	bne bin_to_bcd_bit
	
	plx
	pla
	plp
	rts
	
;****************************************
;* bcd_to_str
;* Convert num_buf to chars
;* Input : num_a in BCD format
;* Output : num_buf in ASCII 6 digits
;* Output is big endian, input is not
;* Regs affected : P
;****************************************
bcd_to_str
	pha
	phx
	phy

	ldx #5						; Index in to string
	ldy #0						; Current BCD digit
bcd_str
	lda num_a,y
	; Convert 1s digit of byte
	pha
	and #0xf
	clc
	adc #0x30
	sta num_buf,x
	; Convert 10s digit of byte
	pla
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc #0x30					; Convert to ASCII
	sta num_buf-1,x
	dex
	dex
	iny
	cpy #3						; 3 BCD digits max
	bne bcd_str

	ply
	plx
	pla
	rts
	
;****************************************
;* out_bcd
;* Output a bcd string in num_buf
;* Input : num_buf has the ASCII
;* Input : C=1 print leading zeros else not
;* Output : num_buf in ASCII 6 digits
;* Output is big endian, input is not, Y=digits printed
;* Regs affected : P
;****************************************
out_bcd
	pha
	phx
	php
	ldy #0						; How many digits printed
	ldx #0						; Index in to string
out_bcd_digit
	lda num_buf,x
	cpy #0						; If not in leading zero mode
	bne out_bcd_print			; No then go print

	cmp #'0'					; else check if zero
	bne out_bcd_print			; No then go print

	plp
	php
	bcc out_bcd_next			; If C=0 go to next digit, else print
out_bcd_print
	iny
	jsr io_put_ch
out_bcd_next
	inx
	cpx #6
	bne out_bcd_digit
	cpy #0						; If nothing printed
	bne out_bcd_fin
	lda #'0'					; Need to put out 1 zero
	jsr io_put_ch
	iny
out_bcd_fin
	plp
	plx
	pla
	clc
	rts
	
		
	
;****************************************
;* print_a_to_d
;* Convert X,A to decimal string
;* Input : X,A = number Low,High
;* Input : C=1 print leading zeros else not
;* Output : num_buf in ASCII max 6 digits
;* Output is big endian, input is not
;* Regs affected : P
;****************************************
print_a_to_d
	php
	jsr hex_to_bcd				; Convert to BCD
	jsr bcd_to_str				; Convert BCD to string
	plp
	jsr out_bcd					; Print a string
	rts
	