;==================================================================================
; Contents of this file are copyright Grant Searle
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

loadAddr	.EQU	0D000h
numSecs		.EQU	24	; Number of 512 sectors to be loaded

SD_DATA		.EQU	088H
SD_CONTROL	.EQU	089H
SD_STATUS	.EQU	089H
SD_LBA0		.EQU	08AH
SD_LBA1		.EQU	08BH
SD_LBA2		.EQU	08CH

LF		.EQU	0AH		;line feed
FF		.EQU	0CH		;form feed
CR		.EQU	0DH		;carriage RETurn

;================================================================================================

		.ORG	5000H		; Loader origin.

		CALL	printInline
		.TEXT "CP/M System Transfer by G. Searle 2012-13"
		.DB CR,LF,0

		LD	B,numSecs

		LD	A,0
		LD	(lba0),A
		ld 	(lba1),A
		ld 	(lba2),A
		ld 	(lba3),A
		LD	HL,loadAddr
		LD	(dmaAddr),HL
processSectors:

		call	writehst

		LD	DE,0200H
		LD	HL,(dmaAddr)
		ADD	HL,DE
		LD	(dmaAddr),HL
		LD	A,(lba0)
		INC	A
		LD	(lba0),A

		djnz	processSectors

		CALL	printInline
		.DB CR,LF
		.TEXT "System transfer complete"
		.DB CR,LF,0

		RET				

; =========================================================================
; Disk routines as used in CBIOS
; =========================================================================
setLBAaddr:
		LD	A,(lba2)
		OUT	(SD_LBA2),A
		LD	A,(lba1)
		OUT	(SD_LBA1),A
		LD	A,(lba0)
		OUT	(SD_LBA0),A
		ret

;================================================================================================
; Write physical sector to host
;================================================================================================

writehst:
		PUSH 	AF
		PUSH 	BC
		PUSH 	HL

wrWait1: IN	A,(SD_STATUS)
		CP	128
		JR	NZ,wrWait1

		CALL 	setLBAaddr
		
		LD	A,$01	; 01 = Write block
		OUT	(SD_CONTROL),A
	
		LD 	c,4
		;LD 	HL,hstbuf
wr4secs:
		LD 	b,128
wrByte:
	
wrWait2: IN	A,(SD_STATUS)
		CP	160 ; Write buffer empty
		JR	NZ,wrWait2

		LD 	A,(HL)
		OUT	(SD_DATA),A
		INC 	HL
		dec 	b
		JR 	NZ, wrByte

		dec 	c
		JR 	NZ,wr4secs

		POP 	HL
		POP 	BC
		POP 	AF
		
		;XOR 	a
		;ld	(erflag),a
		RET


;================================================================================================
; Utilities
;================================================================================================

printInline:
		EX 	(SP),HL 	; PUSH HL and put RET ADDress into HL
		PUSH 	AF
		PUSH 	BC
nextILChar:	LD 	A,(HL)
		CP	0
		JR	Z,endOfPrint
		RST 	08H
		INC 	HL
		JR	nextILChar
endOfPrint:	INC 	HL 		; Get past "null" terminator
		POP 	BC
		POP 	AF
		EX 	(SP),HL 	; PUSH new RET ADDress on stack and restore HL
		RET

lba0		.DB	00h
lba1		.DB	00h
lba2		.DB	00h
lba3		.DB	00h
dmaAddr		.dw	0

	.END
