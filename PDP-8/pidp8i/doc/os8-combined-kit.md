# OS/8 Combined Kit

## Introduction

To create the richest OS/8 environment, one had to purchase add-ons:

* OS/8 V3D Extension Kit which contained `BASIC`, `TECO`, and the new `FUTIL`
file utility.
* OS/8 V3D FORTRAN IV
* OS/8 V3D Device Extensions which contained device drivers for more modern
devices like the RL02 cartridge disk drive, the RX02 dual density floppy, and
the KT8A memory subsystem that enlarged the PDP-8 maximum memory from 32K to
128K words.

(The two similarly named "Extensions" kits are a continuing source of confusion.)

In March of 1979, the baseline OS/8 distribution and these three add-ons were
put together as a single product, the "OS/8 V3D Combined Kit."

## Sources

## Media

## Patches

The OS/8 Combined Kit Information Guide says, "In addition, the kit's
modules have been updated with the binary patches described in the
OS/8 Device Extensions User's Guide and in the issues of the Digital
Software News (through June 1979)." Testing and review has determined
that this is not always true.

### Earlier recommendations re-affirmed:


### Verified Patches:

OS/8 V3D Patches:

`EDIT 21.17.1M` Applied in source form.
`EDIT 21.17.2M` Applied in source form.
`EDIT 21.17.3M` Applied in source form.
`EDIT 21.17.4M` Still bad. Not applied.
`FOTP 21.19.1M` Applied in source form.
`MCPIP 21.21.1M` Applied in source form.
`PAL8 21.22.1 M` Irrelevant. We have PAL8 V13A
`PAL8 21.22.2 M` Irrelevant. We have PAL8 V13A
`PAL8 21.22.3 M` Irrelevant. We have PAL8 V13A
`PAL8 21.22.4 M` Irrelevant. We have PAL8 V13A. Does not fit in that source either.
`PIP 21.23-1M` Applied in source form.
`PIP10 21.24.1M` Applied in source form.
`SET 21.26.1M`, `2M`, and `3M` All irrelevant. Set V2A now.

OS/8 Extension Kit V3D Patches:

`BATCH 31.23.1 M` Irrelevant. We have `BATCH` version 10.
`BRTS 31.11.1M` Applied in source form.
`BRTS 31.11.2 O` was supposedly an optional patch.  In the Combined
Kit, the patch is labeled mandatory, and applied in source form.
`BRTS 31.11.5 M` is available if you use `BASIC.UF` The patch is
expected to match and work.
`FUTIL 31.21.1 M` Not relevant. We have v8
`FUTIL 31.21.2 M` Not relevant. We have v8
`MSBAT 31.22.1 M` Applied in source form.

OS/8 FORTRAN IV Patches:

`F4/PASS3 21.1.2 M` Applied in source form. (Thank you, Lee Nichols!)
`F4 51.3.1 M` Applied in source form. (Thank you, Lee Nichols!)
`FORLIB 51.10.1 M` ha been applied in source form.
`FRTS 51.3.3 O` Has been applied in source form.

OS/8 V3D Device Extensions December 1978 Patches:

`ABSLDR 35.18.1 M` Applied in source form. (Thank you, Lee Nichols!)
`FUTIL 35.13.1 M` Applied in source form.
`MONITOR 35.2.1 M` Applied in source form. (Thank you, Lee Nichols!)
`FRTS 35.1.3 M` Is a note on how to avoid breaking `FRTS.SV` if
`ABSLDR.SV` lacking patch  `35.18.1 M` is used to load `FRTS.SV`
before applying `FPAT.BN`.  We build from source, and have the patch
so this is not an issue. 

### Applied Patches:

The Combined Kit sources were obtained from Lee Nichols who built them
and verified that the built binaries matched a Combined Kit binary
distribution he had.  When the patches applied to the V3D distribution
were reviewed, some patches dated later than the documented "through
June 1979" application date were discovered **not** to have been
applied.  Interpreting this state of affairs has been guided by pragmatism:

1. How could the documented release date of March 1979 include patches
appearing in the June/July 1979 PDP-8 Digital Software News? Probably impossible.
2. Was the software development team 100% accurate in their
application of patches? Probably not.
3. Is the statement "matches the binary distribution" from Lee
credible? Probably yes.
4. Is it worth the extra work to hand-integrate patches into source as
meticulously as Lee did with the patches he did integrate, when we
have proven binary patches and a pre-existing automated patch
application infrastructure?  Probably not.

Therefore, the following patches are applied using the same mechanism
used for the V3D distribution:

OS/8 V3D patches:

`CREF 21.15.1 M` Apr/May 1978.  Required update to apply to `CREF V5B`.
`CREF 21.15.2 M` Feb/Mar 1980.
`ABSLDR 21.29.1 M` Dec 1979/Jan 1980 -- Determined necessary after much research. See below.

OS/8 Extension Kit V3D patches: 11 need work.

`SABR 21.91.1M` needed (Oct '79)
`BLOAD 31.10.1M` needed (Feb/Mar 80)
`BRTS 31.11.3 O` is an optional patch that enables 132 column
output. It is recommended because it is expected that wide column
output is desirable.

`TECO 31.20.5 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.6 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.7 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.8 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.10 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.11 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.12 M` Needs to be applied. Apr/May 1978. Should have been in source.
`TECO 31.20.13 M` Needs to be applied. Oct/Nov 1978. Should have been in source.

OS/8 FORTRAN IV patches 1 needs work:

`F4 51.3.2 M` Has not been applied. Looks like it might be
needed. Jun/Jul 1978. Should have been in source.

OS/8 V3D Device Extensions December 1978 Patches: 2 need work.

`PAL8 35.14.1 M` Needs to be applied. (April/May '79)
`BLOAD 35.51.1 M`  Needed but same as `BLOAD-31.10.1 M` for Baseline.

Review and consider applying the available `MACREL v2` patches. 10 items


### Missing / Updated Patches:

`BASIC.UF-31.5.1 M`, a mandatory patch, was expected to have been
integrated into the source.  The sources that "built binaries that
matched the Combined Kit Binary Floppies did not contain
it. `BASIC.UF` can't work without this patch because page zero
literals in `BRTS` are adjusted to match.  This patch has been
incorporated into the `UF.PA` source.

The source of `CREF` was labeled version `5B` but contained no changes
other than the version string when compared against the OS/8 V3D
source.  The original `CREF 21.15.1 M` patch would not apply because
the version number, 0302, did not match what it was expecting.  To for
the Combined Kit, the patch is modified to not care what version
number is set.

### TODO:

Fix 3 patches:

Applying patch CREF-21.15.1M-v5B.patch8...	Old value: 0302 does not match 0301. Aborting patch.


Confirm application and correct operation.


### Patch research details: 

`ABSLDR 21.29.1 M` is supposedly a mandatory patch that enables
`ABSLDR` to work with `SAVE` image files.  Normally `ABSLDR` only
loads `BIN` format files. The patch sequence number, `21.29`
identifies the patch as being for the OS/8 V3D version of `ABSLDR`.
But the patch changes locations that are not used by `ABSLDR.SV`.
Furthermore, the patch says it upgrades `ABSLDR` from version 6B to
version 6C.

Version 6 of `ABSLDR` was part of the OS/8 V3D Device Extensions kit.
See [our documention on the OS/8 V3D Device Extensions][os8ext].
Verification of this now seems within reach, with the expectation that
it is mis-labeled, and is properly applied to the version with the
Extensions kit. Until it is verified, applying this patch is *not*
recommended.

Reviewing the 6A source we have for the Combined Kit, this patch
appears mis-labeled, and necessary for ABSLDR V6B.  This patch was not
re-numbered as of the latest issue to be found of PDP-8 Digital
Software News [October/November 1980 (Order Number
AA-K629A-BA)][dsn-1980-10].

`PAL8-21.22.4 M` Is broken and doubly mis-labeled. Mis-label #1: It is
an optional, not mandatory patch. Mis-label #2: It is for product
sequence `35.14`, the `V13` codeline of `PAL-8` that, like `ABSLDR
V6`, is in the Device Extensions kit.  The breakage: Source listing
quits working.  *Do not apply this patch!*

I've looked at the V13 PAL8 source, and this patch doesn't match up
to it either.

## Documentation and Historical Notes

Re-creating this whole kit, along with all the supporting operational and
historical documentation has been a challenge.  But at last we have it.

The creation date for the kit is known from the announcement of the
removal of support (Effective 28 April 1980) for the individual
components that appeared on page 3 of the 1980 April/May [PDP-8
Digital Software News][dsn-1980-04] (Order Number AA-J871A-BA.)

The detailed description of the kit can be found in the Digital
Software Product Description SPD 4.4.1 dated September 1979, which
appears on page 71 of the [1979 October/November PDP-8 Digital
Software News][dsn-1979-10] (Order Number AA-J235A-BA)

An overview of the kit can be found in the [OS/8 Combined Kit
Information Guide][os8cktig] (Order number AA-J016B-TA.) It enumerates
other relevant documents, almost all of which are available on the Net:

* OS/8 DEVICE EXTENSION RELEASE NOTES - AA-H565A-TA
* [OS/8 DEVICE EXTENSIONS USER'S GUIDE - AA-D319A-TA][dev-ext-u-g]
* [OS/8 ERROR MESSAGES - AA-H610A-TA][os8-err-msgs]
* [OS/8 FORTRAN IV SOFTWARE SUPPORT MANUAL - DEC-S8-LFSSA-A-D][fiv-support]
* [OS/8 LANGUAGE REFERENCE MANUAL - AA-H609A-TA][os8-lang-ref]
* [OS/8 MARK SENSE BATCH USER'S MANUAL - DEC-S8-OBUGA-A-D][os8-msb]
* [OS/8 SOFTWARE SUPPORT MANUAL - DEC-S8-OSSMB-A-D][os8-soft-supt]
* [OS/8 SYSTEM GENERATION NOTES - AA-H606A-TA][os8-sysgen]
* [OS/8 SYSTEM REFERENCE MANUAL - AA-H607A-TA][os8-sys-ref]
* [OS/8 TECO REFERENCE MANUAL - AA-H608A-TA][os8-teco-ref]
* [OS/8 V3D SYSTEM RELEASE NOTES - DEC-S8-OSRNA-B-D][v3d-rel-notes]
* [TECO POCKET GUIDE - AV-D530A-TK][teco-pocket]

The components and version numbers are listed starting on page 15 of
the OS/8 Combined Kit Information Guide.  This information also
appears starting at page 7 of the [1979 December/1980 January PDP-8
Digital Software News][dsn-1979-12] (Order Number AA-J442A-BA).

### <a id="license"></a>License

Copyright © 2017 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
[dsn-1980-04]:https://archive.org/details/bitsavers_decpdp8sofswNewsAAJ871ABA_952366
[dsn-1979-10]:https://archive.org/details/bitsavers_decpdp8sofswNewsAAJ235ABA_2298034
[os8cktig]:ftp://ftp.dbit.com/pub/pdp8/doc/os8cktig.doc
[dsn-1979-12]:https://archive.org/details/bitsavers_decpdp8sofswNewsAAJ442ABA_2496461
[dev-ext-u-g]:https://poetnerd.com/pdp8-alive/pdp8-alive/artifact/694f464f6aee76e7
[os8-err-msgs]:https://archive.org/details/bitsavers_decpdp8os8ar79_1411130
[fiv-support]:https://archive.org/details/bitsavers_decpdp8os8p_4653670
[os8-lang-ref]:https://archive.org/details/bitsavers_decpdp8os879_21565181
[os8-msb]:http://www.pdp8.net/pdp8cgi/query_docs/tifftopdf.pl/pdp8docs/dec-s8-obuga-a-d.pdf
[os8-soft-supt]:https://archive.org/details/bitsavers_decpdp8os8up_5566495
[os8-sysgen]:https://archive.org/details/bitsavers_decpdp8os8otes_1404154
[os8-sys-ref]:https://archive.org/details/bitsavers_decpdp8os8an_11163494
[os8-teco-ref]:https://archive.org/details/bitsavers_decpdp8os879_5310047
[v3d-rel-notes]:https://archive.org/details/bitsavers_decpdp8os8elN_488624
[teco-pocket]:https://archive.org/details/bitsavers_dectecoAVDde1978_3836960
[dsn-1980-10]:https://archive.org/details/bitsavers_decpdp8sofswNewsAAK629ABA_1652391
