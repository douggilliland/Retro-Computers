---
layout: page
title: Planck 6502 software
---

## Programmable Logic

The first thing to setup when building your Planck 6502 is to program the PLD chip on the backplane. This provides address decoding logic for all 5 expansion slots on the backplane. Basically, when a specific address range is request by the CPU, this chip pulls one of the SLOT selection lines low. It also pulls the SSEL signal low to let other expansion boards as well the the CPU board know that an expansion slot is selected. This disables the memory on the CPU board and allows other boards to disable themselves as well if necessary.

The source code used to program the chip is in [CUPL](https://en.wikipedia.org/wiki/Programmable_Array_Logic#CUPL) format and provided as `backplane.PLD` files in the [`Software/PAL/`](https://gitlab.com/planck-6502/planck-6502/-/tree/master/Software/PAL) directory. 

Also provided is the precompiled binay (`BACKPLANE.jed`) in the same folder. This file can be used to program your ATF22V10 chip immediately with the defaulta address values for each slot. Please see [Expansion slot activation](/Hardware/#expansion-slot-activation) for the default slot addresses.

You will then need to program the ATF16V8 for the CPU board in much the same way.

Once that is done, everytinh is setup to run...


## Actual software

The software is currently built around [Tali Forth 2](https://github.com/scotws/TaliForth2). A binary is provided in [`Software/forth/taliforth-planck.bin`](https://gitlab.com/planck-6502/planck-6502/-/tree/master/Software/forth). Just program this binary to a 32K eeprom, insert it in the ZIF socket on the CPU board and you should be good to go.

By default the software expects the I/O board to be in SLOT 2 and the Serial board to be in SLOT 3, but this can be changed by changing the hardware definitions in [`platform-planck.asm`](https://gitlab.com/planck-6502/planck-6502/-/blob/master/Software/forth/platform/platform-planck.asm#L109) or by reprogramming the backplane PLD chip as detailed above.

### Running the software

By default, the PS/2 keyboard from the I/O card is enabled as an input, as well input from the serial card, which means you can use both to type text into the Planck 6502.

For output you will see that both serial output as well as VGA output is enabled in the software. However the VGA output is only for me to test VGA output at this time since the VGA expansion card is not yet finalized.

You can however use the LCD as an output if you want to use your Planck as a stand alone computer. With a PS/2 keyboard and the LCD screen it is really quite a usable Forth machine.

Some small utilities are present on the provided software, defined as forth words:
- `uptime` gives the time since power up / reset in hours, minutes, seconds and hundredths of a second. The time itself is stored in 4 bytes starting at address `$82`. The number at that address is incremented every 5 milliseconds with a 21.175 MHz main crystal.



### Customizing the software

Say you just [created a new board](/Hardware/make) for your computer, you will need to write drivers for it. I recommend doing so in assembly as that will give you the best performance, but the drivers can also be written in forth. Below, i will detail how to write drivers in assembly for your custom expansion card.

As you can see, the [Software/drivers](https://gitlab.com/planck-6502/planck-6502/-/tree/master/Software/drivers) folder already contains drivers for expansion cards. You can create a new file named `my_card.s` and write your initialization and usage routines in it.

Then in the [forth/platform/platform_planck.asm](https://gitlab.com/planck-6502/planck-6502/-/blob/master/Software/forth/platform/platform-planck.asm) file you will have to include your new driver file or files similarly to how other driver files are included : 

````
.require "../../drivers/my_card.s"
````

Any zero page variables that your driver routines use will also need to be added to platform_planck.asm

Then, after the `kernel_init:` label, you can call your initialization routine if any.

To use your driver from Forth, please see the [Tali Forth documentation](https://github.com/scotws/TaliForth2/blob/master/docs/manual.md#adding-new-words) for adding new native words.
