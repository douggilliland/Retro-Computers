---
layout: post
title:  "The VGA card FINALLY starts to work"
excerpt_separator: <!--more-->
image: /img/vga-output.jpg
---

It's been a long since I have started to work on a VGA card for my homebrew computers, [even before the Planck was a thing](https://github.com/jfoucher/6502-vga). I started with a cheap Gowin FPGA develoment board, but the development tools were windows only and not very reliable. 
<!--more-->

So I switched to an ice40 dev board, specifically to the [Upduino V3](https://tinyvision.ai/products/upduino-v3-0), which has a full open source toolchain, and that seemed to work better. 

However, the ice40 is rather limited, because it does not have dual ported RAM, so that means you have to be careful not to read from and write to the RAM at the same. This is pretty annoying, because you have to read from the RAM while you are displaying to the screen, but the computer can also trigger writes to video RAM whenever it wants.

This means I have to buffer all VRAM writes while the screen is shown, and then do all the actual writing data when the screen is in one of the blanking intervals. Pretty annoying, and I got sidetracked with asynchronous FIFO buffers for a while, but could not get any of them to work. In the end a simple circular buffer seems to be the most reliable.

For now, the display supports only one "high resolution" character mode of 640x480 pixels which comes to 80x60 characters of 8 by 8 pixels. The foreground and background color can be changed globally.

![VGA output on 4/3 screen](/img/vga-output.jpg)

There is a blinking hardware cursor that at the position where the next character will be placed, and a forth word allows for clearing the screen.

The card itself is very simple, consisting only of two level shifters, the Upduino, and an 8 bit resistor DAC, for now all on of the the [prototype boards](/Hardware/proto).

![VGA card based on Upduino V3](/img/vga-card.jpg)




