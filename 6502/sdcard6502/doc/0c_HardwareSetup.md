[Previous: About the Sample Code](0b_SampleCode.md)
---

# Initial Hardware Setup

For this tutorial I'm using a very simple hardware setup, to make it clear how
things work.  I'll hopefully revisit this at a later date and show some better
ways to connect it, which use up fewer pins and allow faster send/receive code.
The simple setup is fine though to begin with.

# SD module pins

Your SD module should have pins labeled CS, SCK, MOSI, and MISO, as well as
power pins.  If so then great, it's the same as mine!

But if your module has differently-labeled pins, such as DI, DO, CLK, etc, then
please refer to Wikipedia's page on the [SPI protocol](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) 
to read how they correspond to the names I'm using here.

You might also have some additional pins, such as a signal to tell you whether
a card is inserted.  Some modules have it and others don't.  It's not important
for now.

The function of the main pins is as follows:
* CS - chip select - usually high, pull it low before sending a command
* SCK - serial clock - transition this from low to high to send and receive a bit
* MOSI - master out, slave in - used to send data to the SD card
* MISO - master in, slave out - used to receive data from the SD card

# Connecting to the 6522 VIA

The 6522 VIA already has its whole Port B used up by the LCD, as well as the
top three pins of Port A.

To keep things simple to begin with, we're only going to use some of the spare
pins on Port A, and not share pins with the LCD for now.

__Make sure your SD adapter module does level-shifting before connecting it up!__
If it doesn't, then this could damage your SD card.

* Connect CS to PA4 (6522 pin 5)
* Connect SCK to PA3 (6522 pin 4)
* Connect MOSI to PA2 (6522 pin 3)
* Connect MISO to PA1 (6522 pin 2)

You also need to connect any power pins.  If your module doesn't have its own
regulator, you may need to give it an additional 3.3V supply.  

Unfortunately there's no easy way to check that this is working - you need to
write proper SPI send/receive functions first, which are covered in the next
chapter.

---
[Next: 1. Reading and Writing Bytes](1_ReadingWritingBytes.md)
