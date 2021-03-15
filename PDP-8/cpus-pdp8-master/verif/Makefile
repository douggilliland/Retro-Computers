
CVER_FLAGS = +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap
#CVER_FLAGS = 

RTESTS = test_tt test_rf test_io

RTL = \
	../rtl/pdp8_tt.v ../rtl/pdp8_rf.v ../rtl/pdp8_io.v \
	../rtl/pdp8_ram.v ../rtl/ram_32kx12.v ../rtl/ram_256x12.v \
	../rtl/ide_disk.v ../rtl/ide.v \
	../rtl/top.v \
	../rtl/pdp8.v

all: regress

#---------------------------------------------------------------------

#cver +showpc +test=../tests/diags/MAINDEX-08-D1GB.mem +pc=0326 +switches=7777 +cycles=20 test_pdp8.v 

#cver +test=../tests/diags/MAINDEC-8I-D01C.mem +pc=0200 +switches=7777 +cycles=2000000 test_pdp8.v 

#cver +test=tss8_init.mem +pc=24200 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v 

#cver +showpc +cycles=5000 +test=tss8_init.mem +pc=24200 +cycles=2000000 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v

#cver +showpc +cycles=100000 +test=tss8_init.mem +pc=24200 +loadvpi=../pli/ide/pli_ide.so:vpi_compat_bootstrap test_pdp8.v > xx

define runone_verilog_regression
	cver $(CVER_FLAGS) $(1) >$(2);
	@if grep -q ERROR $(2); then exit 1; fi;
	@if grep -q FAILURE $(2); then exit 1; fi;
	@echo success
endef

RTEST_LOGS = $(addsuffix .log,$(RTESTS))

$(RTEST_LOGS) : %.log : %.v $(RTL)
	$(call runone_verilog_regression,$<,$@)

# verilog testbench regression tests
regress: $(RTEST_LOGS)

test_tt: test_tt.v
	$(call runone_verilog_regression,$<,$@)

test_rf: test_rf.v
	$(call runone_verilog_regression,$<,$@)
	echo ok

test_io: test_io.v
	$(call runone_verilog_regression,$<,$@)
	echo ok

#
clean:
	rm -f verilog.log
	rm -f *.vcd *.log
