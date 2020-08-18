# m68k elf gcc
The GNU C-Compiler with Binutils and other useful tools for 68000 cross development

This is a Makefile based approach to build the toolchain to reduce the build time.

The original work was by Steve Moody https://github.com/SteveMoody73/m68k-elf-toolchain

These tools are build:
* binutils
* gcc with libs for C/C++/ObjC
* vasm
* vbcc
* vlink
* newlib


# Short Guide
## Prerequisites

### Linux Mint
```
sudo apt install make git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex gettext texinfo
```

## Download needed source files

```
git clone https://github.com/SteveMoody73/m68k-elf-toolchain
cd m68k-elf-toolchain
make update
```

## Overview
```
make help
```
yields:
```
make help            display this help
make info            print prefix and other flags
make all             build and install all
make <target>        builds a target: binutils, gcc, vasm, vbcc, vlink, libgcc, newlib
make clean           remove the build folder
make clean-<target>  remove the target's build folder
make clean-prefix    remove all content from the prefix folder
make update          perform git pull for all targets
make update-<target> perform git pull for the given target
make info            display some info

```
display which targets can be build, you'll mostly use
*`make all`
*`make clean`
*`make clean-prefx`
## Prefix
The default prefix is `/opt/m68k-elf`. You may specify a different prefix by adding `PREFIX=yourprefix` to make command. E.g.
```
make all PREFIX=/opt/m68k
```

Note: I modified Steve's Makefile to set the PWD variable to the path I was installing from.

## Building
Simply run `make all`. Also add -j to speedup the build.

```
make clean
make clean-prefix
date; make all -j3 >&b.log; date
```
