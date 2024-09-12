..\ca65 AciaTest.s -o AciaTest.o -l
..\ld65 -C AciaTest.cfg AciaTest.o -o AciaTest.bin
..\srec_cat.exe AciaTest.bin -binary -o AciaTest.hex -Intel
