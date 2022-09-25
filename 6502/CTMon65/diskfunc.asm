		list
;=====================================================
; This is a collection of functions for performing
; higher level disk functions.  This hides the nasty
; details of communications with the remote disk
; system.
;
; August 20, 2014 - Bob Applegate
;                   bob@corshamtech.com
;
; 06/14/2015 - Bob Applegate
;		Now that there is an official standard
;		for the protocol between the host (this
;		code) and the DCP (Arduino code), this
;		code has been updated to be compliant.
;
; 01/14/2016 - Bob Applegate
;              Finally converted to 6502.
;
;		include	"parproto.inc"
;
; Number of drives emulated
;
DRIVES		equ	4
;
;=====================================================
; This is a sanity check to verify connectivity to the
; Arduino code is working.  Returns C clear if all is
; good, or C set if not.
;
DiskPing	jsr	xParSetWrite
		lda	#PC_PING	;command
		jsr	xParWriteByte	;send to Arduino
		jsr	xParSetRead
		jsr	xParReadByte	;read their reply
DiskRetGood	jsr	xParSetWrite
		clc			;assume it's good
		rts
		page
;=====================================================
; This starts a directory read of the raw drive, not
; the mounted drive.  No input parameters.  This simply
; sets up for reading the entries, then the user must
; read each entry.
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskDir		jsr	xParSetWrite
		lda	#PC_GET_DIR	;send command
		jsr	xParWriteByte
		clc		;assume it works
		rts
		page
;=====================================================
; Read the next directory entry.  On input, X (MSB)
; and Y (LSB) point to a 13 byte area to receive the
; drive data.
;
; Returns C set if end of directory (ie, attempt to
; read and there are none left).  Else, C is clear
; and X/Y point to the null at end of filename.
;
DiskDirNext	stx	sptr+1
		sty	sptr
		jsr	xParSetRead	;read results
		jsr	xParReadByte	;get response code
		cmp	#PR_NAK		;error?
		beq	DDNErr
		cmp	#PR_DIR_END	;end?
		beq	DDNErr
;
; This contains a directory entry.
;
		ldy	#0
DDNloop		jsr	xParReadByte
		sta	(sptr),y
		cmp	#0	;end?
		beq	DDNEnd
		jsr	INCPT
		jmp	DDNloop
DDNEnd		jsr	xParSetWrite
		ldx	sptr+1
		ldy	sptr
		clc		;not end of files
		rts
;
; Error.  Set C and return.  This is not really
; proper, since this implies a simple end of the
; directory rather than an error.
;
DDNErr		jsr	xParSetWrite
		sec
		rts
		page
;=====================================================
; This opens a file on the SD for reading.  On entry,
; X (MSB) and Y (LSB) point to a null-terminated
; filename to open.  On return, C is clear if the file
; is open, or C set if an error (usually means the
; file does not exist.
;
; Assumes write mode has been set.  Returns with it set.
;
DiskOpenRead	lda	#PC_READ_FILE
DiskOpen	sty	INL	;save ptr to filename
		stx	INH
		pha
		jsr	xParSetWrite
		pla
		jsr	xParWriteByte
		ldy	#-1
DiskOpenLoop	iny
		lda	(INL),y
		jsr	xParWriteByte
		lda	(INL),y
		bne	DiskOpenLoop
		jsr	xParSetRead
		jsr	xParReadByte	;get response
		cmp	#PR_ACK
		bne	DiskOpenErr
		jsr	xParSetWrite	;back to write mode
		clc
		rts
;
; Got an error.
;
DiskOpenErr	jsr	xParReadByte	;get error code
		jsr	xParSetWrite	;back to write mode
		sec
		rts
;=====================================================
; This opens a file on the SD for writing.  On entry,
; X (MSB) and Y (LSB) point to a null-terminated
; filename to open.  On return, C is clear if the file
; is open, or C set if an error.
;
; Assumes write mode has been set.  Returns with it set.
;
DiskOpenWrite	lda	#PC_WRITE_FILE
		jmp	DiskOpen	;jump into common code
;
;=====================================================
; On entry, A contains the number of bytes to read
; from the file, X (MSB) and Y (LSB) point to the
; buffer where to put the data.  On return, C will
; be set if EOF was reached (and no data read), or
; C will be clear and A contains the number of bytes
; actually read into the buffer.
;
; Modifies A, X and Y.  Also modifies INL and INH
; (00F8 and 00F9).
;
DiskRead	pha
		sty	INL	;save ptr to buffer
		stx	INH
		lda	#PC_READ_BYTES
		jsr	xParWriteByte	;command
		pla		;number of bytes to get
		jsr	xParWriteByte
		jsr	xParSetRead	;get ready for response
		jsr	xParReadByte	;assume PR_FILE_DATA
		jsr	xParReadByte	;length
		pha
		tax			;count
		beq	DiskReadEof	;zero = EOF
		ldy	#0	;offset
DiskReadLoop	jsr	xParReadByte
		sta	(INL),y
		iny		;next offset
		dex
		bne	DiskReadLoop
		jsr	xParSetWrite
		pla		;retrieve byte count
DiskOk		clc	
		rts
DiskReadEof	jsr	xParSetWrite
		pla
		sec
		rts
;
;=====================================================
; On entry, A contains the number of bytes to write
; to the file, X (MSB) and Y (LSB) point to the
; buffer where to get the data.  On return, C will
; be set if an error was detected, or C will be clear
; if no error.  Note that if A contains 0 on entry,
; no bytes are written.
;
; Modifies A, X and Y.  Also modifies INL and INH
; (00F8 and 00F9).
;
DiskWrite	cmp	#0
		beq	DiskOk
		sty	INL	;save ptr to filename
		stx	INH
		pha
		lda	#PC_WRITE_BYTES
		jsr	xParWriteByte	;command
		pla		;number of bytes to write
		pha		;save again
		jsr	xParWriteByte
		pla
		tax			;count
		ldy	#0	;offset
DiskWriteLoop	lda	(INL),y	;get next byte
		jsr	xParWriteByte
		iny		;next offset
		dex
		bne	DiskWriteLoop
		jsr	xParSetRead ;read the status
		jsr	xParReadByte
		cmp	#PR_ACK
		beq	DiskOk1	;all good
		jsr	xParReadByte	;read error code
		jsr	xParSetWrite 
		sec	
		rts
;
DiskOk1		jsr	xParSetWrite
		clc
		rts
;
;=====================================================
; Call this to close any open file.  No parameters
; and no return status.
;
DiskClose	lda	#PC_DONE
		jmp	xParWriteByte


