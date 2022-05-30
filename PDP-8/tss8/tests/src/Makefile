
PALD = ../../utils/macro/macro8x

BIN = MAINDEC-08-D1GB-D.bin MAINDEC-8I-D01C-D.bin

all: $(BIN)

MAINDEC-08-D1GB-D.bin: MAINDEC-08-D1GB-D.pal
	$(PALD) $<

MAINDEC-8I-D01C-D.bin: MAINDEC-8I-D01C-D.pal
	$(PALD) $<

clean:
	rm -f *.bin *.err *.lst
