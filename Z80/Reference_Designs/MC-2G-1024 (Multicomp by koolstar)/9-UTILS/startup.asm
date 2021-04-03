;
; usage: INITPATH 
;
; DOS+ utility.  For first-time searchpath setup of DOS+.
;
;
path	EQU	014h		;BDOS offset to path address
;
; DOS+/CPM  Calls
cpmver	EQU	12
getinfo	EQU	210		;e = 0 returns BDOS base address
;
bdos	EQU	5

	ORG	100h

	JP	init
pstr:	DB	41h,24h,0h,0h,0h,0h,0h,0h,0h	;A$ - with extra room to patch

; Start here
init:	LD	HL,0		;Check if OS is capable
	ADD	HL,SP
	LD	SP,stack
	PUSH	HL
	LD	C,cpmver	;Make sure running DOS+ 2.4 up
	CALL	bdos
	INC	H
	DEC	H
	JP	NZ,exit		;not MPM etc
	CP	22h
	JP	C,exit		;< 2.2, cant be compatible mode
	CP	30h
	JP	NC,exit		;Can't use CPM 3
	CP	24h
	JP	NC,init1		;ok, 2.4 thru 2.f
	CALL	getbas		;of DOS+, if running
	LD	A,H		;DOS+ returns base pointer
	OR	A		;CPM returns 0
	JP	Z,exit		;not in compatible mode

; DOS+ running, check parameters and execute
init1:	CALL	getbas		;of DOS+
	LD	L,path		;point to configured path location
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	OR	H
	JP	Z,exit		;no path configured
	LD	A,(HL)
	OR	A
	JP	NZ,exit		;path already set
	EX	DE,HL		;path pointer to de
	LD	HL,pstr
init2:	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	OR	A
	JR	NZ,init2
	
; restore SP and exit
exit:	POP	HL
	LD	SP,HL
	RET
		
; Get BDOS base page, on DOS+.  CPM returns 0
; a,f,h,l
getbas:	PUSH	BC
	PUSH	DE
	LD	C,getinfo
	LD	E,0
	CALL	bdos		;get BDOS base page
	POP	DE
	POP	BC
	RET
	
	DS	48
stack:
	END
°)
