;*******************************************************************
; Altair 680 Program
;  Load S-Record file into memory (below 8000h) from the 680-UIO
;  serial port, with error checking and reporting
;
; Usage:
;  Use the Altair 680 ACIA PROM Monitor's 'L' command to load this
;  program from the Teletype's paper tape reader (connected to the
;  Altair 680's onboard serial port). Then jump to address 8000h
;  ('J 8000') to load a larger program (e.g. Altair 680 Basic) via
;  a high-speed paper tape reader that is connected to the 680-UIO
;  serial port.
;
; Error Codes:
;  A  --  Address error - attempt to write above 7FFFh
;  C  --  Checksum error
;  H  --  Hex error (illegal character encountered)
;  M  --  Memory error (memory read-back failed)
;
; Revision History:
;    Date        Author         Comment
;  20OCT2011  M. Eberhard  Created
;  21OCT2011  M. Eberhard  Print initial CRLF, error messages
;  23OCT2011  M. Eberhard  Cleanup, ignore nulls
;
; Program Notes:
; * Written to assemble with A68.com (DOS-based cross assembler)
; * A68.com vers. 1.2.02 assembles 'jsr' incorrectly. to fix, patch
;   A68.com address AFABh to be 8Dh (was 9Dh).
; * A68.com does not generate 'direct' versions of lda and sta. We
;   generate them the hard way (with .db) here.
; * The intention is to connect the 680-UIO serial port to a high-
;   speed paper tape reader that is enabled by the RS232 RTS signal.
; * Runs in RAM at 8000h, which is the Altair 680's onboard RAM
;   if the Altair has 32K of RAM in expansion boards.
; * Echo is turned off while this program loads, by writing to the
;   PROM monitor's 'echo' flag.
; * This program uses some of the same RAM variables as the
;   PROM monitor program.
; * The high-spead reader is enabled/disabled by RTS.
;*******************************************************************

;**
;* 6800 equates
;**
	.equ	SKIP2,h'8c	;CPX instruction for SKIP2 trick
;stupid assembler can't do direct addressing for lda, sta
	.equ	ldaad,h'96	;ldaa direct
	.equ	ldabd,h'd6	;ldab direct
	.equ	staad,h'97	;staa direct
	.equ	stabd,h'd7	;stab direct
;**
;* ASCII equates
;**
	.equ	CR,h'0d		;carriage return
	.equ	LF,h'0a		;line feed
;**
;* MC6850 ACIA equates
;**
	.equ	ACIACTL,h'f006	;control port
	.equ	ACIASTA,h'f006	;Status port
	.equ	ACIADAT,h'f007	;data port

	.equ	RESACIA,b'00000011	;reset
	.equ	RTSACIA,b'00010101	;RTS active, no ints, /16 clock, 8N1
	.equ	NRTACIA,b'01010101	;RTS inactive

	.equ	RDRF,b'00000001	;Rx reg full
	.equ	TDRE,b'00000010 ;Tx reg empty
	.equ	DCD,b'00000100	;DCD input
	.equ	CTS,b'00001000	;CTS input
	.equ	FE,b'00010000	;Framing Error
	.equ	OVRN,b'00100000	;Rx Overrun
	.equ	PE,b'01000000	;Parity Error
	.equ	IRQ,b'10000000	;int request
;**
;* RAM variables, same as PROM monitor
;**
	.org	h'f1

stack:	.rs	1		;top of stack
brkadr:	.rs	1		;(not used)
echo:	.rs	1		;bit 7 is tty Echo Flag
extflg:	.rs	1		;(not used)
bufull:	.rs	1		;(not used)
savstk:	.rs	2		;(not used)
temp:	.rs	1		;temporary Storage
bytect:	.rs	1		;byte Count
xhi:	.rs	1		;xreg High
xlow:	.rs	1		;xreg Low
shift:	.rs	1		;(not used)
savex:	.rs	2		;(not used)
buffer:	.rs	1		;(not used)

;**
;* PROM Monitor entry points
;**
	.equ	out2h,h'ff6d	;print a in hex, clobber b
	.equ	outch,h'ff81	;print chr in b on console
	.equ	reset,h'ffd8	;cold start
	.equ	crlf,h'ffab	;command interpreter re-entry

;**
;* Disable echo during load
;**
	.org	echo
	.db	b'10000000
;**
;* Main Program
;**
	.org	h'8000		;run in onboard 1K RAM

main:	ldx	#h'0000		;clear xhi/xlow in case of error
	stx	xhi

	ldab	#CR		;initial CRLF
	bsr	gooutc
	ldab	#LF
	bsr	gooutc

	ldab	#RESACIA	;reset 680-UIO ACIA
	stab	ACIACTL
	ldab	#RTSACIA	;setup ACIA, enable CTS
	stab	ACIACTL

;**
;* Load Paper Tape from 680-UIO
;* Load only S1 type records
;* Check address, memory write, checksum
;* Terminate on S9 or checksum error
;**
load:	bsr	inch	;read chr from ACIA
	cmpb	#'S'
	bne	load	;wait for starting S

	clra		;zero checksum

	bsr	inch	;read chr following S
	cmpb	#'9'
	beq	done	;S9 End Of File

	cmpb	#'1'
	bne	load	;Ignore all but S1 & S9

	bsr	byte	;read record byte count
	subb	#h'03	;subtract off checksum, address
	.db	stabd,bytect	;save byte count in RAM

	bsr	byte	;get & save high order address
	.db	stabd,xhi
	bsr	byte	;get & save low order address
	.db	stabd,xlow
	ldx	xhi	;load x with 16-bit address

gdata:	stx	xhi	;test for illegal address
	.db	ldabd,xhi
	bmi	adderr	;only lower 32K allowed

	bsr	byte	;get data byte
	stab	0,x     ;store data at target address

	cmpb	0,x	;read back to test write
	bne	memerr	

	inx		;bump pointer
	dec	bytect	;decrement byte count
	bne	gdata	;loop through record's data bytes

	bsr	byte	;get checksum
	inca		;increment checksum
	beq	load	;checksum ok: go get another record

	ldab	#'C'	;checksum error
	bra	error

;**
;* normal exit after S9 record
;**
done:	ldaa	#NRTACIA	;disable reader
	staa	ACIACTL
	bra	gores

;**
;* jump to outch for shorter code
;**
gooutc:	jmp	outch

;**
;* Subroutine to input one chr from 88-UIO ACIA into b-register
;* Strip parity and ignore nulls
;**
inch:	ldab	ACIASTA	;88-UIO ACIA status to B
	asrb		;rotate RDRF bit into Carry
	bcc	inch	;spin until chr ready

	ldab	#h'7f	;mask parity
	andb	ACIADAT	;get chr
	beq	inch	;ignore nulls
	rts

;**
;* Subroutine to a read byte (2 hex digits) into b-register
;* a-register is used for checksum
;**
byte:	bsr	inhex	;(get 1st hex digit
	aslb		;shift to high order nibble
	aslb
	aslb
	aslb
	.db	stabd,temp

	bsr	inhex	;get 2nd hex digit
	addb	temp	;combine digits
	aba		;add To checksum
	rts

;***
;* Subroutine to input one hex digit into b-register
;* Jump to error if invalid character
;**
inhex:	bsr	inch	;get a chr
	subb	#'0'	;convert ASCII number to hex
	cmpb	#h'09
	ble	in1hg	;done already?

	cmpb	#h'11
	bmi	hexerr	;not hex 
	cmpb	#h'16
	bgt	hexerr	;not hex
	subb	#h'07	;convert ASCII letter to hex
in1hg:	rts

;**
;* Error Routines
;* Print error chr in b, then '?', then address in xhi/xlow
;* Return to PROM monitor via 'reset' to fix stack
;**
adderr:	ldab	#'A'		;write to upper 32K
	.db	SKIP2		;CPX: SKIP2 the next 2 bytes

memerr:	ldab	#'M'		;memory read-back error
	.db	SKIP2		;CPX: SKIP2 the next 2 bytes

hexerr:	ldab	#'H'		;bad hex digit

error:	ldaa	#NRTACIA	;disable reader
	staa	ACIACTL		;...right away

	bsr	gooutc		;print error code in b

	ldab	#'?'
	bsr	gooutc

	.db	ldaad,xhi	;high byte of address
	jsr	out2h
	.db	ldaad,xlow	;low byte of address
	jsr	out2h

	clrb			;a couple of nulls to flush the
	bsr	gooutc		;...onboard ACIA transmitter before
	bsr	gooutc		;...the PROM monitor resets it

gores:	jmp	reset		;the only exit

;**
;* enable echo after load
;**
	.org	echo
	.db	b'00000000

	.end

