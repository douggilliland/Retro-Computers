# Building the m68k elf GCC Cross compiler on a linux box
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

### Built on Linux Mint 19.2 Tuna Running in VirtualBox
```
sudo apt install make git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex gettext texinfo
```

## Download needed source files

I modified the Makefile to set the PWD for my machine. You can edit the file to fix the PWD. https://github.com/douggilliland/Retro-Computers/blob/master/68000/Dev%20Tools/m68k-elf-toolchain/Makefile
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
Simply run `make all`

## Did not do the following lines
```
make clean
make clean-prefix
date; make all -j3 >&b.log; date
```
