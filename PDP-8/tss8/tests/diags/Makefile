#
# make "mem" files for simulation from various binary formats
# we get to xxdp and other places.
#

SIMH_PDP8 = ../../simhv36-1/BIN/pdp8

DIAGS = MAINDEX-08-D1GB MAINDEC-8I-D01C MAINDEC-8I-D02B \
	MAINDEC-08-D5EB MAINDEC-08-D5FA \
	MAINDEC-08-D1GD MAINDEC-08-D1EB MAINDEC-08-D1HA


MEMS = $(addsuffix .mem,$(basename $(DIAGS)))
LOGS = $(addsuffix .log,$(basename $(DIAGS)))

#all: loadtomem mems logs
all: mems logs

mems: $(MEMS)

define loadone-skip
	../../utils/showbin/showbin -z $(1) >$(2);
	../../utils/skipz/skipz $(1) >$(1).fixed;
endef

define loadone
	../../utils/showbin/showbin $(1) >$(2);
endef

# dd if=/dev/zero of=rf.dsk bs=1024 count=512

define genlog_from_script
	M=10000 $(SIMH_PDP8) $(1) >$(2)
endef

#------------------------------

%.mem: ../bin/%-PB.pt
	$(call loadone-skip,$<,$@)

%.mem: ../bin/%.bin
	$(call loadone,$<,$@)

#------------------------------

.PRECIOUS: $(LOGS)

logs: $(LOGS)

%.log : %.simh.script
	$(call genlog_from_script,$<,$@)


#------------------------------

clean:
	rm -rf *.mem *.log
	rm -rf loadtomem
