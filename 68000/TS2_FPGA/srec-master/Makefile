CC=clang
CFLAGS=-Wall -std=c99 -pedantic -Wextra -Weverything -Wno-padded -Os #-emit-llvm
LDFLAGS=-Os
AR=ar
ARFLAGS=rcs

OBJS = kk_srec.o bin2srec.o srec2bin.o
BINPATH = ./
LIBPATH = ./
BINS = $(BINPATH)srec2bin $(BINPATH)bin2srec
LIB = $(LIBPATH)libkk_srec.a
TESTER =
TESTFILE = $(LIB)

.PHONY: all clean distclean test

all: $(BINS) $(LIB)

$(OBJS): kk_srec.h
$(BINS): | $(BINPATH)
$(LIB): | $(LIBPATH)

$(LIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $+

$(BINPATH)srec2bin: srec2bin.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $+

$(BINPATH)bin2srec: bin2srec.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $+

test: $(BINPATH)bin2srec $(BINPATH)srec2bin $(TESTFILE)
	@$(TESTER) $(BINPATH)bin2srec -v -a 0x80000 \
		-h '123456789_123456789_123456789_1' \
		-i '$(TESTFILE)' -x 0xFF | \
	    $(TESTER) $(BINPATH)srec2bin -A -v | \
	    diff '$(TESTFILE)' -
	@echo Loopback test success!

$(sort $(BINPATH) $(LIBPATH)):
	@mkdir -p $@

clean:
	rm -f $(OBJS)

distclean: | clean
	rm -f $(BINS) $(LIB)
	@rmdir $(BINPATH) $(LIBPATH) >/dev/null 2>/dev/null || true

