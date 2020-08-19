REM BUILD THE SERIAL RECEIVER  (S RECORDS and $ RECORDS)

REM specify S RECORDS (S_RECORD) and/or $ RECORDS (D_RECORD)
REM set the STACK ADDRESS (optional)

REM compile and assemble for the 68000

c68 -O -Of0 -Xp -Xd +o -DX%1 -DX%2 -DPC_AT srcvr2.c

REM add -DSTACK=stack_address to the asm68 line to set stack address

ECHO .%1 > SRCVR.DOC
ECHO .%2 >> SRCVR.DOC

IF NOT X%3 == X GOTO SET_STK
asm68 -lQ -DPC_AT srcvr1.s
ECHO STACK ADDRESS NOT SET >> SRCVR.DOC
GOTO X
:SET_STK
asm68 -lQ -DPC_AT -DSTACK=%3 srcvr1.s
ECHO STACK ADDRESS = %3 >> SRCVR.DOC
:X

link68 -Q -o srcvr68.out srcvr1.o srcvr2.o -i srcvr.ld

REM compile and assemble for the 68020

c020 -O -Of0 -Xp -Xd +o -DX%1 -DX%2 -DPC_AT srcvr2.c

REM add -DSTACK=stack_address to the asm68 line to set stack address

IF NOT X%3 == X GOTO SET_STK1
asm68 -lQ -DM68020 -DPC_AT srcvr1.s
GOTO X1
:SET_STK1
asm68 -lQ -DM68020 -DPC_AT -DSTACK=%3 srcvr1.s
:X1

link68 -Q -o srcvr020.out srcvr1.o srcvr2.o -i srcvr.ld

del srcvr1.o
del srcvr2.o
type srcvr.doc
