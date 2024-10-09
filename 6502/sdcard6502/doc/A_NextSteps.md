[Previous: 4. Reading Sectors](4_ReadingSectors.md)
---

# Next Steps

Here are some possible next steps.  Whether they're worthwhile depends on your needs.

## Multiplexing - share pins with the LCD

I've done this on a separate computer.  There are some caveats:

### MISO holds its state when CS is high

This is an over-simplification - see the elm-chan doc for more details.  But in
many circumstances, the SD card will continue to drive MISO even when CS is
high (i.e. deselected).  This interferes with other devices that might be
sharing that data pin.

An easy but hacky solution for this is to connect the SD card's MISO input
through a resistor, e.g. 1k.  Depending on the nature of the other devices,
this may be enough impedance to let the other devices work properly.  Otherwise
you need to either not share this pin, or use a transceiver, or try the
mitigation from the elm-chan doc (which is basically to pulse the clock 8 times
after CS goes high at the end of a command).

### SD cards don't start in SPI mode

On startup the SD card is not operating as a true SPI device - it is using its
native 4-channel protocol, and in this state it reacts to inputs even when CS
is high, contrary to usual expectations.  It's only after the initialization
sequence that it stops reacting.

One way to mitigate this is to ensure that whenever CS is high, MOSI is also
pulled high.  In this state, even if the clock pulses, the SD card won't mind.
You can do this by adding a diode from CS to MOSI near the SD module, and a
resistor from MOSI to the 6522.

## More optimal pin choices

The code to read and write bits struggles a bit because the data to read or
write must be held in the accumulator (in order to shift it) and the PORTA
values also need to be in the accumulator, so we can use ORA/EOR/etc to toggle
SCK.

However, if we move MISO to PB7 then the negative flag will get set based on
the MISO value when we read from PORTB into any register, and we can branch on
that straight away without needing any comparisons.  So we can let A store the
result permanently, without needing to swap it in and out.

And if we move MOSI to PB7, but keep CS and SCK on port A, then we can very
easily write the whole output value to port B, shift it, write again, etc.

TBC

---
[Next: Older SD/MMC Cards](B_OlderCards.md)
