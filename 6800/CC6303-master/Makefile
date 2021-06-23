
all: cc68 as68 copt frontend libc

.PHONY: cc68 as68 frontend libc copt

cc68:
	+(cd common; make)
	+(cd cc68; make)

as68:
	+(cd as68; make)

copt:
	+(cd copt; make)

libc:
	+(cd libc; make)
	+(cd lib6800; make)
	+(cd lib6803; make)
	+(cd lib6303; make)
	+(cd libio; make)
	+(cd target-mc10; make)
	+(cd target-flex; make)
	mkdir -p tmp
	rm -f tmp/*
	rm -f lib6800.a
	rm -f lib6803.a
	rm -f lib6303.a
	cp lib6800/*.o tmp
	(cd tmp; ar rc ../lib6800.a *.o)
	cp -f lib6803/*.o tmp
	(cd tmp; ar rc ../lib6803.a *.o)
	cp -f lib6303/*.o tmp
	(cd tmp; ar rc ../lib6303.a *.o)

frontend:
	+(cd frontend; make)

clean:
	(cd common; make clean)
	(cd cc68; make clean)
	(cd as68; make clean)
	(cd frontend; make clean)
	(cd copt; make clean)
	(cd libc; make clean)
	(cd lib6800; make clean)
	(cd lib6803; make clean)
	(cd lib6303; make clean)
	(cd libio; make clean)
	(cd target-mc10; make clean)
	(cd target-flex; make clean)
	rm -f lib6800.a lib6803.a lib6303.a

#
#	This aspect needs work
#
install:
	mkdir -p /opt/cc68/bin
	mkdir -p /opt/cc68/lib
	mkdir -p /opt/cc68/include
	mkdir -p /opt/cc68/include/flex
	cp cc68/cc68 /opt/cc68/lib
	cp as68/as68 /opt/cc68/bin
	cp as68/ld68 /opt/cc68/bin
	cp as68/nm68 /opt/cc68/bin
	cp as68/osize68 /opt/cc68/bin
	cp as68/dumprelocs68 /opt/cc68/bin
	cp copt/copt /opt/cc68/lib
	cp copt/killdeadlabel /opt/cc68/lib/killdeadlabel68
	cp frontend/cc68 /opt/cc68/bin/
	cp cc68.rules /opt/cc68/lib
	cp cc68-00.rules /opt/cc68/lib
	cp libc/crt0.o /opt/cc68/lib
	cp libc/libc.a /opt/cc68/lib
	cp lib6800.a /opt/cc68/lib
	cp lib6803.a /opt/cc68/lib
	cp lib6303.a /opt/cc68/lib
	cp libio/6800/libio6800.a /opt/cc68/lib
	cp libio/6803/libio6803.a /opt/cc68/lib
	cp include/*.h /opt/cc68/include/
	cp target-mc10/lib/libmc10.a /opt/cc68/lib
	cp target-mc10/tools/tapeify /opt/cc68/lib/mc10-tapeify
	cp target-flex/lib/libflex.a /opt/cc68/lib
	cp target-flex/tools/binify /opt/cc68/lib/flex-binify
	cp target-flex/include/*.h /opt/cc68/include/flex/
