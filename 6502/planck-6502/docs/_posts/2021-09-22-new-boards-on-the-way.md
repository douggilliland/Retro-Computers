---
layout: post
title:  "Planck computer design is in fabrication"
image: /img/resistors.jpg
---

The Planck computer is almost ready for the big time. I received the prototype a few days ago and the build with through hole components was fine, except I feel it takes slightly longer to solder all the components when they are through hole, because you have to cut all those spiky legs off, and my side cutters are not very sharp...

Then I had to reprogram the address decoding chip that handles the extension slots, to enable the new extension slot at address `$FFD0` and the serial chip at address `$FFE0`.

I also had to had to change the code slightly to update the serial chip address to the new one, and burn it to the EEPROM.

But after all that was done, it turns out that it works perfectly, on the first go, with a 24MHz oscillator, making the computer itself run at 12MHz. Very nice! There was only a slight mistake: the footprints I used for the resistors are slightly smaller than the resistors I have on hand, which means I had to install the resistors like that to make them fit:


![Bent resistors](/img/resistors.jpg){: width="450" style="margin: 2em auto;display:block;"}

This is now corrected on [the latest revision of the board](https://gitlab.com/planck-6502/planck-6502/-/tree/master/Hardware/cpu_backplane)

As you can from the image below, I had initially planned to use a ZIF socket for the EEPROM on the prototype board, since the computer has no provision for in circuit programming of the EEPROM. However, I went ahead and soldered a regular socket in it, because it turns out that a zif socket can be made to fit in a regular socket just fine.

![The Planck 6502 computer is running!](/img/computer.jpg)

All existing cards seem to work just fine in the new computer, which is expected but a relief nonetheless.

As  of right now, the final revision is in production, as well as three other boards, two of which I only have built on the prototype boards until now : the [OPL2 board](/Hardware/opl2/) and the [LCD board](/Hardware/lcd/). The third one is the through hole version of the [I/O board](/Hardware/io/)

Next, I am planning on designing a board to interact with an SD card. This board will plug into the back of the I/O  board with a ribbon cable to use its SPI capability. I will have to research some simple filesystems to use, because even implementing FAT16 in 6502 assembly seems like a daunting challenge.