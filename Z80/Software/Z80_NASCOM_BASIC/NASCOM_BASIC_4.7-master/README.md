# NASCOM ROM BASIC Ver 4.7, (C) 1978 Microsoft

Scanned from source published in 80-BUS NEWS from Vol 2, Issue 3 (May-June 1983) to Vol 3, Issue 3 (May-June 1984).

Adapted for the freeware Zilog Macro Assembler 2.10 to produce the original ROM code (checksum A934H). PA

http://www.nascomhomepage.com/

==============================================================================

The updates to the original BASIC within this file are copyright (C) Grant Searle

You have permission to use this for NON COMMERCIAL USE ONLY.
If you wish to use it elsewhere, please include an acknowledgement to myself.

http://searle.wales/

==============================================================================

The rework to support MS Basic HLOAD, RESET, and the Z80 instruction tuning are copyright (C) 2020 Phillip Stevens

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

@feilipu, August 2020

==============================================================================

# RC2014

ACIA 6850 interrupt driven serial I/O to run modified NASCOM Basic 4.7.

Full input and output buffering with incoming data hardware handshaking.
Handshake shows full before the buffer is totally filled to allow run-on from the sender.
Transmit and receive are interrupt driven, and are fast.

Receive buffer is 255 bytes, to allow efficient pasting of Basic into the editor.
Transmit buffer is 15 bytes, because the RC2014 is too slow to fill the buffer.
Receive buffer overflows are silently discarded.

## Mini, Micro, Classic: 32kB MS Basic

This ROM works with the most basic default versions of the RC2014, with 32k of RAM.
This is the ROM to choose if you want fast I/O from a standard RC2014.

This ROM provides both Intel `HLOAD` function and a `RST`, `INT0`, and `NMI` JumP Table.
This allows you to upload Assembly or compiled C programs, and then run them as described.

## Plus: 64kB MS Basic

This version requires a 64k/56k RAM module.
The 56k version utilises the full 56k RAM memory space of the RC2014, starting at `0x2000`.

This ROM provides both Intel `HLOAD` function and a `RST`, `INT0`, and `NMI` JumP Table.
This allows you to upload Assembly or compiled C programs, and then run them as described.

## Mini, Micro, Classic: 32kB MS Basic using AM9511A APU Module

This ROM works with the most basic default versions of the RC2014, with 32k of RAM.
This is the ROM to choose if you want fast I/O from a standard RC2014, and you have installed an AM9511A APU Module.

## Mini, Micro, Classic: 32kB MS Basic using LUT Multiply Module

This ROM works with the most basic default version of the RC2014, with 32k of RAM.
This is the ROM to choose if you want fast I/O from a standard RC2014, and you have installed a LUT (Multiply) Module.

==============================================================================

# YAZ180

ASCI0 interrupt driven serial I/O to run modified NASCOM Basic 4.7.

If you're using the YAZ180 with 32kB Nascom Basic, then all of the RAM between `0x3000` and `0x7FFF` is available for your assembly programs, without limitation. In the YAZ180 the area between `0x2000` and `0x2FFF` is reserved for system calls, buffers, and stack space. For the RC2014 the area from `0x8000` is reserved for these uses.

In the YAZ180 32kB Basic, the area from `0x4000` to `0x7FFF` is the Banked memory area, and this RAM can be managed by the HexLoadr program to write to all of the physical RAM space using ESA Records.

HexLoadr supports the Extended Segment Address Record Type, and will store the MSB of the ESA in the Z180 BBR Register. The LSB of the ESA is silently abandoned. When HexLoadr terminates the BBR is returned to the original value.

Two versions of initialisation routines NASCOM Basic are provided.

## 56k Basic with integrated HexLoadr

The 56k version utilises the full 56k RAM memory space of the YAZ180, starting at `0x2000`.

Full input and output ASCI0 buffering. Transmit and receive are interrupt driven.

Receive buffer is 255 bytes, to allow efficient pasting of Basic into the editor.
Receive buffer overflows are silently discarded.

Transmit buffer is 255 bytes, because the YAZ180 is 36.864MHz CPU.
Transmit function busy waits when buffer is full. No Tx characters lost.

## 32k Basic with integrated HexLoadr

The 32k version uses the CA0 space for buffers and the CA1 space for Basic.
This leaves the Bank RAM / Flash space in `0x4000` to `0x7FFF` available for other usage.

The rationale is to allow in-circuit programming, and an exit to another system.
An integrated HexLoadr program is provided for this purpose.

Full input and output ASCI0 buffering. Transmit and receive are interrupt driven.

Receive buffer is 255 bytes, to allow efficient pasting of Basic into the editor.
Receive buffer overflows are silently discarded.

Transmit buffer is 255 bytes, because the YAZ180 is 36.864MHz CPU.
Transmit function busy waits when buffer is full. No Tx characters lost.

https://feilipu.me/2016/05/23/another-z80-project/

==============================================================================

# Important Addresses

There are a number of important Z80 addresses or origins that need to be managed within your assembly program.

## RST locations

For convenience, because we can't easily change the ROM code interrupt routines already present in the RC2014, the ACIA serial Tx and Rx routines are reachable by calling `RST` instructions from your program.

* Tx: `RST 08H` expects a byte to transmit in the `a` register.
* Rx: `RST 10H` returns a received byte in the `a` register, and will block (loop) until it has a byte to return.
* Rx Check: `RST 18H` will immediately return the number of bytes in the Rx buffer (0 if buffer empty) in the `a` register.

## USR Jump Address & Parameter Access

For the RC2014 with 32k Basic the location for `USR(x)` is `0x8224`, and with 56k Basic the location for `USR(x)` is `0x2224`. For the YAZ180 with 32k Basic the `USR(x)` jump address is located at `0x8004`. For the YAZ180 with 56k Basic the `USR(x)` jump address is located at `0x2704`.

# Program Usage

1. Select the preferred origin `.ORG` for your arbitrary program, and assemble a HEX file using your preferred assembler, or compile a C program using z88dk. For the RC2014 32kB, suitable origins commence from `0x8400`, and the default z88dk origin for RC2014 is `0x9000`.

2. Give the `HLOAD` command within Basic.

3. Using a serial terminal, upload the HEX file for your arbitrary program that you prepared in Step 1, using the Linux `cat` utility or similar. If desired the python `slowprint.py` program can also be used for this purpose. `python slowprint.py > /dev/ttyUSB0 < myprogram.hex` or `cat > /dev/ttyUSB0 < myprogram.hex`. The RC2014 interface can absorb full rate uploads, so using `slowprint.py` is an unnecessary precaution.

4. Start your program by typing `PRINT USR(0)`, or `? USR(0)`, or other variant if you have a parameter to pass to your program.

5. Profit.

## Workflow Notes

Note that your program and the `USR(x)` jump address setting will remain in place through a RC2014 Warm Reset, provided you prevent Basic from initialising the RAM locations you have used. Also, you can reload your assembly program to the same RAM location through multiple Warm Resets, without reprogramming the `USR(x)` jump.

Any Basic programs loaded will also remain in place during a Warm Reset.

Issuing the `RESET` keyword will clear the RC2014 RAM, and return the original memory contents.
