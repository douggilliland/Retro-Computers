;
;                          BYESUB.ASM
;         A routine to load/run a .com file on request
; 
;   When used by itself, or, as intended, as a called subroutine for
;RCP/M conditional logoffs, (security violation, overstayers, etc.),
;this routine will make use of the autorun feature buried in the CCP 
;module of CP/M. The file specified at the equate near the end of the 
;program will be loaded into the ccp command buffer, and the ccp will
;be cold started. This will act as if the name had been typed in at
;the console, and the return key hit.
;
;   Note that the value of CPR is system dependant. This must be 
;changed for your paticular system.
;
;              ----------------------------------
;
;------------------
;   Mods / Fixes  :
;------------------
;
;11/06/82    Initial Release
;
;			Mark J. Pulver
;			AIMS  (312) 789-0499
;
;
;-----------------
;   Code starts  :
;-----------------
;
cpr	equ	0c700h	;ccp cold start
cbuff	equ	cpr+7	;address of command length pointer
cival	equ	cpr+8	;address of command buffer
cibptr	equ	cpr+59h	;address of pointer to ccp command buffer
;
offset	equ	0
;
;
	org	0100h
;
bye:	equ	$+offset
	lhld	byefil		;get length
	mov	b,l		;B needs it for MOVE
	lxi	h,byefil	;get name of file
	lxi	d,cbuff		;where its going
	call	move		;move name into buffer
	lxi	h,cival		;get command buffer location
	shld	cibptr		;stuff it in pointer
	lda	user
	mov	c,a		;C must have user/drive
	jmp	cpr		;cold start ccp
;
move:	equ	$+offset	;hl to de length in b
	mov	a,m
	stax	d
	inx	d
	inx	h
	dcr	b
	jnz	move
	ret
;
user:	equ	$+offset
	db	0			;user/drive spec for file,
					;follows 0004h conventions
byefil:	equ	$+offset
	db	5,'BYE',0		;comfile to run
;command length ^       ^- - - "0" must be here
;+2 for first and last bytes
;
;
	end