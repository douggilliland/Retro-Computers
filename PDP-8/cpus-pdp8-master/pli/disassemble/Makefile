#

INCS = -I../../cver/gplcver-2.12a.src/pli_incs

CFLAGS= -fPIC -Wall -g $(INCS) -D__CVER__
LFLAGS= -G -shared -export-dynamic

all: pli_disassemble.so pli_disassemble.vpi

pli_disassemble.o: pli_disassemble.c 
	$(CC) $(CFLAGS) -c pli_disassemble.c

pli_disassemble.so: pli_disassemble.o
	$(LD) $(LFLAGS) pli_disassemble.o -o pli_disassemble.so

pli_disassemble.vpi: pli_disassemble.o
	$(LD) $(LFLAGS) pli_disassemble.o -o pli_disassemble.vpi

clean:
	rm -f *.o *.so *.vpi
