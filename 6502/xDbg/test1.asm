; Assemble with as65 -x option
;
; This assembler uses different syntax than the xDebugger for the
; SMB, CMB, BBR and BBS instructions.
;
	include	"xkim.inc"
	code
	org	$0200
Test	ldx	#15
loop	stz	0,x
	dex
	bpl	loop
	nop
	nop
	smb	0,0	;set bit zero
	smb	1,1
	smb	2,2
	smb	3,3
	bbs	0,0,Test

	org	AutoRun
	dw	Test
	end
