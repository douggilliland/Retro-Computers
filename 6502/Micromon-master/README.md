# Micromon

A very small extendable BIOS and simple Monitor which requires:
 A 65C02 CPU
 2KB RAM minimum
 2KB ROM minimum
 65(C)51 ACIA for a console (no other hardware is required or coded for)
 
 
Actual ROM space is 1.75KB and provides 16 functions for a basic monitor program.
BIOS supports an interrupt-driven 128-byte buffer for Receive and Transmit.

Ideal for testing a very basic 65C02/65C51 hardware design. If this code doesn't work, you have a (hardware) problem!
