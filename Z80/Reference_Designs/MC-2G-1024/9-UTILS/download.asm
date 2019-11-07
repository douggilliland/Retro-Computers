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

TPA	EQU	100H
REBOOT	EQU	0H
BDOS	EQU	5H
CONIO	EQU	6
CONIN	EQU	1
CONOUT	EQU	2
PSTRING	EQU	9
MAKEF	EQU	22
CLOSEF	EQU	16
WRITES	EQU	21
DELF	EQU	19
SETUSR	EQU	32

CR	EQU	0DH
LF	EQU	0AH

FCB	EQU	05CH
BUFF	EQU	080H

cpmver	EQU 12

	ORG TPA

	LD A,(0002h)		; conout via BIOS
	LD H,A
	LD L,0CH
	LD (BCOUT),HL		; put call address in putchr routine
	JR start

restart:
	LD HL,crlf
	CALL putstr

start:	LD A,0
	LD (buffPos),A
	LD (cksum),A
	LD (bytcnt),A
	LD (prtcnt),A
	LD HL,BUFF
	LD (buffPtr),HL

waitlt:	CALL getchr
	CP 'U'
	JP Z,setuser
	CP ':'
	JR NZ,waitlt


	LD C,DELF		; delete existing file
	LD DE,FCB
	CALL BDOS

	LD C,MAKEF		; create file
	LD DE,FCB
	CALL BDOS


gethex:
	CALL getchr		; read characters till '>' end of data
	CP '>'
	JR Z,close
	LD B,A
	PUSH BC
	CALL getchr
	POP BC
	LD C,A

	CALL bctoa

	LD B,A
	LD A,(cksum)
	ADD A,B
	LD (cksum),A
	LD A,(bytcnt)
	INC A
	LD (bytcnt),A

	LD A,B
	LD HL,(buffPtr)
	LD (HL),A
	INC HL
	LD (buffPtr),HL

	LD A,(buffPos)
	INC A
	LD (buffPos),A
	CP 80H
	JR NZ,nowrite

	LD C,WRITES
	LD DE,FCB
	CALL BDOS
	LD A,'.'
	CALL putchr

        ; New line every 8K (64 dots)
	LD A,(prtcnt)
	INC A
	CP 64
	JR NZ,nocrlf
	LD (prtcnt),A
	LD A,CR
	CALL putchr
	LD A,LF
	CALL putchr
	LD A,0
nocrlf:	LD (prtcnt),A

	LD HL,BUFF
	LD (buffPtr),HL

	LD A,0
	LD (buffPos),A
nowrite:
	JR gethex


close:
	LD A,(buffPos)
	CP 0
	JR Z,nowrt2

	LD B,1AH
	LD HL,(buffPtr)
close1:	LD (HL),B
	INC HL
	INC A
	CP 80H
	JR NZ,close1
	LD C,WRITES
	LD DE,FCB
	CALL BDOS
	LD A,'.'
	CALL putchr

nowrt2:
	LD C,CLOSEF
	LD DE,FCB
	CALL BDOS

; Byte count (lower 8 bits)
	CALL getchr
	LD B,A
	PUSH BC
	CALL getchr
	POP BC
	LD C,A

	CALL bctoa
	LD B,A
	LD A,(bytcnt)
	SUB B
	JR Z,bytctok

	LD HL,ctermsg
	CALL putstr

;	; Sink remaining checksum
	CALL getchr
	CALL getchr

	JR nxtfile

bytctok:
	CALL getchr
	LD B,A
	PUSH BC
	CALL getchr
	POP BC
	LD C,A

	CALL bctoa
	LD B,A
	LD A,(cksum)
	SUB B
	JR Z,cksumok

	LD HL,ckermsg
	CALL putstr
	JR nxtfile

cksumok:
	LD HL,OKMess
	CALL putstr

nxtfile:
	LD HL,chkcmd		; get next user input
	LD D,10			; check it against DOWNLOAD command
dld1:	CALL getchr
	JR Z,finish		; timeout - user input ended
	CP ' '			; sink ctrl characters (CR,LF etc)
	JR C,dld1
	CP (HL)
	JR NZ,finish		; not download command
	INC HL
	DEC D
	JR NZ,dld1

	LD HL,FCB+1		; clear the FCB
	LD A,' '		; filename & extent
	LD B,11
fclr1:	LD (HL),A
	INC HL
	DJNZ fclr1
	XOR A			; rest of FCB
	LD B,21
fclr2:	LD (HL),A
	INC HL
	DJNZ fclr2

	LD HL,FCB+1
dld2:	CALL getchr		; next should be filename
	CP ' '			; filename finished
	JP C,restart		; do next file
	JR Z,dld2		; remove spaces
	CALL putchr		; show filename
	CP '.'
	JR Z,dext
	CP 'a'
	JR C,dupper
	AND 5Fh			; make uppercase
dupper:	LD (HL),A		; store filename in FCB
	INC HL
	JR dld2
dext	LD HL,FCB+9		; move pointer to file extent
	JR dld2

finish:	LD C,SETUSR
	LD E,0
	JP BDOS

setuser:
	CALL getchr
	CALL hex2val
	LD E,A
	LD C,SETUSR
	CALL BDOS
	JP waitlt


; Wait for a char into A (no echo)
getchr:	LD B,0		; timeout counter
getc1:	LD E,0FFh
	PUSH HL
	PUSH BC
	LD C,CONIO
	CALL BDOS
	POP BC
	POP HL
	OR A
	RET NZ			; return when character ready
	DJNZ getc1		; also return after 256 empty tries
	RET			; with zero flag still set


; Write A to output
putchr:	LD C,A
	DB 0C3H	 	; opcode for JP
BCOUT:	DS 2		; filled in earlier

putstr: LD A,(HL)
	OR A
	RET Z
	PUSH HL
	CALL putchr
	POP HL
	INC HL
	JR putstr

;------------------------------------------------------------------------------
; Convert ASCII characters in B C registers to a byte value in A
;------------------------------------------------------------------------------
bctoa:	LD A,B		; Move the hi order byte to A
	SUB '0'		; Take it down from Ascii
	CP 0Ah		; Are we in the 0-9 range here?
	JR C,bctoa1	; If so, get the next nybble
	SUB 7		; But if A-F, take it down some more
bctoa1:	RLCA		; Rotate the nybble from low to high
	RLCA		; One bit at a time
	RLCA		; Until we
	RLCA		; Get there with it
	LD B,A		; Save the converted high nybble
	LD A,C		; Now get the low order byte
	SUB '0'		; Convert it down from Ascii
	CP 0Ah		; 0-9 at this point?
	JR C,bctoa2	; Good enough then, but
	SUB 7		; Take off 7 more if it's A-F
bctoa2:	ADD A,B		; Add in the high order nybble
	RET

; Change hex in A to actual value in A
hex2val:
	SUB '0'
	CP 0Ah
	RET C
	SUB 7
	RET


buffPos:	DB 0h
buffPtr:	DW 0000h
prtcnt:		DB 0h
cksum:		DB 0h
bytcnt:		DB 0h
chkcmd:		DB 'A:DOWNLOAD '
OKMess:		DB CR,LF,'OK',CR,LF,0
ckermsg:	DB CR,LF,'======Checksum Error======',CR,LF,0
ctermsg:	DB CR,LF,'======File Length Error======'
crlf:		DB CR,LF,0
	END
