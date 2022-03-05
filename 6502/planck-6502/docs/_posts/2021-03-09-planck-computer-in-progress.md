---
layout: post
title:  "Designing a complete extensible computer"
image: /img/cpu_backplane.png
---

The Planck 6502 backplane can make a great retro computer if you add in the basic necessary boards. For the simplest possible configuration however, you need at least three boards : the backplane itself, the CPU board (which also contains RAM and ROM) and a serial board for I/O.

Following a reddit discussion on the [Planck 6502 intro post](https://www.reddit.com/r/retrocomputing/comments/luu9z0/planck_6502_an_open_hardware_extensible_retro/gp9m2jv) it occurred to me that it would not be more expensive to have a single slightly bigger board that would house the CPU, RAM, ROM and serial chips, while keeping all the expansion the the original Planck backplane has.

So I started drawing up a [schematic and a board layout](https://gitlab.com/planck-6502/planck-6502/-/tree/master/Hardware/cpu_backplane), and it turns out that all this can fit on a 100mmx150mm board, just 50mm wider than the original backplane. And while this is outside the "cheap PCB offer" of the likes of Jlcpcb, the price is still *very* reasonable. Actually it costs about the same as one backplane and 2 expansion boards.

So I feel that this new design is a win for most situations. I do not recommend you get it fabricated just yet since it has not been tested and will probably have a few bugs.

However, I cannot resist putting a 3D view here:

![Planck computer 3D view](/img/cpu_backplane.png)

Hope you like it, [contact me](mailto:jfoucher@6px.eu) with any comments or suggestions.
