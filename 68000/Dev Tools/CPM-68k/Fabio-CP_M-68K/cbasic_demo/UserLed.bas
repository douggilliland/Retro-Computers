01 REM ***********************************************************************
02 REM
03 REM 68k-MBC User led and key demo (CP/M-68K CBASIC (C68) Basic Compiler)
04 REM
05 REM Blink USER led until USER key is pressed
06 REM
07 REM ***********************************************************************
08 REM
INTEGER EXWRPT, STRPT, EXRDPT, LED, KEY, J
10 PRINT "Press USER key to exit"
11 EXWRPT = 0ffffch : REM Address of the EXECUTE WRITE OPCODE write port
12 STRPT = 0ffffdh  : REM Address of the STORE OPCODE write port
13 EXRDPT = 0ffffch : REM Address of the EXECUTE READ OPCODE read port
14 LED = 0         : REM USER LED write Opcode (0x00)
15 KEY = 80h       : REM USER KEY read Opcode (0x80)
16 PRINT "Now blinking..."
18 POKE STRPT,LED : REM Store the USER LED write Opcode
20 POKE EXWRPT,1 : REM Turn USER LED on
30 GOSUB 505 : REM Delay sub
40 POKE STRPT,LED : REM Store the USER LED write Opcode
45 POKE EXWRPT,0 : REM Turn USER LED off
50 GOSUB 505 : REM Delay
60 GOTO 18
490 REM
500 REM * * * * * DELAY SUB
501 REM
505 FOR J=0 TO 1000
506 POKE STRPT,KEY : REM Store the USER KEY read Opcode
508 IF PEEK(EXRDPT)=1 THEN GOTO 700 : REM Exit if USER key is pressed
510 NEXT J
520 RETURN
690 REM
691 REM * * * * * PROGRAM END
692 REM
700 POKE STRPT,LED : REM Store the USER LED write Opcode
710 POKE EXWRPT,0 : REM Turn USER LED off
720 PRINT "Terminated by USER Key"

