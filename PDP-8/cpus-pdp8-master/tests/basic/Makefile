#

PALD = ../../utils/macro/macro8x
SHOWBIN = ../../utils/showbin/showbin

all: user.bin uart.bin

user.bin: user.pal
	$(PALD) $<
	$(SHOWBIN) $@ >$(basename $<).mem

uart.bin: uart.pal
	$(PALD) $<
	$(SHOWBIN) $@ >$(basename $<).mem

clean:
	rm -f *.mem *.bin *.lst *~

