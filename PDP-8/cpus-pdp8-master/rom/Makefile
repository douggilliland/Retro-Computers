
all: rom.mem uart.mem

%.bin: %.pal
	../utils/macro/macro8x $<

%.mem: %.bin
	../utils/showbin/showbin $< >$@

clean:
	rm -rf *.lst *.bin *.mem
