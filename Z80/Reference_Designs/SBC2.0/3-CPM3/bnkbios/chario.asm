	title 'Character I/O handler for z80 chip based system'

; Character I/O for the Modular CP/M 3 BIOS


	public	?cinit,?ci,?co,?cist,?cost
	public	@ctbl

CBUFSIZE	equ 20h			; 12 bytes hysteresis, 
CBUFHIGH	equ CBUFSIZE / 2	; 16 bytes overrun
CBUFLOW		equ CBUFSIZE / 4	; minimal underrun

RTS$HIGH	equ 0E8h	; bit '1' is RTS 
RTS$LOW		equ 0EAh

SIOA$D		equ 00h
SIOB$D		equ 01h
SIOA$C		equ 02h
SIOB$C		equ 03h

max$devices	equ 2

	cseg

cbufferA:			; SIO-A. Keep these adresses together
cUseA:		db 0		; number of characters in buffer 
coPtrA:		db 0		; location of lsat character read
ciPtrA:		db 0		; location of last character written
cSIOA:		db SIOA$D	; data port address
cBufA:		ds CBUFSIZE

cbufferB			; SIO-B. Keep these adresses together
cUseB:		db 0		; number of characters in buffer 
coPrtB:		db 0		; location of lsat character read
ciPtrB:		db 0		; location of last character written
cSIOB:		db SIOB$D	; data port address
cBufB:		ds CBUFSIZE

SIOCMD:	db 00h,18h	; reset channel
	db 04h,0C4h	; set clock/64, 1 stopbit
	db 01h,18h	; set interrupt on all Rx characters
	db 03h,0E1h	; set Rx enable, 8 bits data
	db 05h,RTS$LOW	; set Tx enable, 8 bits data, DTR & RTS
	db 02h		; set interrupt vector (channel B only)

?cinit:	mov a,c ! cpi max$devices ! rnc
	lxi h,SIOCMD		; initialize SIO commands
	dcr c ! jz cinitB
cinitA:	mvi b,10		; SIO A uses the first 5 commands
	mvi c,SIOA$C
	db 0EDh,0B3h		; otir
	db 0EDh,05Eh		; im 2
	ei ! ret		; last interface called, enable interrupts

cinitB:	mvi b,11		; SIO B uses all 6 commands
	mvi c,SIOB$C		; 
	db 0EDh,0B3h		; otir
	lxi h,itab ! db 0CBh,045h	; check if even
	jz setint ! inx h	; if not, plus 1
setint:	mov a,l ! db 0EDh,079h	;  out (c),a .. set interrupt vector
	mov a,h ! db 0EDh,047h	; ld I,A .. set interrupt page
	lxi d,serialInt		; create interrupt table
	mov m,e ! inx h ! mov m,d
 ret

	; character input
?ci:	push h ! push b ! push d
	dcr b ! jz rxB		; SIO B
rxA:	lxi h,cbufferA ! jmp rxAB
rxB:	lxi h,cbufferB
rxAB:	push h ! xra a ! mov d,a
rxwait:	cmp m ! jz rxwait
	di
	inx h ! inr m ! db 0CBh,0AEh	; res 5,(hl)
	mov e,m ! inx h ! inx h ! mov c,m
	inx h ! dad d ! mov a,m
	pop h ! push psw ! dcr m
	mvi a,CBUFLOW ! cmp m ! jc RTShi
	mvi b,RTS$LOW ! call setRTS
RTShi:	pop psw ! pop d ! pop b ! pop h
	ei ! ret

setRTS:	inr c ! inr c ! mvi a,05h
	db 0EDh,079h	; out (c),a
	mov a,b ! db 0EDh,079h	; out (c),a
	ret

	; character input status
?cist:	dcr b ! jz cistB		; SIO B
cistA:	lda cUseA ! jmp cistAB
cistB:	lda cUseB
cistAB:	ora a ! rz
	mvi a,-1 ! ret

	; character output
?co:	push b ! dcr b ! jz coB
coA:	call costA ! jz coA
	pop b ! mov a,c ! out SIOA$D ! ret
coB:	call costB ! jz coB
	pop b ! mov a,c ! out SIOB$D ! ret

	; character output status
	; Status byte D2=TX Buff Empty, D0=RX char ready
?cost:	dcr b ! jz costB
costA:	mvi c,SIOA$C ! jmp costAB
costB:	mvi c,SIOB$C
costAB:	xra a ! db 0EDh,079h	; out (c),a
	db 0EDh,078h	; in a,(c)
	ani 04h ! rz
	mvi a,-1 ! ret

@ctbl:	db 'TTY   ',0Fh,0Eh
	db 'CRT   ',0Fh,0Eh
	db 00
	

serialInt:
	di
	push h ! push b ! push d ! push psw
	xra a ! mov d,a ! out SIOA$C
	in SIOA$C ! rrc ! jnc cintB
	lxi h,cbufferA ! jmp cintAB
cintb:	lxi h,cbufferB
cintAB:	push h ! inx h ! inx h ! inr m
	db 0CBh,0AEh		; res 5,(hl)
	mov e,m ! inx h ! mov c,m ! inx h
	dad d ! db 0EDh,078h	; in a,(c)
	mov m,a ! pop h ! inr m
	db 0CBh,066h		; bit 4,(hl)
	jz RTSlo ! mvi b,RTS$HIGH ! call setRTS
RTSlo:	pop psw ! pop d ! pop b ! pop h
	ei ! db 0EDh,04Dh	; reti


itab:	ds 3	; this is where the interrupt table will be. Either this 
		; location or the next, wichever is even

	end
