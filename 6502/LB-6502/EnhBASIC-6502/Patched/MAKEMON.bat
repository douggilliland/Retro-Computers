CLS
..\..\ca65 basic.asm -o basic.o -l
..\..\ca65 --listing -o monitor.o monitor.asm
..\..\ld65 -C symon.config -vm -m monitor.map -o monitor.rom monitor.o
..\..\srec_cat.exe monitor.rom -binary -o moncode.hex -Intel
