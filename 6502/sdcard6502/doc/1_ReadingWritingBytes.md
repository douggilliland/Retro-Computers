[Previous: Hardware Setup](0c_HardwareSetup.md)
---

# 1. Reading and Writing Bytes

Source code: [1\_readwritebyte.s](../src/1\_readwritebyte.s)

This sample warms up the SD card, reads and prints a byte, sends a command, and prints the response.

It is based on Ben's "hello world" code.

Key changes:
* DDRA is initialized differently, to set the correct pins as outputs (not MISO)
* LCD initialization is moved to a subroutine
* Some extra utility subroutines are provided, e.g. `print_hex`
* `sd_readbyte`, `sd_writebyte`, and `sd_waitresult` subroutines are provided for low-level communication with the card
* There's a loop to pump the clock 80 times, to allow the card to boot up
* After preinitialization, the code uses `sd_readbyte` and `sd_writebyte` to test communication with the card

## Expected result

The code will print an `I`, then read a byte from the card and print a value in hex.  This should normally be `FF`, but may be `00` if you don't have a card present.

Next it will print `c00` and then send CMD0 (a kind of reset command) to the card.  It then reads the result and prints it in hex - this is expected to be `01`,
which means the card understood the command and is now in an uninitialized state.

If all goes well, it will print a final `Y`.  If it detected a problem at any stage, it will print `X` and halt.

## Troubleshooting

In general, if anything doesn't work, double-check all the connections, and make sure nothing is getting warm.

If you're running with a high clock speed, try reducing it to 1MHz.

Consider trying a different SD card if you have one available.

### The hex number after `I` was not `FF`

If `I00` is printed, it may mean that no card is present in the reader, or the module is not wired in correctly.  Check MISO in particular.

Otherwise, it's not necessarily a problem - it could simply mean the card had something waiting to send from before a reset.

### `IFFc00` with no result code

Either the card didn't receive the command, or the response was lost.  Check
MISO first, but all connections really.  You could try wiring MOSI to ground
instead of to the 6522, to see if that at least gets a response from the SD
card.

### `IFFc0009X`

Result code 09 means CRC failure.  At least some data is getting through each
way though.  Make sure MOSI, MISO, and SCK are correctly connected.  Make sure
the data being sent - and CRC - are correct in the code.  

---
[Next: 2. Sending Commands](2_SendCommand.md)
