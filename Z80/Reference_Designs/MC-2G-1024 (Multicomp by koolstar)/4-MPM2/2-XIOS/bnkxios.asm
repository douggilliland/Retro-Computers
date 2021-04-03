
	jmp commonbase
wbote:
	jmp warmstart ! jmp const ! jmp conin
	jmp conout ! jmp list ! jmp rtnempty
	jmp rtnempty ! jmp home ! jmp seldsk
	jmp settrk ! jmp setsec ! jmp setdma
	jmp read ! jmp write ! jmp pollpt
	jmp sectran

	jmp selmemory ! jmp polldevice ! jmp startclock
	jmp stopclock ! jmp exitregion ! jmp maxconsole
	jmp systeminit
	nop ! nop ! nop		; three nops for no idle process

commonbase:
	jmp coldstart
swtuser:
	jmp $-$
swtsys:	jmp $-$
pdisp:	jmp $-$
xdos:	jmp $-$
sysdat: dw $-$

coldstart:
warmstart:
	mvi c,0
	jmp xdos

nmbcns	equ	4	; number of consoles
ndisks	equ	3	; number of disks in system

poll	equ	131	; XDOS poll function
makeque	equ	134	; XDOS make queue function
readque	equ	137	; XDOS read queue function
writeque equ	139	; XDOS write queue function
xdelay	equ	141	; XDOS delay function
create	equ	144	; XDOS create process function

pllpt	equ	0	; poll printer
plco0	equ	1	; poll console out #0
plco1	equ	2	; poll console out #1
plco2	equ	3	; poll console out #2
plco3	equ	4	; poll console out #3
plci0	equ	5	; poll console in #0
plci1	equ	6	; poll console in #1
plci2	equ	7	; poll console in #2
plci3	equ	8	; poll console in #3

const:	call ptbljmp
	dw pt0st,pt1st,pt2st,pt3st

conin:	call ptbljmp
	dw pt0in,pt1in,pt2in,pt3in

conout:	call ptbljmp
	dw pt0out,pt1out,pt2out,pt3out

ptbljmp:
	mov a,d
	cpi nmbcns
	db 038h,tbljmp-$-1	;jr c,tbljmp
	pop psw

rtnempty:
	xra a
	ret
tbljmp:
	add a
	pop h
	mov e,a ! mvi d,0 ! dad d	; make index
	mov e,m ! inx h ! mov d,m	; get jump address
	xchg ! pchl			; go there

sts0	equ	80h		; Grant's design allows for 4 consoles
data0	equ	81h
sts1	equ	82h
data1	equ	83h
sts2	equ	84h
data2	equ	85h
sts3	equ	86h
data3	equ	87h

; console 0
polci0:
pt0st:	in sts0 ! ani 1 ! rz	; bit 0 = character ready
	mvi a,-1 ! ret

pt0in:	call polci0 ! ora a
	db 020h,pt0in1-$-1	;jr nz,pt0in1
	mvi c,poll ! mvi e,plci0 ! call xdos
pt0in1:	in data0
	ret

pt0out:	call polco0 ! ora a
	db 020h,pt0out1-$-1	;jr nz,pt0out1
	push b
	mvi c,poll ! mvi e,plco0 ! call xdos
	pop b
pt0out1:
	mov a,c ! out data0 ! ret

polco0:	in sts0 ! ani 2 ! rz	; bit 1 = buffer empty
	mvi a,-1 ! ret

; console 1
polci1:
pt1st:	in sts1 ! ani 1 ! rz	; bit 1 = character ready
	mvi a,-1 ! ret

pt1in:	call polci1 ! ora a
	db 020h,pt1in1-$-1	;jr nz,pt1in1
	mvi c,poll ! mvi e,plci1 ! call xdos
pt1in1:	in data1
	ret

pt1out:	call polco1 ! ora a
	db 020h,pt1out1-$-1	;jr nz,pt1out1
	push b
	mvi c,poll ! mvi e,plco1 ! call xdos
	pop b
pt1out1:
	mov a,c ! out data1 ! ret

polco1:	in sts1 ! ani 2 ! rz	; bit 1 = buffer empty
	mvi a,-1 ! ret

; console 2
polci2:
pt2st:	in sts2 ! ani 1 ! rz	; bit 2 = character ready
	mvi a,-1 ! ret

pt2in:	call polci2 ! ora a
	db 020h,pt2in1-$-1	;jr nz,pt2in1
	mvi c,poll ! mvi e,plci2 ! call xdos
pt2in1:	in data2
	ret

pt2out:	call polco2 ! ora a
	db 020h,pt2out1-$-1	;jr nz,pt2out1
	push b
	mvi c,poll ! mvi e,plco2 ! call xdos
	pop b
pt2out1:
	mov a,c ! out data2 ! ret

polco2:	in sts2 ! ani 2 ! rz	; bit 1 = buffer empty
	mvi a,-1 ! ret

; console 3
polci3:
pt3st:	in sts3 ! ani 1 ! rz	; bit 3 = character ready
	mvi a,-1 ! ret

pt3in:	call polci3 ! ora a
	db 020h,pt3in1-$-1	;jr nz,pt3in1
	mvi c,poll ! mvi e,plci3 ! call xdos
pt3in1:	in data3
	ret

pt3out:	call polco3 ! ora a
	db 020h,pt3out1-$-1	;jr nz,pt3out1
	push b
	mvi c,poll ! mvi e,plco3 ! call xdos
	pop b
pt3out1:
	mov a,c ! out data3 ! ret

polco3:	in sts3 ! ani 2 ! rz	; bit 1 = buffer empty
	mvi a,-1 ! ret

list:
	mov a,c ! ret
pollpt:
	mvi a,-1 ! ret

polldevice:
	mov a,c
	cpi nmbdev
	db 038h,devok-$-1	;jr c,devok
	mvi a,nmbdev
devok:
	call tbljmp

devtbl: dw pollpt
	dw polco0,polco1,polco2,polco3
	dw polci0,polci1,polci2,polci3
nmbdev	equ	($-devtbl)/2	; number of devices to poll
	dw rtnempty

maxconsole:
	mvi a,nmbcns ! ret

mmu$select	equ 0F8h
mmu$frame	equ 0FDh

selmemory:
			; Reg BC = adr of mem descriptor
			; BC ->  base   1 byte,
			;        size   1 byte,
			;        attrib 1 byte,
			;        bank   1 byte.
	lxi h,3 ! dad b ! mov a,m

bank:		; 48k segments
	push b ! push h
	ana a
	db 028h,bank1-$-1		; jr z,bank1 - bank 0 stays 0
	mov c,a ! rlc ! add c		; times 3
	inr a 				; add common
bank1:	mvi b,3 ! mvi h,0 ! mov l,a	; get start values
nextblock:
	mov a,h ! out mmu$select	; replace this block
	mov a,l ! out mmu$frame		; with this one
	inr h ! inr l			; update pointers
	db 010h,nextblock-$-1		; djnz, ...repeat 3 times
	pop h ! pop b
	ret

startclock:
	mvi a,-1 ! sta tickn ! ret

stopclock:
	xra a ! sta tickn ! ret

exitregion:
	lda preemp ! ora a ! rnz
	ei ! ret

systeminit:		; init runs in the area designated for ALV1 and -2
	jmp initonce	; this code will be replaced with RET

flagwait equ	132
flagset	equ	133
dsptch	equ	142

inthnd:
	shld svdhl
	pop h ! shld svdret
	push psw
	lxi h,0 ! dad sp ! shld svdsp	; save users stack pointer
	lxi sp,lstintstk		; use local stack for interrupts
	push d ! push b

	mvi a,-1 ! sta preemp		; set preempted flag

clkint:
	lda tickn ! ora a		; test tickn, indicates delayed processes
	db 028h,notickn-$-1		; jr z,notickn
	mvi c,flagset ! mvi e,1 ! call xdos	; set flag #1 each tick
notickn:
	lxi h,clkcnt ! dcr m		; decr tick counter
	db 020h,not1sec-$-1		; jr nz,not1sec
	push h
	lhld sysdat
	mvi l,122			; ticks per second in sysdat page
	mov a,m
	pop h				; get clkcnt back
	mov m,a				; set value
	mvi c,flagset ! mvi e,2 ! call xdos	; set flag #2 each second
not1sec:
intdone:
	xra a ! sta preemp		; clear preempted flag
	pop b ! pop d
	lhld svdsp ! sphl		; restore stack pointer
	pop psw 
	lhld svdret ! push h
	lxi h,pdisp ! push h		; mp/m dispatch on stack
	lhld svdhl
	db 0EDh,04Dh			; reti - dispatch

clkcnt:	db	50	; init clock count on a full second
intstk:			; local intrpt stk
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
lstintstk:
svdhl:	dw 0
svdsp:	dw 0
svdret:	dw 0
tickn:	db 0
preemp:	db 0


; =============================================================================
; Disk processing entry points
; =============================================================================
blksiz	equ	4096
hstsiz	equ	512
hstspt	equ	32
hstblk	equ	hstsiz/128
cpmspt	equ	hstblk * hstspt
secmsk	equ	hstblk-1
secshf	equ	2

wrall	equ	0
wrdir	equ	1
wrual	equ	2

seldsk:	mov a,c				; selected disknumber
	cpi ndisks ! jnc nodsk		; max drive?
	mvi b,0 ! lxi h,mnttab ! dad b	; make index
	mov b,m ! inr b ! jnz dskok	; check for disk mounted

nodsk:	lxi h,0 ! ret

dskok:	sta sekdsk			; seek disk number
	rlc ! rlc ! rlc ! rlc		; multiply by 16
	lxi h,dpbase			; base of param block
	mvi b,0 ! mov c,a ! dad b	; hl=.dpb(curdsk)
	ret

;------------------------------------------------------------------------------
home:	; home the selected disk
	lda hstwrt		; check for pending write
	ora a ! jnz homed
	sta hstact		; clear host active flag
homed:	lxi b,0000h

;------------------------------------------------------------------------------
settrk:	; set track given by registers bc
	mov h,b ! mov l,c
	shld sektrk		; track to seek
	ret

;------------------------------------------------------------------------------
setsec:	; set sector given by registers bc
	mov h,b ! mov l,c
	shld seksec		; sector to seek
	ret

;------------------------------------------------------------------------------
setdma:	; set dma address given by registers bc
	mov h,b ! mov l,c
	shld dmaadr		; track to seek
	inx h ! mov a,l		; test for flush buffers
	ora h ! rnz		; hl=FFFF is flush buffer
	lxi h,hstwrt
	mov a,m ! mvi m,0
	ora a ! rz
	call writehst		; write pending
	ora a ! rz
	pop h
	ret

;------------------------------------------------------------------------------
sectran:
	push b ! pop h ! ret

;------------------------------------------------------------------------------
read:	;read the selected CP/M sector
	xra a ! sta unacnt		; unacnt = 0
	inr a ! sta readop		; read operation
	sta rsflag			; must read data
	mvi a,wrual ! sta wrtype	; treat as unalloc
	jmp rwoper			; to perform the read

;------------------------------------------------------------------------------
write:
;	write the selected CP/M sector
	xra a		; 0 to accumulator
	sta readop	; not a read operation
	mov a,c		; write type in c
	sta wrtype
	ani wrual	; write unallocated?
	jz chkuna	; check for unalloc
; 
;	write to unallocated, set parameters
	mvi a,blksiz/128 ! sta unacnt	; next unalloc recs
	lda sekdsk ! sta unadsk		; unadsk = sekdsk
	lhld sektrk ! shld unatrk	; unatrk = sectrk
	lda seksec ! sta unasec		; unasec = seksec

chkuna:
;	check for write to unallocated sector
	lda unacnt		; any unalloc remain?
	ora a ; jz alloc	; skip if not
	db 028h,alloc-$-1
	
;	more unallocated records remain
	dcr a			; unacnt = unacnt-1
	sta unacnt
	lda sekdsk		; same disk?
	lxi h,unadsk
	cmp m			; sekdsk = unadsk?
	;jnz alloc		; skip if not
	db 020h,alloc-$-1

;	disks are the same
	lxi h,unatrk
	call sektrkcmp		; sektrk = unatrk?
	;jnz alloc		; skip if not
	db 020h,alloc-$-1

;	tracks are the same
	lda seksec		; same sector?
	lxi h,unasec
	cmp m			; seksec = unasec?
	;jnz alloc		; skip if not
	db 020h,alloc-$-1

;	match, move to next sector for future ref
	inr m			; unasec = unasec+1
	mov a,m			; end of track?
	cpi cpmspt		; count CP/M sectors
	;jc noovf		; skip if no overflow
	db 038h,noovf-$-1

;	overflow to next track
	mvi m,0			; unasec = 0
	lhld unatrk
	inx h
	shld unatrk		; unatrk = unatrk+1

noovf:
;	match found, mark as unnecessary read
	xra a			; 0 to accumulator
	sta rsflag		; rsflag = 0
	;jmp rwoper		; to perform the write
	db 018h,rwoper-$-1

alloc:
;	not an unallocated record, requires pre-read
	xra a			; 0 to accum
	sta unacnt		; unacnt = 0
	inr a			; 1 to accum
	sta rsflag		; rsflag = 1

;------------------------------------------------------------------------------
rwoper:
;	enter here to perform the read/write
	xra a			; zero to accum
	sta erflag		; no errors (yet)
	lda seksec		; compute host sector
	rept secshf
	ora a			; carry = 0
	rar			; shift righ
	endm
	sta sekhst		; host sector to seek

;	active host sector?
	lxi h,hstact		; host active flag
	mov a,m
	mvi m,1			; always becomes 1
	ora a			; was it already?
	;jz filhst		; fill host if not
	db 028h,filhst-$-1

;	host buffer active, same as seek buffer?
	lda sekdsk
	lxi h,hstdsk		; same disk?
	cmp m			; sekdsk = hstdsk?
	;jnz nomatch
	db 020h,nomatch-$-1

;	same disk, same track?
	lxi h,hsttrk		; high byte first
	call sektrkcmp		; sektrk = hsttrk?
	;jnz nomatch
	db 020h,nomatch-$-1

;	same disk, same track, same buffer?
	lda sekhst
	lxi h,hstsec		; sekhst = hstsec?
	cmp m
	;jz match		; skip if match
	db 028h,match-$-1

nomatch:
;	proper disk, but not correct sector
	lda hstwrt		; host written?
	ora a
	cnz writehst		; clear host buff

filhst:
;	may have to fill the host buffer
	lda sekdsk
	sta hstdsk
	lhld sektrk
	shld hsttrk
	lda sekhst
	sta hstsec
	lda rsflag		; need to read?
	ora a
	cnz readhst		; yes, if 1
	xra a			; 0 to accum
	sta hstwrt		; no pending write

match:
;	copy data to or from buffer
	lda seksec		; mask buffer number
	ani secmsk		; least signif bits
	mov l,a			; ready to shift
	mvi h,0			; double count
	rept 7			; shift left 7
	dad h
	endm

;	hl has relative host buffer Address
	lxi d,hstbuf
	dad d			; hl = host Address
	xchg			; now in DE
	lhld dmaadr		; de = buffer Address
	xchg
;	lxi b,128		; bc = bytecount
	lda readop		; which way?
	ora a
	;jnz rwmove		; skip if read
	db 020h,rwmove-$-1

;	write operation, mark and switch direction
	mvi a,1
	sta hstwrt		; hstwrt = 1
	xchg			; source/dest swap

rwmove:
	push d ! push h
	call swtuser		; switch in user bank
	pop h ! pop d
	lxi b,128
	db 0EDh,0B0h	; ldir
	call swtsys		; switch system bank back in

;	data has been moved to/from host buffer
	lda wrtype		; write type
	ani wrdir		; to directory?
	;jz rwend		; no, just end up here
	db 028h,rwend-$-1

;	clear host buffer for directory write
	lda erflag		; check prior to DIR activity
	ora a			; errors?
	;jnz rwend		; skip if so
	db 020h,rwend-$-1
	xra a			; zero to accumulator
	sta hstwrt		; buffer written
	call writehst

rwend:	lda erflag
	ora a			; if errors, reset so no match
	rz			; none, just return
	lxi h,hstdsk
	mvi m,-1		; cant possibly match
	ret

;------------------------------------------------------------------------------
; Utility subroutine for 16-bit compare
sektrkcmp:
	; HL = .unatrk or .hsttrk, compare with sektrk
	xchg
	lxi h,sektrk
	ldax d			; low byte compare
	cmp m			; same?
	rnz			; return if not
;	low bytes equal, test high 1s
	inx d
	inx h
	ldax d
	cmp m			; sets flags
	ret

; =============================================================================
; Write physical sector to host
; =============================================================================
sd$data		equ 088h
sd$control	equ 089h
sd$status	equ 089h
sd$lba0		equ 08ah
sd$lba1		equ 08bh
sd$lba2		equ 08ch

sd$read		equ 0
sd$write	equ 1

writehst:
	push b ! push h

	call setlba

	lxi b,2			; count in bc (b=256, c=2)
	lxi h,hstbuf		; destination Address

	mvi a,sd$write ! out sd$control		; select SD blockwrite

whst1:	in sd$status ! cpi 0A0H	; write buffer empty
	db 020h,whst1-$-1	;jr nz,whst
	mov a,m ! out sd$data
	inx h
	db 010h,whst1-$-1		; djnz whst1
	dcr c 
	db 020h,whst1-$-1		; twice for 512 bytes

	pop h ! pop b

	xra a ! sta erflag ! ret

;
; =============================================================================
; Read physical sector from host
; =============================================================================

readhst:
	push b ! push h

	call setlba

	lxi b,2			; count in bc (b=256, c=2)
	lxi h,hstbuf		; destination Address

	mvi a,sd$read ! out sd$control		; select SD blockread

rhst1:	in sd$status ! cpi 0E0H		; read data ready
	db 020h,rhst1-$-1		; jr nz,rhst1
	in sd$data ! mov m,a
	inx h
	db 010h,rhst1-$-1		; djnz rhst1
	dcr c 
	db 020h,rhst1-$-1		; twice for 512 bytes

	pop h ! pop b

	xra a ! sta erflag ! ret


; =============================================================================
; Convert track/head/sector into LBA for physical access to the disk
; routine destroys AF, HL and BC
; =============================================================================
setlba:		; don't save registers. this routine is called from 
		; readhst and writehst which already save them

	lda hstdsk ! mov c,a		; drive in c
	mvi b,0 ! lxi h,mnttab ! dad b	; make index
	mov a,m ! rrc ! rrc ! mov c,a	; get volume, line up in lba 
	ani 03Fh ! out sd$lba2		; top 6 bits are lba2
	mov a,c ! ani 0C0h ! mov c,a	; low 2 bits, stored high
	lhld hsttrk  ! mov a,h		; high track byte
	rrc ! rrc ! rrc			; line up in lba
	ora c ! mov c,a			; add remaining drive bits
	mov a,l ! rrc ! rrc ! rrc	; line up low track byte
	mov l,a ! ani 1Fh ! ora c	; save, mask, add leftover track bits
	out sd$lba1			; is lba1
	mov a,l ! ani 0E0h ! mov c,a	; mask remaining track bits 
lba1:	in sd$status ! cpi 080h ! jnz lba1	; wait for SD to be ready
	lda hstsec ! ora c		; get sector, add leftover bits
	out sd$lba0 ! ret		; is lba 0

; Disk mount table 
mnttab:	db 0		; volume for disk A: to be filled in on cold boot
	db 0		; volume for disk B:
	db 0		; volume for disk C:

sekdsk:	ds 1		; seek disk number
sektrk:	ds 2		; seek track number
seksec:	ds 2		; seek sector number
; 
hstdsk:	ds 1		; host disk number
hsttrk:	ds 2		; host track number
hstsec:	ds 1		; host sector number
; 
sekhst:	ds 1		; seek shr secshf
hstact:	ds 1		; host active flag
hstwrt:	ds 1		; host written flag
; 
unacnt:	ds 1		; unalloc rec cnt
unadsk:	ds 1		; last unalloc disk
unatrk:	ds 2		; last unalloc track
unasec:	ds 1		; last unalloc sector
; 
erflag:	ds 1		; error reporting
rsflag:	ds 1		; read sector flag
readop:	ds 1		; 1 if read operation
wrtype:	ds 1		; write operation type
dmaadr:	ds 2		; last dma Address
dpbase:
dbh0:	dw 0,0,0,0,dirbuf,dpb,0,alv0
dph1:	dw 0,0,0,0,dirbuf,dpb,0,alv1
dph2:	dw 0,0,0,0,dirbuf,dpb,0,alv2

dpb:	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 240		; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 0000h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks

dirbuf:	ds 128
alv0:	ds 256
alv1:	;ds 256

;--------------------------------
; this section runs only once, 
; it will be overwritten by alv1 and 2
;--------------------------------

ce$timint	equ 078h
rtshigh		equ 0D5h
rtslow		equ 095h
b115200		equ 7

initonce:
	push h			; save jump table vector
	mvi a,rtslow		; init all terminals
	out 80h ! out 82h ! out 84h ! out 86h
	mvi a,b115200		; select baudrate
	out 07Bh ! out 07Ch ! out 07Dh ! out 07Eh

	db 0d9h			; exx - get alternate register set
	mov a,b ! sta mnttab			; save active volume
	mov a,c ! add a ! ori 80h ! sta sts	; save active console
	db 0d9h			; exx - save for ?

	mvi a,0C9h ! sta systeminit		; repair broken call

setdskb:			; mount drives B: and C:
	call printnxt
	db 0dh,0ah,'Enter volume number for drive B: ',0
	call getvol
	xra a ! cmp d ! jnz setdskb		; check for larger than 255
	lxi b,1 ! call ckmnt ! jz setdskb	; mount drive1 or try again
setdskc:
	call printnxt
	db 0dh,0ah,'Enter volume number for drive C: ',0
	call getvol
	xra a ! cmp d ! jnz setdskc		; check for larget than 255
	lxi b,2 ! call ckmnt ! jz setdskc	; mount drive2 or try again

	; set up memory segments
	lhld sysdat ! mvi l,15 ! mov b,m	; get number of memory segments
	dcr b			; b = highest bank +1
	pop h			; jump table vector in hl

nxtbank:			; set up page 0 of all memory segments
	mov a,b ! dcr a		; adjust to base 0
	call bank		; switch to segment in a
	mvi a,0F3h ! sta 38h	; disable interrupts
	mvi a,0c3h ! sta 0 ! sta 39h	; 'JMP' in 0000 and 0038
	shld 1 ! push h		; jump table vector
	lxi h,inthnd ! shld 3Ah ! pop h	; interrupt vctor
	db 010h,nxtbank-$-1	; djnz nxtbank
	db 0EDh,056h		; back in segment 0, im 1
	mvi a,1 ! out ce$timint	; turn on timer
	call printnxt		; tell user init is finished
	db 0dh,0ah,'Init complete',0dh,0ah,0
	ei ! ret

ckmnt:	push b			; mount the volume, or return 0 on error
	mov a,e ! lxi h,mnttab
	push h
	lxi b,ndisks
	db 0edh,0b1h	; cpir
	pop h ! pop b
	rz
	dad b ! mov m,a ! ret	; a holds volume number
	; volume 0 is mounted but signals as error.


getvol:	lxi h,vbuff		; get user input
	mvi b,0 ! mov m,b
vloop:	call getchr
	cpi 0dh ! jz dtoh
	cpi 8 ! jz erase
	cpi '0' ! jc vloop
	cpi '9'+1 ! jnc vloop
	mov m,a ! call putchr
	inr b ! inx h
	jmp vloop
	
				; BS key pressed
erase:	dcr b ! jp era1		; anything to erase?
	mvi b,0 ! jmp vloop	; no, reset counter, get back
era1:	call printnxt		; erase character
	db 08,' ',08,0
	mvi m,0 ! dcx h		; make end of string
	jmp vloop 		; go back

dtoh:	mvi m,0			; decimal to hex conversion
	lxi h,vbuff ! lxi d,0	; read number from vbuff, store result in de
	push d
dloop:	mov a,m			; get character
	sui '0' ! jc ddone	; is it less than '0'? then were done
	mov e,a			; store in de
	xthl			; get result from stack
	mov b,h ! mov c,l	; store it in bc
	dad h ! dad h ! dad b	; times 5
	dad h			; times 2 (makes 10)
	dad d			; add last digit
	xthl			; back on stack
	inx h			; go for next digit
	jmp dloop
ddone:	pop d			; reg de holds result
	ret

getchr:	lda sts ! mov c,a	; get character from console
getc1:	db 0EDh,078h		; in a,(c)
	ani 1 ! jz getc1
	inr c			; now datax
	db 0EDh,078h		; in a,(c)
	ret

putchr:	push psw		; output character to console
	lda sts ! mov c,a	; select control port
putc1:	db 0EDh,078h	; in a,(c)
	ani 2 ! jz putc1	; wait for buffer empty
	inr c			; select data port
	pop psw			; get character back
	db 0EDh,079h	; out (c),a
	ret

printnxt:		; print$() implementation
	pop h ! mov a,m
	inx h ! push h
	cpi 0 ! rz
	call putchr
	jmp printnxt

sts	ds 1		; stores active status port (80h, 82h ...)

vbuff: ds 10		; holds input string (0 terminated)
;--------------------------------

alv2	equ alv1+256

	ds alv1+512-$	; reserve the remainder to make place for alv1 and alv2

hstbuf:	ds hstsiz	; host buffer

hstBufEnd:	equ	$

	end
