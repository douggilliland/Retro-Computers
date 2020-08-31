;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; Initialisation routines to suit Z8S180 CPU, with internal USART.
;
; Internal USART interrupt driven serial I/O
; Full input and output buffering.
;
; https://github.com/feilipu/
; https://feilipu.me/
;

;==============================================================================
;
; INCLUDES SECTION
;

INCLUDE    "yaz180.inc"

;==============================================================================
;
; CODE SECTION
;

;------------------------------------------------------------------------------
SECTION z180_interrupts
ASCI0_INTERRUPT:
        push af
        push hl
                                    ; start doing the Rx stuff
        in0 a, (STAT0)              ; load the ASCI0 status register
        tst ASCI_RDRF               ; test whether we have received on ASCI0
        jr z, ASCI0_TX_CHECK        ; if not, go check for bytes to transmit

ASCI0_RX_GET:
        in0 l, (RDR0)               ; move Rx byte from the ASCI0 RDR to l
        
        and ASCI_OVRN|ASCI_PE|ASCI_FE   ; test whether we have error on ASCI0
        jr nz, ASCI0_RX_ERROR       ; drop this byte, clear error, and get the next byte

        ld a, (ASCI0RxBufUsed)      ; get the number of bytes in the Rx buffer      
        cp ASCI0_RX_BUFSIZE-1       ; check whether there is space in the buffer
        jr nc, ASCI0_RX_CHECK       ; buffer full, check whether we need to drain H/W FIFO

        ld a, l                     ; get Rx byte from l
        ld hl, (ASCI0RxInPtr)       ; get the pointer to where we poke
        ld (hl), a                  ; write the Rx byte to the ASCI0RxInPtr target

        inc l                       ; move the Rx pointer low byte along, 0xFF rollover
        ld (ASCI0RxInPtr), hl       ; write where the next byte should be poked

        ld hl, ASCI0RxBufUsed
        inc (hl)                    ; atomically increment Rx buffer count
        jr ASCI0_RX_CHECK           ; check for additional bytes

ASCI0_RX_ERROR:
        in0 a, (CNTLA0)             ; get the CNTRLA0 register
        and ~ASCI_EFR               ; to clear the error flag, EFR, to 0 
        out0 (CNTLA0), a            ; and write it back

ASCI0_RX_CHECK:                     ; Z8S180 has 4 byte Rx H/W FIFO
        in0 a, (STAT0)              ; load the ASCI0 status register
        tst ASCI_RDRF               ; test whether we have received on ASCI0
        jr nz, ASCI0_RX_GET         ; if still more bytes in H/W FIFO, get them

ASCI0_TX_CHECK:                     ; now start doing the Tx stuff
        and ASCI_TDRE               ; test whether we can transmit on ASCI0
        jr z, INTERRUPT_EXIT        ; if not, then end

        ld a, (ASCI0TxBufUsed)      ; get the number of bytes in the Tx buffer
        or a                        ; check whether it is zero
        jr z, ASCI0_TX_TIE0_CLEAR   ; if the count is zero, then disable the Tx Interrupt

        ld hl, (ASCI0TxOutPtr)      ; get the pointer to place where we pop the Tx byte
        ld a, (hl)                  ; get the Tx byte
        out0 (TDR0), a              ; output the Tx byte to the ASCI0

        inc l                       ; move the Tx pointer low byte along, 0xFF rollover
        ld (ASCI0TxOutPtr), hl      ; write where the next byte should be popped

        ld hl, ASCI0TxBufUsed
        dec (hl)                    ; atomically decrement current Tx count

        jr nz, INTERRUPT_EXIT       ; if we've more Tx bytes to send, we're done for now

ASCI0_TX_TIE0_CLEAR:
        in0 a, (STAT0)              ; get the ASCI0 status register
        and ~ASCI_TIE               ; mask out (disable) the Tx Interrupt
        out0 (STAT0), a             ; set the ASCI0 status register

INTERRUPT_EXIT:
        pop hl
        pop af
        ei
        ret

PRT0_INTERRUPT:
        push af
        push hl

        in0 a, (TCR)                ; to clear the PRT0 interrupt, read the TCR
        in0 a, (TMDR0H)             ; followed by the TMDR0

        ld hl, sysTimeFraction
        inc (hl)
        jr NZ, INTERRUPT_EXIT       ; at 0 we're at 1 second count, interrupted 256 times

;       ld hl, sysTime              ; inc hl works, provided the storage is contiguous
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr NZ, INTERRUPT_EXIT
        inc hl
        inc (hl)
        jr INTERRUPT_EXIT

;------------------------------------------------------------------------------
SECTION z180_asci0
RX0_CHK:
        LD      A,(ASCI0RxBufUsed)
        CP      $0
        RET

;------------------------------------------------------------------------------
RX0:
        ld a, (ASCI0RxBufUsed)      ; get the number of bytes in the Rx buffer
        or a                        ; see if there are zero bytes available
        jr z, RX0                   ; wait, if there are no bytes available

        push hl                     ; Store HL so we don't clobber it

        ld hl, (ASCI0RxOutPtr)      ; get the pointer to place where we pop the Rx byte
        ld a, (hl)                  ; get the Rx byte

        inc l                       ; move the Rx pointer low byte along, 0xFF rollover
        ld (ASCI0RxOutPtr), hl      ; write where the next byte should be popped

        ld hl, ASCI0RxBufUsed
        dec (hl)                    ; atomically decrement Rx count

        pop hl                      ; recover HL
        ret                         ; char ready in A

;------------------------------------------------------------------------------
TX0:
        push hl                     ; store HL so we don't clobber it        
        ld l, a                     ; store Tx character 

        ld a, (ASCI0TxBufUsed)      ; get the number of bytes in the Tx buffer
        or a                        ; check whether the buffer is empty
        jr nz, TX0_BUFFER_OUT       ; buffer not empty, so abandon immediate Tx

        in0 a, (STAT0)              ; get the ASCI0 status register
        and ASCI_TDRE                ; test whether we can transmit on ASCI0
        jr z, TX0_BUFFER_OUT        ; if not, so abandon immediate Tx

        ld a, l                     ; Retrieve Tx character for immediate Tx
        out0 (TDR0), a              ; output the Tx byte to the ASCI0

        pop hl                      ; recover HL
        ret                         ; and just complete

TX0_BUFFER_OUT:
        ld a, (ASCI0TxBufUsed)      ; Get the number of bytes in the Tx buffer
        cp ASCI0_TX_BUFSIZE-1       ; check whether there is space in the buffer
        jr nc, TX0_BUFFER_OUT       ; buffer full, so wait for free buffer for Tx

        ld a, l                     ; retrieve Tx character

        ld hl, ASCI0TxBufUsed
        di
        inc (hl)                    ; atomic increment of Tx count
        ld hl, (ASCI0TxInPtr)       ; get the pointer to where we poke
        ei
        ld (hl), a                  ; write the Tx byte to the ASCI0TxInPtr   

        inc l                       ; move the Tx pointer low byte along, 0xFF rollover
        ld (ASCI0TxInPtr), hl       ; write where the next byte should be poked

        pop hl                      ; recover HL

        in0 a, (STAT0)              ; load the ASCI0 status register
        and ASCI_TIE                ; test whether ASCI0 interrupt is set
        ret nz                      ; if so then just return

        di                          ; critical section begin
        in0 a, (STAT0)              ; get the ASCI status register again
        or ASCI_TIE                 ; mask in (enable) the Tx Interrupt
        out0 (STAT0), a             ; set the ASCI status register
        ei                          ; critical section end
        ret

;------------------------------------------------------------------------------
SECTION z180_asci0_print
TX0_PRINT:
        LD      A,(HL)              ; Get a byte
        OR      A                   ; Is it $00 ?
        RET     Z                   ; Then RETurn on terminator
        CALL    TX0                 ; Print it
        INC     HL                  ; Next byte
        JR      TX0_PRINT           ; Continue until $00

;------------------------------------------------------------------------------
SECTION     z180_hexloadr
HEX_START:
            ld hl, initString
            call TX0_PRINT

            ld c,0                  ; non zero c is our ESA flag

HEX_WAIT_COLON:
            call RX0                ; Rx byte
            cp ':'                  ; wait for ':'
            jr nz, HEX_WAIT_COLON
            ld hl, 0                ; reset hl to compute checksum
            call HEX_READ_BYTE      ; read byte count
            ld b, a                 ; store it in b
            call HEX_READ_BYTE      ; read upper byte of address
            ld d, a                 ; store in d
            call HEX_READ_BYTE      ; read lower byte of address
            ld e, a                 ; store in e
            call HEX_READ_BYTE      ; read record type
            cp 02                   ; check if record type is 02 (ESA)
            jr z, HEX_ESA_DATA
            cp 01                   ; check if record type is 01 (end of file)
            jr z, HEX_END_LOAD
            cp 00                   ; check if record type is 00 (data)
            jr nz, HEX_INVAL_TYPE   ; if not, error
HEX_READ_DATA:
;            ld a, '*'               ; "*" per byte loaded  # DEBUG
;            call TX0                ; Print it             # DEBUG
            call HEX_READ_BYTE
            ld (de), a              ; write the byte at the RAM address
            inc de
            djnz HEX_READ_DATA      ; if b non zero, loop to get more data
HEX_READ_CHKSUM:
            call HEX_READ_BYTE      ; read checksum, but we don't need to keep it
            ld a, l                 ; lower byte of hl checksum should be 0
            or a
            jr nz, HEX_BAD_CHK      ; non zero, we have an issue
            ld a, '#'               ; "#" per line loaded
            call TX0                ; Print it
;            ld a, CR                ; CR                   # DEBUG
;            call TX0                ; Print it             # DEBUG
;            ld a, LF                ; LF                   # DEBUG
;            call TX0                ; Print it             # DEBUG
            jr HEX_WAIT_COLON

HEX_ESA_DATA:
            in0 a, (BBR)            ; grab the current Bank Base Value
            ld c, a                 ; store BBR for later recovery
            call HEX_READ_BYTE      ; get high byte of ESA
            out0 (BBR), a           ; write it to the BBR  
            call HEX_READ_BYTE      ; get low byte of ESA, abandon it, but calc checksum
            jr HEX_READ_CHKSUM      ; calculate checksum

HEX_END_LOAD:
            call HEX_READ_BYTE      ; read checksum, but we don't need to keep it
            ld a, l                 ; lower byte of hl checksum should be 0
            or a
            jr nz, HEX_BAD_CHK      ; non zero, we have an issue
            call HEX_BBR_RESTORE    ; clean up the BBR
            ld hl, LoadOKStr
            call TX0_PRINT
            jp WARMSTART            ; ready to run our loaded program from Basic
            
HEX_INVAL_TYPE:
            call HEX_BBR_RESTORE    ; clean up the BBR
            ld hl, invalidTypeStr
            call TX0_PRINT
            jp START                ; go back to start

HEX_BAD_CHK:
            call HEX_BBR_RESTORE    ; clean up the BBR
            ld hl, badCheckSumStr
            call TX0_PRINT
            jp START                ; go back to start

HEX_BBR_RESTORE:
            ld a, c                 ; get our BBR back
            ret z                   ; if it is zero, chances are we don't need it
            out0 (BBR), a           ; write it to the BBR
            ret

HEX_READ_BYTE:                      ; Returns byte in a, checksum in hl
            push bc
            call RX0                ; Rx byte
            sub '0'
            cp 10
            jr c, HEX_READ_NBL2     ; if a<10 read the second nibble
            sub 7                   ; else subtract 'A'-'0' (17) and add 10
HEX_READ_NBL2:
            rlca                    ; shift accumulator left by 4 bits
            rlca
            rlca
            rlca
            ld c, a                 ; temporarily store the first nibble in c
            call RX0                ; Rx byte
            sub '0'
            cp 10
            jr c, HEX_READ_END      ; if a<10 finalize
            sub 7                   ; else subtract 'A' (17) and add 10
HEX_READ_END:
            or c                    ; assemble two nibbles into one byte in a
            ld b, 0                 ; add the byte read to hl (for checksum)
            ld c, a
            add hl, bc
            pop bc
            ret                     ; return the byte read in a

;------------------------------------------------------------------------------
SECTION     z180_init

PUBLIC      Z180_INIT

Z180_INIT:
            XOR     A               ; Zero Accumulator

                                    ; Clear Refresh Control Reg (RCR)
            OUT0    (RCR),A         ; DRAM Refresh Enable (0 Disabled)

                                    ; Clear INT/TRAP Control Register (ITC)             
            OUT0    (ITC),A         ; Disable all external interrupts.             

                                    ; Set Operation Mode Control Reg (OMCR)
            LD      A,OMCR_M1E      ; Enable M1 for single step, disable 64180 I/O _RD Mode
            OUT0    (OMCR),A        ; X80 Mode (M1 Disabled, IOC Disabled)

                                    ; Set internal clock = crystal x 2 = 36.864MHz
                                    ; if using ZS8180 or Z80182 at High-Speed
            LD      A,CMR_X2        ; Set Hi-Speed flag
            OUT0    (CMR),A         ; CPU Clock Multiplier Reg (CMR)

                                    ; DMA/Wait Control Reg Set I/O Wait States
            LD      A,DCNTL_IWI0
            OUT0    (DCNTL),A       ; 0 Memory Wait & 2 I/O Wait

                                    ; Set Logical RAM Addresses
                                    ; $2000-$FFFF RAM   CA1 -> $2n
                                    ; $0000-$1FFF Flash BANK -> $n0

            LD      A,$20           ; Set New Common 1 / Bank Areas for RAM
            OUT0    (CBAR),A

            LD      A,$10           ; Set Common 1 Base Physical $12000 -> $10
            OUT0    (CBR),A

            LD      A,$00           ; Set Bank Base Physical $00000 -> $00
            OUT0    (BBR),A

                                    ; load the default ASCI configuration
                                    ; BAUD = 115200 8n1
                                    ; receive enabled
                                    ; transmit enabled
                                    ; receive interrupt enabled
                                    ; transmit interrupt disabled

            LD      A,ASCI_RE|ASCI_TE|ASCI_8N1
            OUT0    (CNTLA0),A      ; output to the ASCI0 control A reg

                                    ; PHI / PS / SS / DR = BAUD Rate
                                    ; PHI = 18.432MHz
                                    ; BAUD = 115200 = 18432000 / 10 / 1 / 16 
                                    ; PS 0, SS_DIV_1 0, DR 0           
            XOR     A               ; BAUD = 115200
            OUT0    (CNTLB0),A      ; output to the ASCI0 control B reg

            LD      A,ASCI_RIE      ; receive interrupt enabled
            OUT0    (STAT0),A       ; output to the ASCI0 status reg

                                    ; we do 256 ticks per second
            ld      hl, CPU_CLOCK/CPU_TIMER_SCALE/256-1
            out0    (RLDR0L), l
            out0    (RLDR0H), h
                                    ; enable down counting and interrupts for PRT0
            ld      a, TCR_TIE0|TCR_TDE0
            out0    (TCR), a

            LD      SP,TEMPSTACK    ; Set up a temporary stack

            LD      HL,ASCI0RxBuf   ; Initialise 0Rx Buffer
            LD      (ASCI0RxInPtr),HL
            LD      (ASCI0RxOutPtr),HL

            LD      HL,ASCI0TxBuf   ; Initialise 0Tx Buffer
            LD      (ASCI0TxInPtr),HL
            LD      (ASCI0TxOutPtr),HL              

            XOR     A               ; 0 the ASCI0 Tx & Rx Buffer Counts
            LD      (ASCI0RxBufUsed),A
            LD      (ASCI0TxBufUsed),A

            EI                      ; enable interrupts

START:                                     
            LD      HL,SIGNON1      ; Sign-on message
            CALL    TX0_PRINT       ; Output string
            LD      A,(basicStarted); Check the BASIC STARTED flag
            CP      'Y'             ; to see if this is power-up
            JR      NZ,COLDSTART    ; If not BASIC started then always do cold start
            LD      HL,SIGNON2      ; Cold/warm message
            CALL    TX0_PRINT       ; Output string
CORW:
            RST     10H             ; get a byte from ASCI0
            AND     11011111B       ; lower to uppercase
            CP      'H'             ; are we trying to load an Intel HEX program?
            JP      Z, HEX_START    ; then jump to HexLoadr
            CP      'C'
            JR      NZ, CHECKWARM
            RST     08H
            LD      A, CR
            RST     08H
            LD      A, LF
            RST     08H
COLDSTART:
            LD      A,'Y'           ; Set the BASIC STARTED flag
            LD      (basicStarted),A
            JP      $0399           ; <<<< Start Basic COLD:

CHECKWARM:
            CP      'W'
            JR      NZ, CORW
            RST     08H
            LD      A, CR
            RST     08H
            LD      A, LF
            RST     08H
WARMSTART:
            JP      $039C           ; <<<< Start Basic WARM:


;==============================================================================
;
; STRINGS
;

SECTION         z180_init_strings

SIGNON1:        DEFM    CR,LF
                DEFM    "YAZ180 - feilipu",CR,LF
                DEFM    "z88dk",CR,LF,0

SIGNON2:        DEFM    CR,LF
                DEFM    "Cold or Warm start, "
                DEFM    "or HexLoadr (C|W|H) ? ",0

initString:     DEFM    CR,LF,"HexLoadr: "
                DEFM    CR,LF,0

invalidTypeStr: DEFM    CR,LF,"Invalid Type",CR,LF,0
badCheckSumStr: DEFM    CR,LF,"Checksum Error",CR,LF,0
LoadOKStr:      DEFM    CR,LF,"Done",CR,LF,0

;==============================================================================
;
; Z80 INTERRUPT VECTOR SERVICE ROUTINES
;

EXTERN  REINIT
EXTERN  NULL_RET, NULL_INT, NULL_NMI

PUBLIC  Z180_TRAP
PUBLIC  RST_08, RST_10, RST_18, RST_20, RST_28, RST_30
PUBLIC  INT_INT0, INT_NMI

DEFC    Z180_TRAP   =   REINIT          ; Initialise again, for the moment
DEFC    RST_08      =   TX0             ; TX a byte over ASCI0
DEFC    RST_10      =   RX0             ; RX a byte over ASCI0, loop byte available
DEFC    RST_18      =   RX0_CHK         ; Check ASCI0 status, return # bytes available
DEFC    RST_20      =   NULL_RET        ; RET
DEFC    RST_28      =   NULL_RET        ; RET
DEFC    RST_30      =   NULL_RET        ; RET
DEFC    INT_INT0    =   NULL_INT        ; EI RETI
DEFC    INT_NMI     =   NULL_NMI        ; RETN

;==============================================================================
;
; Z180 INTERRUPT VECTOR SERVICE ROUTINES
;

EXTERN  NULL_RET

PUBLIC  INT_INT1, INT_INT2, INT_PRT0, INT_PRT1
PUBLIC  INT_DMA0, INT_DMA1, INT_CSIO, INT_ASCI0, INT_ASCI1

DEFC    INT_INT1    =   NULL_RET        ; external /INT1
DEFC    INT_INT2    =   NULL_RET        ; external /INT2
DEFC    INT_PRT0    =   PRT0_INTERRUPT  ; PRT channel 0
DEFC    INT_PRT1    =   NULL_RET        ; PRT channel 1
DEFC    INT_DMA0    =   NULL_RET        ; DMA channel 0
DEFC    INT_DMA1    =   NULL_RET        ; DMA Channel 1
DEFC    INT_CSIO    =   NULL_RET        ; Clocked serial I/O
DEFC    INT_ASCI0   =   ASCI0_INTERRUPT ; Async channel 0
DEFC    INT_ASCI1   =   NULL_RET        ; Async channel 1

;==============================================================================

