## Planck CPU board

This is the CPU board for the Planck 6502 based computer. It contains 32K of ram and 32K of rom.

The RAM and ROM can be inhibited by setting the <span style="text-decoration:overline">INH</span> signal low.

It is then the responsibility of that card to respond to the whole address range (execpt the one where expansion cards are active) to provide required functionality such as reset vectors, zero page, etc...

If the <span style="text-decoration:overline">SSEL</span> signal is low (one of the slots is active), both the RAM and the ROM will be offline.

The board can accept either a narrow or wide DIP28 RAM chip.

This is what the board looks like

![CPU board 3D view](proc_board.png)



<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This documentation is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.