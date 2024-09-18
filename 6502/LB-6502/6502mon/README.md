# Enhanced BASIC

Loomcom 6502 ROM Monitor plus Enhanced BASIC

**Version:** 1.0

**Last Updated:** July 27, 2014

## 1.0 About

This project contains an experimental 6502 ROM monitor being developed
for the [Symon 6502 Simulator](http://github.com/sethm/symon) and
associated hardware.

## 2.0 Assembly

Assembled with [CA65](http://www.cc65.org/doc/ca65.html) under Windows. rUN MAKEMON.BAT
to make to ROM file moncode.hex.

## 3.0 To Do

- Enhance the 'E' and 'D' commands to take '/' as the first
  argument, which will automatically increment the previously
  used Examine or Deposit address. e.g.:

```
     *D 0300 01   ; Deposit "01" to 0x0300
     *D / 02      ; Deposit "02" to 0x0301
     *D / 03      ; Deposit "03" to 0x0302
```

## 4.0 License

This project is free software. It is distributed under the MIT
License. Please see the file 'COPYING' for full details of the
license.

## 5.0 Acknowledgements

Enhanced 6502 BASIC (EhBASIC, contained entirely in the file
"basic.asm") is Version 2.22, and is copyright (c) Lee Davison.
It is distributed for non-commercial use only!
