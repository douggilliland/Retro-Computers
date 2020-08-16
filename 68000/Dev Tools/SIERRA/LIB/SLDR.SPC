BANNER         = NO    [YES, NO]
SERIAL_PORT    = COM1  [COM1, COM2, COM3, COM4]
BAUD_RATE      = 9600  [300, 600, 1200, 2400, 4800, 9600, 19200]
PARITY         = NONE  [EVEN, ODD, NONE]
WORD_LENGTH    = 8     [7, 8]
STOP_BITS      = 1     [1, 2]
BUF_SIZE       = 512   [1 - 15000]
RECOGNIZE_XOFF = PC    [NO, TARGET, PC, BOTH]
SHOW_ECHO      = NO    [YES, NO]
SEND_LINEFEED  = YES   [YES, NO]
RECORD_PADDING = 3     [0 - 65535]
CHAR_DELAY     = 0     [0 - 65535]
SEND_TO_FILE   = NO    [YES, NO]
SHOW_LOAD_INFO = YES   [YES, NO]
LIST_SPECS     = NO    [YES, NO]

%1	dialog to start target serial receiver
!\r
?>
= 100
!LO 0\r
= 200

%2	dialog to start loaded program in target
!\r
?>
= 150
!G 5000\r
