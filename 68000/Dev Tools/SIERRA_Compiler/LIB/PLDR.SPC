BANNER          = NO    [YES, NO]
PARALLEL_PORT   = LPT1  [LPT1, LPT2, LPT3]	  
SERIAL_PORT     = COM1  [COM1, COM2, COM3, COM4]
BAUD_RATE       = 9600  [300, 600, 1200, 2400, 4800, 9600, 19200]
PARITY          = NONE  [EVEN, ODD, NONE]
WORD_LENGTH     = 8     [7, 8]
STOP_BITS       = 1     [1, 2]
RECOGNIZE_XOFF  = PC    [NO, TARGET, PC, BOTH]
SHOW_LOAD_INFO  = YES   [YES, NO]
LIST_SPECS      = NO    [YES, NO]

%1	dialog to start target parallel receiver
!\r
?>
= 100
!G 50000\r
= 200
