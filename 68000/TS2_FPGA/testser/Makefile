all:	testser.run testser.s

testser.run: testser.c
	/opt/m68k-elf/bin/m68k-elf-gcc -Wall -m68000 -msoft-float -c testser.c
	/opt/m68k-elf/bin/m68k-elf-ld --defsym=_start=main -Ttext=0x2000 -Tdata=0x3000 -Tbss=0x4000 --section-start=.rodata=0x5000 testser.o `/opt/m68k-elf/bin/m68k-elf-gcc -m68000 -print-libgcc-file-name`
	/opt/m68k-elf/bin/m68k-elf-objcopy -O srec a.out testser.run

testser.s: testser.c
	/opt/m68k-elf/bin/m68k-elf-gcc -Wall -nostdlib -nodefaultlibs -m68000 -S testser.c

clean:
	$(RM) a.out testser.o testser.run testser.s testser.lst
	
