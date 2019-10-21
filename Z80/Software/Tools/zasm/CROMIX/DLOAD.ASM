	z80
	maclib jsysequ
	maclib SYScalls

CR	equ	0x0d
LF	equ	0x0a

DLdata	equ	0xa0
DLstat	equ	0xa1
DLcntrl	equ	0xa1
DLrdy	equ	0x01
Dlnrdy	equ	0x00
DLrew	equ	0xff

	org	0x100

DLOAD:
	lxi	sp,Stack
	lxi	IY,Data
	wrline	stdout,OpenMsg

	lixd	argv
	lda	argc
	cmpi	2		;need 2 args arg0 and arg1
	jz	GoodArgs
Usage:
	wrline	stderr,UsageMsg
	exit	1
GoodArgs:	
	mov	l,2(IX)	;hl -> arg1
	mov	h,3(IX)
	create	 ,op.write|op.condf,0
	jnc	DoIt
	cmpi	?exists
	jnz	CantOpen
FileExists:
	wrline	stderr,OverwritePrompt
	rdbyte	stdin
	cmpi	'y'
	jz	Overwrite
	cmpi	'Y'
	jnz	Exit
Overwrite:
	mov	l,2(IX)	;hl -> arg1
	mov	h,3(IX)
	create	,op.write|op.truncf,0
	jnc	DoIt
CantOpen:
	perror
	push	hl
	printf	stderr,CantOpenCntrl
	pop	hl
	exit	1
DoIt:
	mov	FN-Data(IY),b	;save FN (b)
	printf	stderr,DownloadingCntrl

	output	DLcntrl,DLrew	;rewind file

	mov	b,FN-Data(IY)	;b=FN

while:
	input	DLstat
	cmpi	DLrdy
	jnz	EndOfInput

	input	DLdata
	sta	InByte

	input	DLstat
	cmpi	DLrdy
	jnz	EndOfInput
	
	lda	InByte	;a=byte
	mov	b,FN-Data(IY)	;b=FN
	wrbyte	
	jmp	while

EndOfInput:
	mov	b,FN-Data(IY)	;b=FN
	close

Finished:
	;mov	b,FN-Data(IY)	;b=FN
	;cstat	,st.size
	mov	l,2(IX)	;hl -> arg1
	mov	h,3(IX)
	fstat	,st.size
	push	de
	push	hl
	printf	stderr,FinishedCntrl
	pop	hl
	pop 	de

Exit:
	exit	0
data:
FN		db	0
InByte		db	0

OpenMsg		db	"Dload for Z80 Emulator, Cromix Version 1.0",CR,LF,0
UsageMsg	db	"    Usage: dload <filename><cr>",cr,lf,0
OverwritePrompt	db	"File Exists - Overwrite? (Y or N) - ",0
CantOpenCntrl	db	"\nCan't open %s\n",0
DownloadingCntrl	db	"\nDownloading...",0
FinishedCntrl	db	"Finished\n%Ld Bytes Written\n",0
;stack is done like this so CROMIX knows how big this program is.
		dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;stack
		dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;stack
		dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;stack
		dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;stack
Stack
	end 	DLOAD