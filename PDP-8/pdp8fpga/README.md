This is my implementation of the project in Tom Almy's book ["The PDP-8 Class Project: Resoling An Old Machine."](https://www.amazon.com/PDP-8-Class-Project-Resoling-Machine/dp/1790487978/)

I did the project on a Digilent Basys-3 board but it should work on any similar hardware.

Per the book, the front panel controls are:

* SW15 - RUN/STOP switch, LED 15 is the RUN light.
* SW11-0 - front panel switch register.
* LEFT - LOAD PC from switch register.
* RIGHT - LOAD AC from switch register.
* DOWN - DEPOSIT (data in switch register to address in PC and then increment PC).
* UP - single step.
* CENTER - display select, controls what 4 digit octal number is shown on the 7-segments:
  * PC (LED 3 is lit)
  * AC (LED 2 is lit, and the decimal point is on if LINK is set)
  * MQ (LED 1 is lit)
  * Memory at address set in switch register (LED 0 is lit)

The implementation coverts the base instruction set and part of the EAE (data movement bits
and the MUY and DVI instructions.) The IOT instruction is set up to talk to an I/O bus, but
the only device implemented is device 4, the printer. The printer device drives an 80x60
dumb terminal on a connected VGA display which only recognizes the special characters CR and
LF. RAM is implemented as a Xilinx block memory IP, and the memory controller uses a handshake
protocol that should work with memory of any speed. Interrupts and more advanced features
like memory management are not implemented.

The end goal of the book was to be able to run a program that generates all of the prime
numbers which can be represented in 12 bits (the PDP-8's word size). RAM at boot contains
the program from the book's companion files, which starts at address 200 octal. Running
it is easy:

* Connect a VGA monitor
* Turn on the board and load the bitstream (you should see @PDP-8 on the screen)
* Set the switches to ocal 200
* Hit the left button once to load PC with 200
* Turn switch 15 from off to on to put the CPU in run mode

The run light will flash very briefly, and the screen will fill with prime numbers.

