# OS/8 V3D Device Extensions

The _OS/8 V3D Device Extensions_ kit (product code `QF026`) was released
in December 1978. It was created to support the newest PDP-8 hardware:

*   The `KT8A` Memory Management option which enables addressing by a
    factor of four beyond the previous maximum of 32K to a whopping
    128K of memory. The highest memory field for a PDP-8a goes up from
    7 to 37 (octal).

*   The `RL01` disk supporting 4 times the previous usual disk capacity,
    now up to nearly 5 Meg.

*   The `RX02` double-density floppy disks.

* Device drivers `VXSY` and `VXNS` enables use of `KT8A` extended
    memory as a file oriented system or non-system device.

This distribution contains software updates:

*   A version of `BUILD`, the system builder that could run under
    `BATCH`.  The previous version would just hang.

*   An update to the OS/8 system including `Keybord Monitor` version
    3S, and a version of `ODT` that works with memory fields greater
    than 7.

*   `ABSLDR` version 6A supports loading into memory fields greater
    than 7.

*   `PAL8` version 13A allows code to specify memory fields greater
    than 7.

*   `CCL` version 7A updates the 'MEMORY' command to recognize up
    to 128K words of memory.

*   `PIP` version 14A knows the sizes of the new devices, and has
    updated how it copies in the monitor system head.

*   `RESORC` version 5A includes new devices.

*   `BOOT` version 5A boots new devices.

*   `RXCOPY` version 4B formats and copies single and double density
    floppies.

*   `FUTIL` version 8A recognizes new core control block format that
    can represent extended above field 7.

The _OS/8 V3D Device Extensions User's Guide_ can be found
in [Willem van der Mark's PDP-8 doc archive][vdmdoc], under
[OS/8 - Device Extensions - User's Guide - December 1978 AA-D319A-TA.pdf][vdmextensions].
or on the [ftp.dbit.com pdp8 doc archive][dbitdoc] at [devextug.doc --
OS/8 Device Extensions User's Guide][dbitug]

The release notes can be found on ftp.dbit.com at [devextrn.doc	OS/8
Device Extensions Release Notes ][dbitrn].

Details on how the `KT8A` Memory Extension hardware works, physically
and programatically, can also be found at Willem van der Mark's site:
[vandermark.ch ... Emulator.128KMemory/EK-KT08A-UG_jul78-ocr.pdf][kt8adoc].

When reference is made to `PAL8` version 13, that version originally came
from this kit.

The distribution DECtape for this kit, part number `AL-H525A-BA` has
not yet been found.  The PDP-8 Software Components Catalog July 1979
gives no part number for a Source DECtape distribution of this kit.
There is an RK05 source distribution, part number
`AN-H529A-SA`. However, plausable source and binary have recently been
found!

The binaries were on someone's local hard disk and not published to
the net anywhere I could find.  Sadly those binaries did not include
the DECtape's system area, and so the updated version of the OS/8
Keyboard Monitor, Command Decoder and `ODT` seemed lost until a tape
could be found. It appears that the original source of these .en files
is Johnny Billingquist's site, [ftp.update.uu.se ... dectape1][uuseext1].

Then, however, a self-extracting archive called, `os8v3f.exe` was
found on a mirror site of ibiblio.org, [rtk.mirrors.pdp-11.ru
... fromhichols][rtknicnols]. Mainline ibiblio.org didn't have it, perhaps it was
purged because of its `.exe` extension.  The archive is also available
directly from [ftp.update.uu.se ... fromnichols][uusenichols], but at slow speed.

When that archive was extracted, the manifest of source files
corresponds exactly to the manifest of binaries in the Extensions Kit
file archive are present.  This looks quite promising for a future
project to upgrade to OS/8 V3D with the Device Extensions software,
and to create system packs useful even on PDP-8a hardware with 128K
words of memory!

After comparing sources found for OS/78, and OS/278, as well as Willem
van der Mark's locally modified sources labeled OS/8 version 4, I have
moderate confidence that these sources will enable validation and
integration of most, if not all the OS/8 V3D Device Extensions
functionality.

[rtknichols]: http://rtk.mirrors.pdp-11.ru/ftp.update.uu.se/pdp8/pdp-8/fromnichols/
[uuseext1]: ftp://ftp.update.uu.se/pub/pdp8/pdp-8/os8/os8.v3d/binaries/devext/dectapes/dectape1/
[uusenichols]: ftp://ftp.update.uu.se/pub/pdp8/pdp-8/fromnichols/

## FUTIL

This validation has been done with regards to `FUTIL`.

The `MACREL` v2 tape shipped with version 8A of `FUTIL`. That was
necessary because V2 of `MACREL` supported the latest memory
expansion, and so the OS/8 Core Control Block format needed to change.

`FUTIL` version 8A integrated patches for `FUTIL` version 7 into the
source.  Finding those patches in the version 8A source strongly
increased my confidence in those patches.

Unfortunately the `FUTIL.SV` verson 8A executable was saved
incorrectly and then shipped. The Core Control Block setting and
starting address were mis-specified. So `FUTIL` version 8A *hangs*
when run under `BATCH`.

The [April-May 1979][dsn1979apr] issue of _PDP-8 Digital Software
News_ contained patch `35.13.1M` which fixed this problem and upgraded
`FUTIL` to version 8B.  I've confirmed both the problem and the fix.

Currently if you opt in to having `MACREL` on the system packs, you
get `MACREL` v2 and `FUTIL` version 8B. If leave `MACREL` out, you get
`FUTIL` version 7. The automated pack builder recognizes that the
version 7 patches won't apply to version 8, and fails to apply them.
The research I did on the OS/8 Device Extensions kit and on
`MACREL` increased my confidence about the `FUTIL` version 7 patches.

See also [our documentation on the `MACREL` integration][macreldoc]
and [our documentation on applying OS/8 patches][patchdoc].

### <a id="license"></a>License

Copyright © 2017 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].

[vdmdoc]: http://vandermark.ch/pdp8/index.php?n=PDP8.Manuals
[vdmextensions]: http://vandermark.ch/pdp8/uploads/PDP8/PDP8.Manuals/AA-D319A-TA.pdf
[dbitdoc]: ftp://ftp.dbit.com/pub/pdp8/doc/
[dbitug]: ftp://ftp.dbit.com/pub/pdp8/doc/devextug.doc
[dbitrn]: ftp://ftp.dbit.com/pub/pdp8/doc/devextrn.doc
[kt8adoc]: http://www.vandermark.ch/pdp8/uploads/Emulator/Emulator.128KMemory/EK-KT08A-UG_jul78-ocr.pdf
[dsn1979apr]: http://bitsavers.org/pdf/dec/pdp8/softwarenews/198010_PDP8swNews_AA-K629A-BA.pdf
[macreldoc]:https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-macrel.md
[macreldoc]:https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-patching.md
[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md

