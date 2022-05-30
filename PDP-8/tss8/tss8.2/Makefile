
MACRO = ../utils/macro/macro8x
SHOWBIN = ../utils/showbin

all: init.bin fip.bin si.bin ts8.bin

clean:
	rm -f *.bin *.prm *.lst *.err *.mem *.dump

init.bin:
	rm -f init.err init.lst
	$(MACRO) -o init melrose.pal param.pal link.pal init.pal

fip.bin:
	rm -f fip.err fip.lst
	$(MACRO) -o fip melrose.pal param.pal link.pal fip.pal

si.bin:
	rm -f si.err si.lst
	$(MACRO) -o si melrose.pal param.pal link.pal si.pal

ts8.bin:
	rm -f ts8.err ts8.lst
	$(MACRO) -o ts8 melrose.pal param.pal link.pal ts8.pal

xxx:
	$(SHOWBIN) fip.bin >fip.src.mem
	$(SHOWBIN) init.bin >init.src.mem
	$(SHOWBIN) si.bin >si.src.mem
	$(SHOWBIN) ts8.bin >ts8.src.mem
#	sdiff fip.rf.mem fip.src.mem
#	sdiff init.rf.mem init.src.mem
#	sdiff si.rf.mem si.src.mem