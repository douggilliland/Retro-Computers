# DCP A PAL Disassembly Program

This is a pretty good disassembler for the PDP-8 with a powerful
mechanism for refining the disassembly.

The source has been lost, but at some point, some intrepid soul
will feed DCP to itself and regenerate it.

There are two differen tools, DCP16 an DCP24.  The former fits into 16K of memory.
The latter, consuming 24K, does a richer job of interpreting EAE (Extended
Arithmetic Element) instructions, and a richer INFO file to refine the
disassembly.

The documentation in DCP.WU is adequate to make sense of using the program.

Upstream is from [bitsavers.org][bitsavers] and replicated at [dbit.com][dbit] and
[The deramp.com Vintage Computing Archive][deramp].

[dbit]: http://www.dbit.com/pub/pdp8/nickel/utils/dcp/os8/
[bitsavers]: http://www.bitsavers.org/bits/DEC/pdp8/papertapeImages/russ.ucs.indiana.edu/Utils/DCP/OS8/
[deramp]: https://deramp.com/downloads/mfe_archive/011-Digital%20Equipment%20Corporation/01%20DEC%20PDP-8%20Family%20Software/10%20Operating%20Systems/OS-8/20%20Utilities/DCP/