;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  KEYBOARD.S
;*  This is the keyboard module to enable interfacing a
;*  BBC keyboard using a 65c22.  The BBC keyboard is cool
;*  in that it provides a signal to know if something was
;*  pressed in hardware, so the more cycle heavy code to
;*  actually check which key etc can be done only when
;*  necessary.  Debouncing is necessary to not scan too
;*  often, with the timing for this happening during the
;*  interrupt cycle.
;*
;**********************************************************

	; ROM code
	code

;****************************************
;* init_keyboard
;* Initialise the keyboard settings
;****************************************
init_keyboard
	lda #KB_REP_DEL
	sta kb_rep_del
	lda #KB_REP_TIM
	sta kb_rep_tim
	lda #KB_DEBOUNCE
	sta kb_debounce
	stz kb_stat
	rts
	

;****************************************
;* int_kb_handler
;* Keyboard interrupt handler
;****************************************
int_kb_handler	
	lda kb_deb				; If keyboard pressed is debounce 0?
	bne int_skip_scan		; If not zero, then don't check keys
	lda cia0_ifr			; Check status register CIA0
	and #IFR_CA2			; Keyboard pressed?
	beq int_keys_up
int_do_read
	lda kb_debounce			; Set debounce
	sta kb_deb
int_skip_scan
	rts
int_keys_up					; No key pressed
	stz kb_raw				; Using 65c02 stz opcode
	stz kb_last
	stz kb_code
	stz kb_deb
	stz kb_rep
	rts
	
;****************************************
;* kb_read_raw
;* Read keyboard (not shift+ctrl)
;* X = Keyboard code
;* Carry = 1 means key found, 0 = no keys found
;****************************************
kb_read_raw
	pha
	phy

	ldy #KB_EN				; Enable h/w strobe
	sty IO_0 + PRA
	
	lda kb_deb				; Don't scan if on debounce
	beq kb_no_key
	
	lda #KB_W				; This is the mask to look for
	ldy #0					; Start at row 1, column 0, KB_EN is low
kb_check_w_col
	ldx #7					; Only 7 rows as row zero is skipped
	iny						; Increment past row 0
kb_check_w_key
	sty IO_0 + PRA			; Set the row and column with KB_EN low
	bit IO_0 + PRB			; Bit test for the W status
	bne got_key				; Found key
	iny						; Advance row
	dex						; Do each row
	bne kb_check_w_key
	cpy #0b01010000			; If not got to column 10 then continue
	bne kb_check_w_col

	; no key found
	ldy #KB_EN				; Re-enable h/w strobe
	sty IO_0 + PRA

kb_no_key
	clc						; Clear carry flag = no keys found
	
	ply
	pla
	rts

got_key
	sty kb_raw				; Save the raw key code
	ldx kb_table_std,y		; Load up standard key code mapping
	lda #0b00000000			; Check shift pressed (row=0, col=0)
	sta IO_0 + PRA
	lda IO_0 + PRB			; Read w
	and #KB_W
	bne do_shifted_key
	lda kb_stat
	and #KB_SHIFTLK			; Check shift lock
	beq skip_shifted_key	
do_shifted_key
	ldx kb_table_shift,y	; Overwrite X with shifted key code mapping
skip_shifted_key
	lda #0b00001000			; Check ctrl pressed (row=0, col=1)
	sta IO_0 + PRA
	lda IO_0 + PRB			; Read w
	and #KB_W
	beq skip_ctrl_key
	txa						; If ctrl pressed then only take bottom 5 bits
	and #0x1f				; Which will result in codes 0 to 31
	tax
	bra skip_caps_lock		; no point in checking caps lock
skip_ctrl_key
	lda kb_stat				; Check caps lock
	and #KB_CAPSLK
	beq skip_caps_lock
	txa						; Easier to modify in A
	cmp #'a'				; If < 'a' then skip
	bcc skip_caps_lock
	cmp #'z'+1				; If > 'z' then skip
	bcs skip_caps_lock
	eor #0x20				; Switch off bit 0x20
	tax						; to make upper case
skip_caps_lock
	stx kb_code				; Store mapped key code
	ldy #KB_EN				; Re-enable h/w strobe
	sty IO_0 + PRA
	sec						; Set carry flag = key found
	
	ply
	pla
	rts
	
;****************************************
;* kb_scan_options
;* Scans options dip switch
;* A = Options code for all 8 bits
;****************************************
kb_scan_options
	phy

	ldy #0
	stz tmp_a
kb_check_option
	lda kb_option_code, y	; Binary option code, row = 0, col = y
	sta IO_0 + PRA
	lda IO_0 + PRB			; Read w
	and #KB_W
	beq kb_skip_option
	lda tmp_a
	ora kb_option_bit, y	; Set the bit if option on
	sta tmp_a
kb_skip_option
	iny
	cpy #8
	bne kb_check_option
	lda tmp_a

	ply
	rts
	
	
;****************************************
;* kb_scan_key
;* Scans for a key, returns zero for no key found
;* Processes caps and shift lock but these don't count as key presses
;* A = Key code
;****************************************
kb_scan_key
	phy
	phx
	
	ldy kb_rep_del			; Initially, assuming normal repeat delay
	jsr kb_read_raw			; H/W scan of keyboard
	bcc kb_scan_nothing		; C clear means nothing found
	cpx #0x80				; Was it a special key (caps/shift lock)?
	bcs kb_special			; If so process
	lda kb_raw
	cmp kb_last
	bne kb_return_code		; This key different from last key
	ldy kb_rep_tim
	ldx kb_rep				; If repeat timer is zero then emit code
	beq kb_return_code

kb_scan_nothing
	plx
	ply
	
	lda #0					; 0 = no key
	
	rts
kb_return_code				; Return a key because raw != last
	sty kb_rep				; Delay before the same key is emitted again
	sta kb_last				; Now make last = raw
	
	plx
	ply
	
	lda kb_code				; Get the actual code
	
	rts

kb_special					; Process special keys
	cpx kb_last				; If last is not zero then don't process because
	beq kb_scan_nothing		; special keys don't obey repeat or debounce
	stx kb_last				; Update last
	cpx #0x8a				; CAPS?
	beq kb_caps_lock		; Yes
	cpx #0x8b				; Shift Lock?
	bne kb_scan_nothing		; No, then found nothing (F keys don't do anything)
	;Process shift lock
	lda kb_stat
	eor #KB_SHIFTLK
	sta kb_stat
	clc
	and #KB_SHIFTLK
	beq kb_skip_shiftlk
	sec
kb_skip_shiftlk
	jsr set_led2
	bra kb_scan_nothing
	;Process caps lock
kb_caps_lock
	lda kb_stat
	eor #KB_CAPSLK
	sta kb_stat
	clc
	and #KB_CAPSLK
	beq kb_skip_capslk
	sec
kb_skip_capslk
	jsr set_led1
	bra kb_scan_nothing

;****************************************
;* kb_get_key
;* Waits for a key press, C=1 synchronous
;* A = Key code
;****************************************
kb_get_key
	php
	jsr kb_scan_key
	cmp #0
	bne kb_scan_got_key
	plp						; No key, so check C
	bcs kb_get_key			; Keep looking if C
	sec						; Indicate key not got
	rts
kb_scan_got_key
	plp						; Pull stack
	clc						; Indicate key valid
	rts
	
;****************************************
;* kb_table_std (no shift)
;* Keyboard table - zero indicates nothing
;****************************************
kb_table_std
	db 0x00								; Zero entry means nothing
	db 'q',0x80, '1',0x8a,0x8b,   9, 27	; Q, F0, 1, CAPSL, SHIFTL, TAB, ESC
	db 0x00								; Skip row 0
	db '3', 'w', '2', 'a', 's', 'z',0x81; 3, W, 2, A, S, Z, F1
	db 0x00								; Skip row 0
	db '4', 'e', 'd', 'x', 'c', ' ',0x82; 4, E, D, X, C, SPC, F2
	db 0x00								; Skip row 0
	db '5', 't', 'r', 'f', 'g', 'v',0x83; 5, T, R, F, G, V, F3
	db 0x00								; Skip row 0
	db 0x84,'7', '6', 'y', 'h', 'b',0x85; F4, 7, 6, Y, H, B, F5
	db 0x00								; Skip row 0
	db '8', 'i', 'u', 'j', 'n', 'm',0x86; 8, I, U, J, N, M, F6
	db 0x00								; Skip row 0
	db 0x87,'9', 'o', 'k', 'l', ',',0x88; F7, 9, O, K, L, , , F8
	db 0x00								; Skip row 0
	db '-', '0', 'p', '@', ';', '.',0x89; -, 0, P, @, ;, ., F9
	db 0x00								; Skip row 0
	db '^', '_', '[', ':', ']', '/', 92	; ^, _, [, :, ], /, '\'
	db 0x00								; Skip row 0
	db   8,  10,  11,  13, 127,   6,  9	; Left, Down, Up, Return, Delete, Copy, Right
	db 0x00								; Skip row 0

;****************************************
;* kb_table_shift (with shift)
;* Keyboard table - zero indicates nothing
;****************************************
kb_table_shift
	db 0x00					; Zero entry means nothing
	db 'Q',0x80, '!',0x8a,0x8b,   9, 27	; Q, F0, 1, CAPSL, SHIFTL, TAB, ESC
	db 0x00					; Skip row 0
	db '#', 'W', '"', 'A', 'S', 'Z',0x81; 3, W, 2, A, S, Z, F1
	db 0x00					; Skip row 0
	db '$', 'E', 'D', 'X', 'C', ' ',0x82; 4, E, D, X, C, SPC, F2
	db 0x00					; Skip row 0
	db '%', 'T', 'R', 'F', 'G', 'V',0x83; 5, T, R, F, G, V, F3
	db 0x00					; Skip row 0
	db 0x84, 39, '&', 'Y', 'H', 'B',0x85; F4, 7, 6, Y, H, B, F5
	db 0x00					; Skip row 0
	db '(', 'I', 'U', 'J', 'N', 'M',0x86; 8, I, U, J, N, M, F6
	db 0x00					; Skip row 0
	db 0x87,')', 'O', 'K', 'L', '<',0x88; F7, 9, O, K, L, , , F8
	db 0x00					; Skip row 0
	db '=', '0', 'P', '@', '+', '>',0x89; -, 0, P, @, ;, ., F9
	db 0x00					; Skip row 0
	db '~', 96, '{', '*', '}', '?', '|'	; ^, _, [, :, ], /, '\'
	db 0x00					; Skip row 0
	db   8,  10,  11,  13, 127,   6,  9	; Left, Down, Up, Return, Delete, Copy, Right
	db 0x00					; Skip row 0

; Option switches
kb_option_code
	db 0b00010000
	db 0b00011000
	db 0b00100000
	db 0b00101000
	db 0b00110000
	db 0b00111000
	db 0b01000000
	db 0b01001000
kb_option_bit
	db 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01
	
