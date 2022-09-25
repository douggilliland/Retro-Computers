
ASM=../xasm/new/basm

all: ctmon65.hex

clean:
	rm -f *.bin *.hex *.lst

ctmon65.hex: ctmon65.asm acia.asm config.inc io.asm
	$(ASM) ctmon65.asm



