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

numDrives	.EQU	15		; Not including A:


SD_DATA		.EQU	088H
SD_CONTROL	.EQU	089H
SD_STATUS	.EQU	089H
SD_LBA0		.EQU	08AH
SD_LBA1		.EQU	08BH
SD_LBA2		.EQU	08CH

LF		.EQU	0AH		;line feed
FF		.EQU	0CH		;form feed
CR		.EQU	0DH		;carriage RETurn

;====================================================================================

		.ORG	5000H		; Format program origin.


		CALL	printInline
		.TEXT "CP/M Formatter 2.0 by G. Searle 2013"
		.DB CR,LF,0

		LD	A,'A'
		LD	(drvName),A

; There are 512 directory entries per disk, 4 DIR entries per sector
; So 128 x 128 byte sectors are to be initialised
; The drive uses 512 byte sectors, so 32 x 512 byte sectors per disk
; require initialisation

;Drive 0 (A:) is slightly different due to reserved track, so DIR sector starts at 32
		LD	A,(drvName)
		RST	08H		; Print drive letter
		INC	A
		LD	(drvName),A

		LD	A,$20
		LD	(secNo),A

processSectorA:

		LD	A,(secNo)
		OUT 	(SD_LBA0),A
		LD	A,0
		OUT 	(SD_LBA1),A
		LD	A,0
		OUT 	(SD_LBA2),A
		LD	a,$E0

		call	writehst

		LD	A,(secNo)
		INC	A
		LD	(secNo),A
		CP	$40
		JR	NZ, processSectorA



;Drive 1 onwards (B: etc) don't have reserved tracks, so sector starts at 0

		LD 	DE,$0040  ; HL increment
		LD 	HL,$0040  ; H = LBA2, L=LBA1, initialise for drive 1 (B:)

		LD	B,numDrives

processDirs:

		LD	A,(drvName)
		RST	08H		; Print drive letter
		INC	A
		LD	(drvName),A

		LD	A,0
		LD	(secNo),A

processSector:
		LD	A,(secNo)
		OUT 	(SD_LBA0),A
		LD	A,L
		OUT 	(SD_LBA1),A
		LD	A,H
		OUT 	(SD_LBA2),A

		call	writehst

		LD	A,(secNo)
		INC	A
		LD	(secNo),A
		CP	$20
		JR	NZ, processSector

		ADD	HL,DE

		DEC	B
		JR	NZ,processDirs

		CALL	printInline
		.DB CR,LF
		.TEXT "Formatting complete"
		.DB CR,LF,0

		RET				

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

		;CALL 	setLBAaddr
		
		LD	A,$01	; 01 = Write block
		OUT	(SD_CONTROL),A
	
		LD 	c,4
wr4secs:
		LD 	HL,dirData
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


secNo		.db	0
drvName		.db	0


; Directory data for 1 x 128 byte sector
dirData:
		.DB $E5,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$00,$00,$00
		.DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

		.DB $E5,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$00,$00,$00
		.DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

		.DB $E5,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$00,$00,$00
		.DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

		.DB $E5,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$00,$00,$00
		.DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

		.END
	