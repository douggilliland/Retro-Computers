# m68k elf gcc
The GNU C-Compiler with Binutils and other useful tools for cross development

This is a Makefile based approach to build the toolchain to reduce the build time.

Right now these tools are build:
* binutils
* gcc with libs for C/C++/ObjC
* vasm
* vbcc
* vlink
* newlib


# Short Guide
## Prerequisites

### Ubuntu
```
sudo apt install make git gcc g++ lhasa libgmp-dev libmpfr-dev libmpc-dev flex gettext texinfo
```

### Windows with Cygwin
Install cygwin via setup.exe and add wget. Then open cygwin shell and run:

```
wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
install apt-cyg /bin
apt-cyg install gcc-core gcc-g++ python git perl-Pod-Simple gperf patch automake make makedepend bison flex libncurses-devel python-devel gettext-devel libgmp-devel libmpc-devel libmpfr-devel
```

### Windows with MSYS2/MinGW
Install then open the shell and run:

```
pacman -S vim git tar unzip bison texinfo gettext libtool autoconf automake gcc make wget patch rsync flex ncurses-devel
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
If building using MSYS2/MinGW windows paths can be specified as follows.
```
make all PREFIX=c:/m68k-elf
```
or
```
make all PREFIX=c:\\m68k-elf
```



## Building
Simply run `make all`. Also add -j to speedup the build.

```
make clean
make clean-prefix
date; make all -j3 >&b.log; date
```
