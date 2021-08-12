;
; 6809 Disassembler
;
; Copyright (C) 2019 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;
; Revision History
; Version Date         Comments
; 0.0     29-Jan-2019  First version started, based on 6502 code.
; 0.1     03-Feb-2019  All instructions now supported.
;
; To Do:
; - Other TODOs in code
; - Add option to suppress data bytes in output (for feeding back into assembler)
; - Add option to show invalid opcodes as constants
; - Some unwanted spaces in output due to use of ASSIST09 routines

; Character defines

EOT     EQU     $04             ; String terminator
LF      EQU     $0A             ; Line feed
CR      EQU     $0D             ; Carriage return
SP      EQU     $20             ; Space

PAGELEN EQU     24              ; Number of instructions to show before waiting for keypress

; ASSIST09 SWI call numbers

INCHNP  EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH   EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1  EQU     2               ; OUTPUT STRING
PDATA   EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS  EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS  EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF   EQU     6               ; OUTPUT CR/LF
SPACE   EQU     7               ; OUTPUT A SPACE
MONITR  EQU     8               ; ENTER ASSIST09 MONITOR
VCTRSW  EQU     9               ; VECTOR EXAMINE/SWITCH
BRKPT   EQU     10              ; USER PROGRAM BREAKPOINT
PAUSE   EQU     11              ; TASK PAUSE FUNCTION

; Start address
        ORG     $1000
        BRA     MAIN            ; So start address stays constant

; Variables

ADDR    RMB     2               ; Current address to disassemble
OPCODE  RMB     1               ; Opcode of instruction
AM      RMB     1               ; Addressing mode of instruction
OPTYPE  RMB     1               ; Instruction type
POSTBYT RMB     1               ; Post byte (for indexed addressing)
LEN     RMB     1               ; Length of instruction
TEMP    RMB     2               ; Temp variable (used by print routines)
TEMP1   RMB     2               ; Temp variable
FIRST   RMB     1               ; Flag used to indicate first time an item printed
PAGE23  RMB     1               ; Flag indicating page2/3 instruction when non-zero

; Instructions. Matches indexes into entries in table MNEMONICS.

OP_INV   EQU    $00
OP_ABX   EQU    $01
OP_ADCA  EQU    $02
OP_ADCB  EQU    $03
OP_ADDA  EQU    $04
OP_ADDB  EQU    $05
OP_ADDD  EQU    $06
OP_ANDA  EQU    $07
OP_ANDB  EQU    $08
OP_ANDCC EQU    $09
OP_ASL   EQU    $0A
OP_ASLA  EQU    $0B
OP_ASLB  EQU    $0C
OP_ASR   EQU    $0D
OP_ASRA  EQU    $0E
OP_ASRB  EQU    $0F
OP_BCC   EQU    $10
OP_BCS   EQU    $11
OP_BEQ   EQU    $12
OP_BGE   EQU    $13
OP_BGT   EQU    $14
OP_BHI   EQU    $15
OP_BITA  EQU    $16
OP_BITB  EQU    $17
OP_BLE   EQU    $18
OP_BLS   EQU    $19
OP_BLT   EQU    $1A
OP_BMI   EQU    $1B
OP_BNE   EQU    $1C
OP_BPL   EQU    $1D
OP_BRA   EQU    $1E
OP_BRN   EQU    $1F
OP_BSR   EQU    $20
OP_BVC   EQU    $21
OP_BVS   EQU    $22
OP_CLR   EQU    $23
OP_CLRA  EQU    $24
OP_CLRB  EQU    $25
OP_CMPA  EQU    $26
OP_CMPB  EQU    $27
OP_CMPD  EQU    $28
OP_CMPS  EQU    $29
OP_CMPU  EQU    $2A
OP_CMPX  EQU    $2B
OP_CMPY  EQU    $2C
OP_COMA  EQU    $2D
OP_COMB  EQU    $2E
OP_COM   EQU    $2F
OP_CWAI  EQU    $30
OP_DAA   EQU    $31
OP_DEC   EQU    $32
OP_DECA  EQU    $33
OP_DECB  EQU    $34
OP_EORA  EQU    $35
OP_EORB  EQU    $36
OP_EXG   EQU    $37
OP_INC   EQU    $38
OP_INCA  EQU    $39
OP_INCB  EQU    $3A
OP_JMP   EQU    $3B
OP_JSR   EQU    $3C
OP_LBCC  EQU    $3D
OP_LBCS  EQU    $3E
OP_LBEQ  EQU    $3F
OP_LBGE  EQU    $40
OP_LBGT  EQU    $41
OP_LBHI  EQU    $42
OP_LBLE  EQU    $43
OP_LBLS  EQU    $44
OP_LBLT  EQU    $45
OP_LBMI  EQU    $46
OP_LBNE  EQU    $47
OP_LBPL  EQU    $48
OP_LBRA  EQU    $49
OP_LBRN  EQU    $4A
OP_LBSR  EQU    $4B
OP_LBVC  EQU    $4C
OP_LBVS  EQU    $4D
OP_LDA   EQU    $4E
OP_LDB   EQU    $4F
OP_LDD   EQU    $50
OP_LDS   EQU    $51
OP_LDU   EQU    $52
OP_LDX   EQU    $53
OP_LDY   EQU    $54
OP_LEAS  EQU    $55
OP_LEAU  EQU    $56
OP_LEAX  EQU    $57
OP_LEAY  EQU    $58
OP_LSR   EQU    $59
OP_LSRA  EQU    $5A
OP_LSRB  EQU    $5B
OP_MUL   EQU    $5C
OP_NEG   EQU    $5D
OP_NEGA  EQU    $5E
OP_NEGB  EQU    $5F
OP_NOP   EQU    $60
OP_ORA   EQU    $61
OP_ORB   EQU    $62
OP_ORCC  EQU    $63
OP_PSHS  EQU    $64
OP_PSHU  EQU    $65
OP_PULS  EQU    $66
OP_PULU  EQU    $67
OP_ROL   EQU    $68
OP_ROLA  EQU    $69
OP_ROLB  EQU    $6A
OP_ROR   EQU    $6B
OP_RORA  EQU    $6C
OP_RORB  EQU    $6D
OP_RTI   EQU    $6E
OP_RTS   EQU    $6F
OP_SBCA  EQU    $70
OP_SBCB  EQU    $71
OP_SEX   EQU    $72
OP_STA   EQU    $73
OP_STB   EQU    $74
OP_STD   EQU    $75
OP_STS   EQU    $76
OP_STU   EQU    $77
OP_STX   EQU    $78
OP_STY   EQU    $79
OP_SUBA  EQU    $7A
OP_SUBB  EQU    $7B
OP_SUBD  EQU    $7C
OP_SWI   EQU    $7D
OP_SWI2  EQU    $7E
OP_SWI3  EQU    $7F
OP_SYNC  EQU    $80
OP_TFR   EQU    $81
OP_TST   EQU    $82
OP_TSTA  EQU    $83
OP_TSTB  EQU    $84

; Addressing Modes. OPCODES table lists these for each instruction.
; LENGTHS lists the instruction length for each addressing mode.
; Need to distinguish relative modes that are 2 and 3 (long) bytes.
; Some immediate are 2 and some 3 bytes.
; Indexed modes can be longer depending on postbyte.
; Page 2 and 3 opcodes are one byte longer (prefixed by 10 or 11)

AM_INVALID      EQU     0       ; $01 (1)
AM_INHERENT     EQU     1       ; RTS (1)
AM_IMMEDIATE8   EQU     2       ; LDA #$12 (2)
AM_IMMEDIATE16  EQU     3       ; LDD #$1234 (3)
AM_DIRECT       EQU     4       ; LDA $12 (2)
AM_EXTENDED     EQU     5       ; LDA $1234 (3)
AM_RELATIVE8    EQU     6       ; BSR $1234 (2)
AM_RELATIVE16   EQU     7       ; LBSR $1234 (3)
AM_INDEXED      EQU     8       ; LDA 0,X (2+)

; *** CODE ***

; Main program. Disassembles a page at a time.

MAIN    LDX     #MAIN           ; Starting address for disassembly (this code)
        STX     ADDR            ; Store it
PAGE    LDA     #PAGELEN        ; Number of instructions to disassemble per page
DIS     PSHS    A               ; Save A
        LBSR    DISASM          ; Do disassembly of one instruction
        PULS    A               ; Restore A
        DECA                    ; Decrement count
        BNE     DIS             ; Go back and repeat until a page has been done
        LEAX    MSG2,PCR        ; Display message to press a key
        LBSR    PrintString
BADKEY  BSR     GetChar         ; Wait for keyboard input
        BSR     PrintCR
        CMPA    #SP             ; Space key pressed?
        BEQ     PAGE            ; If so, display next page
        CMPA    #'Q             ; Q key pressed?
        BEQ     RETN            ; If so, return
        CMPA    #'q             ; q key pressed?
        BEQ     RETN            ; If so, return
        BSR     PrintString     ; Bad key, prompt and try again
        BRA     BADKEY
RETN    RTS                     ; Return to caller

; *** Utility Functions ***
; Some of these call ASSIST09 ROM monitor routines.

; Print CR/LF to the console.
; Registers changed: none
PrintCR
        PSHS    A               ; Save A
        LDA     #CR
        BSR     PrintChar
        LDA     #LF
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print dollar sign to the console.
; Registers changed: none
PrintDollar
        PSHS    A               ; Save A
        LDA     #'$
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print comma to the console.
; Registers changed: none
PrintComma
        PSHS    A               ; Save A
        LDA     #',
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print left square bracket to the console.
; Registers changed: none
PrintLBracket
        PSHS    A               ; Save A
        LDA     #'[
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print right square bracket to the console.
; Registers changed: none
PrintRBracket
        PSHS    A               ; Save A
        LDA     #']
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print space sign to the console.
; Registers changed: none
PrintSpace
        SWI
        FCB     SPACE
        RTS

; Print two spaces to the console.
; Registers changed: none
Print2Spaces
        PSHS    A               ; Save A
        LDA     #SP
        BSR     PrintChar
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print several space characters.
; A contains number of spaces to print.
; Registers changed: none
PrintSpaces
        PSHS    A               ; Save registers used
PS1     CMPA    #0              ; Is count zero?
        BEQ     PS2             ; Is so, done
        BSR     PrintSpace      ; Print a space
        DECA                    ; Decrement count
        BRA     PS1             ; Check again
PS2     PULS    A               ; Restore registers used
        RTS

; Print character to the console
; A contains character to print.
; Registers changed: none
PrintChar
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUTCH           ; Service code byte
        RTS

; Get character from the console
; A contains character read. Blocks until key pressed. Character is
; echoed. Ignores NULL ($00) and RUBOUT ($7F). CR ($OD) is converted
; to LF ($0A).
; Registers changed: none (flags may change). Returns char in A.
GetChar
        SWI                     ; Call ASSIST09 monitor function
        FCB     INCHNP          ; Service code byte
        RTS

; Print a byte as two hex digits followed by a space.
; A contains byte to print.
; Registers changed: none
PrintByte
        PSHS    A,B,X           ; Save registers used
        STA     TEMP            ; Needs to be in memory so we can point to it
        LEAX    TEMP,PCR        ; Get pointer to it
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUT2HS          ; Service code byte
        PULS    X,B,A           ; Restore registers used
        RTS

; Print a word as four hex digits followed by a space.
; X contains word to print.
; Registers changed: none
PrintAddress
        PSHS    A,B,X           ; Save registers used
        STX     TEMP            ; Needs to be in memory so we can point to it
        LEAX    TEMP,PCR        ; Get pointer to it
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUT4HS          ; Service code byte
        PULS    X,B,A           ; Restore registers used
        RTS

; Print a string.
; X points to start of string to display.
; String must be terminated in EOT character.
; Registers changed: none
PrintString
        PSHS    X               ; Save registers used
        SWI                     ; Call ASSIST09 monitor function
        FCB     PDATA1          ; Service code byte
        PULS    X               ; Restore registers used
        RTS

; Disassemble instruction at address ADDR. On return, ADDR points to
; next instruction so it can be called again.

DISASM  CLR     PAGE23          ; Clear page2/3 flag
        LDX     ADDR,PCR        ; Get address of instruction
        LDB     ,X              ; Get instruction op code
        CMPB    #$10            ; Is it a page 2 16-bit opcode prefix with 10?
        BEQ     handle10        ; If so, do special handling
        CMPB    #$11            ; Is it a page 3 16-bit opcode prefix with 11?
        BEQ     handle11        ; If so, do special handling
        LBRA    not1011         ; If not, handle as normal case

handle10                        ; Handle page 2 instruction
        LDA     #1              ; Set page2/3 flag
        STA     PAGE23
        LDB     1,X             ; Get real opcode
        STB     OPCODE          ; Save it.
        LEAX    PAGE2,PCR       ; Pointer to start of table
        CLRA                    ; Set index into table to zero
search10
        CMPB    A,X             ; Check for match of opcode in table
        BEQ     found10         ; Branch if found
        ADDA    #3              ; Advance to next entry in table (entries are 3 bytes long)
        TST     A,X             ; Check entry
        BEQ     notfound10      ; If zero, then reached end of table
        BRA     search10        ; If not, keep looking

notfound10                      ; Instruction not found, so is invalid.
        LDA     #$10            ; Set opcode to 10
        STA     OPCODE
        LDA     #OP_INV         ; Set as instruction type invalid
        STA     OPTYPE
        LDA     #AM_INVALID     ; Set as addressing mode invalid
        STA     AM
        LDA     #1              ; Set length to one
        STA     LEN
        LBRA    dism            ; Disassemble as normal

found10                         ; Found entry in table
        ADDA    #1              ; Advance to instruction type entry in table
        LDB     A,X             ; Get instruction type
        STB     OPTYPE          ; Save it
        ADDA    #1              ; Advanced to address mode entry in table
        LDB     A,X             ; Get address mode
        STB     AM              ; Save it
        CLRA                    ; Clear MSB of D, addressing mode is now in A:B (D)
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LEN             ; Store it
        INC     LEN             ; Add one because it is a two byte op code
        BRA     dism            ; Continue normal disassembly processing.

handle11                        ; Same logic as above, but use table for page 3 opcodes.
        LDA     #1              ; Set page2/3 flag
        STA     PAGE23
        LDB     1,X             ; Get real opcode
        STB     OPCODE          ; Save it.
        LEAX    PAGE3,PCR       ; Pointer to start of table
        CLRA                    ; Set index into table to zero
search11
        CMPB    A,X             ; Check for match of opcode in table
        BEQ     found11         ; Branch if found
        ADDA    #3              ; Advance to next entry in table (entries are 3 bytes long)
        TST     A,X             ; Check entry
        BEQ     notfound11      ; If zero, then reached end of table
        BRA     search11        ; If not, keep looking

notfound11                      ; Instruction not found, so is invalid.
        LDA     #$11            ; Set opcode to 10
        STA     OPCODE
        LDA     #OP_INV         ; Set as instruction type invalid
        STA     OPTYPE
        LDA     #AM_INVALID     ; Set as addressing mode invalid
        STA     AM
        LDA     #1              ; Set length to one
        STA     LEN
        BRA     dism            ; Disassemble as normal

found11                         ; Found entry in table
        ADDA    #1              ; Advance to instruction type entry in table
        LDB     A,X             ; Get instruction type
        STB     OPTYPE          ; Save it
        ADDA    #1              ; Advanced to address mode entry in table
        LDB     A,X             ; Get address mode
        STB     AM              ; Save it
        CLRA                    ; Clear MSB of D, addressing mode is now in A:B (D)
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LEN             ; Store it
        INC     LEN             ; Add one because it is a two byte op code
        BRA     dism            ; Continue normal disassembly processing.

not1011
        STB     OPCODE          ; Save the op code
        CLRA                    ; Clear MSB of D
        TFR     D,X             ; Put op code in X
        LDB     OPCODES,X       ; Get opcode type from table
        STB     OPTYPE          ; Store it
        LDB     OPCODE          ; Get op code again
        TFR     D,X             ; Put opcode in X
        LDB     MODES,X         ; Get addressing mode type from table
        STB     AM              ; Store it
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LEN             ; Store it

; If addressing mode is indexed, get and save the indexed addressing
; post byte.

dism    LDA     AM              ; Get addressing mode
        CMPA    #AM_INDEXED     ; Is it indexed mode?
        BNE     NotIndexed      ; Branch if not
        LDX     ADDR,PCR        ; Get address of op code
                                ; If it is a page2/3 instruction, op code is the next byte after ADDR
        TST     PAGE23          ; Page2/3 instruction?
        BEQ     norm            ; Branch if not
        LDA     2,X             ; Post byte is two past ADDR
        BRA     getpb
norm    LDA     1,X             ; Get next byte (the post byte)
getpb   STA     POSTBYT         ; Save it

; Determine number of additional bytes for indexed addressing based on
; postbyte. If most significant bit is 0, there are no additional
; bytes and we can skip the rest of the check.

        BPL     NotIndexed      ; Branch of MSB is zero

; Else if most significant bit is 1, mask off all but low order 5 bits
; and look up length in table.

        ANDA    #%00011111      ; Mask off bits
        LEAX    POSTBYTES,PCR   ; Lookup table of lengths
        LDA     A,X             ; Get table entry
        ADDA    LEN             ; Add to instruction length
        STA     LEN             ; Save new length

NotIndexed

; Print address followed by a space
        LDX     ADDR,PCR
        LBSR    PrintAddress

; Print one more space

        LBSR    PrintSpace

; Print the op code bytes based on the instruction length

        LDB     LEN             ; Number of bytes in instruction
        LDX     ADDR,PCR        ; Pointer to start of instruction
opby    LDA     ,X+             ; Get instruction byte and increment pointer
        LBSR    PrintByte       ; Print it, followed by a space
        DECB                    ; Decrement byte count
        BNE     opby            ; Repeat until done

; Print needed remaining spaces to pad out to correct column

        LEAX    PADDING,PCR     ; Pointer to start of lookup table
        LDA     LEN             ; Number of bytes in instruction
        DECA                    ; Subtract 1 since table starts at 1, not 0
        LDA     A,X             ; Get number of spaces to print
        LBSR    PrintSpaces

; If a page2/3 instruction, advance ADDR to the next byte which points
; to the real op code.

        TST     PAGE23          ; Flag set
        BEQ     noinc           ; Branch if not
        LDD     ADDR            ; Increment 16-bit address
        ADDD    #1
        STD     ADDR

; Get and print mnemonic (4 chars)

noinc   LDB     OPTYPE          ; Get instruction type to index into table
        CLRA                    ; Clear MSB of D
        ASLB                    ; 16-bit shift of D: Rotate B, MSB into Carry
        ROLA                    ; Rotate A, Carry into LSB
        ASLB                    ; Do it twice to multiple by four
        ROLA                    ;
        LEAX    MNEMONICS,PCR   ; Pointer to start of table
        STA     TEMP1           ; Save value of A
        LDA     D,X             ; Get first char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get second char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get third char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get fourth char of mnemonic
        LBSR    PrintChar       ; Print it

; Display any operands based on addressing mode and call appropriate
; routine. TODO: Could use a lookup table for this.

        LDA     AM              ; Get addressing mode
        CMPA    #AM_INVALID
        BEQ     DO_INVALID
        CMPA    #AM_INHERENT
        BEQ     DO_INHERENT
        CMPA    #AM_IMMEDIATE8
        BEQ     DO_IMMEDIATE8
        CMPA    #AM_IMMEDIATE16
        LBEQ    DO_IMMEDIATE16
        CMPA    #AM_DIRECT
        LBEQ    DO_DIRECT
        CMPA    #AM_EXTENDED
        LBEQ    DO_EXTENDED
        CMPA    #AM_RELATIVE8
        LBEQ    DO_RELATIVE8
        CMPA    #AM_RELATIVE16
        LBEQ    DO_RELATIVE16
        CMPA    #AM_INDEXED
        LBEQ    DO_INDEXED
        BRA     DO_INVALID      ; Should never be reached

DO_INVALID                      ; Display "   ; INVALID"
        LDA     #15             ; Want 15 spaces
        LBSR    PrintSpaces
        LEAX    MSG1,PCR
        LBSR    PrintString
        LBRA    done

DO_INHERENT                    ; Nothing else to do
        LBRA    done

DO_IMMEDIATE8
        LDA     OPTYPE          ; Get opcode type
        CMPA    #OP_TFR         ; Is is TFR?
        BEQ     XFREXG          ; Handle special case of TFR
        CMPA    #OP_EXG         ; Is is EXG?
        BEQ     XFREXG          ; Handle special case of EXG

        CMPA    #OP_PULS        ; Is is PULS?
        LBEQ    PULPSH
        CMPA    #OP_PULU        ; Is is PULU?
        LBEQ    PULPSH
        CMPA    #OP_PSHS        ; Is is PSHS?
        LBEQ    PULPSH
        CMPA    #OP_PSHU        ; Is is PSHU?
        LBEQ    PULPSH
                                ; Display "  #$nn"
        LBSR    Print2Spaces    ; Two spaces
        LDA     #'#             ; Number sign
        LBSR    PrintChar
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (immediate data)
        LBSR    PrintByte       ; Print as hex value
        LBRA    done

XFREXG                          ; Handle special case of TFR and EXG
                                ; Display "  r1,r2"
        LBSR    Print2Spaces    ; Two spaces
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (postbyte)
        ANDA    #%11110000      ; Mask out source register bits
        LSRA                    ; Shift into low order bits
        LSRA
        LSRA
        LSRA
        BSR     TFREXGRegister  ; Print source register name
        LDA     #',             ; Print comma
        LBSR    PrintChar
        LDA     1,X             ; Get postbyte again
        ANDA    #%00001111      ; Mask out destination register bits
        BSR     TFREXGRegister  ; Print destination register name
        LBRA    done

; Look up register name (in A) from Transfer/Exchange postbyte. 4 LSB
; bits determine the register name. Value is printed. Invalid value
; is shown as '?'.
; Value:    0 1 2 3 4 5  8 9 10 11
; Register: D X Y U S PC A B CC DP

TFREXGRegister
        CMPA    #0
        BNE     Try1
        LDA     #'D
        BRA     Print1Reg
Try1    CMPA    #1
        BNE     Try2
        LDA     #'X
        BRA     Print1Reg
Try2    CMPA    #2
        BNE     Try3
        LDA     #'Y
        BRA     Print1Reg
Try3    CMPA    #3
        BNE     Try4
        LDA     #'U
        BRA     Print1Reg
Try4    CMPA    #4
        BNE     Try5
        LDA     #'S
        BRA     Print1Reg
Try5    CMPA    #5
        BNE     Try8
        LDA     #'P
        LDB     #'C
        BRA     Print2Reg
Try8    CMPA    #8
        BNE     Try9
        LDA     #'A
        BRA     Print1Reg
Try9    CMPA    #9
        BNE     Try10
        LDA     #'B
        BRA     Print1Reg
Try10   CMPA    #10
        BNE     Try11
        LDA     #'C
        LDB     #'C
        BRA     Print2Reg
Try11   CMPA    #11
        BNE     Inv
        LDA     #'D
        LDB     #'P
        BRA     Print2Reg
Inv     LDA     #'?             ; Invalid
                                ; Fall through
Print1Reg
        LBSR   PrintChar        ; Print character
        RTS
Print2Reg
        LBSR   PrintChar        ; Print first character
        TFR    B,A
        LBSR   PrintChar        ; Print second character
        RTS

; Handle PSHS/PSHU/PULS/PULU instruction operands
; Format is a register list, eg; "  A,B,X"

PULPSH
        LBSR    Print2Spaces    ; Two spaces
        LDA     #1
        STA     FIRST           ; Flag set before any items printed
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (postbyte)

; Postbyte bits indicate registers to push/pull when 1.
; 7  6   5 4 3  2 1 0
; PC S/U Y X DP B A CC

; TODO: Could simplify this with shifting and lookup table.

        BITA    #%10000000      ; Bit 7 set?
        BEQ     bit6
        PSHS    A,B
        LDA     #'P
        LDB     #'C
        BSR     Print2Reg       ; Print PC
        CLR     FIRST
        PULS    A,B
bit6    BITA    #%01000000      ; Bit 6 set?
        BEQ     bit5

; Need to show S or U depending on instruction

        PSHS    A               ; Save postbyte
        LDA     OPTYPE          ; Get opcode type
        CMPA    #OP_PULS
        BEQ     printu
        CMPA    #OP_PSHS
        BEQ     printu
        LBSR    PrintCommaIfNotFirst
        LDA     #'S             ; Print S
pr1     BSR     Print1Reg
        CLR     FIRST
        PULS    A
        bra     bit5
printu  BSR     PrintCommaIfNotFirst
        LDA     #'U             ; Print U
        bra     pr1
bit5    BITA    #%00100000      ; Bit 5 set?
        BEQ     bit4
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'Y
        BSR     Print1Reg       ; Print Y
        CLR     FIRST
        PULS    A
bit4    BITA    #%00010000      ; Bit 4 set?
        BEQ     bit3
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'X
        BSR     Print1Reg       ; Print X
        CLR     FIRST
        PULS    A
bit3    BITA    #%00001000      ; Bit 3 set?
        BEQ     bit2
        PSHS    A,B
        BSR     PrintCommaIfNotFirst
        LDA     #'D
        LDB     #'P
        BSR     Print2Reg       ; Print DP
        CLR     FIRST
        PULS    A,B
bit2    BITA    #%00000100      ; Bit 2 set?
        BEQ     bit1
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'B
        LBSR    Print1Reg       ; Print B
        CLR     FIRST
        PULS    A
bit1    BITA    #%00000010      ; Bit 1 set?
        BEQ     bit0
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'A
        LBSR    Print1Reg       ; Print A
        CLR     FIRST
        PULS    A
bit0    BITA    #%00000001      ; Bit 0 set?
        BEQ     done1
        PSHS    A,B
        BSR     PrintCommaIfNotFirst
        LDA     #'C
        LDB     #'C
        LBSR    Print2Reg       ; Print CC
        CLR     FIRST
        PULS    A,B
done1   LBRA    done

; Print comma if FIRST flag is not set.
PrintCommaIfNotFirst
        TST     FIRST
        BNE     ret1
        LDA     #',
        LBSR    PrintChar
ret1    RTS

DO_IMMEDIATE16                  ; Display "  #$nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LDA     #'#             ; Number sign
        LBSR    PrintChar
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get first byte (immediate data MSB)
        LDB     2,X             ; Get second byte (immediate data LSB)
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_DIRECT                       ; Display "  $nn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (byte data)
        LBSR    PrintByte       ; Print as hex value
        LBRA    done

DO_EXTENDED                     ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADDR,PCR        ; Get address of op code
        LDA     1,X             ; Get first byte (address MSB)
        LDB     2,X             ; Get second byte (address LSB)
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_RELATIVE8                    ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign

; Destination address for relative branch is address of opcode + (sign
; extended)offset + 2, e.g.
;   $1015 + $(FF)FC + 2 = $1013
;   $101B + $(00)27 + 2 = $1044

        LDX     ADDR,PCR        ; Get address of op code
        LDB     1,X             ; Get first byte (8-bit branch offset)
        SEX                     ; Sign extend to 16 bits
        ADDD    ADDR            ; Add address of op code
        ADDD    #2              ; Add 2
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_RELATIVE16                   ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign

; Destination address calculation is similar to above, except offset
; is 16 bits and need to add 3.

        LDX     ADDR,PCR        ; Get address of op code
        LDD     1,X             ; Get next 2 bytes (16-bit branch offset)
        ADDD    ADDR            ; Add address of op code
        ADDD    #3              ; Add 3
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_INDEXED
        LBSR    Print2Spaces    ; Two spaces

; Addressing modes are determined by the postbyte:
;
; Postbyte  Format  Additional Bytes
; --------  ------  ----------------
; 0RRnnnnn  n,R     0
; 1RR00100  ,R      0
; 1RR01000  n,R     1
; 1RR01001  n,R     2
; 1RR00110  A,R     0
; 1RR00101  B,R     0
; 1RR01011  D,R     0
; 1RR00000  ,R+     0
; 1RR00001  ,R++    0
; 1RR00010  ,-R     0
; 1RR00011  ,--R    0
; 1xx01100  n,PCR   1
; 1xx01101  n,PCR   2
; 1RR10100  [,R]    0
; 1RR11000  [n,R]   1
; 1RR11001  [n,R]   2
; 1RR10110  [A,R]   0
; 1RR10101  [B,R]   0
; 1RR11011  [D,R]   0
; 1RR10001  [,R++]  0
; 1RR10011  [,--R]  0
; 1xx11100  [n,PCR] 1
; 1xx11101  [n,PCR] 2
; 10011111  [n]     2
;
; Where RR: 00=X 01=Y 10=U 11=S

        LDA     POSTBYT         ; Get postbyte
        BMI     ind2            ; Branch if MSB is 1

                                ; Format is 0RRnnnnn  n,R
        ANDA    #%00011111      ; Get 5-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Print offset
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind2
        ANDA    #%10011111      ; Mask out register bits
        CMPA    #%10000100      ; Check against pattern
        BNE     ind3
                                ; Format is 1RR00100  ,R
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind3
        CMPA    #%10001000      ; Check against pattern
        BNE     ind4
                                ; Format is 1RR01000  n,R
        LDX     ADDR,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind4
        CMPA    #%10001001      ; Check against pattern
        BNE     ind5
                                ; Format is 1RR01001  n,R
        LDX     ADDR,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind5
        CMPA    #%10000110      ; Check against pattern
        BNE     ind6
                                ; Format is 1RR00110  A,R
        LDA     #'A
        LBSR    PrintChar       ; Print A
commar  LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind6
        CMPA    #%10000101      ; Check against pattern
        BNE     ind7
                                ; Format is 1RR00101  B,R
        LDA     #'B
        LBSR    PrintChar
        BRA     commar
ind7
        CMPA    #%10001011      ; Check against pattern
        BNE     ind8
                                ; Format is 1RR01011  D,R
        LDA     #'D
        LBSR    PrintChar
        BRA     commar
ind8
        CMPA    #%10000000      ; Check against pattern
        BNE     ind9
                                ; Format is 1RR00000  ,R+
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus
        LBSR    PrintChar
        LBRA    done
ind9
        CMPA    #%10000001      ; Check against pattern
        BNE     ind10
                                ; Format is 1RR00001  ,R++
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LBRA    done
ind10
        CMPA    #%10000010      ; Check against pattern
        BNE     ind11
                                ; Format is 1RR00010  ,-R
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind11
        CMPA    #%10000011      ; Check against pattern
        BNE     ind12
                                ; Format is 1RR00011  ,--R
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind12
        CMPA    #%10001100      ; Check against pattern
        BNE     ind13
                                ; Format is 1xx01100  n,PCR
        LDX     ADDR,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBRA    done
ind13
        CMPA    #%10001101      ; Check against pattern
        BNE     ind14
                                ; Format is 1xx01101  n,PCR
        LDX     ADDR,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBRA    done
ind14
        CMPA    #%10010100      ; Check against pattern
        BNE     ind15
                                ; Format is 1RR10100  [,R]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind15
        CMPA    #%10011000      ; Check against pattern
        BNE     ind16
                                ; Format is 1RR11000  [n,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADDR,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind16
        CMPA    #%10011001      ; Check against pattern
        BNE     ind17
                                ; Format is 1RR11001  [n,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADDR,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind17
        CMPA    #%10010110      ; Check against pattern
        BNE     ind18
                                ; Format is 1RR10110  [A,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'A
        LBSR    PrintChar       ; Print A
comrb   LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind18
        CMPA    #%10010101      ; Check against pattern
        BNE     ind19
                                ; Format is 1RR10101  [B,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'B
        LBSR    PrintChar
        BRA     comrb
ind19
        CMPA    #%10011011      ; Check against pattern
        BNE     ind20
                                ; Format is 1RR11011  [D,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'D
        LBSR    PrintChar
        BRA     comrb
ind20
        CMPA    #%10010001      ; Check against pattern
        BNE     ind21
                                ; Format is 1RR10001  [,R++]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind21
        CMPA    #%10010011      ; Check against pattern
        BNE     ind22
                                ; Format is 1RR10011  [,--R]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        BSR     PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        BRA     done
ind22
        CMPA    #%10011100      ; Check against pattern
        BNE     ind23
                                ; Format is 1xx11100  [n,PCR]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADDR,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        BSR     PrintPCR        ; Print PCR
        LBSR    PrintRBracket   ; Print right bracket
        BRA     done
ind23
        CMPA    #%10011101      ; Check against pattern
        BNE     ind24
                                ; Format is 1xx11101  [n,PCR]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADDR,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        BSR     PrintPCR        ; Print PCR
        LBSR    PrintRBracket   ; Print right bracket
        BRA     done
ind24
        CMPA    #%10011111      ; Check against pattern
        BNE     ind25
                                ; Format is 1xx11111  [n]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADDR,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintRBracket   ; Print right bracket
        BRA     done
ind25                           ; Should never be reached
        BRA     done

; Print register name encoded in bits 5 and 6 of A for indexed
; addressing: xRRxxxxx where RR: 00=X 01=Y 10=U 11=S
; Registers changed: X
PrintRegister
        PSHS    A               ; Save A
        ANDA    #%01100000      ; Mask out other bits
        LSRA                    ; Shift into 2 LSB
        LSRA
        LSRA
        LSRA
        LSRA
        LEAX    <REGTABLE,PCR   ; Lookup table of register name characters
        LDA     A,X             ; Get character
        LBSR    PrintChar       ; Print it
        PULS    A               ; Restore A
        RTS                     ; Return
REGTABLE
        FCC     "XYUS"

; Print the string "PCR" on the console.
; Registers changed: X
PrintPCR
        LEAX    MSG3,PCR        ; "PCR" string
        LBSR    PrintString
        RTS

; Print final CR

done    LBSR    PrintCR

; Update address to next instruction
; If it was a page 2/3 instruction, we need to subtract one from the
; length to account for ADDR being moved to the second byte of the
; instruction.

        TST     PAGE23          ; Flag set
        BEQ     not23           ; Branch if not
        DEC     LEN             ; Decrement length
not23   CLRA                    ; Clear MSB of D
        LDB     LEN             ; Get length byte in LSB of D
        ADDD    ADDR            ; Add to address
        STD     ADDR            ; Write new address

; Return
        RTS

; *** DATA

; Table of instruction strings. 4 bytes per table entry
MNEMONICS
        FCC     "??? "          ; $00
        FCC     "ABX "          ; $01
        FCC     "ADCA"          ; $02
        FCC     "ADCB"          ; $03
        FCC     "ADDA"          ; $04
        FCC     "ADDB"          ; $05
        FCC     "ADDD"          ; $06
        FCC     "ANDA"          ; $07
        FCC     "ANDB"          ; $08
        FCC     "ANDC"          ; $09 Should really  be "ANDCC"
        FCC     "ASL "          ; $0A
        FCC     "ASLA"          ; $0B
        FCC     "ASLB"          ; $0C
        FCC     "ASR "          ; $0D
        FCC     "ASRA"          ; $0E
        FCC     "ASRB"          ; $0F
        FCC     "BCC "          ; $10
        FCC     "BCS "          ; $11
        FCC     "BEQ "          ; $12
        FCC     "BGE "          ; $13
        FCC     "BGT "          ; $14
        FCC     "BHI "          ; $15
        FCC     "BITA"          ; $16
        FCC     "BITB"          ; $17
        FCC     "BLE "          ; $18
        FCC     "BLS "          ; $19
        FCC     "BLT "          ; $1A
        FCC     "BMI "          ; $1B
        FCC     "BNE "          ; $1C
        FCC     "BPL "          ; $1D
        FCC     "BRA "          ; $1E
        FCC     "BRN "          ; $1F
        FCC     "BSR "          ; $20
        FCC     "BVC "          ; $21
        FCC     "BVS "          ; $22
        FCC     "CLR "          ; $23
        FCC     "CLRA"          ; $24
        FCC     "CLRB"          ; $25
        FCC     "CMPA"          ; $26
        FCC     "CMPB"          ; $27
        FCC     "CMPD"          ; $28
        FCC     "CMPS"          ; $29
        FCC     "CMPU"          ; $2A
        FCC     "CMPX"          ; $2B
        FCC     "CMPY"          ; $2C
        FCC     "COMA"          ; $2D
        FCC     "COMB"          ; $2E
        FCC     "COM "          ; $2F
        FCC     "CWAI"          ; $30
        FCC     "DAA "          ; $31
        FCC     "DEC "          ; $32
        FCC     "DECA"          ; $33
        FCC     "DECB"          ; $34
        FCC     "EORA"          ; $35
        FCC     "EORB"          ; $36
        FCC     "EXG "          ; $37
        FCC     "INC "          ; $38
        FCC     "INCA"          ; $39
        FCC     "INCB"          ; $3A
        FCC     "JMP "          ; $3B
        FCC     "JSR "          ; $3C
        FCC     "LBCC"          ; $3D
        FCC     "LBCS"          ; $3E
        FCC     "LBEQ"          ; $3F
        FCC     "LBGE"          ; $40
        FCC     "LBGT"          ; $41
        FCC     "LBHI"          ; $42
        FCC     "LBLE"          ; $43
        FCC     "LBLS"          ; $44
        FCC     "LBLT"          ; $45
        FCC     "LBMI"          ; $46
        FCC     "LBNE"          ; $47
        FCC     "LBPL"          ; $48
        FCC     "LBRA"          ; $49
        FCC     "LBRN"          ; $4A
        FCC     "LBSR"          ; $4B
        FCC     "LBVC"          ; $4C
        FCC     "LBVS"          ; $4D
        FCC     "LDA "          ; $4E
        FCC     "LDB "          ; $4F
        FCC     "LDD "          ; $50
        FCC     "LDS "          ; $51
        FCC     "LDU "          ; $52
        FCC     "LDX "          ; $53
        FCC     "LDY "          ; $54
        FCC     "LEAS"          ; $55
        FCC     "LEAU"          ; $56
        FCC     "LEAX"          ; $57
        FCC     "LEAY"          ; $58
        FCC     "LSR "          ; $59
        FCC     "LSRA"          ; $5A
        FCC     "LSRB"          ; $5B
        FCC     "MUL "          ; $5C
        FCC     "NEG "          ; $5D
        FCC     "NEGA"          ; $5E
        FCC     "NEGB"          ; $5F
        FCC     "NOP "          ; $60
        FCC     "ORA "          ; $61
        FCC     "ORB "          ; $62
        FCC     "ORCC"          ; $63
        FCC     "PSHS"          ; $64
        FCC     "PSHU"          ; $65
        FCC     "PULS"          ; $66
        FCC     "PULU"          ; $67
        FCC     "ROL "          ; $68
        FCC     "ROLA"          ; $69
        FCC     "ROLB"          ; $6A
        FCC     "ROR "          ; $6B
        FCC     "RORA"          ; $6C
        FCC     "RORB"          ; $6D
        FCC     "RTI "          ; $6E
        FCC     "RTS "          ; $6F
        FCC     "SBCA"          ; $70
        FCC     "SBCB"          ; $71
        FCC     "SEX "          ; $72
        FCC     "STA "          ; $73
        FCC     "STB "          ; $74
        FCC     "STD "          ; $75
        FCC     "STS "          ; $76
        FCC     "STU "          ; $77
        FCC     "STX "          ; $78
        FCC     "STY "          ; $79
        FCC     "SUBA"          ; $7A
        FCC     "SUBB"          ; $7B
        FCC     "SUBD"          ; $7C
        FCC     "SWI "          ; $7D
        FCC     "SWI2"          ; $7E
        FCC     "SWI3"          ; $7F
        FCC     "SYNC"          ; $80
        FCC     "TFR "          ; $81
        FCC     "TST "          ; $82
        FCC     "TSTA"          ; $83
        FCC     "TSTB"          ; $84

; Lengths of instructions given an addressing mode. Matches values of
; AM_* Indexed addessing instructions length can increase due to post
; byte.
LENGTHS
        FCB     1               ; 0 AM_INVALID
        FCB     1               ; 1 AM_INHERENT
        FCB     2               ; 2 AM_IMMEDIATE8
        FCB     3               ; 3 AM_IMMEDIATE16
        FCB     2               ; 4 AM_DIRECT
        FCB     3               ; 5 AM_EXTENDED
        FCB     2               ; 6 AM_RELATIVE8
        FCB     3               ; 7 AM_RELATIVE16
        FCB     2               ; 8 AM_INDEXED

; Lookup table to return needed remaining spaces to print to pad out
; instruction to correct column in disassembly.
; # bytes: 1 2 3 4
; Padding: 9 6 3 0
PADDING
        FCB     10,7,4,1

; Lookup table to return number of additional bytes for indexed
; addressing based on low order 5 bits of postbyte. Based on
; detailed list of values below.

POSTBYTES
        FCB     0,0,0,0,0,0,0,0
        FCB     1,2,0,0,1,2,0,0
        FCB     0,0,0,0,0,0,0,0
        FCB     1,2,0,0,1,2,0,2

; Pattern:  # Extra bytes:
; --------  --------------
; 0XXXXXXX   0
; 1XX00000   0
; 1XX00001   0
; 1XX00010   0
; 1XX00011   0
; 1XX00100   0
; 1X000101   0
; 1XX00110   0
; 1XX00111   0 (INVALID)
; 1XX01000   1
; 1XX01001   2
; 1XX01010   0 (INVALID)
; 1XX01011   0
; 1XX01100   1
; 1XX01101   2
; 1XX01110   0 (INVALID)
; 1XX01111   0 (INVALID)
; 1XX10000   0 (INVALID)
; 1XX10001   0
; 1XX10010   0 (INVALID)
; 1XX10011   0
; 1XX10100   0
; 1XX10101   0
; 1XX10110   0
; 1XX10111   0 (INVALID)
; 1XX11000   1
; 1XX11001   2
; 1XX11010   0 (INVALID)
; 1XX11011   0
; 1XX11100   1
; 1XX11101   2
; 1XX11110   0 (INVALID)
; 1XX11111   2

; Opcodes. Listed in order indexed by op code. Defines the mnemonic.
OPCODES
        FCB     OP_NEG          ; 00
        FCB     OP_INV          ; 01
        FCB     OP_INV          ; 02
        FCB     OP_COMB         ; 03
        FCB     OP_LSR          ; 04
        FCB     OP_INV          ; 05
        FCB     OP_ROR          ; 06
        FCB     OP_ASR          ; 07
        FCB     OP_ASL          ; 08
        FCB     OP_ROL          ; 09
        FCB     OP_DEC          ; 0A
        FCB     OP_INV          ; 0B
        FCB     OP_INC          ; 0C
        FCB     OP_TST          ; 0D
        FCB     OP_JMP          ; 0E
        FCB     OP_CLR          ; 0F

        FCB     OP_INV          ; 10 Page 2 extended opcodes (see other table)
        FCB     OP_INV          ; 11 Page 3 extended opcodes (see other table)
        FCB     OP_NOP          ; 12
        FCB     OP_SYNC         ; 13
        FCB     OP_INV          ; 14
        FCB     OP_INV          ; 15
        FCB     OP_LBRA         ; 16
        FCB     OP_LBSR         ; 17
        FCB     OP_INV          ; 18
        FCB     OP_DAA          ; 19
        FCB     OP_ORCC         ; 1A
        FCB     OP_INV          ; 1B
        FCB     OP_ANDCC        ; 1C
        FCB     OP_SEX          ; 1D
        FCB     OP_EXG          ; 1E
        FCB     OP_TFR          ; 1F

        FCB     OP_BRA          ; 20
        FCB     OP_BRN          ; 21
        FCB     OP_BHI          ; 22
        FCB     OP_BLS          ; 23
        FCB     OP_BCC          ; 24
        FCB     OP_BCS          ; 25
        FCB     OP_BNE          ; 26
        FCB     OP_BEQ          ; 27
        FCB     OP_BVC          ; 28
        FCB     OP_BVS          ; 29
        FCB     OP_BPL          ; 2A
        FCB     OP_BMI          ; 2B
        FCB     OP_BGE          ; 2C
        FCB     OP_BLT          ; 2D
        FCB     OP_BGT          ; 2E
        FCB     OP_BLE          ; 2F

        FCB     OP_LEAX         ; 30
        FCB     OP_LEAY         ; 31
        FCB     OP_LEAS         ; 32
        FCB     OP_LEAU         ; 33
        FCB     OP_PSHS         ; 34
        FCB     OP_PULS         ; 35
        FCB     OP_PSHU         ; 36
        FCB     OP_PULU         ; 37
        FCB     OP_INV          ; 38
        FCB     OP_RTS          ; 39
        FCB     OP_ABX          ; 3A
        FCB     OP_RTI          ; 3B
        FCB     OP_CWAI         ; 3C
        FCB     OP_MUL          ; 3D
        FCB     OP_INV          ; 3E
        FCB     OP_SWI          ; 3F

        FCB     OP_NEGA         ; 40
        FCB     OP_INV          ; 41
        FCB     OP_INV          ; 42
        FCB     OP_COMA         ; 43
        FCB     OP_LSRA         ; 44
        FCB     OP_INV          ; 45
        FCB     OP_RORA         ; 46
        FCB     OP_ASRA         ; 47
        FCB     OP_ASLA         ; 48
        FCB     OP_ROLA         ; 49
        FCB     OP_DECA         ; 4A
        FCB     OP_INV          ; 4B
        FCB     OP_INCA         ; 4C
        FCB     OP_TSTA         ; 4D
        FCB     OP_INV          ; 4E
        FCB     OP_CLRA         ; 4F

        FCB     OP_NEGB         ; 50
        FCB     OP_INV          ; 51
        FCB     OP_INV          ; 52
        FCB     OP_COMB         ; 53
        FCB     OP_LSRB         ; 54
        FCB     OP_INV          ; 55
        FCB     OP_RORB         ; 56
        FCB     OP_ASRB         ; 57
        FCB     OP_ASLB         ; 58
        FCB     OP_ROLB         ; 59
        FCB     OP_DECB         ; 5A
        FCB     OP_INV          ; 5B
        FCB     OP_INCB         ; 5C
        FCB     OP_TSTB         ; 5D
        FCB     OP_INV          ; 5E
        FCB     OP_CLRB         ; 5F

        FCB     OP_NEG          ; 60
        FCB     OP_INV          ; 61
        FCB     OP_INV          ; 62
        FCB     OP_COM          ; 63
        FCB     OP_LSR          ; 64
        FCB     OP_INV          ; 65
        FCB     OP_ROR          ; 66
        FCB     OP_ASR          ; 67
        FCB     OP_ASL          ; 68
        FCB     OP_ROL          ; 69
        FCB     OP_DEC          ; 6A
        FCB     OP_INV          ; 6B
        FCB     OP_INC          ; 6C
        FCB     OP_TST          ; 6D
        FCB     OP_JMP          ; 6E
        FCB     OP_CLR          ; 6F

        FCB     OP_NEG          ; 70
        FCB     OP_INV          ; 71
        FCB     OP_INV          ; 72
        FCB     OP_COM          ; 73
        FCB     OP_LSR          ; 74
        FCB     OP_INV          ; 75
        FCB     OP_ROR          ; 76
        FCB     OP_ASR          ; 77
        FCB     OP_ASL          ; 78
        FCB     OP_ROL          ; 79
        FCB     OP_DEC          ; 7A
        FCB     OP_INV          ; 7B
        FCB     OP_INC          ; 7C
        FCB     OP_TST          ; 7D
        FCB     OP_JMP          ; 7E
        FCB     OP_CLR          ; 7F

        FCB     OP_SUBA         ; 80
        FCB     OP_CMPA         ; 81
        FCB     OP_SBCA         ; 82
        FCB     OP_SUBD         ; 83
        FCB     OP_ANDA         ; 84
        FCB     OP_BITA         ; 85
        FCB     OP_LDA          ; 86
        FCB     OP_INV          ; 87
        FCB     OP_EORA         ; 88
        FCB     OP_ADCA         ; 89
        FCB     OP_ORA          ; 8A
        FCB     OP_ADDA         ; 8B
        FCB     OP_CMPX         ; 8C
        FCB     OP_BSR          ; 8D
        FCB     OP_LDX          ; 8E
        FCB     OP_INV          ; 8F

        FCB     OP_SUBA         ; 90
        FCB     OP_CMPA         ; 91
        FCB     OP_SBCA         ; 92
        FCB     OP_SUBD         ; 93
        FCB     OP_ANDA         ; 94
        FCB     OP_BITA         ; 95
        FCB     OP_LDA          ; 96
        FCB     OP_STA          ; 97
        FCB     OP_EORA         ; 98
        FCB     OP_ADCA         ; 99
        FCB     OP_ORA          ; 9A
        FCB     OP_ADDA         ; 9B
        FCB     OP_CMPX         ; 9C
        FCB     OP_JSR          ; 9D
        FCB     OP_LDX          ; 9E
        FCB     OP_STX          ; 9F

        FCB     OP_SUBA         ; A0
        FCB     OP_CMPA         ; A1
        FCB     OP_SBCA         ; A2
        FCB     OP_SUBD         ; A3
        FCB     OP_ANDA         ; A4
        FCB     OP_BITA         ; A5
        FCB     OP_LDA          ; A6
        FCB     OP_STA          ; A7
        FCB     OP_EORA         ; A8
        FCB     OP_ADCA         ; A9
        FCB     OP_ORA          ; AA
        FCB     OP_ADDA         ; AB
        FCB     OP_CMPX         ; AC
        FCB     OP_JSR          ; AD
        FCB     OP_LDX          ; AE
        FCB     OP_STX          ; AF

        FCB     OP_SUBA         ; B0
        FCB     OP_CMPA         ; B1
        FCB     OP_SBCA         ; B2
        FCB     OP_SUBD         ; B3
        FCB     OP_ANDA         ; B4
        FCB     OP_BITA         ; B5
        FCB     OP_LDA          ; B6
        FCB     OP_STA          ; B7
        FCB     OP_EORA         ; B8
        FCB     OP_ADCA         ; B9
        FCB     OP_ORA          ; BA
        FCB     OP_ADDA         ; BB
        FCB     OP_CMPX         ; BC
        FCB     OP_JSR          ; BD
        FCB     OP_LDX          ; BE
        FCB     OP_STX          ; BF

        FCB     OP_SUBB         ; C0
        FCB     OP_CMPB         ; C1
        FCB     OP_SBCB         ; C2
        FCB     OP_ADDD         ; C3
        FCB     OP_ANDB         ; C4
        FCB     OP_BITB         ; C5
        FCB     OP_LDB          ; C6
        FCB     OP_INV          ; C7
        FCB     OP_EORB         ; C8
        FCB     OP_ADCB         ; C9
        FCB     OP_ORB          ; CA
        FCB     OP_ADDB         ; CB
        FCB     OP_LDD          ; CC
        FCB     OP_INV          ; CD
        FCB     OP_LDU          ; CE
        FCB     OP_INV          ; CF

        FCB     OP_SUBB         ; D0
        FCB     OP_CMPB         ; D1
        FCB     OP_SBCB         ; D2
        FCB     OP_ADDD         ; D3
        FCB     OP_ANDB         ; D4
        FCB     OP_BITB         ; D5
        FCB     OP_LDB          ; D6
        FCB     OP_STB          ; D7
        FCB     OP_EORB         ; D8
        FCB     OP_ADCB         ; D9
        FCB     OP_ORB          ; DA
        FCB     OP_ADDB         ; DB
        FCB     OP_LDD          ; DC
        FCB     OP_STD          ; DD
        FCB     OP_LDU          ; DE
        FCB     OP_STU          ; DF

        FCB     OP_SUBB         ; E0
        FCB     OP_CMPB         ; E1
        FCB     OP_SBCB         ; E2
        FCB     OP_ADDD         ; E3
        FCB     OP_ANDB         ; E4
        FCB     OP_BITB         ; E5
        FCB     OP_LDB          ; E6
        FCB     OP_STB          ; E7
        FCB     OP_EORB         ; E8
        FCB     OP_ADCB         ; E9
        FCB     OP_ORB          ; EA
        FCB     OP_ADDB         ; EB
        FCB     OP_LDD          ; EC
        FCB     OP_STD          ; ED
        FCB     OP_LDU          ; EE
        FCB     OP_STU          ; EF

        FCB     OP_SUBB         ; F0
        FCB     OP_CMPB         ; F1
        FCB     OP_SBCB         ; F2
        FCB     OP_ADDD         ; F3
        FCB     OP_ANDB         ; F4
        FCB     OP_BITB         ; F5
        FCB     OP_LDB          ; F6
        FCB     OP_STB          ; F7
        FCB     OP_EORB         ; F8
        FCB     OP_ADCB         ; F9
        FCB     OP_ORB          ; FA
        FCB     OP_ADDB         ; FB
        FCB     OP_LDD          ; FC
        FCB     OP_STD          ; FD
        FCB     OP_LDU          ; FE
        FCB     OP_STU          ; FF

; Table of addressing modes. Listed in order,indexed by op code.
MODES
        FCB     AM_DIRECT       ; 00
        FCB     AM_INVALID      ; 01
        FCB     AM_INVALID      ; 02
        FCB     AM_DIRECT       ; 03
        FCB     AM_DIRECT       ; 04
        FCB     AM_INVALID      ; 05
        FCB     AM_DIRECT       ; 06
        FCB     AM_DIRECT       ; 07
        FCB     AM_DIRECT       ; 08
        FCB     AM_DIRECT       ; 09
        FCB     AM_DIRECT       ; 0A
        FCB     AM_INVALID      ; 0B
        FCB     AM_DIRECT       ; 0C
        FCB     AM_DIRECT       ; 0D
        FCB     AM_DIRECT       ; 0E
        FCB     AM_DIRECT       ; 0F

        FCB     AM_INVALID      ; 10 Page 2 extended opcodes (see other table)
        FCB     AM_INVALID      ; 11 Page 3 extended opcodes (see other table)
        FCB     AM_INHERENT     ; 12
        FCB     AM_INHERENT     ; 13
        FCB     AM_INVALID      ; 14
        FCB     AM_INVALID      ; 15
        FCB     AM_RELATIVE16   ; 16
        FCB     AM_RELATIVE16   ; 17
        FCB     AM_INVALID      ; 18
        FCB     AM_INHERENT     ; 19
        FCB     AM_IMMEDIATE8   ; 1A
        FCB     AM_INVALID      ; 1B
        FCB     AM_IMMEDIATE8   ; 1C
        FCB     AM_INHERENT     ; 1D
        FCB     AM_IMMEDIATE8   ; 1E
        FCB     AM_IMMEDIATE8   ; 1F

        FCB     AM_RELATIVE8    ; 20
        FCB     AM_RELATIVE8    ; 21
        FCB     AM_RELATIVE8    ; 22
        FCB     AM_RELATIVE8    ; 23
        FCB     AM_RELATIVE8    ; 24
        FCB     AM_RELATIVE8    ; 25
        FCB     AM_RELATIVE8    ; 26
        FCB     AM_RELATIVE8    ; 27
        FCB     AM_RELATIVE8    ; 28
        FCB     AM_RELATIVE8    ; 29
        FCB     AM_RELATIVE8    ; 2A
        FCB     AM_RELATIVE8    ; 2B
        FCB     AM_RELATIVE8    ; 2C
        FCB     AM_RELATIVE8    ; 2D
        FCB     AM_RELATIVE8    ; 2E
        FCB     AM_RELATIVE8    ; 2F

        FCB     AM_INDEXED      ; 30
        FCB     AM_INDEXED      ; 31
        FCB     AM_INDEXED      ; 32
        FCB     AM_INDEXED      ; 33
        FCB     AM_IMMEDIATE8   ; 34
        FCB     AM_IMMEDIATE8   ; 35
        FCB     AM_IMMEDIATE8   ; 36
        FCB     AM_IMMEDIATE8   ; 37
        FCB     AM_INVALID      ; 38
        FCB     AM_INHERENT     ; 39
        FCB     AM_INHERENT     ; 3A
        FCB     AM_INHERENT     ; 3B
        FCB     AM_IMMEDIATE8   ; 3C
        FCB     AM_INHERENT     ; 3D
        FCB     AM_INVALID      ; 3E
        FCB     AM_INHERENT     ; 3F

        FCB     AM_INHERENT     ; 40
        FCB     AM_INVALID      ; 41
        FCB     AM_INVALID      ; 42
        FCB     AM_INHERENT     ; 43
        FCB     AM_INHERENT     ; 44
        FCB     AM_INVALID      ; 45
        FCB     AM_INHERENT     ; 46
        FCB     AM_INHERENT     ; 47
        FCB     AM_INHERENT     ; 48
        FCB     AM_INHERENT     ; 49
        FCB     AM_INHERENT     ; 4A
        FCB     AM_INVALID      ; 4B
        FCB     AM_INHERENT     ; 4C
        FCB     AM_INHERENT     ; 4D
        FCB     AM_INVALID      ; 4E
        FCB     AM_INHERENT     ; 4F

        FCB     AM_INHERENT     ; 50
        FCB     AM_INVALID      ; 51
        FCB     AM_INVALID      ; 52
        FCB     AM_INHERENT     ; 53
        FCB     AM_INHERENT     ; 54
        FCB     AM_INVALID      ; 55
        FCB     AM_INHERENT     ; 56
        FCB     AM_INHERENT     ; 57
        FCB     AM_INHERENT     ; 58
        FCB     AM_INHERENT     ; 59
        FCB     AM_INHERENT     ; 5A
        FCB     AM_INVALID      ; 5B
        FCB     AM_INHERENT     ; 5C
        FCB     AM_INHERENT     ; 5D
        FCB     AM_INVALID      ; 5E
        FCB     AM_INHERENT     ; 5F

        FCB     AM_INDEXED      ; 60
        FCB     AM_INVALID      ; 61
        FCB     AM_INVALID      ; 62
        FCB     AM_INDEXED      ; 63
        FCB     AM_INDEXED      ; 64
        FCB     AM_INVALID      ; 65
        FCB     AM_INDEXED      ; 66
        FCB     AM_INDEXED      ; 67
        FCB     AM_INDEXED      ; 68
        FCB     AM_INDEXED      ; 69
        FCB     AM_INDEXED      ; 6A
        FCB     AM_INVALID      ; 6B
        FCB     AM_INDEXED      ; 6C
        FCB     AM_INDEXED      ; 6D
        FCB     AM_INDEXED      ; 6E
        FCB     AM_INDEXED      ; 6F

        FCB     AM_EXTENDED     ; 70
        FCB     AM_INVALID      ; 71
        FCB     AM_INVALID      ; 72
        FCB     AM_EXTENDED     ; 73
        FCB     AM_EXTENDED     ; 74
        FCB     AM_INVALID      ; 75
        FCB     AM_EXTENDED     ; 76
        FCB     AM_EXTENDED     ; 77
        FCB     AM_EXTENDED     ; 78
        FCB     AM_EXTENDED     ; 79
        FCB     AM_EXTENDED     ; 7A
        FCB     AM_INVALID      ; 7B
        FCB     AM_EXTENDED     ; 7C
        FCB     AM_EXTENDED     ; 7D
        FCB     AM_EXTENDED     ; 7E
        FCB     AM_EXTENDED     ; 7F

        FCB     AM_IMMEDIATE8   ; 80
        FCB     AM_IMMEDIATE8   ; 81
        FCB     AM_IMMEDIATE8   ; 82
        FCB     AM_IMMEDIATE16  ; 83
        FCB     AM_IMMEDIATE8   ; 84
        FCB     AM_IMMEDIATE8   ; 85
        FCB     AM_IMMEDIATE8   ; 86
        FCB     AM_INVALID      ; 87
        FCB     AM_IMMEDIATE8   ; 88
        FCB     AM_IMMEDIATE8   ; 89
        FCB     AM_IMMEDIATE8   ; 8A
        FCB     AM_IMMEDIATE8   ; 8B
        FCB     AM_IMMEDIATE16  ; 8C
        FCB     AM_RELATIVE8    ; 8D
        FCB     AM_IMMEDIATE16  ; 8E
        FCB     AM_INVALID      ; 8F

        FCB     AM_DIRECT       ; 90
        FCB     AM_DIRECT       ; 91
        FCB     AM_DIRECT       ; 92
        FCB     AM_DIRECT       ; 93
        FCB     AM_DIRECT       ; 94
        FCB     AM_DIRECT       ; 95
        FCB     AM_DIRECT       ; 96
        FCB     AM_DIRECT       ; 97
        FCB     AM_DIRECT       ; 98
        FCB     AM_DIRECT       ; 99
        FCB     AM_DIRECT       ; 9A
        FCB     AM_DIRECT       ; 9B
        FCB     AM_DIRECT       ; 9C
        FCB     AM_DIRECT       ; 9D
        FCB     AM_DIRECT       ; 9E
        FCB     AM_DIRECT       ; 9F

        FCB     AM_INDEXED      ; A0
        FCB     AM_INDEXED      ; A1
        FCB     AM_INDEXED      ; A2
        FCB     AM_INDEXED      ; A3
        FCB     AM_INDEXED      ; A4
        FCB     AM_INDEXED      ; A5
        FCB     AM_INDEXED      ; A6
        FCB     AM_INDEXED      ; A7
        FCB     AM_INDEXED      ; A8
        FCB     AM_INDEXED      ; A9
        FCB     AM_INDEXED      ; AA
        FCB     AM_INDEXED      ; AB
        FCB     AM_INDEXED      ; AC
        FCB     AM_INDEXED      ; AD
        FCB     AM_INDEXED      ; AE
        FCB     AM_INDEXED      ; AF

        FCB     AM_EXTENDED     ; B0
        FCB     AM_EXTENDED     ; B1
        FCB     AM_EXTENDED     ; B2
        FCB     AM_EXTENDED     ; B3
        FCB     AM_EXTENDED     ; B4
        FCB     AM_EXTENDED     ; B5
        FCB     AM_EXTENDED     ; B6
        FCB     AM_EXTENDED     ; B7
        FCB     AM_EXTENDED     ; B8
        FCB     AM_EXTENDED     ; B9
        FCB     AM_EXTENDED     ; BA
        FCB     AM_EXTENDED     ; BB
        FCB     AM_EXTENDED     ; BC
        FCB     AM_EXTENDED     ; BD
        FCB     AM_EXTENDED     ; BE
        FCB     AM_EXTENDED     ; BF

        FCB     AM_IMMEDIATE8   ; C0
        FCB     AM_IMMEDIATE8   ; C1
        FCB     AM_IMMEDIATE8   ; C2
        FCB     AM_IMMEDIATE16  ; C3
        FCB     AM_IMMEDIATE8   ; C4
        FCB     AM_IMMEDIATE8   ; C5
        FCB     AM_IMMEDIATE8   ; C6
        FCB     AM_INVALID      ; C7
        FCB     AM_IMMEDIATE8   ; C8
        FCB     AM_IMMEDIATE8   ; C9
        FCB     AM_IMMEDIATE8   ; CA
        FCB     AM_IMMEDIATE8   ; CB
        FCB     AM_IMMEDIATE16  ; CC
        FCB     AM_INHERENT     ; CD
        FCB     AM_IMMEDIATE16  ; CE
        FCB     AM_INVALID      ; CF

        FCB     AM_DIRECT       ; D0
        FCB     AM_DIRECT       ; D1
        FCB     AM_DIRECT       ; D2
        FCB     AM_DIRECT       ; D3
        FCB     AM_DIRECT       ; D4
        FCB     AM_DIRECT       ; D5
        FCB     AM_DIRECT       ; D6
        FCB     AM_DIRECT       ; D7
        FCB     AM_DIRECT       ; D8
        FCB     AM_DIRECT       ; D9
        FCB     AM_DIRECT       ; DA
        FCB     AM_DIRECT       ; DB
        FCB     AM_DIRECT       ; DC
        FCB     AM_DIRECT       ; DD
        FCB     AM_DIRECT       ; DE
        FCB     AM_DIRECT       ; DF

        FCB     AM_INDEXED      ; E0
        FCB     AM_INDEXED      ; E1
        FCB     AM_INDEXED      ; E2
        FCB     AM_INDEXED      ; E3
        FCB     AM_INDEXED      ; E4
        FCB     AM_INDEXED      ; E5
        FCB     AM_INDEXED      ; E6
        FCB     AM_INDEXED      ; E7
        FCB     AM_INDEXED      ; E8
        FCB     AM_INDEXED      ; E9
        FCB     AM_INDEXED      ; EA
        FCB     AM_INDEXED      ; EB
        FCB     AM_INDEXED      ; EC
        FCB     AM_INDEXED      ; ED
        FCB     AM_INDEXED      ; EE
        FCB     AM_INDEXED      ; EF

        FCB     AM_EXTENDED     ; F0
        FCB     AM_EXTENDED     ; F1
        FCB     AM_EXTENDED     ; F2
        FCB     AM_EXTENDED     ; F3
        FCB     AM_EXTENDED     ; F4
        FCB     AM_EXTENDED     ; F5
        FCB     AM_EXTENDED     ; F6
        FCB     AM_EXTENDED     ; F7
        FCB     AM_EXTENDED     ; F8
        FCB     AM_EXTENDED     ; F9
        FCB     AM_EXTENDED     ; FA
        FCB     AM_EXTENDED     ; FB
        FCB     AM_EXTENDED     ; FC
        FCB     AM_EXTENDED     ; FD
        FCB     AM_EXTENDED     ; FE
        FCB     AM_EXTENDED     ; FF

; Special table for page 2 instructions prefixed by $10.
; Format: opcode (less 10), instruction, addressing mode

PAGE2
        FCB     $21,OP_LBRN,AM_RELATIVE16
        FCB     $22,OP_LBHI,AM_RELATIVE16
        FCB     $23,OP_LBLS,AM_RELATIVE16
        FCB     $24,OP_LBCC,AM_RELATIVE16
        FCB     $25,OP_LBCS,AM_RELATIVE16
        FCB     $26,OP_LBNE,AM_RELATIVE16
        FCB     $27,OP_LBEQ,AM_RELATIVE16
        FCB     $28,OP_LBVC,AM_RELATIVE16
        FCB     $29,OP_LBVS,AM_RELATIVE16
        FCB     $2A,OP_LBPL,AM_RELATIVE16
        FCB     $2B,OP_LBMI,AM_RELATIVE16
        FCB     $2C,OP_LBGE,AM_RELATIVE16
        FCB     $2D,OP_LBLT,AM_RELATIVE16
        FCB     $2E,OP_LBGT,AM_RELATIVE16
        FCB     $2F,OP_LBLE,AM_RELATIVE16
        FCB     $3F,OP_SWI2,AM_INHERENT
        FCB     $83,OP_CMPD,AM_IMMEDIATE16
        FCB     $8C,OP_CMPY,AM_IMMEDIATE16
        FCB     $8E,OP_LDY,AM_IMMEDIATE16
        FCB     $93,OP_CMPD,AM_DIRECT
        FCB     $9C,OP_CMPY,AM_DIRECT
        FCB     $9E,OP_LDY,AM_DIRECT
        FCB     $9D,OP_STY,AM_DIRECT
        FCB     $A3,OP_CMPD,AM_INDEXED
        FCB     $AC,OP_CMPY,AM_INDEXED
        FCB     $AE,OP_LDY,AM_INDEXED
        FCB     $AF,OP_STY,AM_INDEXED
        FCB     $B3,OP_CMPD,AM_EXTENDED
        FCB     $BC,OP_CMPY,AM_EXTENDED
        FCB     $BE,OP_LDY,AM_EXTENDED
        FCB     $BF,OP_STY,AM_EXTENDED
        FCB     $CE,OP_LDS,AM_IMMEDIATE16
        FCB     $DE,OP_LDS,AM_DIRECT
        FCB     $DD,OP_STS,AM_DIRECT
        FCB     $EE,OP_LDS,AM_INDEXED
        FCB     $EF,OP_STS,AM_INDEXED
        FCB     $FE,OP_LDS,AM_EXTENDED
        FCB     $FF,OP_STS,AM_EXTENDED
        FCB     0                             ; indicates end of table

; Special table for page 3 instructions prefixed by $11.
; Same format as table above.

PAGE3
        FCB     $3F,OP_SWI3,AM_INHERENT
        FCB     $83,OP_CMPU,AM_IMMEDIATE16
        FCB     $8C,OP_CMPS,AM_IMMEDIATE16
        FCB     $93,OP_CMPU,AM_DIRECT
        FCB     $9C,OP_CMPS,AM_DIRECT
        FCB     $A3,OP_CMPU,AM_INDEXED
        FCB     $AC,OP_CMPS,AM_INDEXED
        FCB     $B3,OP_CMPU,AM_EXTENDED
        FCB     $BC,OP_CMPS,AM_EXTENDED
        FCB     0                             ; indicates end of table

; Display strings. Should be terminated in EOT character.

MSG1    FCC     "; INVALID"
        FCB     EOT

MSG2    FCC     "PRESS <SPACE> TO CONTINUE, <Q> TO QUIT "
        FCB     EOT

MSG3    FCC     "PCR"
        FCB     EOT
