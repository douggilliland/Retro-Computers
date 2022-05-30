
MACRO = ../utils/macro/macro8x
SHOWBIN = ../utils/showbin

all: init.bin fip.bin si.bin ts8.bin ts8ii.bin INIT.XD.bin

clean:
	rm -f *.bin *.prm *.lst *.err *.mem *.dump

init.bin: INIT.PA
	rm -f init.err init.lst
	$(MACRO) -o init -d UWM.PA PARA.PA PARB.PA PARC.PA INIT.PA

fip.bin: FIP.PA
	rm -f fip.err fip.lst
	$(MACRO) -o fip -d UWM.PA PARA.PA PARB.PA PARC.PA FIP.PA

si.bin: SI.PA
	rm -f si.err si.lst
	$(MACRO) -o si -d UWM.PA PARA.PA PARB.PA PARC.PA SI.PA

ts8.bin: TS8.PA
	rm -f ts8.err ts8.lst
	$(MACRO) -o ts8 -d UWM.PA PARA.PA PARB.PA PARC.PA TS8.PA

ts8ii.bin: TS8II.PA
	rm -f ts8ii.err ts8ii.lst
	$(MACRO) -o ts8ii -d UWM.PA PARA.PA PARB.PA PARC.PA TS8II.PA

INIT.XD.bin: orig-dectapes/INIT.XD
	#it's a bin format papertape encoded as ascii bytes
	#but we dumped it as binary
	../tapes/tools/asc <orig-dectapes/INIT.XD >INIT.XD.bin

xxx:
	$(SHOWBIN) fip.bin >fip.src.mem
	$(SHOWBIN) init.bin >init.src.mem
	$(SHOWBIN) si.bin >si.src.mem
	$(SHOWBIN) ts8.bin >ts8.src.mem
	$(SHOWBIN) ts8ii.bin >ts8ii.src.mem
#	sdiff fip.rf.mem fip.src.mem
#	sdiff init.rf.mem init.src.mem
#	sdiff si.rf.mem si.src.mem