This folder contains CUPL code for the programmable logic chips on the backplane and on the processor board.

To build it, use [Wincupl](https://www.microchip.com/en-us/products/fpgas-and-plds/spld-cplds/pld-design-resources). Hopefully this link still works when you access it. It works fine in [wine](http://www.winehq.org/) if you use Linux or MacOs.

Load the pld file, then click on run -> device dependent compile.

You can then program the .jed file to your chip. A TL866II works fine with both 22V10 and 16V8.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This documentation is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.