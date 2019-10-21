SRCS=$(wildcard */*.c) $(wildcard *.c) 
CC = zcc
CFLAGS = +rc2014 -subtype=basic -v -m -SOfast --c-code-in-asm  -clib=sdcc_ix
#  --max-allocs-per-node200000

all:
	$(CC) $(CFLAGS) --list $(SRCS) -o main -create-app

.PHONY clean:
	rm -f *.bin *.lst *.ihx *.hex *.obj *.rom *.lis zcc_opt.def $(APP_NAME) *.reloc *.sym *.map disasm.txt

run: 
	cat main.ihx | python slowprint.py > /dev/ttyUSB0

build: 
	cp main.bin /home/tobias/Entwicklung/Code/RC2014/ROMs/rom/rc2014_0010.bin
	php /home/tobias/Entwicklung/Code/RC2014/ROMs/rom/build.php