---
layout: board
title: Serial board
status: prod
design_files: https://gitlab.com/planck-6502/planck-6502/-/tree/master/Hardware/serial_board
order: 996
---


This board provides a WDC6551 ACIA chip and its associated oscillator. A socket is provided to plug in the USB to serial adapter of your choice. This allows you to connect the Planck computer to your laptop or desktop computer and interact with via software such as putty or coolTerm.

![Serial board photo](/img/serial_board.jpg)

In the above image you can see the FTDI USB to serial adapter, below which is 65C51 ACIA chip.

To the left of that is the 1.8432 MHz crystal (an SMD part soldered to a piece of prototype board to fit in the DIP socket the board provides)

## Slot placement

The Serial board should be inserted in SLOT 3 on the backplane, otherwise you will have to change the hardware definitions in [`platform-planck.asm`](https://gitlab.com/planck-6502/planck-6502/-/blob/master/Software/forth/platform/platform-planck.asm#L109)