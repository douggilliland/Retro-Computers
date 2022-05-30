#
#
#

IVERILOG=iverilog
VERILOG=cver

#all: igo
all: go

pdp8.o: pdp8.v
	$(VERILOG) -o pdp8.o $(PARTS)

irun: $(PARTS) run.v pdp8.v
	$(IVERILOG) -o run run.v

crun: $(PARTS) run.v pdp8.v
	$(VERILOG) +change_port_type run.v
	echo "exit 0" > run
	chmod +x run

go: crun
	./run

igo: irun
	./run

display:
	./maketraces.sh >traces
	gtkwave caddr.vcd traces

snapshot:
	(suffix=`date +%Y%m%d`; \
	 cd ..; \
	 tar cfz pdp8_verilog_$$suffix.tar.gz pdp8/*.v pdp8/Makefile ; \
	 mv pdp8_verilog* ~/html/heeltoe/html/download/pdp8)
