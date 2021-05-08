01 REM *********************************************
02 REM
03 REM 68k-MBC Print function example
04 REM
06 REM
07 REM *********************************************
08 REM
10 FOR A=0 TO 6.2 STEP 0.2
20 PRINT TAB(40+SIN(A)*20);"*"
30 NEXT A
40 GOTO 10
