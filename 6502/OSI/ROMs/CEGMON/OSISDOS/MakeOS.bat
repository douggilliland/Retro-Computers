cl65 --start-addr 0x300 -Wl -D,__HIMEM__=$2000,-D,__STACKSIZE__=$0200 -t osic1p -vm -m OSISDOS.map -o OSISDOS.o OSISDOS.c
"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\6502\RetroAssembler\retroassembler.exe" -d -D=0x0300 OSISDOS.o OSISDOS.DIS
"..\..\..\..\..\PC Tools\srecord\srec_cat.exe" OSISDOS.o -bin -of 0x300 -o OSISDOS.c1p -os -esa=0x300
