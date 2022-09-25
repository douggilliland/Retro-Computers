# xDbg

xDbg is a 65C02 debugger meant to compliment the Corsham Technologies [xKIM monitor](https://github.com/CorshamTech/xKIM).

## Features
* Pure 6502 code.
* Can load Intel hex files from either the SD card or console.
* Breakpoints without external hardware support.
* Single-stepping without external hardware support.
* WDC65C02 disassembler.
* Examine/edit memory.
* Can compute offsets for relative branches within memory editor.

## Command Summary (not a complete list)
* Exmine/edit memory.
* Display/set registers.
* Jump to code.
* Load Intel hex file from console or SD card.
* Directory of SD card.
* Branch offset calculator, also within memory editor.
* Disassemble WDC65C02 code.
* Step/Step-over
* Breakpoints: list, set, clear, enable, disable.

## Requirements

Must have xKIM v1.8 or later for many of the commands to work, as that version provides subroutine calls for common tools.

# Nota Bene

This is still a work-in-progress, meaning that it has been tested quite a bit as new features were added, but almost certainly contains many bugs still.  The biggest area of doubt is the disassembler, as not every 65C02 instruction has been tested.  

The debugger supports the WDC65C02 processor although it uses only 6502 instructions.  That means if you disassemble a bad 6502 opcode, it might display as a perfectly good WDC65C02 instruction.  Of course, if you execute that instruction while running on a 6502 then bad stuff might happen.

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
