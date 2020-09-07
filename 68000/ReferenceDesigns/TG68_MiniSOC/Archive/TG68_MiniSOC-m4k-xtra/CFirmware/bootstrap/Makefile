ARCH=68000
CC=m68k-elf-gcc
VASM=vasmm68k_mot
LD=m68k-elf-ld
OBJCOPY=m68k-elf-objcopy
SRECCAT=srec_cat

BOOTSTRAPSRC=bootstrap.s 
BOOTSTRAP=bootstrap.elf
BOOTSTRAPSREC=bootstrap.srec
BOOTSTRAPMIF=bootstrap.mif

SDBOOTSTRAP_CSRC=spi.c
SDBOOTSTRAP_ASRC=sdbootstrap.s
C_OBJ=$(patsubst %.c,%.o,$(SDBOOTSTRAP_CSRC))
A_OBJ=$(patsubst %.s,%.o,$(SDBOOTSTRAP_ASRC))
SDBOOTSTRAPOBJ=$(A_OBJ)
SDBOOTSTRAP=sdbootstrap.elf
SDBOOTSTRAPSREC=sdbootstrap.srec
SDBOOTSTRAPMIF=sdbootstrap.mif

all:  $(BOOTSTRAPMIF) $(SDBOOTSTRAPMIF)

clean:
	rm $(BOOTSTRAP) $(BOOTSTRAPSREC) $(SDBOOTSTRAPSREC) $(SDBOOTSTRAPOBJ) $(SDBOOTSTRAP) $(BOOTSTRAPMIF) $(SDBOOTSTRAPMIF)

$(BOOTSTRAP): $(BOOTSTRAPSRC)
	$(VASM) -m68000 -Felf -o $@ $<

%.o: %.s
	$(VASM) -m68000 -Felf -o $@ $<

%.o: %.c
	$(CC) -O1 -c -o $@ $<

$(SDBOOTSTRAP): $(SDBOOTSTRAPOBJ)
	$(LD) -T ldscript.ld -o $@ $(SDBOOTSTRAPOBJ)

$(BOOTSTRAPSREC): $(BOOTSTRAP)
	$(OBJCOPY) -O srec $< $@

$(SDBOOTSTRAPSREC): $(SDBOOTSTRAP)
	$(OBJCOPY) -O srec $< $@

$(BOOTSTRAPMIF): $(BOOTSTRAPSREC)
	$(SRECCAT) $< -o $@ -mif 16

$(SDBOOTSTRAPMIF): $(SDBOOTSTRAPSREC)
	$(SRECCAT) $< -o $@ -mif 16
