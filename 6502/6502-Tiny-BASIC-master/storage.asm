;
;=====================================================
;=====================================================
;=====================================================
; This file contains the functions for saving and
; restoring programs from some sort of mass storage
; device.  This particular version is for using the
; Corsham Tech SD Card System.
;=====================================================
;=====================================================
;=====================================================

		bss
diskBufLength	ds	1
diskBufOffset	ds	1
		code

;
;=====================================================
; Open a file for reading as a program.  The next
; thing on the line should be the filename.
;
iOPENREAD
	if	XKIM || CTMON65
		ldy	CUROFF
		lda	(CURPTR),y
		bne	iOPENfn		;might be filename
;
; No filename supplied.
;
iOPENnofn	lda	#0
		ldx	#ERR_NO_FILENAME
		jmp	iErr2
;
; Add the offset into the buffer start
;
iOPENfn		clc
		tya
		adc	CURPTR
		tay			;LSB
		lda	CURPTR+1
		adc	#0
		tax
		jsr	DiskOpenRead	;attempt to open file
		bcc	Ropenok		;branch if opened ok
;
; Open failed
;
Rdfail		ldx	#ERR_READ_FAIL
Rdfail2		lda	#0
		jmp	iErr2
;
; Clear counts and offsets so the next read will
; cause the file to be read.
;
Ropenok		lda	#0
		sta	diskBufOffset
		sta	diskBufLength
		jmp	NextIL
	endif
;
;=====================================================
iOPENWRITE
	if	XKIM || CTMON65
		ldy	CUROFF
		lda	(CURPTR),y
		beq	iOPENnofn
;
		clc
		tya
		adc	CURPTR
		tay			;LSB
		lda	CURPTR+1
		adc	#0
		tax
		jsr	DiskOpenWrite	;attempt to open file
		bcc	Wopenok		;branch if opened ok
;
; Open failed
;
Wdfail		lda	#0
		ldx	#ERR_WRITE_FAIL
		jmp	iErr2
;
Wopenok		jmp	NextIL
	endif
;
;=====================================================
; Gets a line of input from the disk file and puts it
; into LINBUF.
;
; On exit:
;    CURPTR points to LINBUF
;    LINBUF contains the line with 0 at the end.
;    Y has offset to first non-space character
;    CURROFF has the same as Y.
;
iDGETLINE
	if	XKIM || CTMON65
		ldx	#LINBUF&$ff
		stx	CURPTR
		ldx	#LINBUF>>8
		stx	CURPTR+1
;
		ldx	#0	;offset
iDgetLoop	stx	getlinx
		jsr	getNextFileByte
		bcs	iGetEOF
		cmp	#CR
		beq	iGetEOL
		cmp	#LF
		beq	iGetEOL
		ldx	getlinx
		sta	LINBUF,x
		inx
		bne	iDgetLoop
;
; Handle end of line.  If the line has nothing, loop
; back and get another line.
;
iGetEOL		ldx	getlinx		;blank line?
		beq	iDgetLoop	;yes, ignore it
;
; This can fall through when there is a line, or
; called directly when EOF is encountered.
;
iGetEOF		ldx	getlinx
		lda	#0
		sta	LINBUF,x
		sta	CUROFF
		ldy	#0
		jsr	SkipSpaces
		jmp	NextIL
	endif
;
;=====================================================
; Does a LIST to a file file.
;
iDLIST
	if	XKIM || CTMON65
		jsr	SetOutDisk
		jmp	iLST2
	endif
;
;=====================================================
; Closes any pending disk file.  Okay to call if there
; is no open file.
;
iDCLOSE
	if	XKIM || CTMON65
		jsr	DiskClose
		jmp	NextIL
	endif
;
;=====================================================
; This gets the next byte from an open disk file.  If
; there are no more bytes left, this returns C set.
; Else, C is clear and A contains the character.
;
getNextFileByte
	if	XKIM || CTMON65
		ldx 	diskBufOffset
		cpx	diskBufLength
		bne	hasdata		;branch if still data
;
; There is no data left in the buffer, so read a
; block from the SD system.
;
		lda	#BUFFER_SIZE
		ldx	#buffer>>8
		ldy	#buffer&$ff
		jsr	DiskRead
		bcs	getNextEof
;
; A contains the number of bytes actually read.
;
		sta	diskBufLength	;save length
		cmp	#0		;shouldn't happen
		beq	getNextEof
;
		ldx	#0
hasdata		lda	buffer,x
		inx
		stx	diskBufOffset
		clc
		rts
;
getNextEof	lda	#0
		sta	diskBufOffset
		sta	diskBufLength
		sec
		rts
;
;=====================================================
; Set output vector to the disk output function
;
SetOutDisk	lda	#DOUT&$ff
		sta	BOutVec
		lda	#DOUT/256
		sta	BOutVec+1
		rts
;
;=====================================================

DOUT		sta	buffer
		lda	#1
		ldy	#buffer&$ff
		ldx	#buffer/256
		jsr	DiskWrite
;
; need error checking here
;
		rts
	endif


