---
layout: page
title: An open-hardware, extensible 65c02-based computer
---

![General view](img/1.jpg)


This is a hobby computer based on the 65C02 processor. (I use 6502 and 65C02 interchangeably in this document, but [there are some differences](http://wilsonminesco.com/NMOS-CMOSdif/))

There are already many computers based on the 6502 processor, old ones such as as the Apple 1, Apple II, Commodore 64 and many more; and many more recent ones, from homebrew affairs on prototype board, to complete replicas of old systems.

The one that most closely resembles the Planck is probably the RC6502, itself based on the RC2014 (which uses a Z80 processor) with adaptations to the expansion bus to make it fit the 6502 processor.

Planck is a new variant on this type of expandable machines with a different set of tradeoffs.

### Contraints and requirements

The constraints for its design were the following:

  - Minimum board size, 2 layers, as that is what is cheapest to have fabricated.
  - Easily extensible with for example:
    - Serial port
    - Parallel port
    - SPI / [65SIB](http://forum.6502.org/viewtopic.php?p=10957#p10957) port
    - PS/2 port for keyboard
    - Sound card
    - eventually VGA out
    - SD card
    - LCD screen
  - Target clock speed of 10 to 12 MHz


## Some details

These requirements resulted in a computer based on a [motherboard](/Hardware) hosting RAM, ROM and CPU and extension slots for expansion cards to plug into.

The [Planck hardware pages](/Hardware) explains more about the functionality of the backplane and of each basic extension boards.

Of course, you can [design your own expansion boards](/Hardware/make) to make the computer do whatever **you** decide

<!--
## Buy it now

### With Paypal
Currently out of stock, sorry, should be back around mid Novemeber 2021

<div>
<form target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="WNF3GUCN92CT6">
<table style="border:none"  cellpadding="0">
<tr>
<td style="border:none;vertical-align:middle">
<input type="hidden" name="on0" value="Include ICs ?">
<select name="os0">
	<option value="No ICs">No ICs €69,00 EUR</option>
	<option value="All ICs">All ICs €99,00 EUR</option>
</select>
</td>
<td style="border:none;vertical-align:middle"><input type="hidden" name="currency_code" value="EUR">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_cart_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1"></td>
</tr>
</table>
</form>
</div>

### On Tindie

Currently out of stock, sorry, should be back around mid Novemeber 2021

<a href="https://www.tindie.com/products/24831/"><img src="https://d2ss6ovg47m0r5.cloudfront.net/badges/tindie-larges.png" alt="Buy the Planck 6502 computer on Tindie" width="200" height="104"></a>

### Financial stats

I like openness, so I keep a [running tally of costs and income](/stats).
-->