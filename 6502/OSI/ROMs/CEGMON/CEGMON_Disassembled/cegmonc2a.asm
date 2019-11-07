; DISASSEMBLY OF CEGMONC2.ROM
; SEE **BUG FIX**
; This compiles under the portable A65 assembler.

; NOTE: The original text indicated that the FCXX segment should be
; relocated to $F700 for C2/4.  To simplify the address circuitry, the
; ROM is wired to $F000-$FFFF, with A11 ignored, and the chip disabled
; when $FC00 (ACIA) is enabled.  This scheme maps the $FCXX segment to
; $F400 in hardware, so the offset is calculated as $FCXX-$F4XX.  If
; you follow the original CEGMON wiring instructions (I don't have
; these), then change the offest back to $FC00-$F700.


; EDITOR Commands: (modified from original to be slightly more EMACS-like
;
; Ctl-E Editor on/off
; Ctl-B Back
; Ctl-F Forward
; Ctl-P Prev. line (up)
; Ctl-N Next line (down)
; Ctl-Y yank (copy character to input buffer)

; This file is merged for C1/C2.  Scan for the strings C1/C2, and
; uncomment the appropriate line.  TODO: Once I find a decent Linux
; assembler supporting conditionals, convert to conditional



BASIC   =       $A000   ; BASIC ROM
DISK    =       $C000   ; DISK CONTROLLER (PIA = +$00, ACIA = +$10)
SCREEN  =       $D000   ; SCREEN RAM
KEYBD   =       $DF00   ; KEYBOARD

;; C1/C2
ACIA    =       $FC00   ; SERIAL PORT (MC6850 ACIA) FOR C2/C4
;ACIA   =       $F000   ; SERIAL PORT (MC6850 ACIA) FOR C1/Superboard/UK101


; BASIC ROM ROUTINES
; ROM BASIC provides ACIA I/O for the C2/4, which has the ACIA at
; $FC00.  The C1 must reproduce these in the monitor for the ACIA at
; $F000.

LA34B   =       BASIC+$034B     ; UK101 BASIC RUBOUT KEY RETURN
LA374   =       BASIC+$0374     ; UK101 BASIC RUBOUT KEY RETURN
LA636   =       BASIC+$0636     ; CTRL-C HANDLER
LBD11   =       BASIC+$1D11     ; BASIC COLD START
;LBF15  =       BASIC+$1F15     ; OUTPUT CHAR TO ACIA (C2/C4)
;LBF22  =       BASIC+$1F22     ; INIT ACIA (C2/C4)

LBF2D   =       BASIC+$1F2D     ; CRT SIMULATOR

; C1/C2
;OFFSET =       $FC00-$F400     ; $FC00-FCFF ROM MAPPED TO $F400 (C2/C4)
OFFSET  =       $0              ; no offset needed for C1

;               NMI     IRQ     WIDTH   SIZE    START   COLS    ROWS
;C2/4           $130    $1C0    64      1       128     64      28
;C1P/SBII       $130    $1C0    32      0       69      24      26
;UK101          $130    $1C0    64      0       140     48      14


NMI     =       $130            ; NMI ADDRESS
IRQ     =       $1C0            ; IRQ ADDRESS

;screen parameters for C2
WIDTH   =       64              ; SCREEN WIDTH
SIZE    =       1               ; SCREEN SIZE 0=1K 1=2K

START   =       128             ; SET SCREEN OFFSET
COLS    =       64              ; SET COLUMNS TO DISPLAY
ROWS    =       28              ; SET ROWS TO DISPLAY

;screen parameters for C1
;WIDTH  =       32              ; SCREEN WIDTH
;SIZE   =       0               ; SCREEN SIZE 0=1K 1=2K

;START  =       69              ; SET SCREEN OFFSET
;COLS   =       24              ; SET COLUMNS TO DISPLAY
;ROWS   =       26              ; SET ROWS TO DISPLAY

SWIDTH  =       COLS-1
TOP     =       SCREEN+START
BASE    =       ROWS-1*WIDTH+TOP
BOT     =       SIZE+1*1024+SCREEN

        *=      $F800

; RUBOUT

LF800   LDA     $E
        BEQ     LF80A
        DEC     $E
        BEQ     LF80A
        DEC     $E
LF80A   LDA     #' '
        STA     $201
        JSR     LFF8F
        BPL     LF82D
        SEC
        LDA     $22B
        SBC     #WIDTH ;$40
        STA     $22B
        LDA     $22B+1
        SBC     #0
        STA     $22B+1
        JSR     LFBCF
        BCS     LF82D
        JSR     LFFD1
LF82D   STX     $200
        JSR     LFF88
        JMP     LF8D2

; NEW SCREEN

LF836   STA     $202
        PHA
        TXA
        PHA
        TYA
        PHA
        LDA     $202
        BNE     LF846   ; NOT NULL
        JMP     LF8D2

LF846   LDY     $206    ; SCREEN DELAY
        BEQ     LF84E
        JSR     LFCE1-OFFSET

LF84E   CMP     #$5F
        BEQ     LF800
        CMP     #$C
        BNE     LF861

; CTRL-L

        JSR     LFF8C
        JSR     LFFD1
        STX     $200
        BEQ     LF8CF

LF861   CMP     #$A
        BEQ     LF88C
        CMP     #$1E
        BEQ     LF8E0
        CMP     #$B
        BEQ     LF87D
        CMP     #$1A
        BEQ     LF8D8
        CMP     #$D
        BNE     LF87A

; CR

        JSR     LFF6D
        BNE     LF8D2
LF87A   STA     $201

; CTRL-K

LF87D   JSR     LFF8C
        INC     $200
        INX
        CPX     $222
        BMI     LF8CF
        JSR     LFF70

; LF

LF88C   JSR     LFF8C
        LDY     #2
        JSR     LFBD2
        BCS     LF89E
        LDX     #3
        JSR     LFDEE
        JMP     LF8CF

LF89E   JSR     LFE28
        JSR     LFFD1
        JSR     LFDEE
        LDX     $222
LF8AA   JSR     $227
        BPL     LF8AA
        INX
        JSR     LFDEE
        LDX     #3
        JSR     LFDEE
        JSR     LFBCF
        BCC     LF8AA
        LDA     #' '
LF8BF   JSR     $22A
        BPL     LF8BF
        LDX     #1
LF8C6   LDA     $223,X
        STA     $228,X
        DEX
        BPL     LF8C6
LF8CF   JSR     LFF75
LF8D2   PLA
        TAY
        PLA
        TAX
        PLA
        RTS

; CTRL-Z

LF8D8   JSR     LFE59
        STA     $201
        BEQ     LF904

; CTRL-SHIFT-N

LF8E0   LDA     #' '
        JSR     LFF8F
        JSR     LFFD1
LF8E8   LDX     $222
        LDA     #' '
LF8ED   JSR     $22A
        BPL     LF8ED
        STA     $201
        LDY     #2
        JSR     LFBD2
        BCS     LF904
        LDX     #3
        JSR     LFDEE
        JMP     LF8E8

LF904   JSR     LFFD1
        STX     $200
        BEQ     LF8D2

LF90C   JSR     LF9A6
LF90F   JSR     LFBF5
        JSR     LFEB6
        JSR     LFBE6
        JSR     LFBE0
        LDX     #$10    ; # BYTES DISPLAYED
        STX     $FD
LF91F   JSR     LFBE6
        JSR     LFEF0
        JSR     LFBEB
        BCS     LF97B
        JSR     LFEF9
        DEC     $FD
        BNE     LF91F
        BEQ     LF90F

; 'M'   MOVE MEMORY

LF933   JSR     LFFBD
        JSR     LFDE4
        BCS     LF97E

; 'R'   RESTART FROM BREAKPOINT

LF93B   LDX     $E4
        TXS
        LDA     $E6
        PHA
        LDA     $E5
        PHA
        LDA     $E3
        PHA
        LDA     $E0
        LDX     $E1
        LDY     $E2
        RTI

; 'Z'   SET BREAKPOINT

LF94E   LDX     #3
LF950   LDA     LFA4C-1,X
        STA     IRQ-1,X
        DEX
        BNE     LF950
        JSR     LFE8D
        JSR     LF9B5
        LDA     ($FE),Y
        STA     $E7
        TYA
        STA     ($FE),Y
        BEQ     LF97E

; 'S'   SAVE

LF968   JMP     LFA7E

; 'L'   LOAD

LF96B   DEC     $FB
        BNE     LF9E8

; 'T'   TABULAR DISPLAY

LF96F   BEQ     LF90C
LF971   RTS

LF972   LDA     $FB
        BNE     LF971
        LDA     #'?'
        JSR     LFFEE

LF97B   LDX     #$28
        TXS
LF97E   JSR     LFBF5
        LDY     #0
        STY     $FB
        JSR     LFBE0

; '.'   COMMAND/ADDRESS MODE

LF988   JSR     LFE8D
        CMP     #'M'
        BEQ     LF933
        CMP     #'R'
        BEQ     LF93B
        CMP     #'Z'
        BEQ     LF94E
        CMP     #'S'
        BEQ     LF968
        CMP     #'L'
        BEQ     LF96B
        CMP     #'U'
        BNE     LF9D6
        JMP     ($233)

LF9A6   JSR     LFE8D
        JSR     LF9B5
        JSR     LFBE3
        LDX     #0
LF9B1   JSR     LFE8D
        .BYTE   $2C
LF9B5   LDX     #5
        JSR     LF9C0
        JSR     LFE8D
        .BYTE   $2C
LF9BE   LDX     #3
LF9C0   JSR     LF9C6
        JSR     LFE8D
LF9C6   CMP     #'.'
        BEQ     LF988
        CMP     #'/'
        BEQ     LF9E8
        JSR     LFE93
        BMI     LF972
        JMP     LFEDA

LF9D6   CMP     #'T'
        BEQ     LF96F
        JSR     LF9B5

LF9DD   LDA     #'/'
        JSR     LFFEE
        JSR     LFEF0
        JSR     LFBE6

; '/'   DATA MODE

LF9E8   JSR     LFE8D
        CMP     #'G'
        BNE     LF9F2
        JMP     ($FE)

LF9F2   CMP     #','
        BNE     LF9FC
        JSR     LFEF9
        JMP     LF9E8

LF9FC   CMP     #$A
        BEQ     LFA16
        CMP     #$D
        BEQ     LFA1B
        CMP     #'^'
        BEQ     LFA21
        CMP     #$27
        BEQ     LFA3A
        JSR     LF9BE
        LDA     $FC
        STA     ($FE),Y
LFA13   JMP     LF9E8

LFA16   LDA     #$D
        JSR     LFFEE

LFA1B   JSR     LFEF9
        JMP     LFA31

; '^'

LFA21   SEC
        LDA     $FE
        SBC     #1
        STA     $FE
        LDA     $FF
        SBC     #0
        STA     $FF
LFA2E   JSR     LFBF5

LFA31   JSR     LFEB6
        JMP     LF9DD

LFA37   JSR     LFEF7

; "'"

LFA3A   JSR     LFE8D
        CMP     #$27
        BNE     LFA46
        JSR     LFBE3
        BNE     LFA13
LFA46   CMP     #$D
        BEQ     LFA2E
        BNE     LFA37

LFA4C   JMP     LFA4F

LFA4F   STA     $E0
        PLA
        PHA
        AND     #$10
        BNE     LFA5A
        LDA     $E0
        RTI

; SAVE REGISTERS ON BREAK

LFA5A   STX     $E1
        STY     $E2
        PLA
        STA     $E3
        CLD
        SEC
        PLA
        SBC     #2
        STA     $E5
        PLA
        SBC     #0
        STA     $E6
        TSX
        STX     $E4 ; **BUG FIX** (ORIGINAL VALUE WAS $E1)
        LDY     #0
        LDA     $E7
        STA     ($E5),Y
        LDA     #$E0
        STA     $FE
        STY     $FF
        BNE     LFA2E

LFA7E   JSR     LFFBD
        JSR     LFFF7
        JSR     LFEE9
        JSR     LFFEE
        JSR     LFFE3
        LDA     #'/'
        JSR     LFFEE
        BNE     LFA97
LFA94   JSR     LFEF9

LFA97   JSR     LFEF0
        LDA     #$D
        JSR     LFCB1-OFFSET
        JSR     LFBEB
        BCC     LFA94
        LDA     $E4
        LDX     $E5
        STA     $FE
        STX     $FF
        JSR     LFFE3
        LDA     #'G'
        JSR     LFFEE
        JSR     LFFAC
        STY     $205
        JMP     LF97E

LFABD   TXA
        PHA
        TYA
        PHA
        LDA     $204
        BPL     LFB1F
LFAC6   LDY     $22F
        LDA     $231
        STA     $E4
        LDA     $231+1
        STA     $E5
        LDA     ($E4),Y
        STA     $230
        LDA     #$A1
        STA     ($E4),Y
        JSR     LFD00
        LDA     $230
        STA     ($E4),Y
        LDA     $215
        CMP     #$19            ; Ctl-Y =yank character to buffer
        BEQ     LFB13
        CMP     #2              ; Ctl-B = Backward
        BEQ     LFB0D
        CMP     #$6             ; Ctl-F = forward
        BEQ     LFB07
        CMP     #$13
        BEQ     LFB01
        CMP     #$E             ; Ctl-N (next line)
        BNE     LFB22

; CTRL-N (Next line)

        JSR     LFB7C
        JMP     LFAC6

; CTRL-S (Prev line)

LFB01   JSR     LFE28
        JMP     LFAC6

; CTRL-F (forward)

LFB07   JSR     LFB6B
        JMP     LFAC6

; CTRL-A (Backward)

LFB0D   JSR     LFE19
        JMP     LFAC6

; CTRL-Q (Yank/copy character)

LFB13   LDA     $230
        STA     $215
        JSR     LFB6B
        JMP     LFB43

LFB1F   JSR     LFD00

LFB22   CMP     #5
        BNE     LFB43
        LDA     $204
        EOR     #$FF
        STA     $204
        BPL     LFB1F
        LDA     $22B
        STA     $231
        LDA     $22B+1
        STA     $231+1
        LDX     #0
        STX     $22F
        BEQ     LFAC6
LFB43   JMP     LFDD3

; INPUT

LFB46   BIT     $203
        BPL     LFB68   ; LOAD FLAG CLR
LFB4B   LDA     #2
        STA     KEYBD
        LDA     #$10
        BIT     KEYBD
        BNE     LFB61   ; SPACE KEY PRESSED

; INPUT FROM ACIA

LFB57   LDA     ACIA
        LSR
        BCC     LFB4B
        LDA     ACIA+1
        RTS

LFB61   LDA     #0
        STA     $FB
        STA     $203
LFB68   JMP     LFABD

LFB6B   LDX     $222
        CPX     $22F
        BEQ     LFB77
        INC     $22F
        RTS

LFB77   LDX     #0
        STX     $22F
LFB7C   CLC
        LDA     $231
        ADC     #WIDTH ;$40
        STA     $231
        LDA     $231+1
        ADC     #0
        CMP     #>BOT ;$D8
        BNE     LFB90
        LDA     #>SCREEN
LFB90   STA     $231+1
LFB93   RTS

; CTRL-C CHECK

LFB94   LDA     $212
        BNE     LFB93   ; DISABLE FLAG SET
        LDA     #1
        STA     KEYBD
        BIT     KEYBD
        BVC     LFB93
        LDA     #4
        STA     KEYBD
        BIT     KEYBD
        BVC     LFB93
        LDA     #3      ; CTRL-C PRESSED
        JMP     LA636

LFBB2   .WORD   LFB46   ; 218 INPUT
        .WORD   LFF9B   ; 21A OUTPUT
        .WORD   LFB94   ; 21C CTRL-C
        .WORD   LFE70   ; 21E LOAD
        .WORD   LFE7B   ; 220 SAVE
        .BYTE   SWIDTH  ; 222
        .WORD   TOP     ; 223
        .WORD   BASE    ; 225
        LDA     TOP,X   ; 227
        STA     TOP,X   ; 22A
        DEX             ; 22D
        RTS             ; 22E
        .BYTE   $00     ; 22F
        .BYTE   $20     ; 230
        .WORD   TOP     ; 231
        .WORD   LF988   ; 233

LFBCF   LDX     $222
LFBD2   SEC
        LDA     $22B
        SBC     $223,Y
        LDA     $22B+1
        SBC     $223+1,Y
        RTS

LFBE0   LDA     #'>'
        .BYTE   $2C
LFBE3   LDA     #','
        .BYTE   $2C
LFBE6   LDA     #' '
        JMP     LFFEE

LFBEB   SEC
        LDA     $FE
        SBC     $F9
        LDA     $FF
        SBC     $FA
        RTS

; CRLF

LFBF5   LDA     #$D
        JSR     LFFEE
        LDA     #$A
        JMP     LFFEE

        .BYTE   $40

; FLOPPY DISK BOOTSTRAP
        *=$f400
LFC00   JSR     LFC0C-OFFSET
        JMP     ($FD)

        JSR     LFC0C-OFFSET
        JMP     LFE00

LFC0C   LDY     #0
        STY     DISK+1
        STY     DISK
        LDX     #4
        STX     DISK+1
        STY     DISK+3
        DEY
        STY     DISK+2
        STX     DISK+3
        STY     DISK+2
        LDA     #$FB
        BNE     LFC33

LFC2A   LDA     #2
        BIT     DISK
        BEQ     LFC4D
        LDA     #$FF
LFC33   STA     DISK+2
        JSR     LFCA5-OFFSET
        AND     #$F7
        STA     DISK+2
        JSR     LFCA5-OFFSET
        ORA     #8
        STA     DISK+2
        LDX     #$18
        JSR     LFC91-OFFSET
        BEQ     LFC2A
LFC4D   LDX     #$7F
        STX     DISK+2
        JSR     LFC91-OFFSET
LFC55   LDA     DISK
        BMI     LFC55
LFC5A   LDA     DISK
        BPL     LFC5A
        LDA     #3
        STA     DISK+$10
        LDA     #$58
        STA     DISK+$10
        JSR     LFC9C-OFFSET
        STA     $FE
        TAX
        JSR     LFC9C-OFFSET
        STA     $FD
        JSR     LFC9C-OFFSET
        STA     $FF
        LDY     #0
LFC7B   JSR     LFC9C-OFFSET
        STA     ($FD),Y
        INY
        BNE     LFC7B
        INC     $FE
        DEC     $FF
        BNE     LFC7B
        STX     $FE
        LDA     #$FF
        STA     DISK+2
        RTS

LFC91   LDY     #$F8
LFC93   DEY
        BNE     LFC93
        EOR     $FF,X
        DEX
        BNE     LFC91
        RTS

; INPUT CHAR FROM DISK

LFC9C   LDA     DISK+$10
        LSR
        BCC     LFC9C
        LDA     DISK+$11
LFCA5   RTS

; INIT ACIA

LFCA6   LDA     #3      ; RESET ACIA
        STA     ACIA
; (C1/C2) C2 initialize with $B1, C1 with $11
        LDA     #$B1    ; /16, 8BITS, 2STOP, RTS LOW, RX INT
;       LDA     #$11    ; /16, 8BITS, 2STOP, RTS LOW
        STA     ACIA
        RTS

; OUTPUT CHAR TO ACIA

LFCB1   PHA
LFCB2   LDA     ACIA
        LSR
        LSR
        BCC     LFCB2
        PLA
        STA     ACIA+1
        RTS

; SET KEYBOARD ROW (A)  1=R0, 2=R1, 4=R2 ETC

LFCBE   EOR     #$FF
        STA     KEYBD
        EOR     #$FF
        RTS

; READ KEYBOARD COL (X) 1=C0, 2=C1, 4=C2, 0=NONE

LFCC6   PHA
        JSR     LFCCF-OFFSET
        TAX
        PLA
        DEX
        INX
        RTS

LFCCF   LDA     KEYBD
        EOR     #$FF
        RTS

; UK101 BASIC ROM RUBOUT KEY HANDLER

LFCD5   CMP     #$5F    ; RUBOUT
        BEQ     LFCDC
        JMP     LA374

LFCDC   JMP     LA34B

; DELAY

LFCDF   LDY     #$10
LFCE1   LDX     #$40
LFCE3   DEX
        BNE     LFCE3
        DEY
        BNE     LFCE1
        RTS

;LFCEA  .BYTE   'CEGMON(C)1980 D/C/W/M?'
LFCEA   .BYTE   'Dave'
        .BYTE   $27
        .BYTE   's C2-4P  D/C/W/M?'

; POLLED KEYBOARD INPUT ROUTINE
        *=$FD00
LFD00   TXA
        PHA
        TYA
        PHA

LFD04   LDA     #$80    ; ROW 7
LFD06   STA     KEYBD   ; SET ROW
        LDX     KEYBD   ; READ COL
        BNE     LFD13   ; KEY PRESS

        LSR       ; NEXT ROW
        BNE     LFD06
        BEQ     LFD3A

LFD13   LSR
        BCC     LFD1F
        TXA
        AND     #$20
        BEQ     LFD3A
        LDA     #$1B
        BNE     LFD50

LFD1F   JSR     LFE86
        TYA
        STA     $215
        ASL
        ASL
        ASL
        SEC
        SBC     $215
        STA     $215
        TXA
        LSR
        ASL
        JSR     LFE86
        BEQ     LFD47
        LDA     #0
LFD3A   STA     $216
LFD3D   STA     $213
        LDA     #2
        STA     $214
        BNE     LFD04

LFD47   CLC
        TYA
        ADC     $215
        TAY
        LDA     LFF3C-1,Y

LFD50   CMP     $213
        BNE     LFD3D
        DEC     $214
        BEQ     LFD5F
        JSR     LFCDF-OFFSET
        BEQ     LFD04

LFD5F   LDX     #$64
        CMP     $216
        BNE     LFD68
        LDX     #$F
LFD68   STX     $214
        STA     $216
        CMP     #$21
        BMI     LFDD0

        CMP     #$5F
        BEQ     LFDD0

        LDA     #1
        STA     KEYBD
        LDA     KEYBD
        STA     $215
        AND     #1
        TAX
        LDA     $215
        AND     #6
        BNE     LFDA2
        BIT     $213
        BVC     LFDBB
        TXA
        EOR     #1
        AND     #1
        BEQ     LFDBB
        LDA     #$20
        BIT     $215
        BVC     LFDC3
        LDA     #$C0
        BNE     LFDC3

LFDA2   BIT     $213
        BVC     LFDAA
        TXA
        BEQ     LFDBB
LFDAA   LDY     $213
        CPY     #$31
        BCC     LFDB9
        CPY     #$3C
        BCS     LFDB9
        LDA     #$F0
        BNE     LFDBB

LFDB9   LDA     #$10
LFDBB   BIT     $215
        BVC     LFDC3
        CLC
        ADC     #$C0
LFDC3   CLC
        ADC     $213
        AND     #$7F
        BIT     $215
        BPL     LFDD0
        ORA     #$80
LFDD0   STA     $215
LFDD3   PLA
        TAY
        PLA
        TAX
        LDA     $215
        RTS

LFDDB   JSR     LFEF9
        INC     $E4
        BNE     LFDE4
        INC     $E5
LFDE4   LDA     ($FE),Y
        STA     ($E4),Y
        JSR     LFBEB
        BCC     LFDDB
        RTS

LFDEE   CLC
        LDA     #WIDTH ;$40
        ADC     $228,X
        STA     $228,X
        LDA     #0
        ADC     $228+1,X
        STA     $228+1,X
        RTS

; 65V MONITOR

LFE00   LDX     #$28
        TXS
        CLD
        JSR     LFCA6
        JSR     LFE40
        NOP
        NOP
        JSR     LFE59
        STA     $201
        STY     $FE
        STY     $FF
        JMP     LF97E

LFE19   LDX     $22F
        BEQ     LFE22
        DEC     $22F
        RTS

LFE22   LDX     $222
        STX     $22F
LFE28   SEC
        LDA     $231
        SBC     #WIDTH ;$40
        STA     $231
        LDA     $231+1
        SBC     #0
        CMP     #>SCREEN-1 ;$CF
        BNE     LFE3C
        LDA     #>BOT-1 ;$D7
LFE3C   STA     $231+1
        RTS

LFE40   LDY     #$1C    ; INIT 218-234
LFE42   LDA     LFBB2,Y
        STA     $218,Y
        DEY
        BPL     LFE42
        LDY     #7      ; ZERO 200-206, 212
        LDA     #0
        STA     $212    ; ENABLE CTRL-C FLAG
LFE52   STA     $200-1,Y
        DEY
        BNE     LFE52
        RTS

; CLEAR SCREEN

LFE59   LDY     #0
        STY     $F9
        LDA     #>SCREEN
        STA     $FA
        LDX     #SIZE+1*4 ;8
        LDA     #' '
LFE65   STA     ($F9),Y
        INY
        BNE     LFE65
        INC     $FA
        DEX
        BNE     LFE65
        RTS

; LOAD

LFE70   PHA
        DEC     $203    ; SET LOAD FLAG
        LDA     #0      ; CLR SAVE FLAG
LFE76   STA     $205
        PLA
        RTS

; SAVE

LFE7B   PHA
        LDA     #1      ; SET SAVE FLAG
        BNE     LFE76

; INPUT CHAR FROM ACIA

LFE80   JSR     LFB57
        AND     #$7F    ; CLEAR BIT 7
        RTS

LFE86   LDY     #8
LFE88   DEY
        ASL
        BCC     LFE88
        RTS

LFE8D   JSR     LFEE9
        JMP     LFFEE

; CONVERT ASCII-HEX CHAR TO BINARY

LFE93   CMP     #'0'
        BMI     LFEA9
        CMP     #'9'+1
        BMI     LFEA6
        CMP     #'A'
        BMI     LFEA9
        CMP     #'F'+1
        BPL     LFEA9
        SEC
        SBC     #7
LFEA6   AND     #$F
        RTS

LFEA9   LDA     #$80
        RTS

        JSR     LFEB6
        NOP
        NOP
        JSR     LFBE6
        BNE     LFEBD
LFEB6   LDX     #3
        JSR     LFEBF
        DEX
        .BYTE   $2C
LFEBD   LDX     #0

LFEBF   LDA     $FC,X
        LSR
        LSR
        LSR
        LSR
        JSR     LFECA
        LDA     $FC,X
LFECA   AND     #$F
        ORA     #'0'
        CMP     #'9'+1
        BMI     LFED5
        CLC
        ADC     #7
LFED5   JMP     LFFEE

        .BYTE   $EA,$EA

LFEDA   LDY     #4
        ASL
        ASL
        ASL
        ASL
LFEE0   ROL
        ROL     $F9,X
        ROL     $FA,X
        DEY
        BNE     LFEE0
        RTS

LFEE9   LDA     $FB
        BNE     LFE80
        JMP     LFD00

LFEF0   LDA     ($FE),Y
        STA     $FC
        JMP     LFEBD

LFEF7   STA     ($FE),Y
LFEF9   INC     $FE
        BNE     LFEFF
        INC     $FF
LFEFF   RTS

; POWER ON RESET

LFF00   CLD
        LDX     #$28
        TXS
        JSR     LFCA6-OFFSET
        JSR     LFE40
        JSR     LFE59
        STY     $200

LFF10   LDA     LFCEA-OFFSET,Y
        JSR     LFFEE
        INY
        CPY     #$16
        BNE     LFF10

        JSR     LFFEB
        AND     #$DF
        CMP     #'D'
        BNE     LFF27
        JMP     LFC00-OFFSET

LFF27   CMP     #'M'
        BNE     LFF2E
        JMP     LFE00

LFF2E   CMP     #'W'
        BNE     LFF35
        JMP     0

LFF35   CMP     #'C'
        BNE     LFF00
        JMP     LBD11

; KEYBOARD MATRIX

LFF3C   .BYTE   'P',';','/',$20,'Z','A','Q'
        .BYTE   ',','M','N','B','V','C','X'
        .BYTE   'K','J','H','G','F','D','S'
        .BYTE   'I','U','Y','T','R','E','W'
        .BYTE   $00,$00,$0D,$0A,'O','L','.'
        .BYTE   $00,$5F,'-',':','0','9','8'
        .BYTE   '7','6','5','4','3','2','1'

LFF6D   JSR     LFF8C

LFF70   LDX     #0
        STX     $200
LFF75   LDX     $200
        LDA     #$BD    ; LDA ABS,X
        STA     $22A
        JSR     $22A
        STA     $201
        LDA     #$9D    ; STA ABS,X
        STA     $22A
LFF88   LDA     #$5F
        BNE     LFF8F

LFF8C   LDA     $201
LFF8F   LDX     $200
        JMP     $22A

; OLD SCREEN

LFF95   JSR     LBF2D
        JMP     LFF9E

; OUTPUT

LFF9B   JSR     LF836
LFF9E   PHA
        LDA     $205
        BEQ     LFFBB   ; SAVE FLAG CLR
        PLA
        JSR     LFCB1-OFFSET    ; CHAR TO ACIA
        CMP     #$D
        BNE     LFFBC   ; NOT CR

; 10 NULLS

LFFAC   PHA
        TXA
        PHA
        LDX     #$A
        LDA     #0
LFFB3   JSR     LFCB1-OFFSET
        DEX
        BNE     LFFB3
        PLA
        TAX
LFFBB   PLA
LFFBC   RTS

LFFBD   JSR     LF9A6
        JSR     LFBE0
        LDX     #3
        JSR     LF9B1
        LDA     $FC
        LDX     $FD
        STA     $E4
        STX     $E5
        RTS

; SET DEFAULT WINDOW

LFFD1   LDX     #2
LFFD3   LDA     $223-1,X
        STA     $228-1,X
        STA     $22B-1,X
        DEX
        BNE     LFFD3
        RTS

LFFE0   .BYTE   <BASE           ; CURSOR START
LFFE1   .BYTE   SWIDTH          ; LINE LENGTH - 1
LFFE2   .BYTE   SIZE            ; SCREEN SIZE 0=1K 1=2K

LFFE3   LDA     #'.'
        JSR     LFFEE
        JMP     LFEB6

LFFEB   JMP     ($218)          ; INPUT  FB46
LFFEE   JMP     ($21A)          ; OUTPUT FF9B
LFFF1   JMP     ($21C)          ; CTRL-C FB94
LFFF4   JMP     ($21E)          ; LOAD   FE70
LFFF7   JMP     ($220)          ; SAVE   FE7B

        .WORD   NMI             ; NMI
        .WORD   LFF00           ; RESET
        .WORD   IRQ             ; IRQ

        .END
