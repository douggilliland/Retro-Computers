[Previous: 2. Sending Commands](2_SendCommand.md)
---

# 3. Complete Initialization Sequence

Source code: [3\_fullinitialization.s](../src/3\_fullinitialization.s)

This sample adds a loop issuing ACMD41, which completes the initialization process.

Key changes:
* Add CMD55 and CMD41 to initialization code
* Loop over ACMD41 until card is fully initialized (or error occurs)

## Expected result

The code will cycle through each command, sending it and waiting for a
response.  Before each command it clears the screen and prints the command code
byte, which is $40 plus the command number.  Then it prints the response, which
should be `01` in all cases, except that when the card has finished
initializing the response will become `00`.  There are a lot of delays to make
it easier to see what's going on.

As before, if all goes well it will print a final `Y`, while if it detected a
problem at any stage, it will print `X` and halt.

## Troubleshooting

### `c7705X` or `c6905X`

This means that CMD55 or CMD41 was an invalid command, and it could indicate
that the SD card is too old.  This tutorial only supports SDHC cards.
Nonetheless, you could look at [Older Cards](B_OlderCards.md) and try to adapt
the code.

---
[Next: 4. Reading Sectors](4_ReadingSectors.md)
