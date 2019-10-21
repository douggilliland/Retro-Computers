        list    off
        list    noxref  ; (use this line only with ASMB version 3.08 or later)
;
; Cromemco Inc.
; October 4, 1983
;

; -----------------------------------------------------------------------------
; mode definitions for terminals and printers,
; TTY, QTTY, MTTY, LPT, SLPT, QSLPT, and TYP

; c-register values for .GETMODE and .SETMODE system calls
MD_ISPEED       defv    0               ; input speed
MD_OSPEED       defv    1               ; output speed
MD_MODE1        defv    2               ; flags: RAW, ECHO, etc.
MD_MODED        defv    3               ; delays for NL, CR, etc.
MD_MODE2        defv    4               ; flags: PAUSE, XFF, etc.
MD_MODE3        defv    5               ; flags: CBREAK, VRAW, etc.
MD_ERASE        defv    6               ; auxilliary erase character
MD_DELECHO      defv    7               ; erasure echo character
MD_LKILL        defv    8               ; line kill character
MD_USIGNAL      defv    9               ; SIGUSER signal key
MD_LENGTH       defv    10              ; page length (lines)
MD_WIDTH        defv    11              ; page width (columns)
MD_BMARGIN      defv    12              ; bottom margin (lines)
MODELEN         defv    MD_BMARGIN + 1

; more c-register values for .GETMODE and .SETMODE system calls
MD_STATUS       defv    -100            ; check whether input queues empty
MD_IFLUSH       defv    -101            ; flush input queues
MD_FNKEYS       defv    -104            ; turn function keys on or off
                                        ;       d-register = 1 to enable fnkeys
                                        ;       d-register = 0 to disable them
MD_PSIGHUP      defv    -105            ; signal current process if hang up
;               defv    -106            ; (this value reserved)
MD_MODEM        defv    -108            ; (QTTYs and MTTYs only)
MD_TYP          defv    -109            ; (TYP only)

; more c-register values for TYP only
        struct  64
TYP_CWIDTH      ds      1               ; character width in 1/120 inches
TYP_LHEIGHT     ds      1               ; line height in 1/48 inches
TYP_LMARGIN     ds      1               ; left margin in columns (1/10 inches)
TYP_FORMS       ds      1               ; type of forms (ignored by the driver)
                ds      1               ; reserved
TYPMODLEN       defv    $-64
        mend


; d-register values for MD_ISPEED baudrate calls
S_HANGUP        defv    0               ; hang up phone
;               defv    1               ; 50 baud
;               defv    2               ; 75 baud
S_110           defv    3               ; 110 baud
;               defv    4               ; 134.5 baud
S_150           defv    5               ; 150 baud
;               defv    6               ; 200 baud
S_300           defv    7               ; 300 baud
;               defv    8               ; 600 baud
S_1200          defv    9               ; 1200 baud
;               defv    10              ; 1800 baud
S_2400          defv    11              ; 2400 baud
S_4800          defv    12              ; 4800 baud
S_9600          defv    13              ; 9600 baud
;               defv    14              ; External A
;               defv    15              ; External B
S_19200         defv    16              ; 19200 baud

S_CTSWAIT       defv    125     ; wait for Clear To Send
S_NOCHG         defv    126     ; no change of baudrate
S_UNINIT        defv    127     ; baudrate has not been initialized yet
Sfl_AUTO        defv    7       ; (bit 7) input CRs from keyboard to set baudr

; d-register & e-register bits for MD_MODE1 calls
TANDEM          defv    0       ; send XOFF/XON to control filling of input buf
XTAB            defv    1       ; expand TABs
LCASE           defv    2       ; convert alphabetics to lower case
ECHO            defv    3       ; echo input
CRDEVICE        defv    4       ; on input, map CR into NL,
                                ; on output, change NL to CRLF.
RAW             defv    5       ; on input, return after each character,
                                ; no erase, linekill, or EOF characters,
                                ; no output PAUSE or output width truncation,
                                ; treat X-OFF & X-ON as regular input.
ODD             defv    6       ; parity function bits
EVEN            defv    7       ;       

; d-register & e-register values for MD_MODED calls
NLDELAY         defv    03H     ; (pairs of bits)
TABDELAY        defv    0CH     ;
CRDELAY         defv    30H     ;
FFDELAY         defv    40H     ; (single bits)
BSDELAY         defv    80H     ;

; d-register & e-register bits for MD_MODE2 calls
PAUSE           defv    0       ; wait for CNTRL-Q after a page is output
NOTIMMECHO      defv    1       ; do not echo characters typed-ahead
NOECNL          defv    2       ; do not echo NLs
SGENABLE        defv    3       ; send SIGUSER signal if MD_USIGNAL key pushed
ABENABLE        defv    4       ; send SIGABORT signal if CNTRL-C key pushed
XFF             defv    5       ; expand FFs
WRAP            defv    6       ; wrap-around if page width is exceeded
SIGALLC         defv    7       ; send SIGUSER signal for every key pushed

; d-register & e-register bits for MD_MODE3 calls
ESCRETN         defv    0       ; ESC causes input line to be returned
FNKEYS          defv    1       ; response to 3102 function keys enabled
HUPENAB         defv    2       ; hang up modem when device is finally closed
SIGHUPALL       defv    3       ; send SIGHANGUP signals to all processes which
                                ; use this TTY device if modem hangs up
CBREAK          defv    4       ; on input, return after each character,
                                ; no erase, linekill, or EOF characters.
BINARY          defv    5       ; on input, return after each character,
                                ; no erase, linekill, or EOF characters,
                                ; no output PAUSE or output width truncation,
                                ; treat X-OFF & X-ON as regular input,
                                ; no tandem mode (i.e., no input buf control),
                                ; no abort signal (^C), no user signal,
                                ; no changing or checking parity bit,
                                ; no delays after control chars such as NLs,
                                ; no echoing,
                                ; no character transformations (i.e., ignore
                                ; the LCASE, CRDEV, and XTABS modes)
                                ; no function-key decoding.
RETYPE          defv    6       ; use of edline allowed
DISCARD         defv    7       ; discard the device when it is no longer open


; d-register bits for MD_STATUS calls
INOTEMPTY       defv    0       ; there is a character in the input buffer
                                ; (but if not CBREAK, RAW, or BINARY mode,
                                ; it won't be accessible until a whole line
                                ; is entered)


; .GETMODE d-register bits for MD_MODEM calls
RXDA            defv    0       ; Receiver Data Available
TXBE            defv    2       ; Transmitter Buffer Empty
DCD             defv    3       ; Data Carrier Detect
CTS             defv    5       ; Clear To Send
RXBREAK         defv    7       ; Reciver data line broken

; .GETMODE e-register bits for MD_MODEM calls
notRI           defv    6       ; Not ringing
notDSR          defv    7       ; Data Set not Ready


; .SETMODE d-register and e-register bits
RTS             defv    1       ; Request to Send
TXBREAK         defv    4       ; Break the transmitter line
DTR             defv    7       ; Data Terminal Ready


; d-register bits for MD_TYP call
TYPCHK          defv    1       ; the 3355 printer is in a check condition
TYPPAP          defv    2       ; the 3355 printer is out of paper
TYPRIB          defv    3       ; the 3355 printer is out of ribbon
TYPOFL          defv    4       ; the 3355 printer is off-line


        list    xref    ; (use this line only with ASMB version 3.08 or later)
        list    on
