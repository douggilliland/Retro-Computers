KLIBC_SRC=vsnprintf.c sprintf.c memcpy.c memcmp.c strcpy.c strcmp.c strcat.c strncat.c \
	strncmp.c strlen.c strncpy.c strchr.c malloc.c calloc.c zalloc.c realloc.c
KLIBC_ASM_SRC=memset_asm.s

BUILD_DIR=BUILD
LIBC_OBJ=$(patsubst %.c,$(BUILD_DIR)/%.o,$(KLIBC_SRC))
LIBC_ASM_OBJ=$(patsubst %.s,$(BUILD_DIR)/%.o,$(KLIBC_ASM_SRC))

ARCH=68000
CC=m68k-elf-gcc
AR=m68k-elf-ar
VASM=vasmm68k_mot
CFLAGS+=-m$(ARCH) -Wall -Wno-char-subscripts -O2 -fno-common -fomit-frame-pointer -I../include
LDFLAGS+=-m$(ARCH) -Xlinker -Map=menu.map -nostartfiles -L.

LIBC_TARGET=libc.a

all: $(BUILD_DIR) $(LIBC_TARGET)

clean:
	rm -rf $(BUILD_DIR) $(LIBC_TARGET)

$(LIBC_TARGET): $(LIBC_OBJ) $(LIBC_ASM_OBJ)
	$(AR) -r $(LIBC_TARGET) $(LIBC_OBJ) $(LIBC_ASM_OBJ)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
	
$(BUILD_DIR)/%.o: %.s
	$(VASM) -Felf -o $@ $<

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

