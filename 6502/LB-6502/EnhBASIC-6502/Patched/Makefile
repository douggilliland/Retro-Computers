CA=ca65
LD=ld65

all: monitor

monitor: monitor.o
	$(LD) -C symon.config -vm -m monitor.map -o monitor.rom monitor.o

monitor.o:
	$(CA) --listing -o monitor.o monitor.asm

clean:
	rm -f *.o *.rom *.map *.lst
