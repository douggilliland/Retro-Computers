;    File name: SD_Card.asm
;
;    Program to manipulate some strings

.nolist
.include  "m169def.inc"			; definitions for the Atmega 169
.list

	.dseg
buf:	.byte	513
lne:	.byte	44

	.cseg				; what follows is code
	.org	0x0000
	rjmp	main

hi:	.db	"SD card test",0,0
hi2:	.db	"Init successful",0
hi3:	.db	"Halfway",0
err1:	.db	"timeout 1",0
err2:	.db	"timeout 2",0
err3:	.db	"too many cmd1",0
cmd0:	.db	0x40,0x00,0x00,0x00,0x00,0x95	; SD card cmd 0
cmd1:	.db	0x41,0x00,0x00,0x00,0x00,0xff	; SD card cmd 1
cmd9:	.db	0x49,0x00,0x00,0x00,0x00,0xff	; SD card cmd 9

main:	ldi	r16,high(RAMEND)	; set up stack pointer
	out	SPH,r16
	ldi	r16,low(RAMEND)
	out	SPL,r16

	ldi	r16,0x80		; enable the clock prescaler
	sts	CLKPR,r16		; for 4 cycles
	clr	r16
	sts	CLKPR,r16		; and div factor to 1

	rcall	usart_init		; do rs-232 initialialization

	ldi	ZL,low(hi<<1)		; greetings, earthling
	ldi	ZH,high(hi<<1)
	rcall	flashout

	rcall	SPI_Init		; do SPI initialization
	ldi	ZL,low(hi2<<1)		; greetings again
	ldi	ZH,high(hi2<<1)
	rcall	flashout

loop:	rcall	getchar			; see if there's a character coming in
	breq	loop			; if zero set, no character

	rcall	sendchar		; otherwise, echo it back to them
	rcall	sendCRLF		; follow it with a CRLF
	mov	r0,r1
	rcall	match_jump1
	.dw	'c',get_csd1
	.dw	0,0

get_csd1:
	cbi	portb,portb4		; select ~CS
	ldi	zh,high(cmd9<<1)	; send cmd9
	ldi	zl,low(cmd9<<1)
	rcall	send_fcmd

	ldi	r16,10			; give them 10 tries
okw2:	ser	r20			; wait for response
	rcall	SPI_comm
	dec	r16
	breq	timeout1a
	cpi	r20,0xff
	breq	okw2
	tst	r20
	brne	timeout2a

	ldi	r16,10			; give them 10 tries
okw3:	ser	r20			; wait for response
	rcall	SPI_comm
	dec	r16
	breq	timeout1a
	cpi	r20,0xff
	breq	okw3

	cpi	r20,0xfe		; block start token
	brne	timeout1a

	ldi	yl,low(buf)		; read the CSD data
	ldi	yh,high(buf)
	ldi	r16,18			; 16 bytes & 16 bit CRC

okw4:	ser	r20
	rcall	SPI_comm
	st	y+,r20
	dec	r16
	brne	okw4

	sbi	portb,portb4		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks
	rcall	send_16
	rcall	sendCRLF
	rjmp	loop

timeout2a:
	rjmp	timeout2
timeout1a:
	rjmp	timeout1

; -----------------------------------------------------------
; send_16 - send 16 bytes of buf[] to USART

send_16:
	push	zh
	push	zl
	push	yh
	push	yl
	push	r16
	push	r17
	push	r0

	ldi	yh,high(buf)		; raw data
	ldi	yl,low(buf)
	ldi	zh,high(lne)		; formatted line image
	ldi	zl,low(lne)
	ldi	r16,16
	ldi	r17,' '

monow:	ld	r0,y+
	rcall	byte_2_hex
	dec	r16
	breq	xdne
	st	z+,r17			; separating blank
	rjmp	monow

xdne:	rcall	lne_usart

	pop	r0
	pop	r17
	pop	r16
	pop	yl
	pop	yh
	pop	zl
	pop	zh
	ret

; -----------------------------------------------------------
; flashout - send a null terminated string in flash to the USART
;
;	parameters:
;	  Z points at string in flash
;	returns:
;	  Z is destroyed

flashout:
	push	r1			; save register

floop:	lpm	r1,Z+			; get next char from flash
	tst	r1			; set flags from char
	breq	fdone			; if 0, we hit the end
	rcall	sendchar		; nonzero, send the character
	rjmp	floop			; and repeat

fdone:	rcall	sendCRLF		; tack on a CRLF to be nice

	pop	r1
	ret

; -----------------------------------------------------------
; lne_usart - send a null terminated string in SRAM to the USART
;
;	string is in lne[]

lne_usart:
	push	zh
	push	zl
	push	r1

	ldi	zh,high(lne)
	ldi	zl,low(lne)

flxp:	ld	r1,z+			; get next char
	tst	r1			; set flags from char
	breq	fdne			; if 0, we hit the end
	rcall	sendchar		; nonzero, send the character
	rjmp	flxp			; and repeat

fdne:	rcall	sendCRLF		; tack on a CRLF to be nice

	pop	r1
	pop	zl
	pop	zh
	ret

; -----------------------------------------------------------
; sendCRLF - send a carriage return and line feed to the USART
;
;	parameters:
;	  none

sendCRLF:
	push	r1			; save stuff
	push	r16

	ldi	r16,13			; ASCII 13 = CR
	mov	r1,r16			; sendchar wants arg in r1
	rcall	sendchar

	ldi	r16,10			; ASCII 10 = LF
	mov	r1,r16
	rcall	sendchar

	pop	r16
	pop	r1
	ret

; -----------------------------------------------------------
; usart_init - initialize the USART
;
;	parameters:
;	  none
;
;	returns:
;	  none

usart_init:
	push	r20			; save register

;	set the baud rate using a constant
	ldi	r20,25			; 19,200 bps constant
	sts	UBRRL,r20		; into low order
	clr	r20			; zero
	sts	UBRRH,r20		; into high order
	sts	UCSRA,r20		; set normal speed

;	enable the receiver and transmitter
	ldi	r20,(1<<RXEN) | (1<<TXEN)
	sts	UCSRB,r20

;	set the format as 8 data bits, 2 stop bits, no parity
	ldi	r20,(1<<USBS) | (3<<UCSZ0)
	sts	UCSRC,r20

	pop	r20			; restore register
	ret

; -----------------------------------------------------------
; getchar - read a character from the USART, perhaps
;
;	parameters:
;	  none
;
;	returns:
;	  zero flag set if there's no character
;	  zero flag cleared if there's a character, and it
;	    will be in r1

getchar:
	push	r21			; save register

	lds	r21,UCSRA		; get USART flags
	sbrs	r21,RXC			; is a character ready?
	rjmp	nochar			; jump if not
	lds	r1,UDR			; yes - read it
	clz				; clear the zero flag
	rjmp	outnow

nochar:	sez				; set the zero flag
outnow:	pop	r21			; restore registers
	ret

; -----------------------------------------------------------
; sendchar - send a character to the USART
;
;	parameters:
;	  character to send is in r1

sendchar:
	push	r21			; save register

snd2:	lds	r21,UCSRA		; get USART flags
	sbrs	r21,UDRE		; is transmitter empty?
	rjmp	snd2			; if not, go check again
	sts	UDR,r1			; fire away

	pop	r21			; restore register
	ret

; ------------------------------------------------------
;	SPI_init - initialize SPI communication
;
;	this sets up the SPI stuff and initializes the SD card
;	note: this is hard coded for the AVR Butterfly & SD card test
;
;	  PB1 - SPI clock (pin 5 of SD, SCK)
;	  PB2 - Data in (pin 2 of SD, SPI MOSI)
;	  PB3 - Data out (pin 7 of SD, SPI MISO)
;	  PB4 - Chip Sel (pin 1 of SD, SPI ~SS) - note: center joystick!
;
;	initialization (may or may not be correct)
;	  wait > 1 ms
;	  send 10 0xFF with CS high
;	  send CMD0 (hex: 40 00 00 00 00 95) with CS low
;	  wait for 0x01
;	  repeatedly send CMD1 (hex: 41 00 00 00 00 01)
;	  wait for 0x00

SPI_init:
	push	r16
	push	r17
	push	r20
	push	zh
	push	zl

	sbi	ddrb,portb4		; PB4 is an output to SD card (~CS)
	sbi	portb,portb4		; active low, so set high
	sbi	ddrb,portb0		; dataflash chip select
	sbi	portb,portb0		; kill the dataflash

	sbi	ddrb,portb1		; B1 is an output (SCK)
	sbi	ddrb,portb2		; B2 is an output (MOSI)
	cbi	ddrb,portb3		; B3 is an input (MISO)
	sbi	portb,portb3		; pullup?

	ldi	r16,11			; kill a millisecond or so
	clr	r20
splp:	dec	r20
	brne	splp
	dec	r16
	brne	splp

;	ldi	r16,(1<<spi2x)		; SPI double speed
;	out	spsr,r16
;	enable SPI, master, mode 0
	ldi	r16,(1<<spe)|(1<<mstr)|(0<<cpha)|(0<<cpol)
	out	spcr,r16

;	---------------------- send 74 clock pulses to start it off

	ldi	r16,10			; send 80 clock pulses
	sbi	portb,portb4		; write 1 to ~CS to deselect SD card

splp1:	ser	r20			; send 1's
	rcall	SPI_comm		; clock 8 times each pass
	dec	r16			; counting...
	brne	splp1			; and repeat

;	--------------------- send CMD0 to get into SPI mode

	cbi	portb,portb4		; select ~CS
	ldi	zh,high(cmd0<<1)	; send cmd0
	ldi	zl,low(cmd0<<1)
	rcall	send_fcmd

	ldi	r16,10			; give them 10 tries
okw:	ser	r20			; wait for 0x01 (idle)
	rcall	SPI_comm
	dec	r16
	breq	timeout1
	cpi	r20,1
	brne	okw

	sbi	portb,portb4		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks

;	---------------------- send CMD1 to wait for end of idle

	ldi	yl,0xff
	ldi	yh,0x0f
cc1:	cbi	portb,portb4		; select SD card
	ldi	zh,high(cmd1<<1)
	ldi	zl,low(cmd1<<1)
	rcall	send_fcmd		; send cmd1

	ldi	r17,10			; 10 shots at responding
cc2:	ser	r20
	rcall	SPI_comm
	dec	r17
	breq	timeout2
	cpi	r20,0xff
	breq	cc2

	tst	r20
	breq	okk
	sbiw	yh:yl,1
	breq	timeout3
	sbi	portb,portb4
	ser	r20
	rcall	SPI_comm
	rjmp	cc1

okk:	sbi	portb,portb4		; deselect SD card
	ser	r20
	rcall	SPI_comm		; extra clocks

	pop	zl
	pop	zh
	pop	r20
	pop	r17
	pop	r16
	ret

timeout3:
	ldi	zl,low(err3<<1)		; timeout 3
	ldi	zh,high(err3<<1)
	rjmp	here1
timeout1:
	ldi	zl,low(err1<<1)		; timeout 1
	ldi	zh,high(err1<<1)
	rjmp	here1
timeout2:
	ldi	zl,low(err2<<1)		; timeout 2
	ldi	zh,high(err2<<1) 
here1:	sbi	portb,portb4		; deselect SD card
	rcall	flashout
here:	rjmp	here

; ------------------------------------------------------
;	send_fcmd - send flash command
;
;	Z - points to 6 byte flash command (not preserved)

send_fcmd:
	push	r20
	push	r18

	ldi	r18,6		; command frames are 6 bytes
slw:	lpm	r20,z+		; send them out
	rcall	SPI_comm
	dec	r18		; repeat until done
	brne	slw

	pop	r18
	pop	r20
	ret

; ------------------------------------------------------
;	SPI_comm - exchange a byte with the SPI
;
;	send a byte (command or otherwise) and receive one, too
;
;	parameters: R20 - byte to send
;
;	returns: R20 - byte received

SPI_comm:
	push	r16

	out	spdr,r20	; going out
sp_wt:	in	r16,spsr	; watch spif flag
	sbrs	r16,spif	; 0 means busy
	rjmp	sp_wt

	in	r20,spdr	; grab the incoming byte

	pop	r16
	ret

; -----------------------------------------------------------
; byte_2_hex - convert byte to hexadecimal string
;
;	parameters:
;	  r0 - byte to convert
;	  z - address of destination for string
;
;	returns:
;	  z points at terminating null, r0 preserved
;
;	note: caller must be sure destination has space for
;	  3 bytes (2 hex digits plus null)

byte_2_hex:
	push	r17
	push	r16

	mov	r17,r0		; our byte to convert
	rcall	hnib2hex	; convert high nibble
	mov	r17,r0		; original again
	swap	r17		; exchange nibbles
	rcall	hnib2hex	; convert high nibble
	clr	r17
	st	Z,r17		; add null at end

	pop	r16
	pop	r17
	ret

hnib2hex:			; helper routine - conv hi nibble
	swap	r17
	andi	r17,0x0f	; keep 4 bits
	cpi	r17,10
	brcs	digs		; branch if 0 to 9
	ldi	r16,'A' - 10	; constant to convert 10 --> 'A'
	rjmp	hout

digs:	ldi	r16,'0'		; constant to convert 0 --> '0'
hout:	add	r17,r16		; add constant to our number
	st	Z+,r17		; and store into output string
	ret

; -----------------------------------------------------------
; match_jump1 - find byte match and jump in flash list
;
;	parameters:
;	  R0 - value to match
;
;	returns:
;	  none
;
;	usage:
;	  r0 <-- match value
;	  call match_jump1
;	  .dw  v0,addr0     ; jump to addr0 if r0 = v0
;	  .dw  v1,addr1     ; jump to addr1 if r0 = v1
;	       ...
;	  .dw  0,0	    ; marks end of list
;
;	note: if there is no match, it jumps to addr0
;	      therefore, if there are no addresses, this does a reset

match_jump1:
	push	YL
	push	YH
	push	ZL
	push	ZH
	push	r24
	push	r25
	push	r5

	in	YL,SPL		; copy of revised stack pointer
	in	YH,SPH
	clr	r5		; flag to store first address we see

	ldd	ZH,Y+8		; high rtn address (word address, not byte)
	andi	ZH,0x1f		; manual pg 10 says to mask
	ldd	ZL,Y+9		; low rtn address
	lsl	ZL		; mult by 2 for byte address
	rol	ZH		; needed for lpm instr

lloop1:	lpm	r24,Z+		; low byte of match value
	lpm	r25,Z+		; high match byte, should be zero
	cp	r24,r0		; is low byte what we want?
	breq	useme1		; yes - hop to

	lpm	r24,Z+		; low target address
	lpm	r25,Z+		; high target address
	tst	r5		; is this the first address?
	brne	regad1		; jump if not

	inc	r5		; only do this once
	std	Y+9,r24		; overwrite our return
	std	Y+8,r25		; with first address in list

regad1:	tst	r24		; is jump address = 0?
	brne	lloop1		; low byte not zero - continue
	tst	r25
	brne	lloop1		; high byte not zero - continue
	rjmp	rback1		; yup - head on out

useme1:	lpm	r24,Z+		; low target address
	std	Y+9,r24		; overwrite orig return
	lpm	r25,Z+		; high target address
	std	Y+8,r25		; overwrite orig return

rback1:	pop	r5
	pop	r25
	pop	r24
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	ret			; go to modified return address
