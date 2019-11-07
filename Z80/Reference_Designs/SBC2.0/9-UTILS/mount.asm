COMTAIL		equ 80h
BDOS		equ 0005h
maxDisk		equ 3			; A:-C:
maxVolume	equ 254			; volume 1-120 to assign
					; -1 is unmount so maximum is 255
					; on changing these numbers, change
					; helptext below too.
cpmver		equ 12

CR		equ 0Dh
LF		equ 0Ah

	ORG $100

; Start here
init:	ld C,19h		; get current disk
	call BDOS
	ld (currDrv),A		; store it for later
	ld C,cpmver		; get current CP/M version
	call BDOS
	ld A,H			; if H > 0 we're running MP/M 
	or A			; or somesuch
	jp nz,MPMErr		; MP/M running, exit
	ld A,L			; get version number
	cp 30h
	jr nc,setcpm3		;CP/M-3
; this is CP/M-2 set variables
setcpm2:
	xor A
	dec A
	ld (CPM3),A		; CP/M-3 is invalid (-1)
	ld HL,GetMnt2		; the version 2 routine address
	ld (getmnt),HL
	ld HL,0FFFEh		; retrieve the mounttable
	ld E,(HL)		; address in BIOS
	inc HL
	ld D,(HL)
	ld (MTable),DE		; store it 
	jr parse

setcpm3:
	xor A
	ld (CPM3),A		; CP/M-3 is true (0)
	ld HL,GetMnt3		; the version 3 routine address
	ld (getmnt),HL

parse:	ld HL,COMTAIL		; clean up the command tail
	ld E,(HL)		; first find the end of it
	ld D,0
	add hl,de		; end of the string
	inc HL			; one past the end
	xor A
	ld B,A
	ld A,' '
parse1:	ld (HL),B		; put an 0 at the end of the command
	dec HL			; scan backwards
	cp (HL)			; and shorten the string
	jr z,parse1		; by replacing them with zeros

	; get the first argument (if any)
	ld HL,COMTAIL	; parse the arguments
	call GetChr
	or A			; end of the line? zero arguments
	jp z,showtbl		; then show the mount table and exit

	cp '/'			; if help is required
	jp z,help		; help the user and exit
	cp '?'			; if help is required
	jp z,help		; help the user and exit

	; we now expect a drive letter
	and $5F			; make input uppercase
	sub 'A'			; make binary (A = 0)
	jp c,LDError		; invalid drivename
	cp maxDisk		; disk in range?
	jp nc,LDError		; invalid drivename

	; first argument starts with a valid logical drive letter
	ld (Disk),A		; just right, keep it
	inc  HL			; next character
	ld A,(HL)		; must be ':'
	cp ':'			; not a colon? illegal command
	jp nz,LDError

	; we are happy with the first argument
	call GetChr		; next character
	or A			; end of the line? only one valid argument	
	jr nz,parse2

; use OS-specific call
	ld HL,retmnt
	push HL			; push return address
	ld HL,(getmnt)		; get call address
	jp (HL)			; call (getmnt)
retmnt:	jp showmount		; print only this mount and exit

parse2:	; as of now reject A: as a target drive
	ld A,(Disk)
	dec A
	jp m,LDError

	; Now all we look for is a Volume number
	call getdec		; convert string to binary volume number in DE
	xor A
	cp D			; D should be empty
	jp nz,PDError		; overflow, number larger than 255

parseEnd: ; at this point there is a binary number in e
	ld A,E			; Volume 0 is RAM disk
	or A
	jp z,PDError
	cp maxVolume + 1	; check max disk number 
	jp nc,PDError
	ld (Volume),A		; store the requested physical volume 
	
	; at this point parsing is done, Disk holds A-B-C
	; Volume holds 1-maxVolume (not -1).
	; now follow the validity checks
	; CP/M-3:
	; BIOS disallows mounting the same volume
	; and returns the previous mount for the drive
	; BIOS disallows mounts other than A,B or C and returns -1

mount:	; Disk = A - C, Volume = 1 - Maxvolume. Normal wrap-up
	; check if user wants to remount the current drive
	; nothing harmful will happen, except user confusion
	; just print a warning and continue
	ld HL,currDrv		; see if we remount the current disk
	ld A,(Disk)
	cp (HL)			; compare with requested disk
	jr nz,reset		; skip if not the same
	ld DE,CFMessage		; print warning
	ld  C,09h
	call BDOS

reset:	ld A,(Disk)		; reset the requested logical disk
	ld B,A
	ld E,0			; bitmap for A-1: 
mt1:	rlc E			; start with A:
	djnz mt1		; shift it in the right position for Disk
	ld D,00h		; the rest of the bits are zero
	ld C,25h		; reset selected logical disk
	call BDOS
	; here we do the actual mount.
	ld A,(CPM3)
	inc A
	jr z,mount2

; routine specific for CP/M-3
mount3:	ld DE,BIOSPB		; Bios Parameter Block
	ld  C,50		; BIOS call through BDOS
	call BDOS
	ld HL,Volume
	cp (HL)
	jp  nz,BusyErr
	jp showmount		; show and exit

; routine specific for CP/M-2
mount2:	ld HL,(MTable)		; check if requested physical volume is in use
	ld A,(Volume)		; get requested physical disk
	ld B,maxDisk
mt21:	cp (HL)			; compare it with all mount points
	jp z,BusyErr		; can't mount the same disk twice
	inc HL
	djnz mt21
	call GetMnt2		; mount point in hl
	ld A,(Volume)		; get the requested physical disk
	ld (HL),A		; mount the drive
	jp showmount		; show and exit


GetChr:	inc HL			; next char
	ld A,(HL)
	cp ' '			; skip spaces
	jr z,GetChr		; 
	ret 			; return charactar in a

; GETDEC - [0|,] terminated string is converted from ascii decimal to binary in DE
;-------------------------------------------------------------
getdec:	ld DE,0			; result in DE
	push DE
dloop:	ld a,(HL)		; get character
	cp '9'+1
	jr nc,doops		; not a number.
	sub '0'
	jr c,ddone		; is it less than '0'? then were done
	ld E,A			; store in DE
	ex (SP),HL		; get result from stack
	ld B,H			; store it in bc
	ld C,L
	add HL,HL		; previous result times 10
	add HL,HL
	add HL,BC		; times 5
	add HL,HL		; times 2 (makes 10)
	add HL,DE		; add next digit
	ex (SP),HL		; back on stack
	inc HL			; go for next digit
	jr dloop
ddone:	pop DE			; reg de holds result
	ret
doops:	pop DE			; number out of range
	ld DE,0FF00h		; returns bogus result
	ret ; getdec

; routine specific for CP/M-3
GetMnt3:
	push DE
	ld A,-1			; try to assign invalid volume
	ld (Volume),A
	ld DE,BIOSPB
	ld  C,50
	call BDOS		; BIOS will return actual volume in A
	pop DE
	ret 			; mounted volume in a

; routine specific for CP/M-2
GetMnt2:
	push DE
	ld HL,(MTable)		; find the current mount
	ld A,(Disk)
	ld E,A
	ld D,0
	add HL,DE
	ld A,(HL)
	pop DE
	ret			; mounted volume in A, HL points to it

showmount:
	push AF
	ld A,(Disk)
	add A,41h
	ld (Adisk),a
	ld DE,Adisk		; ascii disk address
	ld C,09h
	call BDOS
	pop AF
	inc A
	jr z,novolume
	dec A
	ld  IX,Avol		; ascii volume address
	ld (IX),' '		; start with spaces
	ld (IX+1),' '		; no leading zeros
HTOA1:	sub 100
	jr c,HTOA2
	set 4,(IX)		; make space a 0
	set 4,(IX+1)
	inc (IX)		; when there is one
	jr HTOA1
HTOA2:	add A,100		; one too much
HTOA3:	sub 10
	jr c,HTOA4
	set 4,(IX+1)
	inc (IX+1)
	jr HTOA3
HTOA4:	add A,3Ah		; number 000 does not occur
	ld (IX+2),A		; no leading space correction
	ld DE,mntmsg
	ld C,09h
	call BDOS
	ret

novolume:
	ld DE,umntmsg
	ld C,09h
	call BDOS
	ret

showtbl:
	xor A
shownext:
	push AF
	ld (Disk),A
	ld HL,retshw
	push HL			; push return address
	ld HL,(getmnt)		; get call address
	jp (HL)			; call (getmnt)
retshw:	call showmount
	pop AF
	inc A
	cp maxDisk
	jr nz,shownext
	ret

help:	ld DE,helptext
	jr exit
MPMErr:	ld DE,MPMErrorMessage
	jr exit
LDError: 		
	ld DE,LDErrorMessage	; error entering logical disk (arg 1)
	jr exit
PDError: 		
	ld DE,PDErrorMessage	; error entering physical disk (arg 2)
	jr exit
BusyErr: 		
	ld DE,IUErrorMessage	; error attemting to mount physical disk twice
exit:	ld  c,$09
	jp BDOS			; print string
	ret

Adisk:	db 'X: $'
mntmsg:	db 'on volume '
Avol:	db '---',CR,LF,'$'
umntmsg:
	db 'not yet mounted',CR,LF,'$'

helptext:
	db ' Version 3.11 (OS-aware)',CR,LF,LF
	db ' format is:  MOUNT [[X:] nnn]',CR,LF,LF 
	db ' MOUNT         shows the mount table',CR,LF
	db ' MOUNT X:      shows the mount for drive X:',CR,LF
	db ' MOUNT X: nnn  mounts nnn on X: (A: excluded)',CR,LF,LF
	db ' notes: - User will be warned on remounting the current drive.',CR,LF
	db '        - Entering leading zeros is not required.',CR,LF,'$'
MPMErrorMessage
	db 'MP/M not supported',CR,LF,'$'
LDErrorMessage
	db 'Invalid Drive',CR,LF,'$'
PDErrorMessage: 
	db 'Invalid Volume',CR,LF,'$'
IUErrorMessage:
	db 'Volume busy.',CR,LF,'$'
CFMessage:
	db 'Remounting your current drive!'
CRLF:	db CR,LF,'$'

currDrv	db 0

BIOSPB:	db 1Eh,0,0,0		; BIOS parameter block, CALL,A,C,B
Disk:	db 0FFh			; value E
Volume:	db 0,0,0		; Value D,L,H

MTable:	ds 2
getmnt:	ds 2
CPM3:	ds 1
	END







