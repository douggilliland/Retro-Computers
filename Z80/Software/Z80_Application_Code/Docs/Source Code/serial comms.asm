;************************************************************************
;Serial Comms Upgraded OCT 2018.
;Using 8255C  PortC  configured   Bits 0-3 OUTPUT, Bits 4-7 INPUT.
;Bit 0 serial OUT
;bit 4 serial in
;CPU z80
;Clock = 8Mhz.
;Comms settings 
;19200 Baud
;8 data
;1 stop
;NO parity.
;Interrupt - Not used.
;*************************************************************************


GETCHAR:  ;This routine gets 1 char from rs232 and returns with it in 'A'
        PUSH    BC
        PUSH    DE
        IN      A,(PORTC)
        BIT     4,A
        jr      NZ,GCHAR1
        LD      HL, kberr1
        RST     08  ;Call print string (Line already low so it's an error). - easily changed to exit with error code.
        jr      gchxit
GCHAR1: ;ok comms line is high so wait for a character to appear!
        IN      A,(PORTC)
        bit     4,A
        JR      NZ,GCHAR1 ;IF LINE IS STILL HIGH
        CALL    Delay26uS;WAIT HALF A BIT
        IN      A,(PORTC)
        BIT     4,A
        JR      Z,gchar5 ;STILL LOW SO VALID
        LD      HL, kberr1
        CALL    SEND_STRING  ;PRINT ERROR THEN RETURN (false start or incorrect speed).
        jr      gchxit
gchar5: ld      b,08 ;set up for 8 bits
        ld      c,0
gchar2: call    Delay52uS  ;delay to centre of next bit
        in      a,(PORTC)
        bit     4,A
        jr      nz,gchar3
        res     7,D
        jr      gchar4
gchar3: set     7,D
gchar4: RRC     D
        djnz    gchar2
        RLC     D
        LD      A,D
gchxit: call    Delay52uS  ;Allow time for rest of stop bit to disappear!
        call    Delay52uS
        call    Delay52uS
        POP     DE
        POP     BC
        RET



            ;8 bit NO parity 1 stop 19200 baud, cpu clock 8MHz
SEND_BYTE:                      ;enter with char in A reg
        PUSH    AF
        PUSH    BC
        ld      C,A
        in      A,(PORTC) ;Redundant? (was check line is ready, maybe re-install)
        res     0,a
        out     (PORTC),A   ;set tx bit low.  sTART BIT

        call    Delay52uS


        ld      B,8             ;SEND 8 BITS LSB first.
nxb:    in      a,(PORTC)
        BIT     0,C
        JR      NZ,NXB1
        RES     0,A
        JR      NXB2
NXB1:   SET     0,A
NXB2:   OUT     (PORTC),A
        call    Delay52uS
        RR      C
        djnz    nxb

        in      A,(PORTC)
        RES     0,A
        out     (PORTC),A       ;set tx bit low. sTOP BIT
        call    Delay52uS
        in      a,(PORTC)
        SET     0,A
        out     (PORTC),A       ;set tx bit HIGH END OF TRANSMISSION
        call    Delay52uS       ;add a delay 150uS twixt chars.
        call    Delay52uS
        call    Delay52uS
        POP     BC
        POP     AF
        RET



Delay52uS:       ;RS232 19200 Baud 1 bit delay
        push bc
        ld      b,18 ;WAS 19.
dius:   nop
        djnz dius
        pop  bc
        ret
Delay26uS:
        push bc  ;RS232 19200 Baud 1/2 bit delay.
        ld      b,7
dius1:  jr dius
                             