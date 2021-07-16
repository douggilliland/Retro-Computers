# YM-2149 (AY-3-8913) Complex Sound Generator

VHDL, BSD 3-Clause

This core is based mostly on the YM-2149 Programmable Sound Generator (PSG), which is an upgraded version of the AY-3-8913 PSG.  The main changes in theYM-2149 over the AY-3-8910 are:

  * 5-bit envelope shape counter for smoother volume ramping, with 1.5dB logarithmic steps.
  * simplified host interface, i.e. no BC2 input.
  * option to divide the input clock in half prior to further dividing.


TODO: Currently the two external 8-bit I/O ports are not implemented.  Their implementation should be easy enough, so it will probably happen in the future when a system that uses the I/O is implemented (they would need to be tested, and the SoC that this core was initially written for does not use the PSG's I/O ports).

A huge amount of effort has gone into making this core as accurate as possible to the real IC, while at the same time making it usable in all-digital SoC designs, i.e. retro-computer and game systems, etc.  Design elements from the real IC were used and implemented when possible, with any work-around or changes noted along with the reasons.

Synthesized and FPGA proven:

  * Xilinx Spartan-6 LX16, SoC 21.477MHz system clock, 3.58MHz clock-enable.


References:

  * The AY-3-8910 [die-shot and reverse engineered schematic][1].  This was the most beneficial reference and greatly appreciated!  Removes any questions about what the real IC does.
  * The YM-2149 and AY-3-8910 datasheets.
  * Real YM-2149 IC.
  * Chip quirks, use, and abuse details from friends and retro enthusiasts.

[1]: https://github.com/lvd2/ay-3-8910_reverse_engineered


Generates:

  * Unsigned 12-bit output for each channel.
  * Unsigned 14-bit summation of the channels.
  * Signed 14-bit PCM summation of the channels, with each channel converted to -/+ zero-centered level or -/+ full-range level.

The tone counters are period-limited to prevent the very high frequency outputs that the original IC is capable of producing.  Frequencies above 20KHz cause problems in all-digital systems with sampling rates around 44.1KHz to 48KHz.  The primary use of these high frequencies was as a carrier for amplitude modulated (AM) audio.  The high frequency would be filtered out by external electronics, leaving only the low frequency audio.

When the tone counters are limited, the normal square-wave is set to always output a '1', but the amplitude can still be changed, which allows the A.M. technique to still work in a digital Soc.


## Basic host interface:

This core uses the simplified form where BC2 is not used or exposed externally (AY-3-8913).
```
  BDIR  BC1     State
    0    0    Inactive
    0    1    Read from PSG
    1    0    Write to PSG
    1    1    Latch address
```
