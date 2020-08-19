# =================================================
# Makefile for building m68k gcc
# based on the amiga gcc makefile by bebbo
# =================================================

include disable_implicite_rules.mk

# =================================================
# variables
# =================================================
SHELL = /bin/bash
PREFIX ?= /opt/m68k-elf

UNAME_S := $(shell uname -s)
BUILD := build-$(UNAME_S)

PWD = /home/doug/m68k-elf-toolchain

GCC_VERSION ?= $(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)

BINUTILS_BRANCH := binutils-2_33-branch
GCC_BRANCH := releases/gcc-9
GCC_LANGUAGES := c,c++,lto

BUILD_THREADS := -j3

GIT_BINUTILS         := git://sourceware.org/git/binutils-gdb.git
GIT_GCC              := https://github.com/gcc-mirror/gcc
GIT_NEWLIB_CYGWIN    := git://sourceware.org/git/newlib-cygwin.git
GIT_VASM             := https://github.com/leffmann/vasm
GIT_VBCC             := https://github.com/bebbo/vbcc
GIT_VLINK            := https://github.com/leffmann/vlink

CFLAGS ?= -Os
CXXFLAGS ?= $(CFLAGS)
CFLAGS_FOR_TARGET ?= -O2 -fomit-frame-pointer
CXXFLAGS_FOR_TARGET ?= $(CFLAGS_FOR_TARGET) -fno-exceptions -fno-rtti

E:=CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" CFLAGS_FOR_BUILD="$(CFLAGS)" CXXFLAGS_FOR_BUILD="$(CXXFLAGS)"  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" CXXFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)"

# =================================================
# determine exe extension for cygwin
$(eval MYMAKE = $(shell which make) )
$(eval MYMAKEEXE = $(shell which "$(MYMAKE:%=%.exe)" 2>/dev/null) )
EXEEXT=$(MYMAKEEXE:%=.exe)

UNAME_S := $(shell uname -s)

# Files for GMP, MPC and MPFR

GMP = gmp-6.1.2
GMPFILE = $(GMP).tar.bz2
MPC = mpc-1.0.3
MPCFILE = $(MPC).tar.gz
MPFR = mpfr-3.1.6
MPFRFILE = $(MPFR).tar.bz2

# =================================================
# pretty output ^^
# =================================================
TEEEE := >&

ifeq ($(sdk),)
__LINIT := $(shell rm .state 2>/dev/null)
endif

$(eval has_flock = $(shell which flock 2>/dev/null))
ifeq ($(has_flock),)
FLOCK := echo >/dev/null
else
FLOCK := $(has_flock)
endif

L0 = @__p=
L00 = __p=
ifeq ($(verbose),)
L1 = ; ($(FLOCK) 200; echo -e \\033[33m$$__p...\\033[0m >>.state; echo -ne \\033[33m$$__p...\\033[0m ) 200>.lock; mkdir -p log; __l="log/$$__p.log" ; (
L2 = )$(TEEEE) "$$__l"; __r=$$?; ($(FLOCK) 200; if (( $$__r > 0 )); then \
  echo -e \\r\\033[K\\033[31m$$__p...failed\\033[0m; \
  tail -n 100 "$$__l"; \
  echo -e \\033[31m$$__p...failed\\033[0m; \
  echo -e \\033[1mless \"$$__l\"\\033[0m; \
  else echo -e \\r\\033[K\\033[32m$$__p...done\\033[0m; fi \
  ;grep -v "$$__p" .state >.state0 2>/dev/null; mv .state0 .state ;echo -n $$(cat .state | paste -sd " " -); ) 200>.lock; [[ $$__r -gt 0 ]] && exit $$__r; echo -n ""
else
L1 = ;
L2 = ;
endif

# =================================================
# working out the correct prefix path for msys
DETECTED_CC = $(CC)
ifeq ($(CC),cc)
DETECTED_VERSION =  $(shell $(CC) -v |& grep version)
ifneq ($(findstring clang,$(DETECTED_VERSION)),)
DETECTED_CC = clang
endif
ifneq ($(findstring gcc,$(DETECTED_VERSION)),)
DETECTED_CC = gcc
endif
endif

USED_CC_VERSION = $(shell $(DETECTED_CC) -v |& grep Target)
BUILD_TARGET=unix
ifneq ($(findstring msys,$(USED_CC_VERSION)),)
BUILD_TARGET=msys
  else
  ifneq ($(findstring mingw,$(USED_CC_VERSION)),)
BUILD_TARGET=msys
  endif
endif

PREFIX_TARGET = $(PREFIX)
ifneq ($(findstring :,$(PREFIX)),)
# Under mingw convert paths such as c:/gcc to /c/gcc
# Quotes added to work around a broken pipe error when running under MinGW
PREFIX_SUB = "/$(subst \,/,$(subst :,,$(PREFIX)))"
PREFIX_PATH = $(subst ",,$(PREFIX_SUB))
else
PREFIX_PATH = $(PREFIX)
endif

export PATH := $(PREFIX_PATH)/bin:$(PATH)

AR_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-ar
AS_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-as
LD_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-ld
NM_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-nm
OBJCOPY_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-objcopy
OBJDUMP_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-objdump
RANLIB_FOR_TARGET=$(PREFIX_PATH)/bin/m68k-elf-ranlib


UPDATE = __x=
ANDPULL = ;__y=$$(git branch | grep '*' | cut -b3-);echo setting remote origin from $$(git remote get-url origin) to $$__x using branch $$__y;\
	git remote remove origin; \
	git remote add origin $$__x; \
	git pull origin $$__y;\
	git branch --set-upstream-to=origin/$$__y $$__y; \

# =================================================

.PHONY: x
x:
	@if [ "$(sdk)" == "" ]; then \
		$(MAKE) help; \
	else \
		$(MAKE) sdk; \
	fi

# =================================================
# help
# =================================================
.PHONY: help
help:
	@echo "make help            display this help"
	@echo "make info            print prefix and other flags"
	@echo "make all             build and install all"
	@echo "make <target>        builds a target: binutils, gcc, vasm, vbcc, vlink, libgcc, newlib"
	@echo "make clean           remove the build folder"
	@echo "make clean-<target>	remove the target's build folder"
	@echo "make clean-prefix    remove all content from the prefix folder"
	@echo "make update          perform git pull for all targets"
	@echo "make update-<target> perform git pull for the given target"
	@echo "make info			display some info"

# =================================================
# all
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: install-dll
all: install-dll
endif

.PHONY: all gcc binutils vasm vbcc vlink libgcc newlib
all: gcc binutils vasm vbcc vlink libgcc newlib

# =================================================
# clean
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: clean-gmp clean-mpc clean-mpfr
clean: clean-gmp clean-mpc clean-mpfr
endif

.PHONY: clean-prefix clean clean-gcc clean-binutils clean-vasm clean-vbcc clean-vlink clean-libgcc clean-newlib
clean: clean-gcc clean-binutils clean-vasm clean-vbcc clean-vlink clean-newlib
	rm -rf $(BUILD)

clean-gcc:
	rm -rf $(BUILD)/gcc

clean-gmp:
	rm -rf projects/gcc/gmp

clean-mpc:
	rm -rf projects/gcc/mpc

clean-mpfr:
	rm -rf projects/gcc/mpfr

clean-libgcc:
	rm -rf $(BUILD)/gcc/m68k-elf
	rm -f $(BUILD)/gcc/_libgcc_done

clean-binutils:
	rm -rf $(BUILD)/binutils

clean-vasm:
	rm -rf $(BUILD)/vasm

clean-vbcc:
	rm -rf $(BUILD)/vbcc

clean-vlink:
	rm -rf $(BUILD)/vlink

clean-newlib:
	rm -rf $(BUILD)/newlib

# clean-prefix drops the files from prefix folder
clean-prefix:
	rm -rf $(PREFIX_PATH)/bin
	rm -rf $(PREFIX_PATH)/libexec
	rm -rf $(PREFIX_PATH)/lib/gcc
	rm -rf $(PREFIX_PATH)/m68k-elf
	mkdir -p $(PREFIX_PATH)/bin

# =================================================
# update all projects
# =================================================
ifeq ($(BUILD_TARGET),msys)
.PHONY: update-gmp update-mpc update-mpfr
update: update-gmp update-mpc update-mpfr
endif

.PHONY: update update-gcc update-binutils update-vasm update-vbcc update-vlink update-newlib
update: update-gcc update-binutils update-vasm update-vbcc update-vlink update-newlib

update-gcc: projects/gcc/configure
	cd projects/gcc && export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done

update-binutils: projects/binutils/configure
	cd projects/binutils && export DEPTH=16; while true; do echo "trying depth=$$DEPTH"; git pull --depth $$DEPTH && break; export DEPTH=$$(($$DEPTH+$$DEPTH));done

update-vasm: projects/vasm/Makefile
	@cd projects/vasm && git pull

update-vbcc: projects/vbcc/Makefile
	@cd projects/vbcc && git pull

update-vlink: projects/vlink/Makefile
	@cd projects/vlink && git pull

update-newlib: projects/newlib-cygwin/newlib/configure
	@cd projects/newlib-cygwin && git pull

ifeq ($(BUILD_TARGET),msys)
update-gmp:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(GMPFILE) ]; \
	then rm -rf projects/$(GMP); rm -rf projects/gcc/gmp; \
	else cd download && wget ftp://ftp.gnu.org/gnu/gmp/$(GMPFILE); \
	fi;
	cd projects && tar xf ../download/$(GMPFILE)
	
update-mpc:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(MPCFILE) ]; \
	then rm -rf projcts/$(MPC); rm -rf projects/gcc/mpc; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpc/$(MPCFILE); \
	fi;
	cd projects && tar xf ../download/$(MPCFILE)

update-mpfr:
	@mkdir -p download
	@mkdir -p projects
	if [ -a download/$(MPFRFILE) ]; \
	then rm -rf projects/$(MPFR); rm -rf projects/gcc/mpfr; \
	else cd download && wget ftp://ftp.gnu.org/gnu/mpfr/$(MPFRFILE); \
	fi;
	cd projects && tar xf ../download/$(MPFRFILE)
endif

status-all:
	GCC_VERSION=$(shell cat 2>/dev/null projects/gcc/gcc/BASE-VER)
# =================================================
# B I N
# =================================================
	
# =================================================
# binutils
# =================================================
CONFIG_BINUTILS :=--prefix=$(PREFIX_TARGET) --target=m68k-elf --disable-werror --enable-lto
BINUTILS_CMD := m68k-elf-addr2line m68k-elf-ar m68k-elf-as m68k-elf-c++filt \
	m68k-elf-ld m68k-elf-nm m68k-elf-objcopy m68k-elf-objdump m68k-elf-ranlib \
	m68k-elf-readelf m68k-elf-size m68k-elf-strings m68k-elf-strip
BINUTILS := $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(BINUTILS_CMD))

BINUTILS_DIR := . bfd gas ld binutils opcodes
BINUTILSD := $(patsubst %,projects/binutils/%, $(BINUTILS_DIR))

ifeq ($(findstring Darwin,$(shell uname)),)
ALL_GDB := all-gdb
INSTALL_GDB := install-gdb
endif

binutils: $(BUILD)/binutils/_done

$(BUILD)/binutils/_done: $(BUILD)/binutils/Makefile $(shell find 2>/dev/null projects/binutils -not \( -path projects/binutils/.git -prune \) -not \( -path projects/binutils/gprof -prune \) -type f)
	@touch -t 0001010000 projects/binutils/binutils/arparse.y
	@touch -t 0001010000 projects/binutils/binutils/arlex.l
	@touch -t 0001010000 projects/binutils/ld/ldgram.y
	@touch -t 0001010000 projects/binutils/intl/plural.y
	$(L0)"make binutils"$(L1)$(MAKE) $(BUILD_THREADS) -C $(BUILD)/binutils all-gas all-binutils all-ld $(ALL_GDB) $(L2)
	$(L0)"install binutils"$(L1)$(MAKE) -C $(BUILD)/binutils install-gas install-binutils install-ld $(INSTALL_GDB) $(L2) 
	@echo "done" >$@

$(BUILD)/binutils/Makefile: projects/binutils/configure
	@mkdir -p $(BUILD)/binutils
	$(L0)"configure binutils"$(L1) cd $(BUILD)/binutils && $(E) $(PWD)/projects/binutils/configure $(CONFIG_BINUTILS) $(L2)
	 
projects/binutils/configure:
	@mkdir -p projects
	@cd projects &&	git clone -b $(BINUTILS_BRANCH) --depth 16 $(GIT_BINUTILS) binutils

# =================================================
# gcc
# =================================================
CONFIG_GCC=--prefix=$(PREFIX_TARGET) --target=m68k-elf --enable-languages=$(GCC_LANGUAGES) \
    --enable-version-specific-runtime-libs --disable-libssp --disable-nls --disable-threads \
	--disable-libmudflap --disable-libgomp --disable-libstdcxx-pch --with-gnu-as --with-gnu-ld \
	--with-newlib --with-headers=$(PWD)/projects/newlib-cygwin/newlib/libc/include/ --disable-shared \
	--src=../../projects/gcc 

GCC_CMD = m68k-elf-c++ m68k-elf-g++ m68k-elf-gcc-$(GCC_VERSION) m68k-elf-gcc-nm \
	m68k-elf-gcov m68k-elf-gcov-tool m68k-elf-cpp m68k-elf-gcc m68k-elf-gcc-ar \
	m68k-elf-gcc-ranlib m68k-elf-gcov-dump
GCC = $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(GCC_CMD))

GCC_DIR := . gcc gcc/c gcc/c-family gcc/cp gcc/objc gcc/config/m68k libiberty libcpp libdecnumber
GCCD := $(patsubst %,projects/gcc/%, $(GCC_DIR))

gcc: $(BUILD)/gcc/_done

$(BUILD)/gcc/_done: $(BUILD)/gcc/Makefile $(shell find 2>/dev/null $(GCCD) -maxdepth 1 -type f )
	$(L0)"make gcc"$(L1) $(MAKE) $(BUILD_THREADS) -C $(BUILD)/gcc all-gcc $(L2) 
	$(L0)"install gcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-gcc $(L2) 
	@echo "done" >$@

$(BUILD)/gcc/Makefile: projects/gcc/configure $(BUILD)/binutils/_done
	@mkdir -p $(BUILD)/gcc
ifeq ($(BUILD_TARGET),msys)
	@mkdir -p projects/gcc/gmp
	@mkdir -p projects/gcc/mpc
	@mkdir -p projects/gcc/mpfr
	@rsync -a projects/$(GMP)/* projects/gcc/gmp
	@rsync -a projects/$(MPC)/* projects/gcc/mpc
	@rsync -a projects/$(MPFR)/* projects/gcc/mpfr
endif	
	$(L0)"configure gcc"$(L1) cd $(BUILD)/gcc && $(E) $(PWD)/projects/gcc/configure $(CONFIG_GCC) $(L2) 

projects/gcc/configure:
	@mkdir -p projects
	@cd projects &&	git clone -b $(GCC_BRANCH) --depth 16 $(GIT_GCC)

# =================================================
# vasm
# =================================================
VASM_CMD := vasmm68k_mot
VASM := $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VASM_CMD))

vasm: $(BUILD)/vasm/_done

$(BUILD)/vasm/_done: $(BUILD)/vasm/Makefile 
	$(L0)"make vasm"$(L1) $(MAKE) -C $(BUILD)/vasm CPU=m68k SYNTAX=mot $(L2) 
	@mkdir -p $(PREFIX_PATH)/bin/
	$(L0)"install vasm"$(L1) install $(BUILD)/vasm/vasmm68k_mot $(PREFIX_PATH)/bin/ ;\
	install $(BUILD)/vasm/vobjdump $(PREFIX_PATH)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vasm/Makefile: projects/vasm/Makefile $(shell find 2>/dev/null projects/vasm -not \( -path projects/vasm/.git -prune \) -type f)
	@rsync -a projects/vasm $(BUILD)/ --exclude .git
	@touch $(BUILD)/vasm/Makefile

projects/vasm/Makefile:
	@mkdir -p projects
	@cd projects &&	git clone -b master --depth 4 $(GIT_VASM)

# =================================================
# vbcc
# =================================================
VBCC_CMD := vbccm68k vprof vc
VBCC := $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VBCC_CMD))

vbcc: $(BUILD)/vbcc/_done

$(BUILD)/vbcc/_done: $(BUILD)/vbcc/Makefile
	$(L0)"make vbcc dtgen"$(L1) TARGET=m68k $(MAKE) -C $(BUILD)/vbcc bin/dtgen $(L2)
	@cd $(BUILD)/vbcc && echo -e "y\\ny\\nsigned char\\ny\\nunsigned char\\nn\\ny\\nsigned short\\nn\\ny\\nunsigned short\\nn\\ny\\nsigned int\\nn\\ny\\nunsigned int\\nn\\ny\\nsigned long long\\nn\\ny\\nunsigned long long\\nn\\ny\\nfloat\\nn\\ny\\ndouble\\n" >c.txt
	$(L0)"run vbcc dtgen"$(L1) cd $(BUILD)/vbcc && bin/dtgen machines/m68k/machine.dt machines/m68k/dt.h machines/m68k/dt.c <c.txt $(L2)
	$(L0)"make vbcc"$(L1) TARGET=m68k $(MAKE) -C $(BUILD)/vbcc $(L2) 
	@mkdir -p $(PREFIX_PATH)/bin/
	@rm -rf $(BUILD)/vbcc/bin/*.dSYM
	$(L0)"install vbcc"$(L1) install $(BUILD)/vbcc/bin/v* $(PREFIX_PATH)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vbcc/Makefile: projects/vbcc/Makefile $(shell find 2>/dev/null projects/vbcc -not \( -path projects/vbcc/.git -prune \) -type f)
	@rsync -a projects/vbcc $(BUILD)/ --exclude .git
	@mkdir -p $(BUILD)/vbcc/bin
	@touch $(BUILD)/vbcc/Makefile

projects/vbcc/Makefile:
	@mkdir -p projects
	@cd projects &&	git clone -b master --depth 4 $(GIT_VBCC)

# =================================================
# vlink
# =================================================
VLINK_CMD := vlink
VLINK := $(patsubst %,$(PREFIX_PATH)/bin/%$(EXEEXT), $(VLINK_CMD))

vlink: $(BUILD)/vlink/_done

$(BUILD)/vlink/_done: $(BUILD)/vlink/Makefile $(shell find 2>/dev/null projects/vlink -not \( -path projects/vlink/.git -prune \) -type f)
	$(L0)"make vlink"$(L1) cd $(BUILD)/vlink && TARGET=m68k $(MAKE) $(L2) 
	@mkdir -p $(PREFIX_PATH)/bin/
	$(L0)"install vlink"$(L1) install $(BUILD)/vlink/vlink $(PREFIX_PATH)/bin/ $(L2)
	@echo "done" >$@

$(BUILD)/vlink/Makefile: projects/vlink/Makefile
	@rsync -a projects/vlink $(BUILD)/ --exclude .git

projects/vlink/Makefile:
	@mkdir -p projects
	@cd projects &&	git clone -b master --depth 4 $(GIT_VLINK)

# =================================================
# L I B R A R I E S
# =================================================


# =================================================
# gcc libs
# =================================================
LIBGCCS_NAMES := libgcov.a libstdc++.a libsupc++.a
LIBGCCS := $(patsubst %,$(PREFIX_PATH)/lib/gcc/m68k-elf/$(GCC_VERSION)/%,$(LIBGCCS_NAMES))

libgcc: $(BUILD)/gcc/_libgcc_done

$(BUILD)/gcc/_libgcc_done: $(shell find 2>/dev/null projects/gcc/libgcc -type f)
	$(L0)"make libgcc"$(L1) $(MAKE) $(BUILD_THREADS) -C $(BUILD)/gcc all-target $(L2) 
	$(L0)"install libgcc"$(L1) $(MAKE) -C $(BUILD)/gcc install-target $(L2)
	@echo "done" >$@

# =================================================
# newlib
# =================================================
NEWLIB_FILES = $(shell find 2>/dev/null projects/newlib-cygwin/newlib -type f)
NEWLIB_CONFIG := --target=m68k-elf --prefix=$(PREFIX_PATH) --enable-newlib-io-c99-formats --enable-newlib-reent-small \
                 --enable-newlib-mb --disable-shared --enable-static --enable-newlib-multithread --disable-newlib-mb \
				 --disable-newlib-atexit-alloc --enable-target-optspace --enable-fast-install

.PHONY: newlib
newlib: $(BUILD)/newlib/_done

$(BUILD)/newlib/_done: $(BUILD)/newlib/newlib/libc.a 
	@echo "done" >$@

$(BUILD)/newlib/newlib/libc.a: $(BUILD)/newlib/newlib/Makefile $(NEWLIB_FILES)
	$(L0)"make newlib"$(L1) $(MAKE) $(BUILD_THREADS) -C $(BUILD)/newlib/newlib $(L2) 
	$(L0)"install newlib"$(L1) $(MAKE) -C $(BUILD)/newlib/newlib install $(L2) 

ifeq (,$(wildcard $(BUILD)/gcc/_done))
$(BUILD)/newlib/newlib/Makefile: $(BUILD)/gcc/_done
endif

$(BUILD)/newlib/newlib/Makefile: projects/newlib-cygwin/configure  
	@mkdir -p $(BUILD)/newlib/newlib
	@rsync -a $(PWD)/projects/newlib-cygwin/newlib/libc/include/ $(PREFIX_PATH)/m68k-elf/sys-include
	$(L0)"configure newlib"$(L1) cd $(BUILD)/newlib/newlib &&  $(PWD)/projects/newlib-cygwin/configure $(NEWLIB_CONFIG) $(L2)

projects/newlib-cygwin/newlib/configure: 
	@mkdir -p projects
	@cd projects &&	git clone --depth 4  $(GIT_NEWLIB_CYGWIN)


# =================================================
# Copy needed dll files
# =================================================

install-dll: $(BUILD)/_installdll_done

$(BUILD)/_installdll_done: $(BUILD)/newlib/_done
ifeq ($(BUILD_TARGET),msys)
	@rsync /usr/bin/msys-2.0.dll $(PREFIX_PATH)/bin
	@rsync /usr/bin/msys-2.0.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	@rsync /usr/bin/msys-2.0.dll $(PREFIX_PATH)/m68k-elf/bin
	@rsync /usr/bin/msys-stdc++-6.dll $(PREFIX_PATH)/bin
	@rsync /usr/bin/msys-stdc++-6.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	@rsync /usr/bin/msys-stdc++-6.dll $(PREFIX_PATH)/m68k-elf/bin
	@rsync /usr/bin/msys-gcc_s-seh-1.dll $(PREFIX_PATH)/bin
	@rsync /usr/bin/msys-gcc_s-seh-1.dll $(PREFIX_PATH)/libexec/gcc/m68k-elf/$(GCC_VERSION)
	@rsync /usr/bin/msys-gcc_s-seh-1.dll $(PREFIX_PATH)/m68k-elf/bin

endif
	@echo "done" >$@
	@touch $@


# =================================================
# info
# =================================================
.PHONY: info v r
info:
	@echo $@ $(UNAME_S)
	@echo CC = $(DETECTED_CC) $(USED_CC_VERSION)
	@echo BUILD_TARGET=$(BUILD_TARGET)
	@echo PREFIX=$(PREFIX)
	@echo PREFIX_PATH=$(PREFIX_PATH)
	@echo GCC_GIT=$(GCC_GIT)
	@echo GCC_BRANCH=$(GCC_BRANCH)
	@echo GCC_VERSION=$(GCC_VERSION)
	@echo CFLAGS=$(CFLAGS)
	@echo TARGET_C_FLAGS=$(TARGET_C_FLAGS)
	@echo BINUTILS_GIT=$(BINUTILS_GIT)
	@echo BINUTILS_BRANCH=$(BINUTILS_BRANCH)
	@$(CC) -v -E - </dev/null |& grep " version "
	@$(CXX) -v -E - </dev/null |& grep " version "
	@echo $(BUILD)

v:
	@for i in projects/* ; do cd $$i 2>/dev/null && echo $$i && (git log -n1 --pretty=oneline) && cd ../..; done
	@echo "." && git log -n1 --pretty=oneline

r:
	@for i in projects/* ; do cd $$i 2>/dev/null && echo $$i && (git remote -v) && cd ../..; done
	@echo "." && git remote -v
