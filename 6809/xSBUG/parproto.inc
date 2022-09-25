;*****************************************************
; Parallel port protocol
;
; This is the header file for making applications
; compliant with The Remote Disk Protocol Guide which
; is on the Corsham Technologies web page somewhere:
;
;    www.corshamtech.com
;
; This was updated 06/13/2015 to be compliant with the
; official specification, so the opcode values changed.
;
;=====================================================
; Commands from host to Arduino
;
PC_GET_VERSION	equ	$01
PC_PING		equ	$05	;ping Arduino
PC_LED_CONTROL	equ	$06	;LED control
PC_GET_CLOCK	equ	$07	;Get RTC
PC_SET_CLOCK	equ	$08	;Set RTC
PC_GET_DIR	equ	$10	;Get directory
PC_GET_MOUNTED	equ	$11	;Get mounted drive list
PC_MOUNT	equ	$12	;Mount drive
PC_UNMOUNT	equ	$13	;Unmount drive
PC_GET_STATUS	equ	$14	;Get status for one drive
PC_DONE		equ	$15	;Stop data
PC_ABORT	equ	PC_DONE
PC_READ_FILE	equ	$16	;Read regular file (non-DSK)
PC_READ_BYTES	equ	$17	;Read sequential bytes
PC_RD_SECTOR	equ	$18	;Read FLEX sector
PC_WR_SECTOR	equ	$19	;Write FLEX sector
PC_GET_MAX	equ	$1a	;Get maximum drives
PC_WRITE_FILE   equ	$1b	;Open file for writing
PC_WRITE_BYTES	equ	$1c	;Data to be written
PC_SAVE_CONFIG	equ	$1d	;Save current config data to file
PC_SET_TIMER	equ	$1e	;Turn on/off RTC timer
PC_READ_LONG	equ	$1f	;read sector using long sector num
PC_WRITE_LONG	equ	$20	;write sector using long sec number
;
;=====================================================
; Responses from Arduino to host
;
PR_VERSION_INFO	equ	$81	;Contains version information
PR_ACK		equ	$82	;ACK (no additional information)
PR_NAK		equ	$83	;NAK - one status byte follows
PR_PONG		equ	$85	;Reply to a ping
PR_CLOCK_DATA	equ	$87	;Clock data
PR_DIR_ENTRY	equ	$90	;Directory entry
PR_DIR_END	equ	$91	;End of directory entries
PR_FILE_DATA	equ	$92	;File data
PR_STATUS	equ	$93	;Drive status
PR_SECTOR_DATA	equ	$94	;Sector data
PR_MOUNT_INFO	equ	$95	;Mount entry
PR_MAX_DRIVES	equ	$96	;Maximum number of drives
;
;=====================================================
; Error codes for NAK events
;
ERR_NONE	equ	00
ERR_NOT_MOUNTED	equ	10
ERR_MOUNTED	equ	11
ERR_NOT_FOUND	equ	12
ERR_READ_ONLY	equ	13
ERR_BAD_DRIVE	equ	14
ERR_BAD_TRACK	equ	15
ERR_BAD_SECTOR	equ	16
ERR_READ_ERROR	equ	17

