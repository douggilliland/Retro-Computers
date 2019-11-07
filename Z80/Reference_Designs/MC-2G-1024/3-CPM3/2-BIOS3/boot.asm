	title	'Boot loader module for CP/M 3.0'

true equ -1
false equ not true

banked	equ true

	public	?init
	public	?ldccp,?rlccp,?time,timint
	extrn	?pmsg,?conin, ?bank
	extrn	@civec,@covec,@aivec,@aovec,@lovec
	extrn 	@cbnk,@dtbl,?stbnk,mnttab
	extrn	@date,@hour,@min,@sec

;	maclib ports
;	maclib z80

mmu$select	equ 0F8h	; use 2 bits to select which one of
				; 4 16k blocks to change
mmu$frame	equ 0FDh	; use 5 bits to remap to one of 32
				; locations in sram


bdos	equ 5

	if banked
tpa$bank	equ 1
	else
tpa$bank	equ 0
	endif

	dseg	; init done from banked memory

?init:
	di
	db 0D9h					; exx get alernate register set
	mov a,b ! sta mnttab			; retrieve boot disk
	mov a,c					; retrieve active console
	db 0D9h					; exx : save for ?
	rrc ! mov b,a				; primary console made into 
	rrc ! ora b ! mov b,a			; mask (00=acia0 C0=acia1)
	mvi a,080h ! xra b ! mov h,a ! mvi l,0
	shld @civec ! shld @covec		; assign console to primary:
	shld @lovec 				; assign printer to primary:
	mvi a,040h ! xra b ! mov h,a 
	shld @aivec ! shld @aovec		; assign AUX to secondary:
	lxi h,@dtbl+2				; point to second drive
	xra a ! mov m,a ! inx h ! mov m,a 	; unmount B:
	inx h ! mov m,a ! inx h ! mov m,a 	; unmount C:
signon:	lxi h,signon$msg ! call ?pmsg		; print signon message
	jmp setint				; bankswitching from cseg

signon$msg:
	db 0Dh,0Ah,0Dh,0Ah
	db 'CP/M Version 3.0 BIOS (2016/9/13)',0Dh,0Ah
	db 'Original concept "FPGA Multicomputer"',0Dh,0Ah
	db 'by Grant Searle',0Dh,0Ah,0Ah,0Ah,0


	cseg

setint:	mvi b,3			; 
si1:	mov a,b ! dcr a		; 
	call ?bank
	mvi a,0F3h ! sta 38h	; opcode for DI
	mvi a,0C3h ! sta 39h	; opdode for JMP
	lxi h,timint ! shld 3Ah	; time interrupt service routine
	db 10h,si1-$-1		; repeat 30 times
	db 0EDh,056h		; im 1
	ei
	ret


	; boot loading must be done from resident memory
	; This version of the boot loader loads the CCP from a file
	; called CCP.COM on the system drive (A:).
	; CCP is stored in low SRAM bank 2 to make remounts of drive A: possible
	; memory map: |bank0|bank0|bank0|bank0|
	;                0     1     2     3
	;             |bank1|bank1|ccp  |bank2|
	;                4     5     6     7
    
?ldccp:	;xra a		; this code is needed when CCP load is 
	;sta ccp$fcb+15	; performed this way more than once
	;lxi h,0	; it is skipped here, because it will take the 
	;shld fcb$nr	; resident portion of BIOS over a 1k boundary.
	lxi d,ccp$fcb ! mvi c,15 ! call bdos	; open file ccp.com on drive a:
	inr a ! jz ccp$error
	lxi d,100h ! mvi c,26 ! call bdos	; set load address to 100h
	lxi d,80h ! mvi c,44 ! call bdos
	lxi d,ccp$fcb ! mvi c,20 ! call bdos	; perform load
	inr a ! jz ccp$error
	mvi a,1 ! out mmu$select	; select memory block 4000h-7FFFh
	mvi a,6 ! out mmu$frame		; map SRAM frame 6 (free under page 2)
	lxi h,100h ! lxi d,4100h ! lxi b,3200
	db 0EDh,0B0h			; (ldir) copy ccp to block 6
	lda @cbnk ! call ?bank		; restore system memory
	ret
ccp$error:
	lxi h,ccp$msg
perr:	call ?pmsg ! call ?conin 
	jmp ?rlccp			; see if CCP is still in memory

;	on warm boot the ccp is loaded from high RAM. This makes a 
;	remount of drive A: possible. No fear of a missing CCP 
;	requiring a system reset

?rlccp:
	mvi a,1 ! out mmu$select 	; select block 4000-7FFF
	mvi a,6 ! out mmu$frame		; map RAM block 6
	lxi d,100h ! lxi h,4100h ! lxi b,3200
	db 0EDh,0B0h	; use Z80 block move instruction	
	lda @cbnk ! call ?bank		; restore system memory
	ret


?time:
	ret

; 20 ms interrupt service routine
timint:
	shld svdhl
	pop h ! shld svdret
	push psw
	lxi h,0 ! dad sp ! shld svdsp	; save users stack pointer
	lxi sp,lstintstk		; use local stack for interrupts
	push d ! push b

	lxi H,sec50			; 20 ms counter
	mvi C,50h ! call addone		; only returns when counter is full
	lxi H,@sec			; point into SCB
	mvi C,60h ! call addone		; count to 60 now
	dcx H ! call addone		; point to minutes
	dcx H				; point to hours
	mvi C,24h ! call addone		; count to 24

	lhld @date ! inx H ! shld @date	; welcome to a brand new day
	db 18h, intend-$-1

addone:	mov A,m ! adi 1			; add one (inc does not carry)
	daa ! mov m,A			; make BCD
	sub C 				; is counter full?
	db 20h,addend-$-1		; if not exit interrupt
	mov m,A ! ret			; store and do next counter
addend:	pop H				; get rid of return address

intend:	pop b ! pop d
	lhld svdsp ! sphl		; restore stack pointer
	pop psw 
	lhld svdret ! push h		; return address
	lhld svdhl ! ei
	db 0EDh,04Dh			; reti

sec50:	db 25h		; 20 ms counter in BCD

intstk:			; local intrpt stk
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
	dw	0c7c7h,0c7c7h,0c7c7h,0c7c7h,0c7c7h
lstintstk:
svdhl:	dw 0
svdsp:	dw 0
svdret:	dw 0

bios$msg:
	db 0Dh,0Ah,0Dh,0Ah,'CCP Ver. 3.0',0Dh,0Ah,00
ccp$msg:
	db 0dh,0Ah,'BIOS Err ',00
ccp$fcb:
	db 1,'CCP     COM',0,0,0,0
	ds 16
fcb$nr:	db 0,0,0

	end
