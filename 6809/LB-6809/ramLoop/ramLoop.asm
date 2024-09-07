; ramLoop.asm
; Assembled with asm6809
; Land Boards, LLC
; Loops on SRAM write/read on LB-6809-01 card

		ORG $C000
; SET LED = LOW
RESVEC
		LDA	#$55
		STA	$0000
		LDB	$0000
		CMPB	#$55
		BNE	FAIL
PASS	
		LDA	#1
		STA	$F000
		BRA	RESVEC
FAIL
		CLRA
		STA	$F000
		BRA	RESVEC
