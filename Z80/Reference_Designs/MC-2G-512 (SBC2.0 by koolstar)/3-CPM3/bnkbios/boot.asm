	title	'Boot loader module for CP/M 3.0'

true equ -1
false equ not true

banked	equ true

	public	?init
	public	?ldccp,?rlccp,?time
	extrn	?pmsg,?conin
	extrn	@civec,@covec,@aivec,@aovec,@lovec
	extrn 	@cbnk,@dtbl,?stbnk,mnttab
;	maclib ports
;	maclib z80


bdos	equ 5

	if banked
tpa$bank	equ 1
	else
tpa$bank	equ 0
	endif

	dseg	; init done from banked memory

?init:
	db 0D9h					; exx get alernate register set
	mov a,b ! sta mnttab			; retrieve boot disk
	mov a,c					; retrieve active console
	db 0D9h					; exx : save for ?
	rrc ! mov b,a				; primary console made into 
	rrc ! ora b ! mov b,a			; mask (00=SIOA C0=SIOB)
	mvi a,040h ! xra b ! mov h,a ! mvi l,0
	shld @civec ! shld @covec		; assign console to primary:
	shld @lovec 				; assign printer to primary:
	mvi a,080h ! xra b ! mov h,a 
	shld @aivec ! shld @aovec		; assign AUX to secondary:
	lxi h,@dtbl+2				; point to second drive
	xra a ! mov m,a ! inx h ! mov m,a 	; unmount B:
	inx h ! mov m,a ! inx h ! mov m,a 	; unmount C:
	lxi h,signon$msg ! call ?pmsg		; print signon message

	ret	

signon$msg:
	db 0Dh,0Ah,0Dh,0Ah
	db 'CP/M Version 3.0 BIOS',0Dh,0Ah
	db 'Original concept "CP/M on Breadboard"',0Dh,0Ah
	db 'by Grant Searle'0Dh,0Ah,0Dh,0Ah,0

	cseg	; boot loading must be done from resident memory
	; This version of the boot loader loads the CCP from a file
	; called CCP.COM on the system drive (A:).
    
?ldccp:
?rlccp:	xra a ! sta ccp$fcb+15			; start at zero
	lxi h,0 !shld fcb$nr
	lxi d,ccp$fcb ! mvi c,15 ! call bdos	; open file ccp.com on drive a:
	inr a ! jz ccp$error
	lxi d,0100h ! mvi c,26 ! call bdos	; set DMA
	lxi d,128 ! mvi c,44 ! call bdos	; allow up to 16k bytes
	lxi d,ccp$fcb ! mvi c,20 ! call bdos	; perfom load
	inr a ! jz ccp$error
	ret
ccp$error:
	lxi h,ccp$msg
perr:	call ?pmsg ! call ?conin 
	jmp ?rlccp			; see if CCP is still in memory


?time:
	ret

bios$msg:
	db 0Dh,0Ah,0Dh,0Ah,'CCP Ver. 3.0',0Dh,0Ah,00
ccp$msg:
	db 0dh,0Ah,'BIOS Err ',00
ccp$fcb:
	db 1,'CCP     COM',0,0,0,0
	ds 16
fcb$nr:	db 0,0,0

	end
