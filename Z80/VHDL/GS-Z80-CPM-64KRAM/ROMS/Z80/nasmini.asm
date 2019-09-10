;==================================================================================
; Contents of this file are copyright Grant Searle
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; http://searle.hostei.com/grant/index.html
;
; eMail: home.micros01@btinternet.com
;
; If the above don't work, please perform an Internet search to see if I have
; updated the web page hosting service.
;
;==================================================================================

; Minimum 6850 ACIA serial I/O to run modified NASCOM Basic 4.7


RTS_HIGH        .EQU     0D5H
RTS_LOW         .EQU     095H

basicStarted    .EQU     $2000
TEMPSTACK       .EQU     $200F

CR              .EQU     0DH
LF              .EQU     0AH
CS              .EQU     0CH             ; Clear screen

                .ORG $0000
;------------------------------------------------------------------------------
; Reset

RST00           DI                       ;Disable interrupts
                JP       INIT            ;Initialize Hardware and go

;------------------------------------------------------------------------------
; TX a character over RS232 

                .ORG     0008H
RST08            JP      TXA

;------------------------------------------------------------------------------
; RX a character over RS232 Channel A [Console], hold here until char ready.

                .ORG 0010H
RST10            JP      RXA

;------------------------------------------------------------------------------
; Check serial status

                .ORG 0018H
RST18            JP      CKINCHAR

;------------------------------------------------------------------------------
RXA:
waitForChar: 	call CKINCHAR
				JR	Z, waitForChar
				IN   	A,($81)
				RET	; Char ready in A


;------------------------------------------------------------------------------
TXA:            PUSH     AF              ; Store character
conout1:        IN       A,($80)         ; Status byte       
                BIT      1,A             ; Set Zero flag if still transmitting character       
                JR       Z,conout1       ; Loop until flag signals ready
                POP      AF              ; Retrieve character
                OUT      ($81),A         ; Output the character
                RET

;------------------------------------------------------------------------------
CKINCHAR 
				IN   A,($80)		; Status byte
				AND  $01
				CP   $0			; Z flag set if no char
				RET

PRINT:          LD       A,(HL)          ; Get character
                OR       A               ; Is it $00 ?
                RET      Z               ; Then RETurn on terminator
                RST      08H             ; Print it
                INC      HL              ; Next Character
                JR       PRINT           ; Continue until $00
                RET
;------------------------------------------------------------------------------
INIT:
               LD        HL,TEMPSTACK    ; Temp stack
               LD        SP,HL           ; Set up a temporary stack
               LD        A,RTS_LOW
               OUT       ($80),A         ; Initialise ACIA
               LD        HL,SIGNON1      ; Sign-on message
               CALL      PRINT           ; Output string
               LD        A,(basicStarted); Check the BASIC STARTED flag
               CP        'Y'             ; to see if this is power-up
               JR        NZ,COLDSTART    ; If not BASIC started then always do cold start
               LD        HL,SIGNON2      ; Cold/warm message
               CALL      PRINT           ; Output string
CORW:
               CALL      RXA
               AND       %11011111       ; lower to uppercase
               CP        'C'
               JR        NZ, CHECKWARM
               RST       08H
               LD        A,$0D
               RST       08H
               LD        A,$0A
               RST       08H
COLDSTART:     LD        A,'Y'           ; Set the BASIC STARTED flag
               LD        (basicStarted),A
               JP        $0100           ; Start BASIC COLD
CHECKWARM:
               CP        'W'
               JR        NZ, CORW
               RST       08H
               LD        A,$0D
               RST       08H
               LD        A,$0A
               RST       08H
               JP        $0103           ; Start BASIC WARM
              
SIGNON1:       .BYTE     CS
               .BYTE     "Z80 SBC By Grant Searle",CR,LF,0
SIGNON2:       .BYTE     CR,LF
               .BYTE     "Cold or warm start (C or W)? ",0
              
.END
