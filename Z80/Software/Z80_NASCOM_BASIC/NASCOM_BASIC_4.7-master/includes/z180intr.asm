;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; https://github.com/feilipu/
;
; https://feilipu.me/
;

;==============================================================================
;
; REQUIRES
;
; Z180_VECTOR_BASE  .EQU   RAM vector address for Z180 Vectors
; INCLUDE       "yaz180.inc"

INCLUDE         "yaz180.inc"

;==============================================================================
;
; Z180 TRAP HANDLING
;
SECTION     z180_vector_trap_handler

EXTERN      Z180_INIT, Z180_TRAP

PUBLIC      INIT, REINIT

INIT:
            PUSH    AF
                                    ; Set I/O Control Reg (ICR)
            LD      A,Z180_IO_BASE  ; ICR = $00 [xx00 0000] for I/O Registers at $00 - $3F
            OUT0    (ICR),A         ; Standard I/O Mapping (0 Enabled)

            IN0     A,(ITC)         ; Check whether TRAP is set, or normal RESET
            AND     ITC_TRAP
            JR      NZ, Z180_TRAP_HANDLER ; Handle the TRAP event

            POP     AF
REINIT:
            LD      A,Z180_VECTOR_BASE/$100
            LD      I,A             ; Set interrupt vector address high byte (I)

                                    ; IL = $40 [010x xxxx] for Vectors at $nn40 - $nn5F
            LD      A,Z180_VECTOR_BASE%$100
            OUT0    (IL),A          ; Set interrupt vector address low byte (IL)

            IM      1               ; Interrupt mode 1 for INT0

            XOR     A               ; Zero Accumulator

                                    ; Clear Refresh Control Reg (RCR)
            OUT0    (RCR),A         ; DRAM Refresh Enable (0 Disabled)

            OUT0    (TCR),A         ; Disable PRT downcounting

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

            LD      HL,Z80_VECTOR_PROTO ; Establish Z80 RST Vector Table
            LD      DE,Z80_VECTOR_BASE
            LD      BC,Z80_VECTOR_SIZE
            LDIR

            LD      HL,Z180_VECTOR_PROTO ; Establish Z180 Vector Table
            LD      DE,Z180_VECTOR_BASE
            LD      BC,Z180_VECTOR_SIZE
            LDIR

            JP      Z180_INIT       ; Start normal Configuration

Z180_TRAP_HANDLER:
            XOR     ITC_TRAP        ; Clear TRAP bit, It must be set to get here.
            OUT0    (ITC),A 
            POP     AF
            JP      Z180_TRAP       ; Jump to proper TRAP handling
;==============================================================================
;
; Z180 INTERRUPT VECTOR TABLE PROTOTYPE
;
; WILL BE DUPLICATED DURING INIT TO:
;
;           .ORG    Z180_VECTOR_BASE

SECTION     z180_vector_table_prototype

EXTERN      INT_INT1, INT_INT2, INT_PRT0, INT_PRT1
EXTERN      INT_DMA0, INT_DMA1, INT_CSIO, INT_ASCI0, INT_ASCI1

;------------------------------------------------------------------------------
; Z180_VECTOR_INT1
            DEFW    INT_INT1

;------------------------------------------------------------------------------
; Z180_VECTOR_INT2
            DEFW    INT_INT2

;------------------------------------------------------------------------------
; Z180_VECTOR_PRT0
            DEFW    INT_PRT0

;------------------------------------------------------------------------------
; Z180_VECTOR_PRT1
            DEFW    INT_PRT1

;------------------------------------------------------------------------------
; Z180_VECTOR_DMA0
            DEFW    INT_DMA0

;------------------------------------------------------------------------------
; Z180_VECTOR_DMA1
            DEFW    INT_DMA1

;------------------------------------------------------------------------------
; Z180_VECTOR_CSIO
            DEFW    INT_CSIO

;------------------------------------------------------------------------------
; Z180_VECTOR_ASCI0
            DEFW    INT_ASCI0

;------------------------------------------------------------------------------
; Z180_VECTOR_ASCI1
            DEFW    INT_ASCI1

;==============================================================================
;
            .END
;
;==============================================================================


