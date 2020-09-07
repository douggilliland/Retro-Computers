ARCH=68000
CC=m68k-elf-gcc
VASM=vasmm68k_mot
LD=m68k-elf-ld
OBJCOPY=m68k-elf-objcopy
SRECCAT=srec_cat

BOOTSTRAPSRC=bootstrap.s 
BOOTSTRAP=bootstrap.elf

RAMTESTSRC=ramtest.s 
RAMTEST=ramtest.elf

SDBOOTSTRAP_CSRC=spi.c
SDBOOTSTRAP_ASRC=sdbootstrap.s
C_OBJ=$(patsubst %.c,%.o,$(SDBOOTSTRAP_CSRC))
A_OBJ=$(patsubst %.s,%.o,$(SDBOOTSTRAP_ASRC))
SDBOOTSTRAPOBJ=$(A_OBJ)
SDBOOTSTRAP=sdbootstrap.elf
SDBOOTSTRAPVHD=sdbootstrap_ROM.vhd

ROMGENDIR = ../../romgen
ROMGEN = $(ROMGENDIR)/romgen

CFLAGS=-m$(ARCH) -O6

all:  $(SDBOOTSTRAPVHD)

clean:
	rm $(SDBOOTSTRAPSREC) $(SDBOOTSTRAPOBJ) $(SDBOOTSTRAP)

$(ROMGEN): $(ROMGENDIR)/romgen.c
	gcc -o $(ROMGENDIR)/romgen $(ROMGENDIR)/romgen.c

%_ROM.vhd: %.bin $(ROMGEN)
	sed 's/soc_firmware/$*_ROM/' >$*_ROM.vhd <$(ROMGENDIR)/rom_prologue.vhd
	$(ROMGEN) $*.bin >>$*_ROM.vhd
	cat >>$*_ROM.vhd $(ROMGENDIR)/rom_epilogue.vhd

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: %.s
	$(VASM) -m68000 -Felf -o $@ $<

%.o: %.s
	$(VASM) -m68000 -Felf -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.srec: %.elf
	$(OBJCOPY) -O srec $< $@

$(SDBOOTSTRAP): $(SDBOOTSTRAPOBJ)
	$(LD) -T ldscript.ld -o $@ $(SDBOOTSTRAPOBJ)


