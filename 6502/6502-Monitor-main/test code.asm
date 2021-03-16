	
	AUTO
PRBYTE 	.EQ $FFDC
ECHO   	.EQ $FFEF
CR     	.EQ $0D
;---------------
START		
		JSR HELLO
    		JSR COUNT
    		RTS
;---------------
HELLO    	LDX #0
.1	   	
		LDA .3,X
    		BPL .2
    		JSR ECHO
    		INX
   		BNE .1
.2	    	ORA #1000.0000
    		JMP ECHO
.3
 ;---------------
 	.AT -/HELLO WORLD/
;---------------
COUNT	   	JSR .2
    		LDX #0
.1		TXA
   		JSR PRBYTE
    		LDA #" "
    		JSR ECHO
    		INX
    		CPX #10
   		BCC .1
.2	    	LDA #CR
   		JMP ECHO
