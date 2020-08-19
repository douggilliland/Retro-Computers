REM BUILD THE PARALLEL RECEIVER AND PARALLEL RECEIVER TEST PROGRAM

REM set SOCKET_ADDR, ROM bus WIDTH and STACK ADDRESS (optional)

REM compile and assemble for the 68000

c68 -O -Of0 -Xp +o -DSOCKET_ADDR=%1 -DWIDTH=%2 prcvr2.c ptest.c

REM add -DSTACK=stack_address to the asm68 line to set stack address

ECHO SOCKET ADDRESS = %1 > PRCVR.DOC
ECHO ROM BUS WIDTH = %2 >> PRCVR.DOC

IF NOT X%3 == X GOTO SET_STK
asm68 -lQ prcvr1.s
ECHO STACK ADDRESS NOT SET >> PRCVR.DOC
GOTO X
:SET_STK
asm68 -lQ -DSTACK=%3 prcvr1.s
ECHO STACK ADDRESS = %3 >> PRCVR.DOC
:X

link68 -Q -o prcvr68.out -T0 prcvr1.o prcvr2.o
link68 -Q -o ptest.out -T0 prcvr1.o ptest.o

REM compile and assemble for the 68020

c020 -O -Of0 -Xp +o -DSOCKET_ADDR=%1 -DWIDTH=%2 prcvr2.c

REM add -DSTACK=stack_address to the asm68 line to set stack address

IF NOT X%3 == X GOTO SET_STK1
asm68 -lQ -DM68020 prcvr1.s
GOTO X1
:SET_STK1
asm68 -lQ -DM68020 -DSTACK=%3 prcvr1.s
:X1

link68 -Q -o prcvr020.out -T0 prcvr1.o prcvr2.o

del prcvr1.o
del prcvr2.o
del ptest.o
type prcvr.doc
