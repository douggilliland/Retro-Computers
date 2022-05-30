# OS/8 `MACREL`

`MACREL`, the MAcro RELocating assembler, was a late development. It
was an attempt to replace `PAL8` with a Macro assembler capable of
producing relocatable modules.  When `MACREL` first came on the scene,
several companies decided to port their next major upgrade to `MACREL`
from `PAL8`.  `MACREL` was so buggy that everybody basically had to
revert to `PAL8` and back-port all the new code originally intended
for the new major upgrade.  This situation befell ETOS Version 5.

We have a binary distribution DECtape image of `MACREL` version 1, DEC
part number `AL-5642A-BA`. Unfortunately the version numbers of the
patches did not match what was shown in the binaries.

With the `MACREL` V1 patches, I wanted to do more research before
recommending application of the patches. In the course of that
research, I discovered that all the archived manuals to be found online
were for `MACREL` v2.

See: [Willem van der Mark's PDP-8 Manuals archive][vandermarkman] for:

* [OS/8 MACREL/LINK -- Software Support -- Version 2C -- September 1980 AA-J7073-TA][maclinkss]
* [OS/8 MACREL/LINK -- User Manual -- Version 2D -- January 1979 AA-5664B-TA][maclinkuser]

Or see the [PDP8 doc tree on ftp.dbit com][dbitdocs] for:

* [maclkssm.doc -- OS/8 MACREL/LINK V2 Software Support Manual][dbitmacssm]
* [maclnkum.doc -- OS/8 MACREL/LINK V2 User's Manual.][dbitmacuser]
* [macrelrn.doc -- OS/8 MACREL/LINK V2 Release Notes][dbitmacrel]

Version 2 was the clearly better baseline.  I didn't hold out much
hope to find binary and source distributions of `MACREL` v2.  (DEC
Part numbers `AL-5642B-BA` for the binary DECtape and the 4 source
DECtapes, `AL-5643B-SA`, `AL-5644B-SA`, `AL-H602B-SA`, and
`AL-H602B-SA`.)

Very recently we found a complete set of `MACREL` version 2 binaries
as part of a buildable RTS-8 Archive at [ibiblio.org ... pdp-8/rts8/v3/release][rts8rel]

We found a source distribution of `MACREL` v2 in Dave Gesswein's
[`misc_floppy`][dgfloppy] archive.  Part one is flagged as having
errors, but another obscure site had a mis-labeled archive of this
same stuff so we may be ok.

The `MACREL` v2 source would not build under `MACREL` v1, but now we
have `MACREL` v2 and initial tests look promising.

Baseline `MACREL` v2 will be integrated into the system packs.
Because we didn't have `MACREL` v2, no work was done to create patch
files, or to validate them.  With both source and binary for `MACREL`
v2 now in hand, this work can proceed.  The plan is to fetch the
patches, validate them, and install all mandatory patches that can be
verified. 

The current integration of `MACREL` v2 includes a hand-applied patch
to `FUTIL`.  We want the latest version of `FUTIL` because it contains
new code handles extended memory and certain `MACREL` data
structures. However version 8A of `FUTIL` shipped on the `MACREL` v2
tape had a bug that causes it to *hang* when run under `BATCH`.

Patch `35.13.1M` fixes this problem and upgrades `FUTIL` to version
8B.  This patch was applied by hand tested, and grouped with what we
integrate onto the system packs when we add `MACREL`.

To reduce uncertainty around the operation of `OVRDRV.MA`, Source
patch `41.5.1M` has been applied by hand to `OVRDRV.MA`.

See also: [our documentaiton on the OS/8 Patching][os8patches]

[vandermarkman]: http://vandermark.ch/pdp8/index.php?n=PDP8.Manuals
[maclinkss]:     http://vandermark.ch/pdp8/uploads/PDP8/PDP8.Manuals/AA-J073A-TA.txt
[maclinkuser]:   http://vandermark.ch/pdp8/uploads/PDP8/PDP8.Manuals/AA-5664B-TA.txt
[dbitdocs]:      ftp://ftp.dbit.com/pub/pdp8/doc/
[dbitmacssm]:    ftp://ftp.dbit.com/pub/pdp8/doc/maclkssm.doc
[dbitmacuser]:   ftp://ftp.dbit.com/pub/pdp8/doc/maclnkum.doc
[dbitmacrel]:    ftp://ftp.dbit.com/pub/pdp8/doc/macrelrn.doc
[rts8rel]:       http://www.ibiblio.org/pub/academic/computer-science/history/pdp-8/rts8/v3/release 
[dgfloppy]:      http://www.pdp8online.com/images/images/misc_floppy.shtml
[os8patches]:    https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-patching.md

### <a id="license"></a>License

Copyright © 2017 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
