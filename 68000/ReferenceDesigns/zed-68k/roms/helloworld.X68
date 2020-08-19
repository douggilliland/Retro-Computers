*-----------------------------------------------------------
* Program    :Hello World
* Written by :@kanpapa
* Date       :10/09/2017
* Description:Test Program 1 for MIC68K board
*-----------------------------------------------------------

;
; Memory map
;
; $000000-$00ffff RAM (32K x 2)
; $010000-$01ffff ROM (32K x 2)
; $f00009         ACIA1
; $f20009         ACIA2
; $f40009         PIA
; $f60009         PTM
;

; Terminal port
ttyst	equ	$f00009
ttyd	equ	$f0000b

; System stack
stack	equ	$00fff0

; Reset Vector   
	org	$010000
	dc.l	stack		;system stack
	dc.l	start		;initial pc

start:	move.b	#$03,ttyst	;setup ports (Master Reset)
	move.b	#$15,ttyst	;8Bits + 1Stop Bits, div 16

	move.l	#stack,a0	;Set Stackpointer
	move.l	a0,usp
	
	lea.l	strmsg.l,a3
	bsr	wstr

loop:	lea.l	message.l,a3
		bsr	wstr
;		bra	loop
        stop #$0000

;
; a3 Pointed to first byte
; end with 0
wstr:	move.b (a3)+,d0
		cmp.b  #0,d0
		beq	wstr1
		bsr writ
        bra	wstr
wstr1:	rts

;
; Generalized write facility writes 1 byte
; passed in d0 to tty.
;
writ:	btst	#$1,ttyst	;sample control register till done
	beq	writ
	move.b	d0,ttyd		;write the character to port
	rts

;
; Messages data
;
cr	equ	$0d		;ASCII code for Carriage Return
lf	equ	$0a		;ASCII code for Line Feed
message	dc.b	'HELLO WORLD',cr,lf,0
strmsg dc.b 'STARTING',cr,lf,0

	end	start

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
