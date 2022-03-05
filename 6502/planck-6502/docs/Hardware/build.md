---
layout: page
short_title: Build Guide
title: Building the computer
order: 10
---

Here is the print version of [the build guide](/Planck 6502 build guide.pdf) I include with the kit.

The computer motherboard as well as all expansion boards not marked as "deprecated" have been redesigned using through hole components almost exclusively.

A build video is coming soon, but for now just solder the lowest components first, such as capacitors and resistors, and progress to the higher components at the end of the build.

The resistors should be placed as follows : 

 - R22, R21, R18, R17, R14, R6, R5, R4, R3, R2 have 1 kΩ value
 - R16 has 2.2 kΩ value
 - R13, R12, R11, R10, R9 have 330 Ω value
 - R27, R26, R25, R24, R23, R15, R8, R1 have 10 kΩ value

There are two types of capacitors: the cylindrical one is called electrolytic and should be placed near the power plug
The other should be placed as follows : the big ones next to the expansion slots, and the small ones near the chips.

Place the 1.8432 MHz oscillator in the footprint that reads "SERIAL CLOCK"
Place the 24 MHz oscillator in the footprint marked "MAIN CLOCK"

All other components have only one place where they can fit, so solder away. Just make sure you put the diodes and the LEDs the right way around.

## Finishing up and testing

Now that everything is soldered up, all that's left to do is to plug the chips in their respective sockets and give the board a test.

First check with a multimeter that you do not have a short between ground and VCC. Give a thorough visual inspection to the board to make sure that all solder joints are ok and that no bridging between pins occurs. Touch up where necessary.

Then if everything looks ok, you are ready to power up the board and test its functionality. It's time to head on over to [the software part of this documentation](/Software)

