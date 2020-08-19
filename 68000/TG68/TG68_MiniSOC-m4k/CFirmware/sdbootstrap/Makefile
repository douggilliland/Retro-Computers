C_SRC=spi.c textbuffer.c
A_SRC=sdbootstrap.s spi_readsector.s

BUILD_DIR=BUILD
C_OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SRC))
A_OBJ=$(patsubst %.s,$(BUILD_DIR)/%.o,$(A_SRC))
OBJ= $(A_OBJ) $(C_OBJ)

ARCH=68000
CC=m68k-elf-gcc
AR=m68k-elf-ar
VASM=vasmm68k_mot
OBJCOPY=m68k-elf-objcopy
CFLAGS+=-m$(ARCH) -Wall -Wno-char-subscripts -O2 -fno-common -fomit-frame-pointer -I./include
LDFLAGS+=-m$(ARCH) -Xlinker -Map=menu.map -nostartfiles -L../klibc

ELF=sdboot.elf
OUTPUT=sdboot.srec
LINK_SCRIPT=ldscript.ld

all: $(BUILD_DIR) $(OUTPUT) $(BOOTSTRAP)

cleanall:
	rm -rf $(BUILD_DIR) $(LIBC_TARGET) $(ELF) $(OUTPUT)
	cd bootstrap; $(MAKE) clean
	cd klibc; $(MAKE) clean

clean:
	rm -rf $(BUILD_DIR) $(LIBC_TARGET) $(ELF) $(OUTPUT)

$(OUTPUT): $(ELF)
	$(OBJCOPY) -O srec $(ELF) $(OUTPUT)

$(ELF): $(OBJ) $(LINK_SCRIPT)
	$(CC) $(LDFLAGS) -o $@ -T $(LINK_SCRIPT) $(OBJ)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
	
$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.s
	$(VASM) -Felf -o $@ $<
