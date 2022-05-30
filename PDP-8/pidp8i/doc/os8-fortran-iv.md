# OS/8 FORTRAN IV

OS/8 `FORTRAN IV` is extensively documented:

* Chapter 8 of the [1974 OS/8 Handbook][os8h1974] (large file!).
* Section 2 of the [OS/8 Language Reference Manual AA-H609A-TA][os8lang].
* The [OS/8 Fortran IV Software Support Manual DEC-S8-LFSSA-A-D][os8f4suppt]

This file serves more as a quick guide to what has been gathered
to this repository as far as distribution DECtapes, and patches
are concerned.

The [1979 OS/8 Software Components Catalog][os8cat] provides an
inventory of and part numbers for the OS/8 V3D binary and source
distribution DECtapes. Images of these DECtapes are all found in
media/os8/subsys as follows:

| DEC Part    | Filename                        | Description       |   
| ----------- | ------------------------------- | ----------------- |
| AL-4549D-BA | al-4549d-ba-fr4-v3d-1.1978.tu56 | Binary DECtape #1 |
| AL-5596D-BA | al-5596d-ba-fr4-v3d-2.1978.tu56 | Binary DECtape #2 |
| AL-4545D-SA | al-4545d-sa-fr4-v3d-1.tu56      | Source DECtape #1 |
| AL-4546D-SA | al-4546d-sa-fr4-v3d-2.tu56      | Source DECtape #2 |
| AL-4547D-SA | al-4547d-sa-fr4-v3d-3.tu56      | Source DECtape #3 |

When with-os8-fortran-iv is enabled (which is the default), the
contents of Binary DECtape #1 are installed on the OS/8 RK05 images
built by `os8-run`.

Binary DECtape #2 contains the `.RA` sources for the components
of the FORTRAN IV library.  Those files are already assembled
and archived in `FORLIB.RL` and installed from Binary DECtape #1.

The three source DECtapes contain the buildable source code for the
rest of OS/8 FORTRAN IV system.  Build instructions are found in
Appendix B of the _OS/8 Fortran IV Software Support Manual_.

If with-os8-patches is configured, the `os8v3d-patched.rk05` image will contain the following patches:

* `F4 21.1.2 M` Fix for the `EQUIVALENCE` statement that brings
  `F4.SV` and `PASS3.SV` up to version 4B.
* `F4 51.3.1 M` Enable recognition of `"` as an incorrect character in
  a subroutine call argument that brings `F4.SV` up to version 4C.
* `F4 51.3.2 M` Enable recognition of syntax errors in type
  declarations.
* `FORLIB 51.10.1 M` Updates `FORLIB.RL` to contain an corrected
  `DLOG` function that will correctly handle numbers smaller than
  `1.1-018`.

There is one more patch available, `FRTS 51.3.3 O`, an optional patch
that enables the FORTRAN IV runtime system to accommodate 2 page
system handlers in addition to the TD8E handler.  This patch has not
yet been verified.

FORTRAN IV on the system packs should work.

The sources are available in the tree in the files named above.

Enjoy!

[os8h1974]: http://bitsavers.trailing-edge.com/pdf/dec/pdp8/os8/OS8_Handbook_Apr1974.pdf
[os8lang]: http://bitsavers.trailing-edge.com/pdf/dec/pdp8/os8/AA-H609A-TA_OS8_Language_Reference_Manual_Mar79.pdf
[os8f4suppt]: http://bitsavers.trailing-edge.com/pdf/dec/pdp8/os8/DEC-S8-LFSSA-A-D_F4swSupp.pdf
[os8cat]: https://ia601002.us.archive.org/8/items/bitsavers_decpdp8sofoftwareComponentsCatalogJul79_7798622/AV-0872E-TA_PDP-8_Software_Components_Catalog_Jul79.pdf

### <a id="license"></a>License

Copyright © 2017 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
