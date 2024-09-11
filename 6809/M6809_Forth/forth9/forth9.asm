**************************************************
*                                                *
*               FORTH for the 6809               *
*                                                *
*    This version of FORTH was written to be     *
*    used as a ROM-able bare bones operating     *
*    system for a 6809 based micro-controller.   *
*    The high level defintions are based on      *
*    Thomas Newman's 8086/88 implementation of   *
*    the Forth Interest Group's model in order   *
*    to insure the portability of existing       *
*    code. All of the primitives were written    *
*    during July 1990 by:                        *
*                                                *
*                    Mike Pashea                 *
*          Southern Illinois University          *
*          Dept. of Engineering Box 1801         *
*          Edwardsville, Il. 62026-1801          *
*                  (618)-692-2391                *
*                                                *
*    This FORTH is direct threaded for speed,    *
*    however none of the assembly routines       *
*    have been optimized yet. It appears that    *
*    all of the bugs have been worked out        *
*    though.                                     *
*                                                *
*    The Forth Interest Group's publications     *
*    are public domain and may be obtained       *
*    from:                                       *
*                                                *
*            The Forth Interest Group            *
*            P.O. Box 1105                       *
*            San Carlos, Ca. 94070               *
*                                                *
*    The goal of this project has been to get    *
*    a small system up and running as quickly    *
*    as possible. The following source code      *
*    will assemble using the Motorola Freeware   *
*    6809 Assembler, with the number of          *
*    primitives being kept at a minimum.         *
*    Hopefully this will encourage translation   *
*    to similar Motorola processors, such as     *
*    the 68HC11. I've also commented the         *
*    primatives as much as possible to aid in    *
*    the translation.                            *
*                                                *
*    The target system for which this FORTH      *
*    was written has the following memory map:   *
*                                                *
*    0000-0400  A 2k EEPROM  (for saving code)   *
*    9800-9801  6850 ACIA    (serial port)       *
*    C000-DFFF  An 8k RAM    (FORTH dictionary,  *
*                             TIB and stacks)    *
*    E000-FFFF  An 8k ROM    (ROMable FORTH)     *
*                                                *
*    The current target system is being used     *
*    to develop other micro-controller systems   *
*    with EEPROM. Later hardware versions will   *
*    contain some parallel ports for doing data  *
*    aquisition and control.                     *
*                                                *
*    For the moment, there is no editor. In the  *
*    current system additional definitions are   *
*    written on an IBM PC and saved as an ascii  *
*    file. The definitions are then uploaded     *
*    through the serial port using Kermit. I     *
*    have written an assembler however, and      *
*    I'll give it out as soon as the bugs are    *
*    fixed.                                      *
*                                                *
*    FORTH Register Assignments                  *
*                                                *
*    FORTH  6809     FORTH Preservation Rules    *
*    -----  ----     ------------------------    *
*                                                *
*    IP      Y       INTERPRETER POINTER.        *
*                    MUST BE PRESERVED           *
*                    ACROSS FORTH WORDS.         *
*                                                *
*    W       X       WORD POINTER                *
*                                                *
*    SP      U       PARAMETER STACK POINTER.    *
*                    MUST BE PRESERVED ACROSS    *
*                    FORTH WORDS.                *
*                                                *
*    RP      S       RETURN STACK.               *
*                    MUST BE PRESERVED ACROSS    *
*                    FORTH WORDS.                *
*                                                *
*           RELEASE AND VERSION NUMBERS          *
*                                                *
**************************************************
FIGREL  EQU   1
FIGREV  EQU   0
USRVER  EQU   0

**************************************************
*                                                *
*            ASCII CHARACTERS USED               *
*                                                *
**************************************************
ABL     EQU   $0020          ; A blank
ACR     EQU   $00D0          ; A carriage return
ADOT    EQU   $002E          ; A period
BELL    EQU   $0007          ; A bell (^G)
BSIN    EQU   $005F          ; An input delete
BSOUT   EQU   $0008          ; A output backspace
DLE     EQU   $0010          ; (^P)
LF      EQU   $00A0          ; A line feed
FF      EQU   $00C0          ; A form feed

**************************************************
*                                                *
*               MEMORY ALLOCATION                *
*                                                *
**************************************************
RAMS    EQU   $C000          ; Start of RAM
EM      EQU   $E000          ; End of RAM + 1
NSCR    EQU   $0000          ; Number of 1024 byte screens
KBBUF   EQU   $0080          ; Data bytes per disk buffer
US      EQU   $0040          ; User variable space
RTS     EQU   $00A0          ; Return stack and terminal buffer
CO      EQU   $0084          ; Data bytes per buffer plus 4
NBUF    EQU   $0000          ; Number of buffers
BUF1    EQU   $E000          ; First disk buffer
INITR0  EQU   BUF1-US        ; Base of return stack
INITS0  EQU   INITR0-RTS     ; Base of parameter stack

ACIAC   EQU   $9800          ; ACIA Control
ACIAD   EQU   $9801          ; ACIA Data

**************************************************
*                                                *
*             START OF ROMABLE FORTH             *
*                                                *
**************************************************
        ORG   $E000
ORIG    LDA   #$03           ; Configure the ACIA
        STA   ACIAC
        LDA   #$16
        STA   ACIAC
        LDY   #ENTRY
        LDS   #$DFA0         ; Initial stack pointers
        LDU   #$DF20
        LDX   ,Y++           ; Set up is done, now do FORTH
        JMP   [,X++]
ENTRY   FDB   COLD

**************************************************
*                                                *
*                INITIAL USER TABLE              *
*                                                *
**************************************************
TOP     FDB   RTASK-7        ; Top word in FORTH vocabulary
UTABLE  FDB   INITS0         ; Initial parameter stack base
        FDB   INITR0         ; Initial return stack base
        FDB   INITS0         ; Initial TIB
        FDB   32             ; Initial WIDTH
        FDB   0              ; Initial WARNING
        FDB   INITDP         ; Initial FENCE
        FDB   INITDP         ; Initial DP
        FDB   RFORTH+6       ; Initial VOC-LINK
UP      FDB   INITR0         ; Initial user area pointer
RPP     FDB   INITR0         ; Initial return stack pointer

**************************************************
*                                                *
*           START OF THE FORTH DICTIONARY        *
*                                                *
**************************************************
DP0     FCB   $83
        FCC   'LI'
        FCB   $D4            ; 'T'+$80
        FDB   $0000          ; LFA of zero indicates start of dictionary
LIT     FDB   *+2
        LDD   ,Y++           ; Get Literal
        PSHU  D              ; Push to user stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $87
        FCC   'EXECUT'
        FCB   $C5
        FDB   LIT-6
EXEC    FDB   *+2
        PULU  X              ; Get CFA from parameter stack
        JMP   [,X++]         ; Execute NEXT

        FCB   $86
        FCC   'BRANC'
        FCB   $C8
        FDB   EXEC-10
BRAN    FDB   *+2
BRAN1   LDD   ,Y             ; Get offset value
        LEAY  D,Y            ; Add offset to instruction pointer
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $87
        FCC   '0BRANC'
        FCB   $C8
        FDB   BRAN-9
ZBRAN   FDB   *+2
        PULU  D
        CMPD  #0             ; Is top of stack zero?
        BEQ   BRAN1          ; Yes, must branch
        LEAY  2,Y            ; No, skip branch offset
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $86
        FCC   '(LOOP'
        FCB   $A9
        FDB   ZBRAN-10
XLOOP   FDB   *+2
        LDD   #$0001         ; Assume an increment of 1
XLOO1   ADDD  0,S            ; Add increment to loop index
        STD   0,S            ; Put the new index on the stack
        CMPD  2,S            ; Compare index with limit
        BLT   BRAN1          ; Branch if index < limit
        LEAS  4,S            ; Drop the index and the limit
        LEAY  2,Y            ; Skip the branch offset
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $87
        FCC   '(+LOOP'
        FCB   $A9
        FDB   XLOOP-9
XPLOO   FDB   *+2
        PULU  D              ; Get the increment value
        BRA   XLOO1          ; Go do loop

        FCB   $84
        FCC   '(DO'
        FCB   $A9
        FDB   XPLOO-10
XDO     FDB   *+2
        PULU  D,X            ; Get initial index and limit values
        PSHS  X,D            ; Push to system stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $C9
        FDB   XDO-7
IDO     FDB   *+2
        LDD   0,S            ; Get the index
        PSHU  D              ; Push it to the parameter stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'DIGI'
        FCB   $D4
        FDB   IDO-4
DIGIT   FDB   *+2
        CLRA                 ; Clear high byte
        LDB   3,U            ; Ascii digit is low byte of 2nd on the stack
        SUBB  #$30           ; Convert to binary
        BLO   DIGI2          ; Not a number
        CMPB  #$0A           ; Ascii 0-9?
        BLO   DIGI1          ; Yes, check against base
        CMPB  #$11           ; Ascii A-Z?
        BLO   DIGI2          ; No, less than 'A'
        CMPB  #$2A
        BHI   DIGI2          ; No, greater than 'Z'
        SUBB  #7             ; Legal letter - convert to binary
DIGI1   CMPB  1,U            ; Compare number to base (on top of stack)

                BHS   DIGI2          ; Error if greater than or equal
        STD   2,U            ; No error leave number on the stack
        LDD   #1             ; True flag
        STD   0,U            ; Put flag on top of stack
        BRA   DIGI3          ; NEXT
DIGI2   LEAU  2,U            ; Adjust stack
        LDD   #0             ; False flag
        STD   0,U            ; Put it on the stack
DIGI3   LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $86
        FCC   '(FIND'
        FCB   $A9
        FDB   DIGIT-8
PFIND   FDB   *+2
        PSHS  Y              ; Save IP
        PULU  X              ; LFA of first word in the dictionary search
PFIN1   LDY   0,U            ; Location of packed string (HERE)
        LDB   0,X            ; Get dictionary word length
        TFR   B,A            ; Save the length byte temporarily
        ANDB  #$3F           ; Mask off the two highest bits
        CMPB  0,Y            ; Compare it with the packed string
        BNE   PFIN5          ; Lengths don't match - get another word
PFIN2   LEAX  1,X            ; OK so far - look at the text
        LEAY  1,Y            ;
        LDB   0,X            ; Get next character
        CMPB  0,Y            ; Compare with packed string
        BEQ   PFIN2          ; OK so far - go on to next character
        ANDB  #$7F           ; Doesn't match - toggle high bit
        CMPB  0,Y            ; Try again
        BNE   PFIN6          ; Doesn't match - go get next word
PFIN3   LEAX  5,X            ; We have an exact match - get PFA
        TFR   A,B            ; Retrieve length byte
        CLRA                 ; D now contains the string length byte
        STX   0,U            ; Replace location of packed string with PFA
        LDX   #1             ; Boolean TRUE flag
        PSHU  D              ; Put string length on the stack
        PSHU  X              ; Put boolean flag on the stack
PFIN4   PULS  Y              ; Restore IP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]
PFIN5   LEAX  1,X            ; Skip character count
PFIN6   TST   0,X+           ; Test sign bit
        BPL   PFIN6          ; Keep looking - sign bit is not set
PFIN7   LDX   0,X            ; Get LFA
        CMPX  #0             ; If zero we're at the end of the dictionary
        BNE   PFIN1          ; Look at next word - LFA in X
        STX   0,U            ; Put a boolean false on the stack
        BRA   PFIN4          ; NEXT

        FCB   $87
        FCC   'ENCLOS'
        FCB   $C5
        FDB   PFIND-9
ENCL    FDB   *+2
        PSHS  Y              ; Save the IP
        PULU  D              ; Terminator character is now in B
        LDX   0,U            ; Get starting address, but keep it on the stack
        LDY   #-1            ; Set counter
        LEAX  -1,X           ; Decrement starting address
ENCL1   LEAY  1,Y            ; Increment counter
        LEAX  1,X            ; Increment address
        CMPB  0,X            ; Is character a terminator?
        BEQ   ENCL1          ; Yes, continue looking
        PSHU  Y              ; Character must be text, so push count offset
        TST   0,X            ; Is the character a NULL?
        BNE   ENCL2          ; No, continue
        TFR   Y,X            ; Copy counter
        LEAY  1,Y            ; Increment counter
        BRA   ENCL5          ; Do the push, get IP and do NEXT
ENCL2   LEAY  1,Y            ; Increment counter
        LEAX  1,X            ; Increment address
        CMPB  0,X            ; Is the character a terminator?
        BEQ   ENCL4          ; Yes, finish up
        TST   0,X            ; No, is it a NULL?
        BNE   ENCL2          ; No, continue looking
ENCL3   TFR   Y,X            ; Counters are equal
        BRA   ENCL5          ; Do the push
ENCL4   TFR   Y,X            ; Copy counter
        LEAX  1,X            ; Increment the counter
ENCL5   PSHU  Y,X            ; Do the push
        PULS  Y              ; Restore IP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'EMI'
        FCB   $D4
        FDB   ENCL-10
EMIT    FDB   DOCOL
        FDB   PEMIT
        FDB   ONE
        FDB   OUTT
        FDB   PSTOR
        FDB   SEMIS

        FCB   $83
        FCC   'KE'
        FCB   $D9
        FDB   EMIT-7
KEY     FDB   DOCOL
        FDB   PKEY
        FDB   SEMIS

        FCB   $89
        FCC   '?TERMINA'
        FCB   $CC
        FDB   KEY-6
QTERM   FDB   DOCOL
        FDB   PQTER
        FDB   SEMIS

        FCB   $82
        FCC   'C'
        FCB   $D2
        FDB   QTERM-12
CR      FDB   DOCOL
        FDB   LIT
        FDB   $0D
        FDB   PEMIT
        FDB   LIT
        FDB   $0A
        FDB   PEMIT
        FDB   SEMIS

        FCB   $85
        FCC   'CMOV'
        FCB   $C5
        FDB   CR-5
CMOVE   FDB   *+2
        PSHS  Y              ; Save the instruction pointer
        PULU  D              ; Get the count
        ADDD  0,U            ; Add it to the destination address
        PULU  X,Y            ; Destination in X, Source in Y
        PSHU  D              ; Put final destination addr. on stack
CMOV1   LDA   ,Y+            ; Do the move
        STA   ,X+
        CMPX  0,U            ; At the final destination?
        BLT   CMOV1          ; If not, continue
        LEAU  2,U            ; Drop final destination from the stack
        PULS  Y              ; Restore the instruction pointer
        LDX   ,Y++           ; NEX
        JMP   [,X++]

        FCB   $82
        FCC   'U'
        FCB   $AA
        FDB   CMOVE-8
USTAR   FDB   *+2            ; Unsigned multiplication subroutine
        LDD   0,U            ; Get OP2
        STD   -2,S           ; Save it just below the return stack
        LDD   2,U            ; Get OP1
        STD   -4,S           ; Save it also
        CLR   0,U            ; Clear high order word
        CLR   1,U            ;
        LDA   -3,S           ; Get OP1 low byte
        LDB   -1,S           ; Get OP2 low byte
        MUL                  ; Multiply
        STD   2,U            ; Save the first partial product on the stack
        LDA   -4,S           ; Get OP1 high byte
        LDB   -1,S           ; Get OP2 low byte
        MUL                  ; Multiply
        ADDD  1,U            ; Add to first partial product
        STD   1,U            ; And update
        LDA   -3,S           ; Get OP1 low byte
        LDB   -2,S           ; Get OP2 high byte
        MUL                  ; Multiply
        ADDD  1,U            ; Add to second partial product
        STD   1,U            ; And update
        BCC   NOCARY         ; Check for a carry into high byte
        INC   0,U            ; Add carry if neccesary
NOCARY  LDA   -4,S           ; Get OP1 high byte
        LDB   -2,S           ; Get OP2 high byte
        MUL                  ; Multply
        ADDD  0,U            ; Add to third partial product
        STD   0,U            ; And update - Result is on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'U'
        FCB   $AF
        FDB   USTAR-5
USLAS   FDB   *+2            ; 32 by 16 unsigned division routine
        LDD   0,U            ; Get divisor
        CMPD  #0             ; Check for a divide by zero
        BNE   USLA1          ; OK - continue
        LDD   #-1            ; Trap a divide by zero
        LEAU  6,U            ; Drop all data from stack
        PSHU  D              ; Set flags
        PSHU  D              ;
        BRA   USLA4          ; NEXT
USLA1   LDA   #32            ; Set counter for 32 bit division
        PSHU  A              ; 0,U is the counter - 1,U is the divisor
        LDD   3,U            ; 3,U and 5,U are the high and low words of
        CLRA                 ; the dividend
        CLRB                 ;
USLA2   ASL   6,U            ; Shift dividend and quotient
        ROL   5,U
        ROL   4,U
        ROL   3,U
        ROLB                 ; Shift dividend into D register
        ROLA
        CMPD  1,U            ; Is dividend greater than the divisor?
        BLO   USLA3          ; No, skip subtraction
        SUBD  1,U            ; Yes, do subtraction
        INC   6,U            ; Increment low byte quotient
USLA3   DEC   0,U            ; Decrement counter
        BNE   USLA2          ; Loop for a non-zero count
        LDX   5,U            ; Now the remainder is in D, the quotient is at 5,U
        LEAU  7,U            ; Drop data on the stack
        PSHU  D              ; Push remainder
        PSHU  X              ; Push quotient
USLA4   LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'AN'
        FCB   $C4
        FDB   USLAS-5
ANDD    FDB   *+2
        PULU  D              ; Get top of stack
        ANDA  0,U            ; AND high order byte
        ANDB  1,U            ; AND low order byte
        STD   0,U            ; Leave result on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'O'
        FCB   $D2
        FDB   ANDD-6
ORR     FDB   *+2
        PULU  D              ; Get top of stack
        ORA   0,U            ; OR high order byte
        ORB   1,U            ; OR low order byte
        STD   0,U            ; Leave result on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'XO'
        FCB   $D2
        FDB   ORR-5
XORR    FDB   *+2
        PULU  D              ; Get top stack
        EORA  0,U            ; XOR high order byte
        EORB  1,U            ; XOR low order byte
        STD   0,U            ; Leave result on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'SP'
        FCB   $C0
        FDB   XORR-6
SPAT    FDB   *+2
        TFR   U,D            ; Get current parameter stack pointer
        PSHU  D              ; Put it on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'SP'
        FCB   $A1
        FDB   SPAT-6
SPSTO   FDB   *+2
        LDX   UP             ; Initial user pointer
        LEAX  6,X            ; Point to location in user table
        LDU   0,X            ; Get parameter stack pointer
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'RP'
        FCB   $C0
        FDB   SPSTO-6
RPAT    FDB   *+2
        PSHU  S              ; Get current return stack pointer
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'RP'
        FCB   $A1
        FDB   RPAT-6
RPSTO   FDB   *+2
        LDX   UP             ; Initial user pointer
        LEAX  8,X            ; Point to location in user table
        LDS   0,X            ; Get return stack pointer
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   ';'
        FCB   $D3
        FDB   RPSTO-6
SEMIS   FDB   *+2
        PULS  Y              ; Fetch old IP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'LEAV'
        FCB   $C5
        FDB   SEMIS-5
LEAVE   FDB   *+2
        LDD   0,S            ; Get index
        STD   2,S            ; Store at limit
        LDX   ,Y++           ; NEXT
        JMP   [0,X]

        FCB   $82
        FCC   '>'
        FCB   $D2
        FDB   LEAVE-8
TOR     FDB   *+2
        PULU  D              ; Get top of parameter stack
        PSHS  D              ; Push it to the return stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'R'
        FCB   $BE
        FDB   TOR-5
FROMR   FDB   *+2
        PULS  D              ; Get top of return stack
        PSHU  D              ; Push it to the parameter stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $D2
        FDB   FROMR-5
RR      FDB   IDO+2          ; Does the same as I

        FCB   $82
        FCC   '0'
        FCB   $BD
        FDB   RR-4
ZEQU    FDB   *+2
        PULU  D              ; Get top of stack
        LDX   #1             ; Assume TRUE
        CMPD  #0             ; Compare to zero
        BEQ   ZEQ1           ; See if assumtion is correct
        LEAX  -1,X           ; No, it is FALSE
ZEQ1    PSHU  X              ; Leave flag
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   '0'
        FCB   $BC
        FDB   ZEQU-5
ZLESS   FDB   *+2
        PULU  D              ; Get top of stack
        LDX   #1             ; Assume TRUE
        CMPD  #0             ; Compare to zero
        BLT   ZLESS1         ; Check assumption
        LEAX  -1,X           ; No, it is FALSE
ZLESS1  PSHU  X              ; Leave flag
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $AB
        FDB   ZLESS-5
PLUS    FDB   *+2
        PULU  D              ; Get top of stack
        ADDD  0,U            ; Add it to new top of stack
        STD   0,U            ; Put sum on top of stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'D'
        FCB   $AB
        FDB   PLUS-4
DPLUS   FDB   *+2
        CLRA                 ; Clear A and the carry bit
        LDB   #4             ; Do four bytes
        TFR   U,X            ; Get a reference to the top of the stack
DPLU1   LDA   3,X            ; Get a byte from D2
        ADCA  7,X            ; Add it to a byte from D1 with the carry
        STA   7,X            ; Update
        LEAX  -1,X           ; Adjust X
        DECB                 ; Decrement counter
        BNE   DPLU1          ; Loop if not done
        LEAU  4,U            ; Adjust stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'MINU'
        FCB   $D3
        FDB   DPLUS-5
MINUS   FDB   *+2
        CLRA
        CLRB                 ; Clear D
        SUBD  0,U            ; Get twos complement in D
        STD   0,U            ; Update
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $86
        FCC   'DMINU'
        FCB   $D3
        FDB   MINUS-8
DMINU   FDB   *+2
        COM   0,U            ; Complement the high order bytes of
        COM   1,U            ; The double number
        COM   2,U            ;
        NEG   3,U            ; Twos complement the lowest byte
        BNE   DMIN1          ; And add carrys as needed
        INC   2,U            ;
        BNE   DMIN1          ;
        INC   1,U            ;
        BNE   DMIN1          ;
        INC   0,U            ;
DMIN1   LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'OVE'
        FCB   $D2
        FDB   DMINU-9
OVER    FDB   *+2
        LDD   2,U            ; Get 2nd item on stack
        PSHU  D              ; Put it on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'DRO'
        FCB   $D0
        FDB   OVER-7
DROP    FDB   *+2
        LEAU  2,U            ; Adjust stack pointer
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'SWA'
        FCB   $D0
        FDB   DROP-7
SWAP    FDB   *+2
        PULU  D              ; Get top of stack
        PULU  X              ; Get 2nd on stack
        PSHU  D              ; Top of stack is now 2nd
        PSHU  X              ; 2nd is now top of stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $83
        FCC   'DU'
        FCB   $D0
        FDB   SWAP-7
DUP     FDB   *+2
        LDD   0,U            ; Get top of stack
        PSHU  D              ; Push it back on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   '2DU'
        FCB   $D0
        FDB   DUP-6
TDUP    FDB   *+2
        LDD   0,U            ; Get high order word
        LDX   2,U            ; Get low order word
        PSHU  X,D            ; Do the DUP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   '+'
        FCB   $A1
        FDB   TDUP-7
PSTOR   FDB   *+2
        PULU  X              ; Get address
        PULU  D              ; Get increment
        ADDD  0,X            ; Do addition
        STD   0,X            ; Store addition
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $86
        FCC   'TOGGL'
        FCB   $C5
        FDB   PSTOR-5
TOGGL   FDB   *+2
        PULU  D,X            ; Get bit pattern in B, address in X
        EORB  0,X            ; Do the TOGGLE
        STB   0,X            ; Replace byte
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $C0
        FDB   TOGGL-9
AT      FDB   *+2
        LDD   [0,U]          ; Fetch word pointed to by top of stack
        STD   0,U            ; Put word on the top of stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'C'
        FCB   $C0
        FDB   AT-4
CAT     FDB   *+2
        LDB   [0,U]          ; Fetch byte pointed to by top of stack
        CLRA                 ; Clear high order byte
        STD   0,U            ; Put word on the top of the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]


        FCB   $82
        FCC   '2'
        FCB   $C0
        FDB   CAT-5
TAT     FDB   *+2
        PULU  X              ; Get pointer
        LDD   2,X            ; Get least significant word
        PSHU  D              ; Push it
        LDD   0,X            ; Get most significant word
        PSHU  D              ; Push it
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $A1
        FDB   TAT-5
STORE   FDB   *+2
        PULU  X              ; Get address
        PULU  D              ; Get word in D register
        STD   0,X            ; Store word at address
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'C'
        FCB   $A1
        FDB   STORE-4
CSTOR   FDB   *+2
        PULU  X              ; Get address
        PULU  D              ; Get byte in B register
        STB   0,X            ; Store byte at address
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   '2'
        FCB   $A1
        FDB   CSTOR-5
TSTOR   FDB   *+2
        PULU  X              ; Get address
        PULU  D              ; Get most significant word
        STD   0,X            ; Store it
        PULU  D              ; Get least significant word
        STD   2,X            ; Store it
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $C1
        FCB   $BA
        FDB   TSTOR-5
COLON   FDB   DOCOL
        FDB   QEXEC
        FDB   SCSP
        FDB   CURR
        FDB   AT
        FDB   CONT
        FDB   STORE
        FDB   CREAT
        FDB   RBRAC
        FDB   PSCOD
DOCOL   PSHS  Y              ; Store IP
        LEAY  0,X            ; New IP = WP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $C1
        FCB   $BB
        FDB   COLON-4
SEMI    FDB   DOCOL
        FDB   QCSP
        FDB   COMP
        FDB   SEMIS
        FDB   SMUDG
        FDB   LBRAC
        FDB   SEMIS

        FCB   $84
        FCC   'NOO'
        FCB   $D0
        FDB   SEMI-4
NOOP    FDB   DOCOL
        FDB   SEMIS

        FCB   $88
        FCC   'CONSTAN'
        FCB   $D4
        FDB   NOOP-7
CON     FDB   DOCOL
        FDB   CREAT
        FDB   SMUDG
        FDB   COMMA
        FDB   PSCOD
DOCON   LDD   0,X            ; Get data pointed to by WP
        PSHU  D              ; Push it on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $88
        FCC   'VARIABL'
        FCB   $C5
        FDB   CON-11
VAR     FDB   DOCOL
        FDB   CON
        FDB   PSCOD
DOVAR   PSHU  X              ; Push the word pointer on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'USE'
        FCB   $D2
        FDB   VAR-11
USER    FDB   DOCOL
        FDB   CON
        FDB   PSCOD
DOUSE   LDD   UP             ; Get initial user pointer
        ADDD  0,X            ; Add the offset
        PSHU  D              ; Put it on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $B0
        FDB   USER-7
ZERO    FDB   DOCON
        FDB   0

        FCB   $81
        FCB   $B1
        FDB   ZERO-4
ONE     FDB   DOCON
        FDB   1

        FCB   $81
        FCB   $B2
        FDB   ONE-4
TWO     FDB   DOCON
        FDB   2

        FCB   $81
        FCB   $B3
        FDB   TWO-4
THREE   FDB   DOCON
        FDB   3

        FCB   $82
        FCC   'B'
        FCB   $CC
        FDB   THREE-4
BLS     FDB   DOCON
        FDB   $20

        FCB   $83
        FCC   'C/'
        FCB   $CC
        FDB   BLS-5
CSLL    FDB   DOCON
        FDB   64

        FCB   $85
        FCC   'FIRS'
        FCB   $D4
        FDB   CSLL-6
FIRST   FDB   DOCON
        FDB   BUF1

        FCB   $85
        FCC   'LIMI'
        FCB   $D4
        FDB   FIRST-8
LIMIT   FDB   DOCON
        FDB   EM

        FCB   $85
        FCC   'B/BU'
        FCB   $C6
        FDB   LIMIT-8
BBUF    FDB   DOCON
        FDB   KBBUF

        FCB   $85
        FCC   'B/SC'
        FCB   $D2
        FDB   BBUF-8
BSCR    FDB   DOCON
        FDB   $08

        FCB   $87
        FCC   '+ORIGI'
        FCB   $CE
        FDB   BSCR-8
PORIG   FDB   DOCOL
        FDB   LIT
        FDB   ORIG
        FDB   PLUS
        FDB   SEMIS

*************************************************
*                                               *
*                 USER VARIABLES                *
*                                               *
*************************************************
        FCB   $82
        FCC   'S'
        FCB   $B0
        FDB   PORIG-10
SZERO   FDB   DOUSE
        FDB   6

        FCB   $82
        FCC   'R'
        FCB   $B0
        FDB   SZERO-5
RZERO   FDB   DOUSE
        FDB   8

        FCB   $83
        FCC   'TI'
        FCB   $C2
        FDB   RZERO-5
TIB     FDB   DOUSE
        FDB   10

        FCB   $85
        FCC   'WIDT'
        FCB   $C8
        FDB   TIB-6
WIDTH   FDB   DOUSE
        FDB   12

        FCB   $87
        FCC   'WARNIN'
        FCB   $C7
        FDB   WIDTH-8
WARN    FDB   DOUSE
        FDB   14

        FCB   $85
        FCC   'FENC'
        FCB   $C5
        FDB   WARN-10
FENCE   FDB   DOUSE
        FDB   16

        FCB   $82
        FCC   'D'
        FCB   $D0
        FDB   FENCE-8
DP      FDB   DOUSE
        FDB   18

        FCB   $88
        FCC   'VOC-LIN'
        FCB   $CB
        FDB   DP-5
VOCL    FDB   DOUSE
        FDB   20

        FCB   $83
        FCC   'BL'
        FCB   $CB
        FDB   VOCL-11
BLK     FDB   DOUSE
        FDB   22

        FCB   $82
        FCC   'I'
        FCB   $CE
        FDB   BLK-6
INN     FDB   DOUSE
        FDB   24

        FCB   $83
        FCC   'OU'
        FCB   $D4
        FDB   INN-5
OUTT    FDB   DOUSE
        FDB   26

        FCB   $83
        FCC   'SC'
        FCB   $D2
        FDB   OUTT-6
SCR     FDB   DOUSE
        FDB   28

        FCB   $86
        FCC   'OFFSE'
        FCB   $D4
        FDB   SCR-6
OFSET   FDB   DOUSE
        FDB   30

        FCB   $87
        FCC   'CONTEX'
        FCB   $D4
        FDB   OFSET-9
CONT    FDB   DOUSE
        FDB   32

        FCB   $87
        FCC   'CURREN'
        FCB   $D4
        FDB   CONT-10
CURR    FDB   DOUSE
        FDB   34

        FCB   $85
        FCC   'STAT'
        FCB   $C5
        FDB   CURR-10
STATE   FDB   DOUSE
        FDB   36

        FCB   $84
        FCC   'BAS'
        FCB   $C5
        FDB   STATE-8
BASE    FDB   DOUSE
        FDB   38

        FCB   $83
        FCC   'DP'
        FCB   $CC
        FDB   BASE-7
DPL     FDB   DOUSE
        FDB   40

        FCB   $83
        FCC   'FL'
        FCB   $C4
        FDB   DPL-6
FLD     FDB   DOUSE
        FDB   42

        FCB   $83
        FCC   'CS'
        FCB   $D0
        FDB   FLD-6
CSPP    FDB   DOUSE
        FDB   44

        FCB   $82
        FCC   'R'
        FCB   $A3
        FDB   CSPP-6
RNUM    FDB   DOUSE
        FDB   46

        FCB   $83
        FCC   'HL'
        FCB   $C4
        FDB   RNUM-5
HLD     FDB   DOUSE
        FDB   48

*************************************************
*                                               *
*            END OF USER VARIABLES              *
*                                               *
*************************************************
        FCB   $82
        FCC   '1'
        FCB   $AB
        FDB   HLD-6
ONEP    FDB   *+2
        LDD   0,U            ; Get top of parameter stack
        ADDD  #1             ; Increment top of parameter stack
        STD   0,U            ; Put word back on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   '2'
        FCB   $AB
        FDB   ONEP-5
TWOP    FDB   *+2
        LDD   0,U            ; Get top of parameter stack
        ADDD  #2             ; Add 2
        STD   0,U            ; Put word back on stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $84
        FCC   'HER'
        FCB   $C5
        FDB   TWOP-5
HERE    FDB   DOCOL
        FDB   DP
        FDB   AT
        FDB   SEMIS

        FCB   $85
        FCC   'ALLO'
        FCB   $D4
        FDB   HERE-7
ALLOT   FDB   DOCOL
        FDB   DP
        FDB   PSTOR
        FDB   SEMIS

        FCB   $81
        FCB   $AC
        FDB   ALLOT-8
COMMA   FDB   DOCOL
        FDB   HERE
        FDB   STORE
        FDB   TWO
        FDB   ALLOT
        FDB   SEMIS

        FCB   $82
        FCC   'C'
        FCB   $AC
        FDB   COMMA-4
CCOMM   FDB   DOCOL
        FDB   HERE
        FDB   CSTOR
        FDB   ONE
        FDB   ALLOT
        FDB   SEMIS

        FCB   $81
        FCB   $AD
        FDB   CCOMM-5
SUBB    FDB   *+2
        LDD   2,U            ; Get first value
        SUBD  0,U            ; Do subtraction
        LEAU  2,U            ; Adjust stack
        STD   0,U            ; Put difference on top of stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $81
        FCB   $BD
        FDB   SUBB-4
EQUAL   FDB   DOCOL
        FDB   SUBB
        FDB   ZEQU
        FDB   SEMIS

        FCB   $81
        FCB   $BC
        FDB   EQUAL-4
LESS    FDB   *+2
        PULU  D              ; Get top of stack
        LDX   #0             ; Assume a FALSE
        CMPD  0,U            ; Compare with new top of stack
        BLE   LESS1          ; Yes it is FALSE
        LEAX  1,X            ; No it is TRUE
LESS1   STX   0,U            ; Leave flag on the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $82
        FCC   'U'
        FCB   $BC
        FDB   LESS-4
ULESS   FDB   DOCOL
        FDB   TDUP
        FDB   XORR
        FDB   ZLESS
        FDB   ZBRAN
        FDB   ULES1-*
        FDB   DROP
        FDB   ZLESS
        FDB   ZEQU
        FDB   BRAN
        FDB   ULES2-*
ULES1   FDB   SUBB
        FDB   ZLESS
ULES2   FDB   SEMIS

        FCB   $81
        FCB   $BE
        FDB   ULESS-5
GREAT   FDB   DOCOL
        FDB   SWAP
        FDB   LESS
        FDB   SEMIS

        FCB   $83
        FCC   'RO'
        FCB   $D4
        FDB   GREAT-4
ROT     FDB   *+2
        PSHS  Y              ; Save IP
        PULU  D,X,Y          ; S1 in D, S2 in X, S3 in Y
        PSHU  D,X            ; Put S1 and S2 back on stack
        PSHU  Y              ; Put S3 on top of stack
        PULS  Y              ; Restore IP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'SPAC'
        FCB   $C5
        FDB   ROT-6
SPACE   FDB   DOCOL
        FDB   BLS
        FDB   EMIT
        FDB   SEMIS

        FCB   $84
        FCC   '-DU'
        FCB   $D0
        FDB   SPACE-8
DDUP    FDB   DOCOL
        FDB   DUP
        FDB   ZBRAN
        FDB   DDUP1-*
        FDB   DUP
DDUP1   FDB   SEMIS

        FCB   $88
        FCC   'TRAVERS'
        FCB   $C5
        FDB   DDUP-7
TRAV    FDB   DOCOL
        FDB   SWAP
TRAV1   FDB   OVER
        FDB   PLUS
        FDB   LIT
        FDB   $7F
        FDB   OVER
        FDB   CAT
        FDB   LESS
        FDB   ZBRAN
        FDB   TRAV1-*
        FDB   SWAP
        FDB   DROP
        FDB   SEMIS

        FCB   $86
        FCC   'LATES'
        FCB   $D4
        FDB   TRAV-11
LATES   FDB   DOCOL
        FDB   CURR
        FDB   AT
        FDB   AT
        FDB   SEMIS

        FCB   $83
        FCC   'LF'
        FCB   $C1
        FDB   LATES-9
LFA     FDB   DOCOL
        FDB   LIT
        FDB   4
        FDB   SUBB
        FDB   SEMIS

        FCB   $83
        FCC   'CF'
        FCB   $C1
        FDB   LFA-6
CFA     FDB   DOCOL
        FDB   TWO
        FDB   SUBB
        FDB   SEMIS

        FCB   $83
        FCC   'NF'
        FCB   $C1
        FDB   CFA-6
NFA     FDB   DOCOL
        FDB   LIT
        FDB   5
        FDB   SUBB
        FDB   LIT
        FDB   -1
        FDB   TRAV
        FDB   SEMIS

        FCB   $83
        FCC   'PF'
        FCB   $C1
        FDB   NFA-6
PFA     FDB   DOCOL
        FDB   ONE
        FDB   TRAV
        FDB   LIT
        FDB   5
        FDB   PLUS
        FDB   SEMIS

        FCB   $84
        FCC   '!CS'
        FCB   $D0
        FDB   PFA-6
SCSP    FDB   DOCOL
        FDB   SPAT
        FDB   CSPP
        FDB   STORE
        FDB   SEMIS

        FCB   $86
        FCC   '?ERRO'
        FCB   $D2
        FDB   SCSP-7
QERR    FDB   DOCOL
        FDB   SWAP
        FDB   ZBRAN
        FDB   QERR1-*
        FDB   ERROR
        FDB   BRAN
        FDB   QERR2-*
QERR1   FDB   DROP
QERR2   FDB   SEMIS

        FCB   $85
        FCC   '?COM'
        FCB   $D0
        FDB   QERR-9
QCOMP   FDB   DOCOL
        FDB   STATE
        FDB   AT
        FDB   ZEQU
        FDB   LIT
        FDB   $11
        FDB   QERR
        FDB   SEMIS

        FCB   $85
        FCC   'QEXE'
        FCB   $C3
        FDB   QCOMP-8
QEXEC   FDB   DOCOL
        FDB   STATE
        FDB   AT
        FDB   LIT
        FDB   $12
        FDB   QERR
        FDB   SEMIS

        FCB   $86
        FCC   '?PAIR'
        FCB   $D3
        FDB   QEXEC-8
QPAIR   FDB   DOCOL
        FDB   SUBB
        FDB   LIT
        FDB   $13
        FDB   QERR
        FDB   SEMIS

        FCB   $84
        FCC   '?CS'
        FCB   $D0
        FDB   QPAIR-9
QCSP    FDB   DOCOL
        FDB   SPAT
        FDB   CSPP
        FDB   AT
        FDB   SUBB
        FDB   LIT
        FDB   $14
        FDB   QERR
        FDB   SEMIS

        FCB   $88
        FCC   '?LOADIN'
        FCB   $C7
        FDB   QCSP-7
QLOAD   FDB   DOCOL
        FDB   BLK
        FDB   AT
        FDB   ZEQU
        FDB   LIT
        FDB   $16
        FDB   QERR
        FDB   SEMIS

        FCB   $87
        FCC   'COMPIL'
        FCB   $C5
        FDB   QLOAD-11
COMP    FDB   DOCOL
        FDB   QCOMP
        FDB   FROMR
        FDB   DUP
        FDB   TWOP
        FDB   TOR
        FDB   AT
        FDB   COMMA
        FDB   SEMIS

        FCB   $C1
        FCB   $DB
        FDB   COMP-10
LBRAC   FDB   DOCOL
        FDB   ZERO
        FDB   STATE
        FDB   STORE
        FDB   SEMIS

        FCB   $81
        FCB   $DD
        FDB   LBRAC-4
RBRAC   FDB   DOCOL
        FDB   LIT
        FDB   $00C0
        FDB   STATE
        FDB   STORE
        FDB   SEMIS

        FCB   $86
        FCC   'SMUDG'
        FCB   $C5
        FDB   RBRAC-4
SMUDG   FDB   DOCOL
        FDB   LATES
        FDB   LIT
        FDB   $20
        FDB   TOGGL
        FDB   SEMIS

        FCB   $83
        FCC   'HE'
        FCB   $D8
        FDB   SMUDG-9
HEX     FDB   DOCOL
        FDB   LIT
        FDB   16
        FDB   BASE
        FDB   STORE
        FDB   SEMIS

        FCB   $87
        FCC   'DECIMA'
        FCB   $CC
        FDB   HEX-6
DECA    FDB   DOCOL
        FDB   LIT
        FDB   10
        FDB   BASE
        FDB   STORE
        FDB   SEMIS

        FCB   $87
        FCC   '(;CODE'
        FCB   $A9
        FDB   DECA-10
PSCOD   FDB   DOCOL
        FDB   FROMR
        FDB   LATES
        FDB   PFA
        FDB   CFA
        FDB   STORE
        FDB   SEMIS

        FCB   $C5
        FCC   ';COD'
        FCB   $C5
        FDB   PSCOD-10
SEMIC   FDB   DOCOL
        FDB   QCSP
        FDB   COMP
        FDB   PSCOD
        FDB   LBRAC
        FDB   SEMIS

        FCB   $87
        FCC   '<BUILD'
        FCB   $D3
        FDB   SEMIC-8
BUILD   FDB   DOCOL
        FDB   ZERO
        FDB   CON
        FDB   SEMIS

        FCB   $85
        FCC   'DOES'
        FCB   $BE
        FDB   BUILD-10
DOES    FDB   DOCOL
        FDB   FROMR
        FDB   LATES
        FDB   PFA
        FDB   STORE
        FDB   PSCOD
DODOE   PSHS  Y              ; Save instruction pointer
        LDY   ,X++           ; IP=[WP] , WP=WP+2
        PSHU  X              ; Put WP on parameter stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'COUN'
        FCB   $D4
        FDB   DOES-8
COUNT   FDB   DOCOL
        FDB   DUP
        FDB   ONEP
        FDB   SWAP
        FDB   CAT
        FDB   SEMIS

        FCB   $84
        FCC   'TYP'
        FCB   $C5
        FDB   COUNT-8
TYPES   FDB   DOCOL
        FDB   DDUP
        FDB   ZBRAN
        FDB   TYPE1-*
        FDB   OVER
        FDB   PLUS
        FDB   SWAP
        FDB   XDO
TYPE2   FDB   IDO
        FDB   CAT
        FDB   EMIT
        FDB   XLOOP
        FDB   TYPE2-*
        FDB   BRAN
        FDB   TYPE3-*
TYPE1   FDB   DROP
TYPE3   FDB   SEMIS

        FCB   $89
        FCC   '-TRAILIN'
        FCB   $C7
        FDB   TYPES-7
DTRAI   FDB   DOCOL
        FDB   DUP
        FDB   ZERO
        FDB   XDO
DTRA1   FDB   OVER
        FDB   OVER
        FDB   PLUS
        FDB   ONE
        FDB   SUBB
        FDB   CAT
        FDB   BLS
        FDB   SUBB
        FDB   ZBRAN
        FDB   DTRA2-*
        FDB   LEAVE
        FDB   BRAN
        FDB   DTRA3-*
DTRA2   FDB   ONE
        FDB   SUBB
DTRA3   FDB   XLOOP
        FDB   DTRA1-*
        FDB   SEMIS

        FCB   $84
        FCC   '(."'
        FCB   $A9
        FDB   DTRAI-12
PDOTQ   FDB   DOCOL
        FDB   RR
        FDB   COUNT
        FDB   DUP
        FDB   ONEP
        FDB   FROMR
        FDB   PLUS
        FDB   TOR
        FDB   TYPES
        FDB   SEMIS

        FCB   $C2
        FCC   '.'
        FCB   $A2
        FDB   PDOTQ-7
DOTQ    FDB   DOCOL
        FDB   LIT
        FDB   $22
        FDB   STATE
        FDB   AT
        FDB   ZBRAN
        FDB   DOTQ1-*
        FDB   COMP
        FDB   PDOTQ
        FDB   WORDS
        FDB   HERE
        FDB   CAT
        FDB   ONEP
        FDB   ALLOT
        FDB   BRAN
        FDB   DOTQ2-*
DOTQ1   FDB   WORDS
        FDB   HERE
        FDB   COUNT
        FDB   TYPES
DOTQ2   FDB   SEMIS

        FCB   $86
        FCC   'EXPEC'
        FCB   $D4
        FDB   DOTQ-5
EXPEC   FDB   DOCOL
        FDB   OVER
        FDB   PLUS
        FDB   OVER
        FDB   XDO
EXPE1   FDB   KEY
        FDB   DUP
        FDB   LIT
        FDB   BSOUT
        FDB   EQUAL
        FDB   ZBRAN
        FDB   EXPE2-*
        FDB   DROP
        FDB   DUP
        FDB   IDO
        FDB   EQUAL
        FDB   DUP
        FDB   FROMR
        FDB   TWO
        FDB   SUBB
        FDB   PLUS
        FDB   TOR
        FDB   ZBRAN
        FDB   EXPE6-*
        FDB   LIT
        FDB   BELL
        FDB   BRAN
        FDB   EXPE7-*
EXPE6   FDB   LIT
        FDB   BSOUT
EXPE7   FDB   BRAN
        FDB   EXPE3-*
EXPE2   FDB   DUP
        FDB   LIT
        FDB   $0D
        FDB   EQUAL
        FDB   ZBRAN
        FDB   EXPE4-*
        FDB   LEAVE
        FDB   DROP
        FDB   BLS
        FDB   ZERO
        FDB   BRAN
        FDB   EXPE5-*
EXPE4   FDB   DUP
EXPE5   FDB   IDO
        FDB   CSTOR
        FDB   ZERO
        FDB   IDO
        FDB   ONEP
        FDB   STORE
EXPE3   FDB   EMIT
        FDB   XLOOP
        FDB   EXPE1-*
        FDB   DROP
        FDB   SEMIS

        FCB   $85
        FCC   'QUER'
        FCB   $D9
        FDB   EXPEC-9
QUERY   FDB   DOCOL
        FDB   TIB
        FDB   AT
        FDB   LIT
        FDB   $50
        FDB   EXPEC
        FDB   ZERO
        FDB   INN
        FDB   STORE
        FDB   SEMIS

        FCB     $C1
        FCB     $80
        FDB     QUERY-8
NULL    FDB     DOCOL
        FDB     BLK
        FDB     AT
        FDB     ZBRAN
        FDB     NULL1-*
        FDB     ONE
        FDB     BLK
        FDB     PSTOR
        FDB     ZERO
        FDB     INN
        FDB     STORE
        FDB     BLK
        FDB     AT
        FDB     BSCR
        FDB     ONE
        FDB     SUBB
        FDB     ANDD
        FDB     ZEQU
        FDB     ZBRAN
        FDB     NULL2-*
        FDB     QEXEC
        FDB     FROMR
        FDB     DROP
NULL2   FDB     BRAN
        FDB     NULL3-*
NULL1   FDB     FROMR
        FDB     DROP
NULL3   FDB     SEMIS


        FCB   $84
        FCC   'FIL'
        FCB   $CC
        FDB   NULL-4
FILL    FDB   *+2
        PSHS  Y              ; Save IP
        PULU  D,X,Y          ; Character in B, count in X, address in Y
FILL1   STB   ,Y+            ; Store character
        LEAX  -1,X           ; Decrement counter
        BNE   FILL1          ; Loop until done
        PULS  Y              ; Get IP
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $85
        FCC   'ERAS'
        FCB   $C5
        FDB   FILL-7
ERASEE  FDB   DOCOL
        FDB   ZERO
        FDB   FILL
        FDB   SEMIS

        FCB   $86
        FCC   'BLANK'
        FCB   $D3
        FDB   ERASEE-8
BLANK   FDB   DOCOL
        FDB   BLS
        FDB   FILL
        FDB   SEMIS

        FCB   $84
        FCC   'HOL'
        FCB   $C4
        FDB   BLANK-9
HOLD    FDB   DOCOL
        FDB   LIT
        FDB   -1
        FDB   HLD
        FDB   PSTOR
        FDB   HLD
        FDB   AT
        FDB   CSTOR
        FDB   SEMIS

        FCB   $83
        FCC   'PA'
        FCB   $C4
        FDB   HOLD-7
PAD     FDB   DOCOL
        FDB   HERE
        FDB   LIT
        FDB   $44
        FDB   PLUS
        FDB   SEMIS

        FCB   $84
        FCC   'WOR'
        FCB   $C4
        FDB   PAD-6
WORDS   FDB   DOCOL
        FDB   TIB
        FDB   AT
        FDB   INN
        FDB   AT
        FDB   PLUS
        FDB   SWAP
        FDB   ENCL
        FDB   HERE
        FDB   LIT
        FDB   $0022
        FDB   BLANK
        FDB   INN
        FDB   PSTOR
        FDB   OVER
        FDB   SUBB
        FDB   TOR
        FDB   RR
        FDB   HERE
        FDB   CSTOR
        FDB   PLUS
        FDB   HERE
        FDB   ONEP
        FDB   FROMR
        FDB   CMOVE
        FDB   SEMIS

        FCB   $88
        FCC   '(NUMBER'
        FCB   $A9
        FDB   WORDS-7
PNUMB   FDB   DOCOL
PNUM1   FDB   ONEP
        FDB   DUP
        FDB   TOR
        FDB   CAT
        FDB   BASE
        FDB   AT
        FDB   DIGIT
        FDB   ZBRAN
        FDB   PNUM2-*
        FDB   SWAP
        FDB   BASE
        FDB   AT
        FDB   USTAR
        FDB   DROP
        FDB   ROT
        FDB   BASE
        FDB   AT
        FDB   USTAR
        FDB   DPLUS
        FDB   DPL
        FDB   AT
        FDB   ONEP
        FDB   ZBRAN
        FDB   PNUM3-*
        FDB   ONE
        FDB   DPL
        FDB   PSTOR
PNUM3   FDB   FROMR
        FDB   BRAN
        FDB   PNUM1-*
PNUM2   FDB   FROMR
        FDB   SEMIS

        FCB   $86
        FCC   'NUMBE'
        FCB   $D2
        FDB   PNUMB-11
NUMB    FDB   DOCOL
        FDB   ZERO
        FDB   ZERO
        FDB   ROT
        FDB   DUP
        FDB   ONEP
        FDB   CAT
        FDB   LIT
        FDB   $2D
        FDB   EQUAL
        FDB   DUP
        FDB   TOR
        FDB   PLUS
        FDB   LIT
        FDB   -1
NUMB1   FDB   DPL
        FDB   STORE
        FDB   PNUMB
        FDB   DUP
        FDB   CAT
        FDB   BLS
        FDB   SUBB
        FDB   ZBRAN
        FDB   NUMB2-*
        FDB   DUP
        FDB   CAT
        FDB   LIT
        FDB   $2E
        FDB   SUBB
        FDB   ZERO
        FDB   QERR
        FDB   ZERO
        FDB   BRAN
        FDB   NUMB1-*
NUMB2   FDB   DROP
        FDB   FROMR
        FDB   ZBRAN
        FDB   NUMB3-*
        FDB   DMINU
NUMB3   FDB   SEMIS

        FCB   $85
        FCC   '-FIN'
        FCB   $C4
        FDB   NUMB-9
DFIND   FDB   DOCOL
        FDB   BLS
        FDB   WORDS
        FDB   HERE
        FDB   CONT
        FDB   AT
        FDB   AT
        FDB   PFIND
        FDB   DUP
        FDB   ZEQU
        FDB   ZBRAN
        FDB   DFIN1-*
        FDB   DROP
        FDB   HERE
        FDB   LATES
        FDB   PFIND
DFIN1   FDB   SEMIS

        FCB   $87
        FCC   '(ABORT'
        FCB   $A9
        FDB   DFIND-8
PABOR   FDB   DOCOL
        FDB   ABORT
        FDB   SEMIS

        FCB   $85
        FCC   'ERRO'
        FCB   $D2
        FDB   PABOR-10
ERROR   FDB   DOCOL
        FDB   WARN
        FDB   AT
        FDB   ZLESS
        FDB   ZBRAN
        FDB   ERRO1-*
        FDB   PABOR
ERRO1   FDB   HERE
        FDB   COUNT
        FDB   TYPES
        FDB   PDOTQ
        FCB   2
        FCC   '? '
        FDB   MESS
        FDB   SPSTO
        FDB   BLK
        FDB   AT
        FDB   DDUP
        FDB   ZBRAN
        FDB   ERR02-*
        FDB   INN
        FDB   AT
        FDB   SWAP
ERR02   FDB   QUIT
        FDB   SEMIS          ; Never executed

        FCB   $83
        FCC   'ID'
        FCB   $AE
        FDB   ERROR-8
IDDOT   FDB   DOCOL
        FDB   PAD
        FDB   LIT
        FDB   $20
        FDB   LIT
        FDB   $5F
        FDB   FILL
        FDB   DUP
        FDB   PFA
        FDB   LFA
        FDB   OVER
        FDB   SUBB
        FDB   PAD
        FDB   SWAP
        FDB   CMOVE
        FDB   PAD
        FDB   COUNT
        FDB   LIT
        FDB   $1F
        FDB   ANDD
        FDB   TYPES
        FDB   SPACE
        FDB   SEMIS

        FCB   $86
        FCC   'CREAT'
        FCB   $C5
        FDB   IDDOT-6
CREAT   FDB   DOCOL
        FDB   DFIND
        FDB   ZBRAN
        FDB   CREAT1-*
        FDB   DROP
        FDB   NFA
        FDB   IDDOT
        FDB   LIT
        FDB   4
        FDB   MESS
        FDB   SPACE
CREAT1  FDB   HERE
        FDB   DUP
        FDB   CAT
        FDB   WIDTH
        FDB   AT
        FDB   MIN
        FDB   ONEP
        FDB   ALLOT
        FDB   DUP
        FDB   LIT
        FDB   $A0
        FDB   TOGGL
        FDB   HERE
        FDB   ONE
        FDB   SUBB
        FDB   LIT
        FDB   $80
        FDB   TOGGL
        FDB   LATES
        FDB   COMMA
        FDB   CURR
        FDB   AT
        FDB   STORE
        FDB   HERE
        FDB   TWOP
        FDB   COMMA
        FDB   SEMIS

        FCB   $C9
        FCC   '[COMPILE'
        FCB   $DD
        FDB   CREAT-9
BCOMP   FDB   DOCOL
        FDB   DFIND
        FDB   ZEQU
        FDB   ZERO
        FDB   QERR
        FDB   DROP
        FDB   CFA
        FDB   COMMA
        FDB   SEMIS

        FCB   $C7
        FCC   'LITERA'
        FCB   $CC
        FDB   BCOMP-12
LITER   FDB   DOCOL
        FDB   STATE
        FDB   AT
        FDB   ZBRAN
        FDB   LITE1-*
        FDB   COMP
        FDB   LIT
        FDB   COMMA
LITE1   FDB   SEMIS

        FCB   $C8
        FCC   'DLITERA'
        FCB   $CC
        FDB   LITER-10
DLITE   FDB   DOCOL
        FDB   STATE
        FDB   AT
        FDB   ZBRAN
        FDB   DLIT1-*
        FDB   SWAP
        FDB   LITER
        FDB   LITER
DLIT1   FDB   SEMIS

        FCB   $86
        FCC   '?STAC'
        FCB   $CB
        FDB   DLITE-11
QSTAC   FDB   DOCOL
        FDB   SPAT
        FDB   SZERO
        FDB   AT
        FDB   SWAP
        FDB   ULESS
        FDB   ONE
        FDB   QERR
        FDB   SPAT
        FDB   HERE
        FDB   LIT
        FDB   $80
        FDB   PLUS
        FDB   ULESS
        FDB   LIT
        FDB   7
        FDB   QERR
        FDB   SEMIS

        FCB   $89
        FCC   'INTERPRE'
        FCB   $D4
        FDB   QSTAC-9
INTER   FDB   DOCOL
INTE1   FDB   DFIND
        FDB   ZBRAN
        FDB   INTE2-*
        FDB   STATE
        FDB   AT
        FDB   LESS
        FDB   ZBRAN
        FDB   INTE3-*
        FDB   CFA
        FDB   COMMA
        FDB   BRAN
        FDB   INTE4-*
INTE3   FDB   CFA
        FDB   EXEC
INTE4   FDB   QSTAC
        FDB   BRAN
        FDB   INTE5-*
INTE2   FDB   HERE
        FDB   NUMB
        FDB   DPL
        FDB   AT
        FDB   ONEP
        FDB   ZBRAN
        FDB   INTE6-*
        FDB   DLITE
        FDB   BRAN
        FDB   INTE7-*
INTE6   FDB   DROP
        FDB   LITER
INTE7   FDB   QSTAC
INTE5   FDB   BRAN
        FDB   INTE1-*
        FDB   SEMIS          ; Never executed

        FCB   $89
        FCC   'IMMEDIAT'
        FCB   $C5
        FDB   INTER-12
IMMED   FDB   DOCOL
        FDB   LATES
        FDB   LIT
        FDB   $40
        FDB   TOGGL
        FDB   SEMIS

        FCB   $8A
        FCC   'VOCABULAR'
        FCB   $D9
        FDB   IMMED-12
VOCAB   FDB   DOCOL
        FDB   BUILD
        FDB   LIT
        FDB   $81A0
        FDB   COMMA
        FDB   CURR
        FDB   AT
        FDB   CFA
        FDB   COMMA
        FDB   HERE
        FDB   VOCL
        FDB   AT
        FDB   COMMA
        FDB   VOCL
        FDB   STORE
        FDB   DOES
DOVOC   FDB   TWOP
        FDB   CONT
        FDB   STORE
        FDB   SEMIS

**************************************************
*                                                *
*       FORTH is not included here for the       *
*       ROMable version because FORTH is a       *
*       variable and must lie in RAM             *
*                                                *
**************************************************

        FCB   $8B
        FCC   'DEFINITION'
        FCB   $D3
        FDB   VOCAB-13
DEFIN   FDB   DOCOL
        FDB   CONT
        FDB   AT
        FDB   CURR
        FDB   STORE
        FDB   SEMIS

        FCB   $C1
        FCB   $A8
        FDB   DEFIN-14
PAREN   FDB   DOCOL
        FDB   LIT
        FDB   $29
        FDB   WORDS
        FDB   SEMIS

        FCB   $84
        FCC   'QUI'
        FCB   $D4
        FDB   PAREN-4
QUIT    FDB   DOCOL
        FDB   ZERO
        FDB   BLK
        FDB   STORE
        FDB   LBRAC
QUIT1   FDB   RPSTO
        FDB   CR
        FDB   QUERY
        FDB   INTER
        FDB   STATE
        FDB   AT
        FDB   ZEQU
        FDB   ZBRAN
        FDB   QUIT2-*
        FDB   PDOTQ
        FCB   2
        FCC   'ok'
QUIT2   FDB   BRAN
        FDB   QUIT1-*
        FDB   SEMIS          ; Never executed

        FCB   $85
        FCC   'ABOR'
        FCB   $D4
        FDB   QUIT-7
ABORT   FDB   DOCOL
        FDB   SPSTO
        FDB   DECA
        FDB   QSTAC
        FDB   CR
        FDB   RFORTH
        FDB   DEFIN
        FDB   QUIT
        FDB   SEMIS          ; Never executed

        FCB   $84
        FCC   'WAR'
        FCB   $CD
        FDB   ABORT-8
WARM    FDB   DOCOL
        FDB   ABORT
        FDB   SEMIS          ; Never executed

        FCB   $84
        FCC   'COL'
        FCB   $C4
        FDB   WARM-7
COLD    FDB   DOCOL
        FDB   LIT
        FDB   UTABLE
        FDB   LIT
        FDB   UP
        FDB   AT
        FDB   LIT
        FDB   6
        FDB   PLUS
        FDB   LIT
        FDB   16
        FDB   CMOVE
        FDB   SPSTO
        FDB   LIT
        FDB   FORTHS
        FDB   LIT
        FDB   RAMS
        FDB   LIT
        FDB   TASKE-FORTHS
        FDB   CMOVE
        FDB   LIT
        FDB   TOP
        FDB   AT
        FDB   LIT
        FDB   RFORTH+6
        FDB   STORE
        FDB   CR
        FDB   DOTCPU
        FDB   PDOTQ
        FCB   14
        FCC   'microFORTH '
        FCB   FIGREL+$30
        FCB   ADOT
        FCB   FIGREV+$30
        FDB   CR
        FDB   PDOTQ
        FCB   44
        FCC   'Southern Illinois University at Edwardsville'
        FDB   CR
        FDB   PDOTQ
        FCB   20
        FCC   'Micro-controller Lab'
        FDB   CR
        FDB   PDOTQ
        FCB   28
        FCC   'Dictionary space available: '
        FDB   SPAT
        FDB   DP
        FDB   AT
        FDB   SUBB
        FDB   UDOT
        FDB   PDOTQ
        FCB   5
        FCC   'bytes'
        FDB   CR
        FDB   ABORT
        FDB   SEMIS          ; Never executed

        FCB   $84
        FCC   'S->'
        FCB   $C4
        FDB   COLD-7
STOD    FDB   DOCOL
        FDB   DUP
        FDB   ZLESS
        FDB   MINUS
        FDB   SEMIS

        FCB   $82
        FCC   '+'
        FCB   $AD
        FDB   STOD-7
PM      FDB   DOCOL
        FDB   ZLESS
        FDB   ZBRAN
        FDB   PM1-*
        FDB   MINUS
PM1     FDB   SEMIS

        FCB   $83
        FCC   'D+'
        FCB   $AD
        FDB   PM-5
DPM     FDB   DOCOL
        FDB   ZLESS
        FDB   ZBRAN
        FDB   DPM1-*
        FDB   DMINU
DPM1    FDB   SEMIS

        FCB   $83
        FCC   'AB'
        FCB   $D3
        FDB   DPM-6
ABS     FDB   DOCOL
        FDB   DUP
        FDB   PM
        FDB   SEMIS

        FCB   $84
        FCC   'DAB'
        FCB   $D3
        FDB   ABS-6
DABS    FDB   DOCOL
        FDB   DUP
        FDB   DPM
        FDB   SEMIS

        FCB   $83
        FCC   'MI'
        FCB   $CE
        FDB   DABS-7
MIN     FDB   DOCOL
        FDB   TDUP
        FDB   GREAT
        FDB   ZBRAN
        FDB   MIN1-*
        FDB   SWAP
MIN1    FDB   DROP
        FDB   SEMIS

        FCB   $83
        FCC   'MA'
        FCB   $D8
        FDB   MIN-6
MAX     FDB   DOCOL
        FDB   TDUP
        FDB   LESS
        FDB   ZBRAN
        FDB   MAX1-*
        FDB   SWAP
MAX1    FDB   DROP
        FDB   SEMIS

        FCB   $82
        FCC   'M'
        FCB   $AA
        FDB   MAX-6
MSTAR   FDB   DOCOL
        FDB   TDUP
        FDB   XORR
        FDB   TOR
        FDB   ABS
        FDB   SWAP
        FDB   ABS
        FDB   USTAR
        FDB   FROMR
        FDB   DPM
        FDB   SEMIS

        FCB   $82
        FCC   'M'
        FCB   $AF
        FDB   MSTAR-5
MSLAS   FDB   DOCOL
        FDB   OVER
        FDB   TOR
        FDB   TOR
        FDB   DABS
        FDB   RR
        FDB   ABS
        FDB   USLAS
        FDB   FROMR
        FDB   RR
        FDB   XORR
        FDB   PM
        FDB   SWAP
        FDB   FROMR
        FDB   PM
        FDB   SWAP
        FDB   SEMIS

        FCB   $81
        FCB   $AA
        FDB   MSLAS-5
STAR    FDB   DOCOL
        FDB   MSTAR
        FDB   DROP
        FDB   SEMIS

        FCB   $84
        FCC   '/MO'
        FCB   $C4
        FDB   STAR-4
SLMOD   FDB   DOCOL
        FDB   TOR
        FDB   STOD
        FDB   FROMR
        FDB   MSLAS
        FDB   SEMIS

        FCB   $81
        FCB   $AF
        FDB   SLMOD-7
SLASH   FDB   DOCOL
        FDB   SLMOD
        FDB   SWAP
        FDB   DROP
        FDB   SEMIS

        FCB   $83
        FCC   'MO'
        FCB   $C4
        FDB   SLASH-4
MOD     FDB   DOCOL
        FDB   SLMOD
        FDB   DROP
        FDB   SEMIS

        FCB   $85
        FCC   '*/MO'
        FCB   $C4
        FDB   MOD-6
SSMOD   FDB   DOCOL
        FDB   TOR
        FDB   MSTAR
        FDB   FROMR
        FDB   MSLAS
        FDB   SEMIS

        FCB   $82
        FCC   '*'
        FCB   $AF
        FDB   SSMOD-8
SSLASH  FDB   DOCOL
        FDB   SSMOD
        FDB   SWAP
        FDB   DROP
        FDB   SEMIS

        FCB   $85
        FCC   'M/MO'
        FCB   $C4
        FDB   SSLASH-5
MSMOD   FDB   DOCOL
        FDB   TOR
        FDB   ZERO
        FDB   RR
        FDB   USLAS
        FDB   FROMR
        FDB   SWAP
        FDB   TOR
        FDB   USLAS
        FDB   FROMR
        FDB   SEMIS

        FCB   $87
        FCC   'MESSAG'
        FCB   $C5
        FDB   MSMOD-8
MESS    FDB   DOCOL
        FDB   WARN
        FDB   AT
        FDB   ZBRAN
        FDB   MESS1-*
        FDB   DDUP
        FDB   ZBRAN
        FDB   MESS2-*
        FDB   LIT
        FDB   4
        FDB   OFSET
        FDB   AT
        FDB   BSCR
        FDB   SLASH
        FDB   SUBB
        FDB   PDOTQ
        FCB   6
        FCC   ' DLINE'
        FDB   SPACE
MESS2   FDB   BRAN
        FDB   MESS3-*
MESS1   FDB   PDOTQ
        FCB   6
        FCC   'MSG # '
        FDB   DOT
MESS3   FDB   SEMIS

PKEY    FDB   *+2
PKEY1   LDA   ACIAC          ; Get control status of the ACIA
        ASRA                 ; Check if buffer is empty
        BCC   PKEY1          ; If so, wait
        LDB   ACIAD          ; Get data
        CLRA
        PSHU  D              ; Push character to the stack
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

PQTER   FDB   *+2
        LDA   ACIAC          ; Get control status of the ACIA
        ASRA                 ; Check if buffer is empty
        BCC   PQTER1         ; If so push ZERO flag
        LDB   ACIAD          ; If not, get key
        CLRA
        PSHU  D
        BRA   PQTER2         ; Go do NEXT
PQTER1  LDD   #0
        PSHU  D              ; Push flag
PQTER2  LDX   ,Y++           ; NEXT
        JMP   [,X++]

PEMIT   FDB   *+2
        PULU  D              ; Character in B register
        ANDB  #$7F           ; Mask off the highest bit
PEMIT1  LDA   ACIAC          ; Get ACIA status
        ASRA                 ; Check if ready to transmit
        ASRA
        BCC   PEMIT1         ; Loop if not ready
        STB   ACIAD          ; Transmit character
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

        FCB   $C1
        FCB   $A7
        FDB   MESS-10
TICK    FDB   DOCOL
        FDB   DFIND
        FDB   ZEQU
        FDB   ZERO
        FDB   QERR
        FDB   DROP
        FDB   LITER
        FDB   SEMIS

        FCB   $86
        FCC   'FORGE'
        FCB   $D4
        FDB   TICK-4
FORGET  FDB   DOCOL
        FDB   CURR
        FDB   AT
        FDB   CONT
        FDB   AT
        FDB   SUBB
        FDB   LIT
        FDB   $18
        FDB   QERR
        FDB   TICK
        FDB   DUP
        FDB   FENCE
        FDB   AT
        FDB   LESS
        FDB   LIT
        FDB   $15
        FDB   QERR
        FDB   DUP
        FDB   NFA
        FDB   DP
        FDB   STORE
        FDB   LFA
        FDB   AT
        FDB   CONT
        FDB   AT
        FDB   STORE
        FDB   SEMIS

        FCB   $84
        FCC   'BAC'
        FCB   $CB
        FDB   FORGET-9
BACK    FDB   DOCOL
        FDB   HERE
        FDB   SUBB
        FDB   COMMA
        FDB   SEMIS

        FCB   $C5
        FCC   'BEGI'
        FCB   $CE
        FDB   BACK-7
BEGIN   FDB   DOCOL
        FDB   QCOMP
        FDB   HERE
        FDB   ONE
        FDB   SEMIS

        FCB   $C5
        FCC   'ENDI'
        FCB   $C6
        FDB   BEGIN-8
ENDIFF  FDB   DOCOL
        FDB   QCOMP
        FDB   TWO
        FDB   QPAIR
        FDB   HERE
        FDB   OVER
        FDB   SUBB
        FDB   SWAP
        FDB   STORE
        FDB   SEMIS

        FCB   $C4
        FCC   'THE'
        FCB   $CE
        FDB   ENDIFF-8
THEN    FDB   DOCOL
        FDB   ENDIFF
        FDB   SEMIS

        FCB   $C2
        FCC   'D'
        FCB   $CF
        FDB   THEN-7
DO      FDB   DOCOL
        FDB   COMP
        FDB   XDO
        FDB   HERE
        FDB   THREE
        FDB   SEMIS

        FCB   $C4
        FCC   'LOO'
        FCB   $D0
        FDB   DO-5
LOOPC   FDB   DOCOL
        FDB   THREE
        FDB   QPAIR
        FDB   COMP
        FDB   XLOOP
        FDB   BACK
        FDB   SEMIS

        FCB   $C5
        FCC   '+LOO'
        FCB   $D0
        FDB   LOOPC-7
PLOOP   FDB   DOCOL
        FDB   THREE
        FDB   QPAIR
        FDB   COMP
        FDB   XPLOO
        FDB   BACK
        FDB   SEMIS

        FCB   $C5
        FCC   'UNTI'
        FCB   $CC
        FDB   PLOOP-8
UNTIL   FDB   DOCOL
        FDB   ONE
        FDB   QPAIR
        FDB   COMP
        FDB   ZBRAN
        FDB   BACK
        FDB   SEMIS

        FCB   $C3
        FCC   'EN'
        FCB   $C4
        FDB   UNTIL-8
END     FDB   DOCOL
        FDB   UNTIL
        FDB   SEMIS

        FCB   $C5
        FCC   'AGAI'
        FCB   $CE
        FDB   END-6
AGAIN   FDB   DOCOL
        FDB   ONE
        FDB   QPAIR
        FDB   COMP
        FDB   BRAN
        FDB   BACK
        FDB   SEMIS

        FCB   $C6
        FCC   'REPEA'
        FCB   $D4
        FDB   AGAIN-8
REPEAT  FDB   DOCOL
        FDB   TOR
        FDB   TOR
        FDB   AGAIN
        FDB   FROMR
        FDB   FROMR
        FDB   TWO
        FDB   SUBB
        FDB   ENDIFF
        FDB   SEMIS

        FCB   $C2
        FCC   'I'
        FCB   $C6
        FDB   REPEAT-9
IF      FDB   DOCOL
        FDB   COMP
        FDB   ZBRAN
        FDB   HERE
        FDB   ZERO
        FDB   COMMA
        FDB   TWO
        FDB   SEMIS

        FCB   $C4
        FCC   'ELS'
        FCB   $C5
        FDB   IF-5
ELSE    FDB   DOCOL
        FDB   TWO
        FDB   QPAIR
        FDB   COMP
        FDB   BRAN
        FDB   HERE
        FDB   ZERO
        FDB   COMMA
        FDB   SWAP
        FDB   TWO
        FDB   ENDIFF
        FDB   TWO
        FDB   SEMIS

        FCB   $C5
        FCC   'WHIL'
        FCB   $C5
        FDB   ELSE-7
WHILE   FDB   DOCOL
        FDB   IF
        FDB   TWOP
        FDB   SEMIS

        FCB   $86
        FCC   'SPACE'
        FCB   $D3
        FDB   WHILE-8
SPACS   FDB   DOCOL
        FDB   ZERO
        FDB   MAX
        FDB   DDUP
        FDB   ZBRAN
        FDB   SPAC2-*
        FDB   ZERO
        FDB   XDO
SPAC1   FDB   SPACE
        FDB   XLOOP
        FDB   SPAC1-*
SPAC2   FDB   SEMIS

        FCB   $82
        FCC   '<'
        FCB   $A3
        FDB   SPACS-9
BDIGS   FDB   DOCOL
        FDB   PAD
        FDB   HLD
        FDB   STORE
        FDB   SEMIS

        FCB   $82
        FCC   '#'
        FCB   $BE
        FDB   BDIGS-5
EDIGS   FDB   DOCOL
        FDB   DROP
        FDB   DROP
        FDB   HLD
        FDB   AT
        FDB   PAD
        FDB   OVER
        FDB   SUBB
        FDB   SEMIS

        FCB   $84
        FCC   'SIG'
        FCB   $CE
        FDB   EDIGS-5
SIGN    FDB   DOCOL
        FDB   ROT
        FDB   ZLESS
        FDB   ZBRAN
        FDB   SIGN1-*
        FDB   LIT
        FDB   $2D
        FDB   HOLD
SIGN1   FDB   SEMIS

        FCB   $81
        FCB   $A3
        FDB   SIGN-7
DIG     FDB   DOCOL
        FDB   BASE
        FDB   AT
        FDB   MSMOD
        FDB   ROT
        FDB   LIT
        FDB   9
        FDB   OVER
        FDB   LESS
        FDB   ZBRAN
        FDB   DIG1-*
        FDB   LIT
        FDB   7
        FDB   PLUS
DIG1    FDB   LIT
        FDB   $30
        FDB   PLUS
        FDB   HOLD
        FDB   SEMIS

        FCB   $82
        FCC   '#'
        FCB   $D3
        FDB   DIG-4
DIGS    FDB   DOCOL
DIGS1   FDB   DIG
        FDB   OVER
        FDB   OVER
        FDB   ORR
        FDB   ZEQU
        FDB   ZBRAN
        FDB   DIGS1-*
        FDB   SEMIS

        FCB   $83
        FCC   'D.'
        FCB   $D2
        FDB   DIGS-5
DDOTR   FDB   DOCOL
        FDB   TOR
        FDB   SWAP
        FDB   OVER
        FDB   DABS
        FDB   BDIGS
        FDB   DIGS
        FDB   SIGN
        FDB   EDIGS
        FDB   FROMR
        FDB   OVER
        FDB   SUBB
        FDB   SPACS
        FDB   TYPES
        FDB   SEMIS

        FCB   $82
        FCC   '.'
        FCB   $D2
        FDB   DDOTR-6
DOTR    FDB   DOCOL
        FDB   TOR
        FDB   STOD
        FDB   FROMR
        FDB   DDOTR
        FDB   SEMIS

        FCB   $82
        FCC   'D'
        FCB   $AE
        FDB   DOTR-5
DDOT    FDB   DOCOL
        FDB   ZERO
        FDB   DDOTR
        FDB   SPACE
        FDB   SEMIS

        FCB   $81
        FCB   $AE
        FDB   DDOT-5
DOT     FDB   DOCOL
        FDB   STOD
        FDB   DDOT
        FDB   SEMIS

        FCB   $81
        FCB   $BF
        FDB   DOT-4
QUES    FDB   DOCOL
        FDB   AT
        FDB   DOT
        FDB   SEMIS

        FCB   $82
        FCC   'U'
        FCB   $AE
        FDB   QUES-4
UDOT    FDB   DOCOL
        FDB   ZERO
        FDB   DDOT
        FDB   SEMIS

        FCB   $85
        FCC   'VLIS'
        FCB   $D4
        FDB   UDOT-5
VLIST   FDB   DOCOL
        FDB   BASE
        FDB   AT
        FDB   TOR
        FDB   HEX
        FDB   CR
        FDB   CR
        FDB   LIT
        FDB   0
        FDB   OUTT
        FDB   STORE
        FDB   CONT
        FDB   AT
        FDB   AT
VLIST1  FDB   DUP
        FDB   DUP
        FDB   LIT
        FDB   0
        FDB   BDIGS
        FDB   DIG
        FDB   DIG
        FDB   DIG
        FDB   DIG
        FDB   EDIGS
        FDB   TYPES
        FDB   DUP
        FDB   ONEP
        FDB   CAT
        FDB   LIT
        FDB   $007F
        FDB   ANDD
        FDB   ZBRAN
        FDB   VLIST2-*
        FDB   SPACE
        FDB   IDDOT
        FDB   BRAN
        FDB   VLIST3-*
VLIST2  FDB   PDOTQ
        FCB   5
        FCC   ' null'
        FDB   DROP
VLIST3  FDB   OUTT
        FDB   AT
        FDB   LIT
        FDB   60
        FDB   GREAT
        FDB   ZBRAN
        FDB   VLIST4-*
        FDB   CR
        FDB   LIT
        FDB   0
        FDB   OUTT
        FDB   STORE
        FDB   BRAN
        FDB   VLIST5-*
VLIST4  FDB   LIT
        FDB   20
        FDB   OUTT
        FDB   AT
        FDB   OVER
        FDB   MOD
        FDB   SUBB
        FDB   SPACS
VLIST5  FDB   PFA
        FDB   LFA
        FDB   AT
        FDB   DUP
        FDB   ZEQU
        FDB   QTERM
        FDB   DUP
        FDB   ZBRAN
        FDB   VLIST6-*
        FDB   KEY
        FDB   DROP
VLIST6  FDB   ORR
        FDB   ZBRAN
        FDB   VLIST1-*
        FDB   DROP
        FDB   CR
        FDB   CR
        FDB   FROMR
        FDB   BASE
        FDB   STORE
        FDB   SEMIS

        FCB   $84
        FCC   '.CP'
        FCB   $D5
        FDB   VLIST-8
DOTCPU  FDB   DOCOL
        FDB   PDOTQ
        FCB   5
        FCC   '6809 '
        FDB   SEMIS

        FCB   $84
        FCC   'DUM'
        FCB   $D0
        FDB   DOTCPU-7
DUMP    FDB   DOCOL
        FDB   BASE
        FDB   AT
        FDB   TOR
        FDB   HEX
        FDB   CR
        FDB   CR
        FDB   LIT
        FDB   5
        FDB   SPACS
        FDB   LIT
        FDB   16
        FDB   LIT
        FDB   0
        FDB   XDO
DUMP1   FDB   IDO
        FDB   LIT
        FDB   3
        FDB   DOTR
        FDB   XLOOP
        FDB   DUMP1-*
        FDB   LIT
        FDB   2
        FDB   SPACS
        FDB   LIT
        FDB   16
        FDB   LIT
        FDB   0
        FDB   XDO
DUMP2   FDB   IDO
        FDB   LIT
        FDB   0
        FDB   BDIGS
        FDB   DIG
        FDB   EDIGS
        FDB   TYPES
        FDB   XLOOP
        FDB   DUMP2-*
        FDB   CR
        FDB   OVER
        FDB   PLUS
        FDB   SWAP
        FDB   DUP
        FDB   LIT
        FDB   15
        FDB   ANDD
        FDB   XORR
        FDB   XDO
DUMP3   FDB   CR
        FDB   IDO
        FDB   LIT
        FDB   0
        FDB   LIT
        FDB   4
        FDB   DDOTR
        FDB   SPACE
        FDB   IDO
        FDB   LIT
        FDB   16
        FDB   PLUS
        FDB   IDO
        FDB   TDUP
        FDB   XDO
DUMP4   FDB   IDO
        FDB   CAT
        FDB   SPACE
        FDB   LIT
        FDB   0
        FDB   BDIGS
        FDB   DIG
        FDB   DIG
        FDB   EDIGS
        FDB   TYPES
        FDB   XLOOP
        FDB   DUMP4-*
        FDB   LIT
        FDB   2
        FDB   SPACS
        FDB   XDO
DUMP5   FDB   IDO
        FDB   CAT
        FDB   DUP
        FDB   LIT
        FDB   32
        FDB   LESS
        FDB   OVER
        FDB   LIT
        FDB   126
        FDB   GREAT
        FDB   ORR
        FDB   ZBRAN
        FDB   DUMP6-*
        FDB   DROP
        FDB   LIT
        FDB   46
DUMP6   FDB   EMIT
        FDB   XLOOP
        FDB   DUMP5-*
        FDB   LIT
        FDB   16
        FDB   XPLOO
        FDB   DUMP3-*
        FDB   CR
        FDB   FROMR
        FDB   BASE
        FDB   STORE
        FDB   SEMIS

**************************************************
*                                                *
*   The following 2 words are used to burn the   *
*   2k EEPROM located at address 0000 on the     *
*   development system. They may be removed as   *
*   long as the LFA's are re-adjusted.           *
*                                                *
**************************************************
        FCB   $84
        FCC   'EEC'
        FCB   $A1
        FDB   DUMP-7
EECSTO  FDB   *+2            ; On entry Address is top of stack, Data is second
        LDD   2,U            ; Get byte in B, address is top of stack
        LDA   #$FF           ; Erase byte
        STA   [0,U]
        BSR   DELAY          ; Wait for delay
        LDA   [0,U]          ; Read data
        STB   [0,U]          ; Store data
        BSR   DELAY          ; Wait for delay
        LDB   [0,U]          ; Read data
        LEAU  4,U            ; Drop address and data
        LDX   ,Y++           ; NEXT
        JMP   [,X++]

DELAY   LDX   #$0470
DELAY1  LEAX  -1,X
        BNE   DELAY1
        RTS

        FCB   $86
        FCC   'EEMOV'
        FCB   $C5
        FDB   EECSTO-7
EEMOV   FDB   DOCOL
        FDB   LIT
        FDB   0
        FDB   XDO
EEMO1   FDB   DUP
        FDB   ONEP
        FDB   ROT
        FDB   DUP
        FDB   ONEP
        FDB   TOR
        FDB   CAT
        FDB   ROT
        FDB   EECSTO
        FDB   FROMR
        FDB   SWAP
        FDB   XLOOP
        FDB   EEMO1-*
        FDB   DROP
        FDB   DROP
        FDB   SEMIS

**************************************************
*                                                *
*    The following is copied to RAM by COLD      *
*                                                *
**************************************************
FORTHS  FCB   $C5            ; The start of the FORTH vocabulary
        FCC   'FORT'
        FCB   $C8
        FDB   EEMOV-9
FORTH   FDB   DODOE
        FDB   DOVOC
        FDB   $81A0
        FDB   RTASK-7
        FDB   0

        FCB   $84
        FCC   'TAS'
        FCB   $CB
        FDB   RFORTH-8
TASK    FDB   DOCOL          ; Last word in vocabulary
        FDB   SEMIS
TASKE   EQU   *              ; The end of the ROMable dictionary

RFORTH  EQU   RAMS+FORTH-FORTHS        ; Location of FORTH in RAM
RTASK   EQU   RAMS+TASK-FORTHS         ; Location of TASK in RAM
INITDP  EQU   RAMS+TASKE-FORTHS        ; Initial DP in RAM
