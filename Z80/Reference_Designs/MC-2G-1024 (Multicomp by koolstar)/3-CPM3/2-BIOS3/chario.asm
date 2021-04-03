	title 'Character I/O handler for z80 chip based system'

; Character I/O for the Modular CP/M 3 BIOS


	public	?cinit,?ci,?co,?cist,?cost
	public	@ctbl

RTS$HIGH	equ 0D5H
RTS$LOW		equ 095H

ACIA0$D		equ 081H
ACIA0$C		equ 080H
ACIA1$D		equ 083H
ACIA1$C		equ 082H

max$devices	equ 6

	cseg

?cinit:
	mvi a,RTS$LOW
	dcr c ! jz cinit1
	inr c ! rnz
	out ACIA0$C ! ret
cinit1:	out ACIA1$C ! ret

	; character input
?ci:	dcr b ! jz rx1		; acia1
	inr b ! jz rx0		; acia0
	mvi a,1Ah ! ret		; return on error
rx0:	in ACIA0$C ! ani 1 ! jz rx0
	in ACIA0$D ! ret
rx1:	in ACIA1$C ! ani 1 ! jz rx1
	in ACIA1$D ! ret

	; character input status
?cist:	dcr b ! jnz cist0
	in ACIA1$C ! jmp ciste
cist0:	inr b ! jz cist1
	xra a ! ret		; return on error
cist1:	in ACIA0$C
ciste:	ani 1 ! rz		; 
	mvi a,-1 ! ret		; 

	; character output
?co:	dcr b ! jz tx1
	inr b ! rnz		; return on error
tx0:	in ACIA0$C ! ani 2 ! jz tx0
	mov a,c !out ACIA0$D ! ret
tx1:	in ACIA1$C ! ani 2 ! jz tx1
	mov a,c ! out ACIA1$D ! ret

	; character output status
?cost:	dcr b ! jnz cost0
	in ACIA1$C ! jmp coste
cost0:	inr b ! jz cost1
	xra a ! ret		; return on error
cost1:	in ACIA0$C
coste:	ani 2 ! rz
	mvi a,-1 ! ret

@ctbl:	db 'TTY   ',0Fh,0Eh
	db 'CRT   ',0Fh,0Eh
	db 00

	end
