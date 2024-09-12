..\ca65 AciaTest.s -o AciaTest.o -l
REM..\ld65 -C AciaTest.cfg AciaTest.o -o AciaTest.bin
..\ld65 -t none AciaTest.o -o AciaTest.bin
..\srec_cat.exe AciaTest.bin -binary -o AciaTest.hex -Intel
