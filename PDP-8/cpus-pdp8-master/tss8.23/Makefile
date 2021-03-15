
MACRO = ../utils/macro/macro8x
SHOWBIN = ../utils/showbin

all: init.bin fip.bin si.bin ts8.bin ts8ii.bin INIT.XD.bin

clean:
	rm -f *.bin *.prm *.lst *.err *.mem *.dump

init.bin: INIT.PA
	rm -f init.err init.lst
	$(MACRO) -o init UWM.PA PARAM.PA INIT.PA

fip.bin: FIP.PA
	rm -f fip.err fip.lst
	$(MACRO) -o fip UWM.PA PARAM.PA FIP.PA

si.bin: SI.PA
	rm -f si.err si.lst
	$(MACRO) -o si UWM.PA PARAM.PA SI.PA

ts8.bin: TS8.PA
	rm -f ts8.err ts8.lst
	$(MACRO) -o ts8 UWM.PA PARAM.PA TS8.PA

ts8ii.bin: TS8II.PA
	rm -f ts8ii.err ts8ii.lst
	$(MACRO) -o ts8ii UWM.PA PARAM.PA TS8II.PA

#it's a bin format papertape encoded as ascii bytes
#but we dumped it as binary
INIT.XD.bin: INIT.XD
	../tapes/tools/asc <INIT.XD >INIT.XD.bin

xxx:
	$(SHOWBIN) fip.bin >fip.src.mem
	$(SHOWBIN) init.bin >init.src.mem
	$(SHOWBIN) si.bin >si.src.mem
	$(SHOWBIN) ts8.bin >ts8.src.mem
	$(SHOWBIN) ts8ii.bin >ts8ii.src.mem
#	sdiff fip.rf.mem fip.src.mem
#	sdiff init.rf.mem init.src.mem
#	sdiff si.rf.mem si.src.mem
