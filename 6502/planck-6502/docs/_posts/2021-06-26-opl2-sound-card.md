---
layout: post
title:  "OPL2 sound card prototype"
image: /img/opl2-sound-card.jpg
---

I am having great trouble building a good VGA output card using either an FPGA or a microcontroller, so for a change I decided to start working on a sound card.

The card uses a YM3812 / OPL2 chip that I happened to have around from another project.

Since I already have experience working with this chip, and some working schematics, building it on one of the [prototype boards](/Hardware/proto) was not too time consuming.

![OPL2 sound card prototype](/img/opl2-sound-card.jpg)

The software however is another business. Since this chip was never used in any kind of 6502 based computer (it was used mainly in the Adlib cards for PCs), no software exists that can interact with it, so it will all have to be created from scratch.

For the time being it only plays some very basic sounds to test proper functionality.
