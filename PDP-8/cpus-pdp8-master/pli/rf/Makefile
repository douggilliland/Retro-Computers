#

INCS = -I../../cver/gplcver-2.12a.src/pli_incs

CFLAGS= -fPIC -Wall -g $(INCS) -D__CVER__
LFLAGS= -G -shared -export-dynamic

all: pli_rf.so pli_rf.vpi

pli_rf.o: pli_rf.c
	$(CC) $(CFLAGS) -c pli_rf.c

pli_ram.o: pli_ram.c
	$(CC) $(CFLAGS) -c pli_ram.c

pli_rf.so: pli_rf.o pli_ram.o
	$(LD) $(LFLAGS) pli_rf.o pli_ram.o -o pli_rf.so

pli_rf.vpi: pli_rf.o pli_ram.o
	$(LD) $(LFLAGS) pli_rf.o pli_ram.o -o pli_rf.vpi


clean:
	rm -f *.o *.so *.vpi

