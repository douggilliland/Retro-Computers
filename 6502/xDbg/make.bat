echo off
IF "%1"=="clean" GOTO CLEAN
as65 -l -s2 xdbg.asm
g++ mnem.cpp -o mnem
as65 -l -x -s2 test1.asm
GOTO DONE

:CLEAN
del *.lst
del *.hex
del *.bin

:DONE

