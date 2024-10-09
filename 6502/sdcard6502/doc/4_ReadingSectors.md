[Previous: 3. Complete Initialization Sequence](3_Initialization.md)
---

# 4. Reading Sectors

Source code: [4\_readsector.s](../src/4\_readsector.s)

This sample follows successful initialization with a call to CMD17 to read a sector from the SD card.

Key changes:
* Encapsulate SD card initialization in a subroutine
* Remove all unnecessary delays from the initialization process
* Call CMD17 after initialization to read sector 0 from the SD card
* Read all the bytes, remember the last two, and print them to the LCD

## Expected result

The code will initialize the SD card much more quickly now, as all the delays
are removed.  Any errors during initialization will still result in `X` being
printed and the program halting.

After initialization it will then read the first sector from the SD card, and
print out the values of the last two bytes of the sector.  Assuming the card is
properly formatted, this should read `55AA`.

## Troubleshooting

There shouldn't be any extra issues here, but if you get errors from
initialization that weren't happening before, try adding some of the delays
back into the initialization code.

---
[Next: Next Steps](A_NextSteps.md)
