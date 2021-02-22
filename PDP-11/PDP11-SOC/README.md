
## Summary

This project is an SOC (System on a Chip) coded in VHDL and implemented for the Lattice iCE40-hx8k dev board. The SOC contains the following components: PDP-11/20 CPU + RAM + UART + Timer + I/O Ports

## Required Hardware

* Lattice iCE40-hx8k dev board (can be ordered online at www.latticesemi.com)
* USB-to-Serial 3.3V adapter (can be ordered from eBay)
* misc USB cables and wires for connecting the USB-to-Serial adapter

NOTE: Make sure the USB-to-serial adapter is a 3.3V version. Some adapters have 5V interface signals which could damage your iCE40-hx8k dev board.

## Tools

* IceCube2 (from Lattice Semiconductor) was used for synthesis and FPGA Routing.
* Icestorm (https:/github.com/cliffordwolf/icestorm) was used for programming.


## Build Flow

I used the Lattice IceCube2 software to generate the SOC_bitmap.bin programming file and then I used this command line "iceprog SOC_bitmap.bin" the program the iCE40-hx8k dev board over the USB cable (iceprog is part of the icestorm tool suite).

## Console Interface

I used the minicom program (on Ubuntu Linux) as a console to communicate with the SOC over the USB-to-Serial connection. Configure minicom using the command line "minicom -s" to configure the serial port for ttyUSB0 and turn of the hardware handshaking. There are probably other alternatives to minicom. Any ANSI terminal-emulator program should work for this application.

## Pinout

The iCE40 pins are defined as follows:
```
UART_RXD   G1 -pullup yes
UART_TXD   G2
PORTA[0]   B5
PORTA[1]   B4
PORTA[2]   A2
PORTA[3]   A1
PORTA[4]   C5
PORTA[5]   C4
PORTA[6]   B3
PORTA[7]   C3
RESET      N3 -pullup yes
CLK        J3 -pullup yes
```

## Memory Map

The memory map of this SOC is as follows:
```
$0000 -> $1FFF  8k RAM
$F000 -> $F006  UART registers
$F008 -> $F00A  Timer registers
$F00C           Output port register
$F00E           Interrupt mask register
$F010 -> $F012  Random number registers
$F014           Interrupt source register
```

## PDP-11/20 CPU Background Info

The PDP-11 series was an extremely successful and influential family of machines from Digital Equipment Corporation (DEC). The first PDP-11 (/20) was introduced in January of 1970 and the PDP-11 series prospered for over two decades through the mid 1990's. Innovative features of the PDP-11 are 8 general purpose registers and a highly orthogonal instruction set with 8 sddressing modes. The CPU in this SOC implements the base PDP-11/20 features (no floating point and no memory management).

## Contributors

* Scott L Baker - SOC design

## License

See the **LICENSE** file in this repository
