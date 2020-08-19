C_SRC=
HEADERS=rs232serial.h ringbuffer.h chardevice.h ps2.h
CXX_SRC=main.cpp rs232serial.cpp ps2.cpp ints.cpp minisoc_hardware.cpp textbuffer.cpp
A_SRC=startup.s

BUILD_DIR=BUILD
C_OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SRC))
CXX_OBJ=$(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CXX_SRC))
A_OBJ=$(patsubst %.s,$(BUILD_DIR)/%.o,$(A_SRC))
OBJ= $(A_OBJ) $(CXX_OBJ)
LIBSTDC=-L uClibc++ -luclibc++ -lsupc++ -Lklibc -lc -lgcc

ARCH=68000
CC=m68k-elf-gcc
CXX=m68k-elf-g++
AR=m68k-elf-ar
LD=m68k-elf-g++
STRIP=m68k-elf-strip
VASM=vasmm68k_mot
OBJCOPY=m68k-elf-objcopy
CFLAGS+=-m$(ARCH) -Wall -Wno-char-subscripts -O2 -fno-common -fomit-frame-pointer -I./include
CXXFLAGS+=-m$(ARCH) -msoft-float -Wall -Wno-char-subscripts -O2 -nostdinc \
	-D__KLIBC__ -fno-common -fomit-frame-pointer -fno-exceptions -I./include -IuClibc++/include/
LDFLAGS=-m$(ARCH) -msoft-float

ELF=out.elf
ELFSTRIP=out2.elf
OUTPUT=boot.sre
LINK_SCRIPT=ldscript.ld
LIBC_TARGET=klibc/libc.a


all: $(BUILD_DIR) $(OUTPUT) $(LIBC_TARGET)

cleanall:
	rm -rf $(BUILD_DIR) $(ELF) $(OUTPUT)
	cd klibc; $(MAKE) clean

clean:
	rm -rf $(BUILD_DIR) $(ELF) $(OUTPUT)

$(LIBC_TARGET):
	cd klibc; $(MAKE)

$(ELFSTRIP): $(ELF)
	cp $(ELF) $(ELFSTRIP)
	$(STRIP) $(ELFSTRIP)

$(OUTPUT): $(ELFSTRIP)
	$(OBJCOPY) -O srec $(ELFSTRIP) $(OUTPUT)

$(ELF): $(OBJ) $(LINK_SCRIPT) $(LIBC_TARGET)
	$(LD) $(LDFLAGS) -o $@ -T $(LINK_SCRIPT) $(OBJ) $(LIBSTDC)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
	
$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.s
	$(VASM) -Felf -o $@ $<
