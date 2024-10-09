[Previous: 1. Reading and Writing Bytes](1_ReadingWritingBytes.md)
---

# 2. Sending Commands

Source code: [2\_sendcommand.s](../src/2\_sendcommand.s)

This sample uses an encapsulated `sd_sendcommand` subroutine to send the CMD0
and CMD8 commands to the card in sequence.

Key changes:
* New subroutine `sd_sendcommand` for sending arbitrary commands to the card
* `zp_sd_cmd_address` is the address of a two-byte pointer in zero page, used to tell `sd_sendcommand` which data to send
* CMD0 and CMD8 commands and arguments are stored in data blocks at `cmd0_bytes` and `cmd8_bytes`

## Expected result

The code will cycle through each command, sending it and waiting for a
response.  Before each command it clears the screen and prints the command code
byte, which is $40 plus the command number.  Then it prints the response, which
should be `01` in both cases.  There are a lot of delays to make it easier to
see what's going on.

As before, if all goes well it will print a final `Y`, while if it detected a
problem at any stage, it will print `X` and halt.

## Troubleshooting

Assuming the previous example worked, the basic communication should work fine
here too.  There's only one real thing to watch out for:

### `c4805X`

This means that CMD8 was an invalid command, and could indicate that the SD
card is too old.  This tutorial only supports SDHC cards.  Nonetheless, you
could look at [Older Cards](B_OlderCards.md) and try to adapt the code.

---
[Next: 3. Complete Initialization Sequence](3_Initialization.md)
