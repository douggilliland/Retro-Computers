;*********************************************************
; FILE: ctmon65.inc
;
; Applications wishing to run under CTMON65 should include
; this file, as it defines vectors and other pieces of
; necessary data.
;*********************************************************
;
		include	"config.inc"
;
		bss
		org	ROM_START
;
;=========================================================
; Jump table to common functions.  The entries in this
; table are used by external programs, so nothing can be
; moved or removed from this table.  New entries always
; go at the end.  Many of these are internal functions
; and I figured they might be handy for others.
;
RESET		ds	3
WARM		ds	3
;
; These are the major and minor revision numbers so that
; code can check to see which CTMON65 version is running.
;
CTMON65ver	ds	1
CTMON65rev	ds	1
		ds	1	;unused
;
; Console related functions
;
cin		ds	3
cout		ds	3
cstatus		ds	3
putsil		ds	3
getline		ds	3
crlf		ds	3
HexA		ds	3
;
; Low-level functions to access the SD card system
;
	if	SD_ENABLED
xParInit	ds	3
xParSetWrite	ds	3
xParSetRead	ds	3
xParWriteByte	ds	3
xParReadByte	ds	3
;
; Higher level SD card functions
;
DiskPing	ds	3
DiskDir		ds	3
DiskDirNext	ds	3
DiskOpenRead	ds	3
DiskOpenWrite	ds	3
DiskRead	ds	3
DiskWrite	ds	3
DiskClose	ds	3
	endif	;SD_ENABLED
;
		org	RAM_START
;
; The use of memory starting from here will remain
; constant through different versions of CTMON65.
;
IRQvec		ds	2
NMIvec		ds	2
;
; Before a L(oad) command, these are set to $FF.
; After loading, if they are different, jump to
; that address.
;
AutoRun		ds	2
;
; Pointer to the subroutine that gets the next input
; character.  Used for doing disk/console input.
;
inputVector	ds	2
;
; Same thing for output.
;
outputVector	ds	2
;
; Buffer for GETLINE
;
buffer		ds	BUFFER_SIZE
