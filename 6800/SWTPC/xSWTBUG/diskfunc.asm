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
;		include	"parproto.inc"
;
; Number of drives emulated
;
DRIVES		equ	4

		code
	if	~IN_SWTBUG
		org	$a800
;
;=====================================================
; This is a jump table to the various functions so
; callers of this code don't need to know exactly
; where each function is or what it's called.
;
; First, the low-level functions.  If the disk system
; has not been used yet, call ParInit first.
;
		jmp	xParInit
		jmp	xParSetWrite
		jmp	xParSetRead
		jmp	xParWriteByte
		jmp	xParReadByte
;
; Followed by higher level functions
;
		jmp	DiskReadSector
		jmp	DiskWriteSector
		jmp	DiskStatus
		jmp	DiskGetDrives
		jmp	DiskGetMounted
		jmp	DiskNextMountedDrv
		jmp	DiskUnmount
		jmp	DiskMount
		jmp	DiskDir
		jmp	DiskDirNext
	endif
;
;=====================================================
; This is a sanity check to verify connectivity to the
; Arduino code is working.  Returns C clear if all is
; good, or C set if not.
;
DiskPing	lda	#PC_PING	;command
		jsr	xParWriteByte	;send to Arduino
		jsr	xParSetRead
		jsr	xParReadByte	;read their reply
DiskRetGood	jsr	xParSetWrite
		clc			;assume it's good
		rts
;
;=====================================================
; Get the maximum number of drives supported.  This
; takes no input parameters.  Returns a value in A
; that is the number of drives supported.  This is a
; one based value, so a return of 4 indicates that four
; drives are supported, 0 to 3.
;
; NOTE: FLEX only supports four drives, so fake it for
; now and always return 4.  This call might be silly
; and prime for removal.
;
DiskGetDrives	lda	#DRIVES
		rts
		page
;=====================================================
; Unmount a filesystem.  On entry, A contains the
; zero-based drive number.
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskUnmount	psha		;save drive
		lda	#PC_UNMOUNT
		jsr	xParWriteByte
		pula
		jsr	xParWriteByte
;
; Handy entry point.  This sets the mode to read, gets
; an ACK or NAK, and if a NAK, gets the error code
; and returns it in A.
;
ComExit		jsr	xParSetRead	;get ready for response
		jsr	xParReadByte
		cmpa	#PR_ACK
		beq	DiskRetGood
;
; Assume it's a NAK.
;
DiskRetErrCode	jsr	xParReadByte	;get error code
DiskRetBad	jsr	xParSetWrite
		sec
		rts
		page
;=====================================================
; Mount a filesystem.  On entry, A contains a zero
; based drive number, B is the read-only flag (0 or
; non-zero), and X points to a filename to mount on
; that drive.  
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskMount       pshb		;save read-only flag
		psha		;save drive
		lda	#PC_MOUNT
		jsr	xParWriteByte	;send the command
		pula
		jsr	xParWriteByte	;send drive number
		pulb
		jsr	xParWriteByte	;send read-only flag
;
; Now send each byte of the filename until the end,
; which is a 0 byte.
;
dmnt1		lda	0,x
		beq	dmnt2
		jsr	xParWriteByte
		inx
		bra	dmnt1
dmnt2		jsr	xParWriteByte	;send trailing null
		bra	ComExit
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
DiskDir		lda	#PC_GET_DIR	;send command
		jsr	xParWriteByte
		clc		;assume it works
		rts
		page
;=====================================================
; Read the next directory entry.  On input, X points
; to a XXX byte area to receive the drive data.
; Returns C set if end of directory (ie, attempt to
; read and there are none left).  Else, C is clear
; and X points to the null at end of filename.
;
DiskDirNext	jsr	xParSetRead	;read results
		jsr	xParReadByte	;get response code
		cmpa	#PR_NAK		;error?
		beq	DDNErr
		cmpa	#PR_DIR_END	;end?
		beq	DDNErr
;
; This contains a directory entry.
;
DDNloop		jsr	xParReadByte
		sta	0,x
		inx
		cmpa	#0	;end of file name?
		bne	DDNloop
DDNEnd		jsr	xParSetWrite
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
; This is a low level disk function for a real OS to
; perform a disk sector read.  On entry, X points to
; a disk parameter block with the following fields:
;
;    drive             DS   1
;    track             DS   1
;    sector            DS   1
;    sectors per track DS   1
;    ptr to data       DS   2   must be 256 bytes long!
;
; The first three fields are zero based.  Sectors per
; track is a one based value.
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskReadSector	lda	#PC_RD_SECTOR	;sector read command
		jsr	Dsendinfo
;
; Now get the response.  Will be either a NAK followed
; by an error code, or a 97 followed by 256 bytes of
; data.
;
		jsr	xParSetRead
		jsr	xParReadByte	;response
		cmpa	#PR_SECTOR_DATA	;data?
		bne	DiskCerror	;no
;
		ldx	4,x	;load buffer address
		ldab	#0	;256 bytes of data
DiskReadLp	jsr	xParReadByte
		sta	0,x
		inx
		decb
		bne	DiskReadLp
;
; All done
;
		jsr	xParSetWrite
		clrb
		rts
;
; Common error handler.  Next byte is the error code
; which goes into B, set carry, and exit.
;
DiskCerror	jsr	xParReadByte
		jsr	DiskErrTranslate
		tab
DiskCerr2	jsr	xParSetWrite
		sec
		rts
		page
;=====================================================
; This is a low level disk function for a real OS to
; perform a disk sector write.  On entry, IX points to
; a disk parameter block with the following fields:
;
;    drive             DS   1
;    track             DS   1
;    sector            DS   1
;    sectors per track DS   1
;    ptr to data       DS   2   must be 256 bytes long!
;
; The first three fields are zero based.  Sectors per
; track is one based.
;
; Returns with C clear on success.  If error, C is set
; and A contains the error code.
;
DiskWriteSector	lda	#PC_WR_SECTOR	;write sector command
		jsr	Dsendinfo
		ldx	4,x	;get pointer
		ldab	#0	;counter
DiskWriteLp	lda	0,x
		jsr	xParWriteByte
		inx
		decb
		bne	DiskWriteLp
;
; Now get response.
;
		jsr	xParSetRead
		jsr	xParReadByte
		cmpa	#PR_NAK	;NAK?
		beq	DiskCerror
;
; This is a common "good" exit point.  Clears B, clears
; carry and sets Z.
;
DiskComEx	jsr	xParSetWrite
		clrb		;clear error indicator
		rts
		page
;=====================================================
; Get list of mounted drives.  This starts the
; process, then each call to DiskNextMountedDrv will
; return the next drive in sequence.
;
DiskGetMounted	lda	#PC_GET_MOUNTED	;start command
		bra	DiskSendByte
		page
;=====================================================
; Get next mounted drive.  On entry, IX points to a
; XXX byte area to receive the data.  Each call loads
; the area with:
;
; Drive number - 1 byte
; Read-only flag.  0 = read/write, non-zero = read-only
; File name    - X bytes of filename (xxxxxxxx.xxx)
; null         - 1 byte ($00)
;
; If C is clear, then the data area is populated with
; data.  If C is set, then there are no more entries.
;
DiskNextMountedDrv
		jsr	xParSetRead
		jsr	xParReadByte
		cmpa	#PR_DIR_END	;end?
		beq	DiskCerr2
		cmpa	#PR_NAK		;NAK?
		beq	DiskCerror
;
; Get drive number, then read-only flag
;
		jsr	xParReadByte	;drive
		sta	0,x
		inx
		jsr	xParReadByte	;read-only flag
		sta	0,x
		inx
DiskNMD		jsr	xParReadByte
		sta	0,x
		inx		;next byte in data
		cmpa	#0	;end?
		bne	DiskNMD
		bra	DiskComEx	;all done
		page
;=====================================================
; Gets status of a specific drive.  The drive number
; (0-3) is in A on entry.
;
; Returns a bitmapped value in A meant to look sort
; of like a 1771 FDC status register:
;
; RW000000
;   P: Clear if the drive is present (mounted), set
;      if not present ("Not Ready").
;   W: Set if the drive is write protected.
;
DiskStatus	psha
		lda	#PC_GET_STATUS	;get status command
		jsr	xParWriteByte	;send request for data
		pula
		jsr	xParWriteByte
		jsr	xParSetRead
		jsr	xParReadByte	;get result code
		cmpa	#PR_STATUS	;status
		bne	DiskSt_1	;else assume error
;
; Get ONE byte of status:
;
;    00000ERU
;
;  U: 0 = mounted, 1 = Unmounted
;  R: 0 = Read/write, 1 = Read only
;  E: 0 = no error, 1 = access error (bad sector?)
;
; The E bit will never be set for status.
;
		jsr	xParReadByte	;what we care about
		psha
		jsr	xParSetWrite
		pula
		jsr	DiskErrTranslate
		rts
DiskSt_1	lda	#%10000000	;drive not present
		rts
		page
;
;=====================================================
; Given a status code from the SD software, convert
; to a 1771 equivalent error and return in A.
;
; RW000000
;   P: Clear if the drive is present (mounted), set
;      if not present ("Not Ready").
;   W: Set if the drive is write protected.
;
DiskErrTranslate
; convert to table lookup eventually.  The 6502 sure
; was better at table lookups than the 6800!
;
		clrb		;clear return value
		bita	#$01	;is drive mounted?
		bne	det_1	;yes, leave top bit clear
		andb	#$80	;drive not mounted
		bra	det_ret	;done
det_1		bita	#$02	;read only?
		bne	det_ret
		andb	#$40
;
; Return value is in B.  Move to A, return.
;
det_ret		tba		;transfer B to A
		rts
;
;=====================================================
; This formats a drive.  On entry, X points to a FCB
; with the following data fields:
;
;                      DS   1	;unused
;    number of tracks  DS   1
;    number of sectors DS   1	;sectors per track
;    sector fill value DS   1
;    ptr to filename   DS   2
;
; If the number of tracks or number of sectors is
; zero, then that indicates a value of 256.
;
; This only creates an empty file of the appropriate
; size; it does not initialize any data structures.
;
;DiskFormat	
;		rts
;
;=====================================================
; This is a helper function for the read and write
; functions.  Enter with A containing the command to
; be sent, X pointing to the data area.  This sends
; the command, then the drive, track, sector and
; sectors per track from the data area.
;
; This must not modify the FCB!  The caller might
; depend on the values in it.
;
; This also de-Flexes the sector number.  Ie, any
; track other than 0 and any sector on track zero
; greater than one has one subtraced from it.
;
Dsendinfo	jsr	xParWriteByte	;command
		lda	0,x	;get drive
		jsr	xParWriteByte	;drive
;
		lda	#2	;256 byte sectors
		jsr	xParWriteByte
;
; If needed, change the sector number from the FLEX
; format to a zero based one.  First sector on the
; first track is sector 0, track 0, then the next
; sector is sector 2.  Yes, 2.  All other tracks
; start with sector 1.  This converts everything to
; a zero based sector number.
;
		lda	1,x	;get track
		jsr	xParWriteByte	;track
		lda	1,x	;get track again
		bne	Dtweak
		lda	2,x	;get sector
		beq	Dnotweak
Dtweak		lda	2,x	;get sector
		deca		;make zero based
Dnotweak	jsr	xParWriteByte	;sector
		lda	3,x	;get tracks/sector
DiskSendByte	jmp	xParWriteByte

;		include	"pario.asm"

