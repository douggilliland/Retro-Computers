;
; 6809 Trace Utility
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
; 0.0     20-Mar-2019  First version started, based on 6502 code.
; 0.1     25-Mar-2019  Basically working, with some limitations.
; 0.2     27-Mar-2019  Mostly working, except for PCR and some corner cases.
;

; Character defines

EOT     EQU     $04             ; String terminator

; Tables and routines in ASSIST09 ROM

OPCODES equ     $C908
PAGE2   equ     $CB08
PAGE3   equ     $CB7B
LENGTHS equ     $C8DB
MODES   equ     $CA08
POSTBYTES equ   $C8E8

GetChar equ     $C07E
Print2Spaces equ $C062
PrintAddress equ $C08F
PrintByte equ   $C081
PrintCR equ     $C02E
PrintChar equ   $C07B
PrintDollar equ $C03B
PrintSpace equ  $C05F
PrintString equ $C09D
ADRS    equ     $5FF0
DISASM  equ     $C0A4

; Instruction types - taken from disassembler

OP_INV   EQU    $00
OP_BSR   EQU    $20
OP_CWAI  EQU    $30
OP_JMP   EQU    $3B
OP_JSR   EQU    $3C
OP_LBSR  EQU    $4B
OP_RTI   EQU    $6E
OP_RTS   EQU    $6F
OP_SWI   EQU    $7D
OP_SWI2  EQU    $7E
OP_SWI3  EQU    $7F
OP_SYNC  EQU    $80

; Addressing modes - taken from disassembler

AM_INVALID    equ 0
AM_RELATIVE8  equ 6
AM_RELATIVE16 equ 7

AM_INDEXED equ  8

        ORG     $1000

; Variables

SAVE_CC RMB     1               ; Saved register values
SAVE_A  RMB     1
SAVE_B  RMB     1
SAVE_D  equ     SAVE_A          ; Synonym for SAVE_A and SAVE_B
SAVE_DP RMB     1
SAVE_X  RMB     2
SAVE_Y  RMB     2
SAVE_U  RMB     2
SAVE_S  RMB     2
SAVE_PC RMB     2
ADDRESS RMB     2               ; Instruction address
NEXTPC  RMB     2               ; Value of PC after next instruction
OPCODE  RMB     1               ; Instruction op code
OPTYPE  RMB     1               ; Instruction type (e.g. JMP)
PAGE23  RMB     1               ; Flag indicating page2/3 instruction when non-zero
POSTBYT RMB     1               ; Post byte (for indexed addressing)
LENGTH  RMB     1               ; Length of instruction
AM      RMB     1               ; Addressing mode
OURS    RMB     2               ; This program's user stack pointer
OURU    RMB     2               ; This program's system stack pointer
BUFFER  RMB     10              ; Buffer holding traced instruction (up to 10 bytes)

        ORG     $2000
        
;------------------------------------------------------------------------
; Code for testing trace function. Just contains a variety of
; different instruction types.

testcode
        lds     #$5000
        ldu     #$6000

bubble  ldx     #base           ; Get table
        ldb     #length         ; Get length
        decb
        leax    b,x             ; Point to end
        clr     exchg           ; Clear exchange flag
next    lda     ,x              ; A = current entry
        cmpa    ,-x             ; Compare with next
        bge     noswit          ; Go to noswitch if current >= next (signed)
        pshs    b               ; Save B
        ldb     ,x              ; Get next
        stb     1,x             ; Store in current
        sta     ,x              ; Store current in next
        puls    b               ; Restore B
        inc     exchg           ; Set exchange flag
noswit  decb                    ; Decrement B
        bne     next            ; Continue until zero
        tst     exchg           ; Exchange = 0?
        bne     bubble          ; Restart of no = 0
forev   bra     forev

; Storage

exchg   rmb     1               ; Exchange flag

; Data to be sorted (random)

length  equ      10             ; Number of data items

base    fcb     203,187,184,205,165,126,19,253,30,24

        ORG     $3000

;------------------------------------------------------------------------
; Main program
; Trace test code. Pressing Q or q will go to monitor, any other key
; will trace another instruction.
; TODO: Make it work as an external command for ASSIST09.

main    ldx     #testcode       ; Start address of code to trace
        stx     ADDRESS
        stx     SAVE_PC
loop    bsr     step
        jsr     EchoOff         : Turn off echo from key press
        lbsr    GetChar         ; Wait for a key press
        cmpa    #'Q'            ; Check for Q
        beq     quit            ; If so, quit
        cmpa    #'q'            ; Check for q
        beq     quit            ; If so, quit
        bra     loop            ; If not, continue
quit    jmp     [$fffe]         ; Go back to ASSIST09 via reset vector

;------------------------------------------------------------------------
; Step: Step one instruction
; Get address to step.
; Call Trace
; Display register values
; Disassemble next instruction (Set ADDR, call DISASM)
; Return

step    lbsr    Disassemble     ; Disassemble the instruction
        bsr     Trace           ; Trace/execute the instruction
        lbsr    DisplayRegs     ; Display register values
        ldx     ADDRESS         ; Get next address
        stx     SAVE_PC         ; And store as last PC
        rts

;------------------------------------------------------------------------
; Trace one instruction.
; Input: Address of instruction in ADDRESS.
; Returns: Updates saved register values.

Trace   clr     PAGE23          ; Clear page2/3 flag
        ldx     ADDRESS,PCR     ; Get address of instruction
        ldb     ,x              ; Get instruction op code
        cmpb    #$10            ; Is it a page 2 16-bit opcode prefix with 10?
        beq     handle10        ; If so, do special handling
        cmpb    #$11            ; Is it a page 3 16-bit opcode prefix with 11?
        beq     handle11        ; If so, do special handling
        lbra    not1011         ; If not, handle as normal case

handle10                        ; Handle page 2 instruction
        lda     #1              ; Set page2/3 flag
        sta     PAGE23
        ldb     1,x             ; Get real opcode
        stb     OPCODE          ; Save it.
        leax    PAGE2,PCR       ; Pointer to start of table
        clra                    ; Set index into table to zero
search10
        cmpb    a,x             ; Check for match of opcode in table
        beq     found10         ; Branch if found
        adda    #3              ; Advance to next entry in table (entries are 3 bytes long)
        tst     a,x             ; Check entry
        beq     notfound10      ; If zero, then reached end of table
        bra     search10        ; If not, keep looking

notfound10                      ; Instruction not found, so is invalid.
        lda     #$10            ; Set opcode to 10
        sta     OPCODE
        lda     #OP_INV         ; Set as instruction type invalid
        sta     OPTYPE
        lda     #AM_INVALID     ; Set as addressing mode invalid
        sta     AM
        lda     #1              ; Set length to one
        sta     LENGTH
        lbra    dism            ; Disassemble as normal

found10                         ; Found entry in table
        adda    #1              ; Advance to instruction type entry in table
        ldb     a,x             ; Get instruction type
        stb     OPTYPE          ; Save it
        adda    #1              ; Advanced to address mode entry in table
        ldb     a,x             ; Get address mode
        stb     AM              ; Save it
        clra                    ; Clear MSB of D, addressing mode is now in A:B (D)
        tfr     d,x             ; Put addressing mode in X
        ldb     LENGTHS,x       ; Get instruction length from table
        stb     LENGTH          ; Store it
        inc     LENGTH          ; Add one because it is a two byte op code
        bra     dism            ; Continue normal disassembly processing.

handle11                        ; Same logic as above, but use table for page 3 opcodes.
        lda     #1              ; Set page2/3 flag
        sta     PAGE23
        ldb     1,x             ; Get real opcode
        stb     OPCODE          ; Save it.
        leax    PAGE3,PCR       ; Pointer to start of table
        clra                    ; Set index into table to zero
search11
        cmpb    a,x             ; Check for match of opcode in table
        beq     found11         ; Branch if found
        adda    #3              ; Advance to next entry in table (entries are 3 bytes long)
        tst     a,x             ; Check entry
        beq     notfound11      ; If zero, then reached end of table
        bra     search11        ; If not, keep looking

notfound11                      ; Instruction not found, so is invalid.
        lda     #$11            ; Set opcode to 10
        sta     OPCODE
        LDA     #OP_INV         ; Set as instruction type invalid
        sta     OPTYPE
        lda     #AM_INVALID     ; Set as addressing mode invalid
        sta     AM
        lda     #1              ; Set length to one
        sta     LENGTH
        bra     dism            ; Disassemble as normal

found11                         ; Found entry in table
        adda    #1              ; Advance to instruction type entry in table
        ldb     a,x             ; Get instruction type
        stb     OPTYPE          ; Save it
        adda    #1              ; Advanced to address mode entry in table
        ldb     a,x             ; Get address mode
        stb     AM              ; Save it
        clra                    ; Clear MSB of D, addressing mode is now in A:B (D)
        tfr     d,x             ; Put addressing mode in X
        ldb     LENGTHS,x       ; Get instruction length from table
        stb     LENGTH          ; Store it
        inc     LENGTH          ; Add one because it is a two byte op code
        bra     dism            ; Continue normal disassembly processing.

not1011
        stb     OPCODE          ; Save the op code
        clra                    ; Clear MSB of D
        tfr     d,x             ; Put op code in X
        ldb     OPCODES,x       ; Get opcode type from table
        stb     OPTYPE          ; Store it
        ldb     OPCODE          ; Get op code again
        tfr     d,x             ; Put opcode in X
        ldb     MODES,x         ; Get addressing mode type from table
        stb     AM              ; Store it
        tfr     d,x             ; Put addressing mode in X
        ldb     LENGTHS,x       ; Get instruction length from table
        stb     LENGTH          ; Store it

; If addressing mode is indexed, get and save the indexed addressing
; post byte.

dism    lda     AM              ; Get addressing mode
        cmpa    #AM_INDEXED     ; Is it indexed mode?
        bne     NotIndexed      ; Branch if not
        ldx     ADDRESS,PCR     ; Get address of op code
                                ; If it is a page2/3 instruction, op code is the next byte after ADDRESS
        tst     PAGE23          ; Page2/3 instruction?
        beq     norm            ; Branch if not
        lda     2,x             ; Post byte is two past ADDRESS
        bra     getpb
norm    lda     1,x             ; Get next byte (the post byte)
getpb   sta     POSTBYT         ; Save it

; Determine number of additional bytes for indexed addressing based on
; postbyte. If most significant bit is 0, there are no additional
; bytes and we can skip the rest of the check.

        bpl     NotIndexed      ; Branch of MSB is zero

; Else if most significant bit is 1, mask off all but low order 5 bits
; and look up length in table.

        anda    #%00011111      ; Mask off bits
        leax    POSTBYTES,PCR   ; Lookup table of lengths
        lda     a,x             ; Get table entry
        adda    LENGTH          ; Add to instruction length
        sta     LENGTH          ; Save new length

NotIndexed

; At this point we have set: ADDRESS, OPCODE, OPTYPE, LENGTH, AM, PAGE23, POSTBYT
; Now check for special instructions that change flow of control or otherwise
; need special handling rather than being directly executed.

; Invalid op code?
        lda     OPTYPE          ; Get op code type
        cmpa    #OP_INV         ; Is it an invalid instruction?
        lbeq    update          ; If so, nothing to do (length is 1 byte)

; Check for PC relative indexed addressing modes that we don't
; currently handle. If so, display a warning but still trace the
; instruction.

        lda    AM               ; Get address mode
        cmpa   #AM_INDEXED      ; Indexed addressing
        bne    trysync          ; Branch if not
        lda    POSTBYT          ; Get the post byte

; It is a PCR mode if the post byte has the pattern 1xxx110x

        anda   #%10001110       ; Mask bits we want to check
        cmpa   #%10001100       ; Check for pattern
        bne    trysync          ; Branch if no match

; Display "Warning: instruction not supported, expect incorrect results."

        leax    MSG12,PCR       ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR

; SYNC instruction. Continue (emulate interrupt and then RTI
; happenning or mask interrupt and instruction continuing).

trysync lda     OPTYPE          ; Get op code type
        cmpa    #OP_SYNC        ; Is it a SYNC instruction?
        lbeq    update          ; If so, nothing to do (length is 1 byte)

; CWAI #$XX instruction. AND operand with CC. Set E flag in CC. Continue (emulate interrupt and then RTI happenning).

        lda     OPTYPE          ; Get op code type
        cmpa    #OP_CWAI        ; Is it a CWAI instruction?
        bne     tryswi
        ldx     ADDRESS         ; Get address of instruction
        lda     1,x             ; Get operand
        ora     #%10000000      ; Set E bit
        ora     SAVE_CC         ; Or with CC
        sta     SAVE_CC         ; Save CC
        lbra    update          ; Done

; SWI instruction. Increment PC. Save all registers except S on hardware stack.
; Set I and F in CC. Set new PC to [FFFA,FFFB].

tryswi  cmpa    #OP_SWI
        bne     tryswi2
        ldx     ADDRESS         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        ora     #%01010000      ; Set I and F bits
        sta     SAVE_CC
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFFA           ; Get address of SWI vector
        stx     ADDRESS         ; Set as new address

        lbra    done            ; Done

; SWI2 instruction. Increment PC. Save all registers except S on
; stack. Set new PC to [FFF4,FFF5].

tryswi2 cmpa    #OP_SWI2
        bne     tryswi3
        ldx     ADDRESS         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFF4           ; Get address of SWI2 vector
        stx     ADDRESS         ; Set as new address

        lbra    done            ; Done

; SWI3 instruction. Increment PC. Save all registers except S on
; stack. Set new PC to [FFF2,FFF3].

tryswi3 cmpa    #OP_SWI3
        bne     tryjmp
        ldx     ADDRESS         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFF2           ; Get address of SWI3 vector
        stx     ADDRESS         ; Set as new address

        lbra    done            ; Done

; JMP instruction. Next PC is operand effective address. Need to
; handle extended, direct, and indexed modes.

tryjmp  cmpa    #OP_JMP         ; Is it a JMP instruction?
        lbne    tryjsr          ; Branch if not.
        lda     OPCODE          ; Get the actual op code
        cmpa    #$7E            ; Extended, e.g. JMP $XXXX ?
        bne     jmp1
        ldx     ADDRESS         ; Get address of instruction
        ldx     1,x             ; Get 16-bit operand (JMP destination)
        stx     ADDRESS         ; Set as new instruction address
        stx     SAVE_PC
        lbra    done            ; Done

jmp1    cmpa    #$0E            ; Direct, e.g. JMP $XX ?
        bne     jmp2
        ldx     ADDRESS         ; Get address of instruction
        ldb     1,x             ; Get 8-bit operand (JMP destination)
        lda     SAVE_DP         ; Get DP register
        std     ADDRESS         ; Full address is DP (in A) + operand (in B)
        std     SAVE_PC
        lbra    done            ; Done

; Must be indexed, e.g. JMP 1,X. Can't get effective address directly
; from instruction. Instead we use this trick: Run a LEAU instruction
; with the same indexed operand. Then examine value of X, which should
; be the new PC. Need to run it with the current index register values
; of X, Y, U, and S.
; TODO: Not handled: addressing modes that change U register like JMP ,U++.
; TODO: Not handled correctly: PCR modes like JMP 10,PCR

jmp2    ldx     ADDRESS         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        ldb     #$33            ; LEAU instruction
        clra                    ; Loop counter and index
        stb     a,y             ; Write LEAU instruction to buffer
        inca                    ; Move to next byte
copy1   ldb     a,x             ; Get instruction byte
        stb     a,y             ; Write to buffer
        inca                    ; Increment counter
        cmpa    LENGTH          ; Copied all bytes?
        bne     copy1

; Add a jump after the instruction to where we want to go after it is executed (ReturnFromJump).

        ldb     #$7E            ; JMP $XXXX instruction
        stb     a,y             ; Store in buffer
        inca                    ; Advance buffer
        ldx     #ReturnFromJump ; Destination address of JMP
        stx     a,y             ; Store in buffer

; Restore registers from saved values.

        sts     OURS            ; Save this program's stack pointers
        stu     OURU

        lda     SAVE_A
        ldb     SAVE_B
        ldx     SAVE_X
        ldy     SAVE_Y
        lds     SAVE_S
        ldu     SAVE_U

; Call instruction in buffer. It is followed by a JMP ReturnFromJump so we get back.

        jmp     BUFFER

ReturnFromJump

; Restore saved registers (except U and PC).

        stx     SAVE_X
        sty     SAVE_Y
        sts     SAVE_S

; Restore this program's stack pointers so RTS etc. will still work.

        lds     OURS
        ldu     OURU

; Value of X is new PC

        stx     ADDRESS         ; Set as new instruction address
        stx     SAVE_PC
        lbra    done            ; Done

; JSR instruction. Next PC is operand effective address. Push return
; address on stack. Need to handle extended, direct, and indexed
; modes.

tryjsr  cmpa    #OP_JSR         ; Is it a JSR instruction?
        lbne    tryrts          ; Branch if not.
        lda     OPCODE          ; Get the actual op code
        cmpa    #$BD            ; Extended, e.g. JSR $XXXX ?
        bne     jsr1

        clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get instruction length (byte)
        addd    ADDRESS         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        ldx     ADDRESS         ; Get address of instruction
        ldx     1,x             ; Get 16-bit operand (JSR destination)
        stx     ADDRESS         ; Set as new instruction address
        stx     SAVE_PC
        lbra    done            ; Done

jsr1    cmpa    #$9D            ; Direct, e.g. JSR $XX ?
        bne     jsr2

        clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get instruction length (byte)
        addd    ADDRESS         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        ldx     ADDRESS         ; Get address of instruction
        ldb     1,x             ; Get 8-bit operand (JSR destination)
        lda     SAVE_DP         ; Get DP register
        std     ADDRESS         ; Full address is DP (in A) + operand (in B)
        std     SAVE_PC
        lbra    done            ; Done

; Must be indexed, e.g. JSR 1,X. Use same LEAU trick as for JMP.
; TODO: Not handled: addressing modes that change U register like JSR ,U++.
; TODO: Not handled correctly: PCR modes like JSR 10,PCR

jsr2    clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get instruction length (byte)
        addd    ADDRESS         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        lbra    jmp2            ; Rest of code is shared with JMP routine

; RTS instruction. Pop PC from stack and set it to next address.

tryrts  cmpa    #OP_RTS         ; Is it a RTS instruction?
        bne     tryrti          ; Branch if not.
        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        puls    x               ; Pull return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer
        stx     ADDRESS         ; Set as new instruction address
        stx     SAVE_PC
        lbra    done            ; Done

; RTI instruction.
; If E flag is not set, pop PC and CC.
; If E flag is set, pop PC, U, Y, X, DP, B, A, and CC.
; Set next instruction to PC.

tryrti  cmpa    #OP_RTI         ; Is it a RTI instruction?
        bne     trybsr          ; Branch if not.
        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        puls    x               ; Pull PC
        stx     ADDRESS         ; Set as new instruction address
        stx     SAVE_PC

        lda     SAVE_CC         ; Test CC
        bpl     notEntire       ; Branch if Entire bit (MSB is not set)
        puls    x               ; Pull U
        stx     SAVE_U
        puls    x               ; Pull Y
        stx     SAVE_Y
        puls    x               ; Pull X
        stx     SAVE_X
        puls    a               ; Pull DP
        sta     SAVE_DP
        puls    a               ; Pull B
        sta     SAVE_B
        puls    a               ; Pull A
        sta     SAVE_A
notEntire
        puls    a               ; Pull CC
        sta     SAVE_CC

        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer
        lbra    done            ; Done

; BSR instruction. Similar to JSR but EA is relative.

trybsr  cmpa    #OP_BSR         ; Is it a BSR instruction?
        bne     trylbsr         ; Branch if not.

; Push return address on stack.

        clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get instruction length (byte)
        addd    ADDRESS         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

; Next PC is PC plus instruction length (2) plus offset operand.

        ldx     ADDRESS         ; Get address of instruction
        clra                    ; Clear MSB
        ldb     1,x             ; Get 8-bit signed branch offset
        sex                     ; Sign extend to 16-bits
        addd    #2              ; Add instruction length (2)
        addd    ADDRESS         ; Add to address
        std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

; LBSR instruction. Similar to BSR above.

trylbsr cmpa    #OP_LBSR        ; Is it a LBSR instruction?
        bne     trybxx          ; Branch if not.

; Push return address on stack.

        clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get instruction length (byte)
        addd    ADDRESS         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

; Next PC is PC plus instruction length (3) plus 16-bit offset operand.

        ldx     ADDRESS         ; Get address of instruction
        ldd     1,x             ; Get 16-bit signed branch offset
        addd    #3              ; Add instruction length (3)
        addd    ADDRESS         ; Add to address
        std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

; Bxx instructions.
; These are executed but we change the destination of the branch so we
; catch whether they are taken or not.
; The code in the buffer will look like this:
;
;       JMP BUFFER
;       ...
; XXXX XX 03           Bxx $03 (Taken)         ; Instruction being traced
; XXXX 7E XX XX        JMP BranchNotTaken
; XXXX 7E XX XX Taken  JMP BranchTaken
;        ...
;
; If we come back via BranchNotTaken, next PC is instruction after the branch (PC plus 2).
; If we come back via BranchTaken, next PC is PC plus offset plus 2.
; Need to set CC to program's value before the branch is executed.

trybxx  lda     AM              ; Get addressing mode
        cmpa    #AM_RELATIVE8   ; Is it a relative branch?
        bne     trylbxx

        ldx     ADDRESS         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        lda     ,x              ; Get branch instruction
        sta     ,y              ; Store in buffer
        lda     #3              ; Branch offset (Taken)
        sta     1,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     2,y             ; Store in buffer
        ldx     #BranchNotTaken ; Address for branch
        stx     3,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     5,y             ; Store in buffer
        ldx     #BranchTaken    ; Address for branch
        stx     6,y             ; Store in buffer

; Restore CC from saved value.

        lda     SAVE_CC
        tfr     a,cc

; Call instruction in buffer. It is followed by a JMP so we get back.

        jmp     BUFFER

BranchTaken                     ; Next PC is PC plus offset plus 2.

        ldx     ADDRESS         ; Get address of instruction
        clra                    ; Clear MSB
        ldb     1,x             ; Get 8-bit signed branch offset
        sex                     ; Sign extend to 16-bits
        addd    #2              ; Add instruction length (2)
        addd    ADDRESS         ; Add to address
        std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

BranchNotTaken                  ; Next PC is instruction after the branch (PC plus 2).

        ldd     ADDRESS         ; Get address of instruction
        addd    #2              ; Add instruction length (2)
        std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

; LBxx instructions. Similar to Bxx above.

trylbxx cmpa    #AM_RELATIVE16  ; Is it a long relative branch?
        lbne    trytfr

; Note Long branch instructions are 4 bytes (prefixed by 10) except
; LBRA which is only 3 bytes.
; BUFFER in this case is:
; XXXX 16 00 03        LBRA $0003 (Taken)   ; Instruction being traced
; XXXX 7E XX XX        JMP  BranchNotTaken1
; XXX  7E XX XX Taken  JMP  BranchTaken1
;
; Or:
;
; XXXX 10 XX 00 03       LBxx $0003 (Taken) ; Instruction being traced
; XXXX 7E XX XX          JMP  BranchNotTaken1
; XXXX 7E XX XX   Taken  JMP  BranchTaken1

        lda     OPCODE          ; Get  opcode
        cmpa    #$16            ; Is it LBRA?
        bne     long            ; Branch if it is one of the other 4 byte instructions
        
        ldx     ADDRESS         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        lda     ,x              ; Get branch instruction
        sta     ,y              ; Store in buffer
        ldx     #3              ; Branch offset (Taken)
        stx     1,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     3,y             ; Store in buffer
        ldx     #BranchNotTaken1 ; Address for branch
        stx     4,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     6,y             ; Store in buffer
        ldx     #BranchTaken1   ; Address for branch
        stx     7,y             ; Store in buffer
        bra     branch

long    ldx     ADDRESS         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        ldx     ,x              ; Get two byte branch instruction
        stx     ,y              ; Store in buffer
        ldx     #3              ; Branch offset (Taken)
        stx     2,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     4,y             ; Store in buffer
        ldx     #BranchNotTaken1 ; Address for branch
        stx     5,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     7,y             ; Store in buffer
        ldx     #BranchTaken1   ; Address for branch
        stx     8,y             ; Store in buffer

; Restore CC from saved value.

branch  lda     SAVE_CC
        tfr     a,cc

; Call instruction in buffer. It is followed by a JMP so we get back.

        jmp     BUFFER

BranchTaken1                    ; Next PC is PC plus offset plus instruction length (3 or 4)

; Offset is 1,X for LBRA (2 byte instruction) and 2,X for others (3 byte instructions)

        ldx     ADDRESS
        lda     OPCODE          ; Get  opcode
        cmpa    #$16            ; Is it LBRA?
        bne     long1           ; Branch if it is one of the other 4 byte instructions

        ldd     ADDRESS         ; Get address
        addd    #3              ; Plus 3
        addd    1,x             ; Add 16-bit signed branch offset
        bra     upd

long1   ldd     ADDRESS         ; Get address
        addd    #4              ; Plus 4
        addd    2,x             ; Add 16-bit signed branch offset

upd     std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

BranchNotTaken1                 ; Next PC is instruction after the branch (PC plus 3 or 4).

        clra                    ; Clear MSB
        ldb     LENGTH          ; Get instruction length
        sex                     ; Sign extend to 16 bits
        addd    ADDRESS         ; Add instruction address
        std     ADDRESS         ; Store new address value
        std     SAVE_PC
        lbra    done            ; Done

; Handle TFR instruction.
; Need to manually handle cases where source or destination is the PC
; since it won't run correctly from the buffer.

trytfr  lda     OPCODE          ; Get the actual op code
        cmpa    #$1F            ; Is it TFR R1,R2 ?
        lbne    tryexg          ; Branch if not
        ldx     ADDRESS         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%01010000      ; Is source register PC?
        bne     checkdest       ; Branch if not

        ldy     ADDRESS         ; Get current PC
        leay    2,y             ; Add instruction length

        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000000      ; D?
        beq     to_d
        cmpa    #%00000001      ; X?
        beq     to_x
        cmpa    #%00000010      ; Y?
        beq     to_y
        cmpa    #%00000011      ; U?
        beq     to_u
        cmpa    #%00000100      ; S?
        beq     to_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

to_d    sty     SAVE_D          ; Write new PC to D
        lbra    update          ; Done
to_x    sty     SAVE_X          ; Write new PC to X
        lbra    update          ; Done
to_y    sty     SAVE_Y          ; Write new PC to Y
        lbra    update          ; Done
to_u    sty     SAVE_U          ; Write new PC to U
        lbra    update          ; Done
to_s    sty     SAVE_S          ; Write new PC to S
        lbra    update          ; Done

checkdest
        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000101      ; Is destination register PC?
        lbne    norml           ; Branch to normal instruction handling if not

        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%00000000      ; D?
        beq     from_d
        cmpa    #%00010000      ; X?
        beq     from_x
        cmpa    #%00100000      ; Y?
        beq     from_y
        cmpa    #%00110000      ; U?
        beq     from_u
        cmpa    #%01000000      ; S?
        beq     from_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

from_d  ldx     SAVE_D          ; Get D
        bra     write
from_x  ldx     SAVE_X          ; Get X
        bra     write
from_y  ldx     SAVE_Y          ; Get Y
        bra     write
from_u  ldx     SAVE_U          ; Get U
        bra     write
from_s  ldx     SAVE_S          ; Get S

write   stx     SAVE_PC
        stx     ADDRESS
        lbra    done

; Handle EXG instruction.
; Need to manually handle cases where source or destination is the PC
; since it won't run correctly from the buffer.

tryexg  lda     OPCODE          ; Get the actual op code
        cmpa    #$1E            ; Is it EXG R1,R2 ?
        bne     trypul          ; Branch if not

        ldx     ADDRESS         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%01010000      ; Is source register PC?
        bne     checkdest1      ; Branch if not
        lda     1,x             ; Get operand byte again
        anda    #%00001111      ; Mask destination bits
        bra     doexg           ; Do the exchange
checkdest1
        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000101      ; Is destination register PC?
        lbne    norml           ; Branch and execute normally if not
        lda     1,x             ; Get operand byte again
        anda    #%11110000      ; Mask source bits
        lsr                     ; Shift into low nybble
        lsr
        lsr
        lsr                     ; And fall thru to code below

doexg   ldy     ADDRESS         ; Get current PC
        leay    2,y             ; Add instruction length

        cmpa    #%00000000      ; Exchange D?
        beq     exg_d
        cmpa    #%00000001      ; Exchange X?
        beq     exg_x
        cmpa    #%00000010      ; Exchange Y?
        beq     exg_y
        cmpa    #%00000011      ; Exchange U?
        beq     exg_u
        cmpa    #%00000100      ; Exchange S?
        beq     exg_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

; At this point Y contains PC

exg_d                           ; Swap PC and D
        ldx     SAVE_D
        exg     x,y
        stx     SAVE_D
        bra     fin
exg_x   ldx     SAVE_X          ; Swap PC and X
        exg     x,y
        stx     SAVE_X
exg_y   ldx     SAVE_Y          ; Swap PC and Y
        exg     x,y
        stx     SAVE_Y
exg_u   ldx     SAVE_U          ; Swap PC and U
        exg     x,y
        stx     SAVE_U
exg_s   ldx     SAVE_S          ; Swap PC and S
        exg     x,y
        stx     SAVE_S
fin     sty     ADDRESS
        sty     SAVE_PC
        lbra    done

; Handle PULS/PULU PC,r,r,r
; Could support it, but handling all the combinations of registers
; would take a lot of code. For now, just generate warning that
; instruction is unsupported and being ignored.

trypul  lda     OPCODE          ; Get the actual op code
        cmpa    #$35            ; Is it PULS ?
        beq     pull            ; If so, handle it.
        cmpa    #$37            ; Is it PULU ?
        bne     trypush         ; If no, skip

pull    ldx     ADDRESS         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%10000000      ; Mask PC bit
        cmpa    #%10000000      ; Is PC bit set?
        bne     norml           ; If not, handle nornmally

; Display "Warning: instruction not supported, skipping."

        leax    MSG11,PCR       ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR
        lbra    update          ; Don't execute it

; Handle PSHS/PSHU PC,r,r,r
; Could support it, but handling all the combinations of registers
; would take a lot of code. For now just generate warning that
; instruction is unsupported and results will be incorrect.
; Still execute the instruction.

trypush lda     OPCODE          ; Get the actual op code
        cmpa    #$34            ; Is it PSHS ?
        beq     push            ; If so, handle it.
        cmpa    #$36            ; Is it PSHU ?
        bne     norml           ; If no, skip

push    ldx     ADDRESS         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%10000000      ; Mask PC bit
        cmpa    #%10000000      ; Is PC bit set?
        bne     norml           ; If not, handle nornmally

; Display "Warning: instruction not supported, expect incorrect results."

        leax    MSG12,PCR       ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR
                                ; Fall through and execute it

; Otherwise:
; Not a special instruction. We execute it from the buffer.
; Copy instruction and operands to RAM buffer (based on LEN, can be 1 to 5 bytes)
; TODO: Handle PC relative instructions.


; Thoughts on handling PC relative modes:
; Original code:
; 2013  A6 8D 00 14                lda     tbl,pcr
; 202B  01 02 03 04 05     tbl     fcb     1,2,3,4,5
; Offset $0014 = $202B - ($2013 + 4)
;
; When running in buffer:
; 101C  A6 8D 10 0B                lda     tbl,pcr
; Offset should be $202B - ($101C + 4) = $100B
; Change offset by $100B - $0014 = $0FF7
; Original Address - Buffer Address = $2013 - $101C - $0FF7
; Should be able to fix up offset to run in buffer.
; Can't handle case where offset is 8 bits but won't reach buffer.


norml   ldx     ADDRESS         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        clra                    ; Loop counter and index
copy    ldb     a,x             ; Get instruction byte
        stb     a,y             ; Write to buffer
        inca                    ; Increment counter
        cmpa    LENGTH          ; Copied all bytes?
        bne     copy

; Add a jump after the instruction to where we want to go after it is executed (ReturnFromTrace).

        ldb     #$7E            ; JMP $XXXX instruction
        stb     a,y             ; Store in buffer
        inca                    ; Advance buffer
        ldx     #ReturnFromTrace ; Destination address of JMP
        stx     a,y             ; Store in buffer

; Restore registers from saved values.

        sts     OURS            ; Save this program's stack pointers
        stu     OURU

        ldb     SAVE_B
        ldx     SAVE_X
        ldy     SAVE_Y
        lds     SAVE_S
        ldu     SAVE_U
        lda     SAVE_DP
        tfr     a,dp
        lda     SAVE_CC
        pshu    a
        lda     SAVE_A
        pulu    cc              ; Has to be last so CC is left unchanged

; Call instruction in buffer. It is followed by a JMP ReturnFromTrace so we get back.

        jmp     BUFFER

ReturnFromTrace

; Restore saved registers (except PC).

        pshu    cc              ; Have to save before it changes
        sta     SAVE_A
        pulu    a
        sta     SAVE_CC
        tfr     dp,a
        sta     SAVE_DP
        stb     SAVE_B
        stx     SAVE_X
        sty     SAVE_Y
        sts     SAVE_S
        stu     SAVE_U

; Restore this program's stack pointers so RTS etc. will still work.

        lds     OURS
        ldu     OURU

; Set this program's DP register to zero just in case calling program changed it.

        clra
        tfr     a,dp

; Update new ADDRESS value based on instruction address and length

update  clra                    ; Set MSB to zero
        ldb     LENGTH          ; Get length byte
        addd    ADDRESS         ; 16-bit add
        std     ADDRESS         ; Store new address value

; And return.

done    rts

;------------------------------------------------------------------------
; Display register values
; Uses values in SAVED_A etc.
; e.g.
; PC=FEED A=01 B=02 X=1234 Y=2345 S=2000 U=2000 DP=00 CC=10001101 (EFHINZVC)

DisplayRegs
        leax    MSG1,PCR
        lbsr    PrintString
        ldx     SAVE_PC
        lbsr    PrintAddress

        leax    MSG2,PCR
        lbsr    PrintString
        lda     SAVE_A
        lbsr    PrintByte

        leax    MSG3,PCR
        lbsr    PrintString
        lda     SAVE_B
        lbsr    PrintByte

        leax    MSG4,PCR
        lbsr    PrintString
        ldx     SAVE_X
        lbsr    PrintAddress

        leax    MSG5,PCR
        lbsr    PrintString
        ldx     SAVE_Y
        lbsr    PrintAddress

        leax    MSG6,PCR
        lbsr    PrintString
        ldx     SAVE_S
        lbsr    PrintAddress

        leax    MSG7,PCR
        lbsr    PrintString
        ldx     SAVE_U
        lbsr    PrintAddress

        leax    MSG8,PCR
        lbsr    PrintString
        lda     SAVE_DP
        lbsr    PrintByte

        leax    MSG9,PCR        ; Show CC in binary
        lbsr    PrintString
        ldx     #8              ; Loop counter
        ldb     SAVE_CC         ; Get CC byte
ploop   aslb                    ; Shift bit into carry
        bcs     one             ; Branch if it is a one
        lda     #'0'            ; Print '0'
        bra     prn
one     lda     #'1'            ; Print '1'
prn     jsr     PrintChar
        leax    -1,x            ; Decrement loop counter
        bne     ploop           ; Branch if not done

        leax    MSG10,PCR
        lbsr    PrintString
        lbsr    PrintCR
        rts

MSG1    FCC     "PC="
        FCB     EOT
MSG2    FCC     "A="
        FCB     EOT
MSG3    FCC     "B="
        FCB     EOT
MSG4    FCC     "X="
        FCB     EOT
MSG5    FCC     "Y="
        FCB     EOT
MSG6    FCC     "S="
        FCB     EOT
MSG7    FCC     "U="
        FCB     EOT
MSG8    FCC     "DP="
        FCB     EOT
MSG9    FCC     "CC="
        FCB     EOT
MSG10   FCC     " (EFHINZVC)"
        FCB     EOT
MSG11   FCC     "Warning: instruction not supported, skipping."
        FCB     EOT
MSG12   FCC     "Warning: instruction not supported, expect incorrect results."
        FCB     EOT

;------------------------------------------------------------------------
; Disassemble an instruction. Uses ASSIST09 ROM code.
; e.g. 
; 1053 2001 86 01    lda     #$01

Disassemble
        ldx     SAVE_PC         ; Get address of instruction
        stx     ADRS            ; Pass it to the disassembler
        jsr     DISASM          ; Disassemble one instruction
        rts

; ASSIST09 SWI call numbers

A_VCTRSW equ    9               ; Vector swap
.ECHO   equ     50              ; Secondary command list

;------------------------------------------------------------------------
; Turn off echo when calling keyboard input routines.

EchoOff pshs    a,x             ; Save registers
        ldx     #$FFFF          ; New echo value (off)
        lda     #.ECHO          ; Load subcode for vector swap
        swi                     ; Request service
        fcb     A_VCTRSW        ; Service code byte
        puls    a,x             ; Save registers
        rts                     ; Return to monitor
