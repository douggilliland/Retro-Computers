;==================================================================================
; Contents of this file are copyright Grant Searle
; HEX routine from Joel Owens.
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; http://searle.hostei.com/grant/index.html
;
; eMail: home.micros01@btinternet.com
;
; If the above don't work, please perform an Internet search to see if I have
; updated the web page hosting service.
;
;==================================================================================

TPA	equ	100H
REBOOT	equ	0H
BDOS	equ	5H
CONIO	equ	6
CONIN	equ	1
CONOUT	equ	2
PSTRING	equ	9
MAKEF	equ	22
CLOSEF	equ	16
WRITES	equ	21
DELF	equ	19
SETUSR	equ	32

CR	equ	0DH
LF	equ	0AH

FCB	equ	05CH
BUFF	equ	080H

cpmver	equ 12

	ORG TPA

	ld A,(0002h)		; conout via BIOS
	ld H,A
	ld L,0CH
	ld (BCOUT),HL		; put call address in putchr routine
	jr start

restart:
	ld HL,crlf
	call putstr

start:	ld A,0
	ld (buffPos),A
	ld (checkSum),A
	ld (byteCount),A
	ld (printCount),A
	ld HL,BUFF
	ld (buffPtr),HL

WAITLT:	call getchr
	cp 'U'
	jp z,SETUSER
	cp ':'
	jr nz,WAITLT


	ld C,DELF		; delete existing file
	ld DE,FCB
	call BDOS

	ld C,MAKEF		; create file
	ld DE,FCB
	call BDOS


GETHEX:
	call getchr		; read characters till '>' end of data
	cp '>'
	jr Z,CLOSE
	ld B,A
	push BC
	call getchr
	pop BC
	ld C,A

	call BCTOA

	ld B,A
	ld A,(checkSum)
	add A,B
	ld (checkSum),A
	ld A,(byteCount)
	inc A
	ld (byteCount),A

	ld A,B
	ld HL,(buffPtr)
	ld (HL),A
	inc HL
	ld (buffPtr),HL

	ld A,(buffPos)
	inc A
	ld (buffPos),A
	cp 80H
	jr nz,NOWRITE

	ld C,WRITES
	ld DE,FCB
	call BDOS
	ld A,'.'
	call putchr

        ; new line every 8K (64 dots)
	ld A,(printCount)
	inc A
	cp 64
	jr nz,noCRLF
	ld (printCount),A
	ld A,CR
	call putchr
	ld A,LF
	call putchr
	ld A,0
noCRLF:	ld (printCount),A

	ld HL,BUFF
	ld (buffPtr),HL

	ld A,0
	ld (buffPos),A
NOWRITE:
	jr GETHEX


CLOSE:
	ld A,(buffPos)
	cp 0
	jr Z,NOWRITE2

	ld B,1AH
	ld HL,(buffPtr)
CLOSE1:	ld (HL),B
	inc HL
	inc A
	cp 80H
	jr NZ, CLOSE1
	ld C,WRITES
	ld DE,FCB
	call BDOS
	ld A,'.'
	call putchr

NOWRITE2:
	ld C,CLOSEF
	ld DE,FCB
	call BDOS

; Byte count (lower 8 bits)
	call getchr
	ld B,A
	push BC
	call getchr
	pop BC
	ld C,A

	call BCTOA
	ld B,A
	ld A,(byteCount)
	sub B
	jr Z,byteCountOK

	ld HL,countErrMess
	call putstr

;	; sink remaining checksum
	call getchr
	call getchr

	jr nextfile

byteCountOK:

; Checksum
	call getchr
	ld B,A
	push BC
	call getchr
	pop BC
	ld C,A

	call BCTOA
	ld B,A
	ld A,(checkSum)
	sub B
	jr Z,checksumOK

	ld HL,chkErrMess
	call putstr
	jr nextfile

checksumOK:
	ld HL,OKMess
	call putstr

nextfile:
	ld HL,chkcmd		; get next user input
	ld D,10			; check it against DOWNLOAD command
dld1:	call getchr
	jr z,finish		; timeout - user input ended
	cp ' '			; sink ctrl characters (CR,LF etc)
	jr c,dld1
	cp (HL)
	jr nz,finish		; not download command
	inc HL
	dec D
	jr nz,dld1

	ld HL,FCB+1		; clear the FCB
	ld A,' '		; filename & extent
	ld B,11
fclr1:	ld (HL),A
	inc HL
	djnz fclr1
	xor A			; rest of FCB
	ld B,21
fclr2:	ld (HL),A
	inc HL
	djnz fclr2

	ld HL,FCB+1
dld2:	call getchr		; next should be filename
	cp ' '			; filename finished
	jp c,restart		; do next file
	jr z,dld2		; remove spaces
	call putchr		; show filename
	cp '.'
	jr z,dext
	cp 'a'
	jr c,dupper
	and 5Fh			; make uppercase
dupper:	ld (HL),A		; store filename in FCB
	inc HL
	jr dld2
dext	ld HL,FCB+9		; move pointer to file extent
	jr dld2

finish:	ld C,SETUSR
	ld E,0
	jp BDOS

SETUSER:
	call getchr
	call HEX2VAL
	ld E,A
	ld C,SETUSR
	call BDOS
	jp WAITLT


; Wait for a char into A (no echo)
getchr:	ld BC,10		; timeout counter
getc1:	ld E,0FFh
	push HL
	push BC
	ld C,CONIO
	call BDOS
	pop BC
	pop HL
	or A
	ret nz			; return when character ready
	djnz getc1		; also return after 256 empty tries
	dec C
	jr nz,getc1
	ret			; with zero flag still set


; Write A to output
putchr:	ld C,A
	db 0C3H	 	; opcode for JP
BCOUT:	ds 2		; filled in earlier

putstr: ld A,(HL)
	or A
	ret z
	push HL
	call putchr
	pop HL
	inc HL
	jr putstr

;------------------------------------------------------------------------------
; Convert ASCII characters in B C registers to a byte value in A
;------------------------------------------------------------------------------
BCTOA	ld A,B		; Move the hi order byte to A
	sub '0'		; Take it down from Ascii
	cp 0Ah		; Are we in the 0-9 range here?
	jr c,BCTOA1	; If so, get the next nybble
	sub 7		; But if A-F, take it down some more
BCTOA1	rlca		; Rotate the nybble from low to high
	rlca		; One bit at a time
	rlca		; Until we
	rlca		; Get there with it
	ld B,A		; Save the converted high nybble
	ld A,C		; Now get the low order byte
	sub '0'		; Convert it down from Ascii
	cp 0Ah		; 0-9 at this point?
	jr c,BCTOA2	; Good enough then, but
	sub 7		; Take off 7 more if it's A-F
BCTOA2	add A,B		; Add in the high order nybble
	ret

; Change Hex in A to actual value in A
HEX2VAL sub '0'
	cp 0Ah
	ret C
	sub 7
	ret


buffPos		db 0h
buffPtr		dw 0000h
printCount	db 0h
checkSum	db 0h
byteCount	db 0h
chkcmd		db 'A:DOWNLOAD '
OKMess		db CR,LF,'OK',CR,LF,0
chkErrMess	db CR,LF,'======Checksum Error======',CR,LF,0
countErrMess	db CR,LF,'======File Length Error======'
crlf		db CR,LF,0
	end
