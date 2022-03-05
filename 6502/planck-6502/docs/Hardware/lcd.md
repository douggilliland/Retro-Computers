---
layout: board
title: LCD board
status: prod
design_files: https://gitlab.com/planck-6502/planck-6502/-/tree/master/Hardware/lcd_board
order: 50
---


This board allows a HD44780 based LCD such as [this one](https://www.ebay.fr/itm/2004-20x4-Character-LCD-Display-Module-2004-LCD-Blue-Yellow-Blacklight-HD44780/264032858433?hash=item3d7995b141:g:7oAAAOSwTztb5q6k&mkcid=1&mkrid=709-53476-19255-0&siteid=71&campid=5338598798&toolid=11800&mkevt=1) to display data from the computer.


![Planck prototype board for LCD](/img/lcd_board.jpg)

## Slot placement

The LCD board should be inserted in SLOT 5 on the backplane, otherwise you will have to change the hardware definitions in [`platform-planck.asm`](https://gitlab.com/planck-6502/planck-6502/-/blob/master/Software/forth/platform/platform-planck.asm#L109)