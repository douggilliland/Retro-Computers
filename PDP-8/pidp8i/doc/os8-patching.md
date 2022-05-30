# OS/8 System Patches

Between major updates to distribution media, DEC would send out
important information and patches to customers through its publication
_PDP-8 Digital Software News_ (_DSN_ for short).

Many issues of _DSN_ can be found on bitsavers.org under
[pdf/dec/pdp8/softwarenews][dsn].

To help customers keep track of which patches to apply, _DSN_ added a
Cumulative Index.

Using the _PDP-8 DIGITAL Software News Cumulative Index_ found in the
latest available issue of _DSN_, [October/November 1980][dsn8010], I
created a spreadsheet of all patches relevant to the OS/8 V3D packs
under construction.  That spreadsheet enabled me to go to the
particular issues containing the patches, and keep track of what
action I took with them.

I reviewed all the patches and came up with a list of the mandatory
patches.  Using OCR'd text from each relevant _DSN_ issue, I created a
file per patch, which I then compared to the scanned PDF and corrected
the OCR errors.

Then I created a way to apply the patches in an automated way.  Most
of the patches were for programs available in source form, so I built
the programs from source, and then bench checked the patch against the
source.  In a few cases the code was too obscure, and I marked the
patch as "plausable" rather than "verified" in my spreadsheet.

The file [`patch-list.txt`][pl] lists all of the patch files in
`media/os8/patches`.  Comments in that file begin with `#` and are
used to disable patches we have rejected for one reason or another.
Each rejected patch also has a comment that explains why that
particular patch was rejected from the default set.  Typical reasons
are:

*   The patch requires hardware our simulator doesn't have.
*   The patch conflicts with another patch we deem more important.
*   The patch changes some behavior, and we prefer that the unpatched
    behavior be the default.

You may want to examine this file to see if there are any decisions you
would reverse.  After modifying that file, say "`make`" to rebuild the
OS/8 binary RK05 disk image file with your choice of patches.

[dsn]:     http://bitsavers.org/pdf/dec/pdp8/softwarenews/
[dsn8010]: http://bitsavers.org/pdf/dec/pdp8/softwarenews/198010_PDP8swNews_AA-K629A-BA.pdf
[pl]:      https://tangentsoft.com/pidp8i/doc/trunk/media/os8/patches/patch-list.txt


## Review of Recommendations

`BRTS 31.11.2 O` is an optional patch which disables 8th bit parity. It
is recommended because sometimes we may want to allow output that
does not force the 8th bit.

`BRTS 31.11.3 O` is an optional patch that enables 132 column
output. It is recommended because it is expected that wide column
output is desirable.

`TECO 31.20.1 O` is an optional patch that permanently forces no case
flagging.  It is not recommended because we want to allow the option
of case flagging.

`TECO 31.20.2 O` is an optional patch that turns off verbose
errors. It was for slow terminals and experienced users who didn't
want to wait to see the long error messages they already knew.  It is
not recommended because we expect a majority of users to be on high
speed terminals needing the verbose errors.

`TECO 31.20.3 O` turns off a warning that you are using the `YANK`
command to completely overwrite a buffer full of text.  Issuing the
command a second time succeeds.  It was again to avoid experienced
users.  It is not recommended because we expect fewer advanced users
who would be annoyed by the protection.

`TECO 31.20.4 O` implements rubout support specifically and uniquely
for the `VT05` terminal in a way that breaks it for all other video
terminals.  It is not recommended because there are VERY few `VT05`
deployments that would use it.

It is at this point that I began to notice that in later years, patches
became less carefully produced, and more prone to errors. Some are not
correctable, even today.

`BASIC.UF-31.5.1 M` shows:

    4044/4514 4556

changing location `4044` from `4514` to `4556`.  Such a change would be
consistent with the stated purpose of the patch, to correct references
to page zero literals that moved with the `V3D` version of `BRTS`.
The source around location '4044' looks like this:

    04043  4775          JMS I   (BUFCDF /SET UP USER BUF
    04044  1273          TAD     NSAM
    04045  7041          CIA
    04046  3276          DCA     NCTR    /-#OF BOARDS TO CLAR

In my judgment the `TAD NSAM` to get the subscript into the `AC`
should be retained, and the `4556` call to `UNSFIX` to truncate the
value of the Floating Point Accumulator should NOT be inserted.  I
modified the patch to leave out that change.  It remains to be seen if
calls to User Functions in OS/8 `BASIC` will ever be run to test this
code.  Here at least is an analysis to later explorers.

`EDIT 21.17.4 M` is supposedly a mandatory patch.  It fixes a problem
with line printer output through a specific parall interface card.
Unfortunately, the patch overwrites mandatory patch in 21.17.2 and is
NOT recommended.

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

`PAL8-21.22.4 M` is broken and doubly mis-labeled. Mis-label #1: It is
an optional, not mandatory patch. Mis-label #2: It is for product
sequence `35.14`, the `V13` codeline of `PAL-8` that, like `ABSLDR
V6`, is in the Device Extensions kit.  The breakage: Source listing
quits working.  *Do not apply this patch!*

Patch `FRTS-51.3.3-O.patch8` is to enable 2-page system drivers like
`RL01`.  Except that the `RL01` driver is only available in the
Extensions kit.  The patch overwrites existing code that makes `FRTS`
able to function with the `TD8E` 2-page system handler.  I've read the
code but don't fully understand it. Perhaps it generalizes the `TD8E`
support.  But if you happen to be using this setup under `TD8E` and
`FRTS` doesn't work, then back out this patch.


## Patch Application Order

In the creation of `v3d.rk05` image booted by default, the
script `v3d-rk05.os8` defines the order in which the patches are applied.
It started off alphabetically by subsystem, but evolved as
order dependencies emerged.

For example, if the `ABSLDR` patch actually did work, it needs the
`FUTIL 31.21.2 M` in order to patch into the `ABSLDR` overlay bits.

I was skeptical of `FUTIL 31.21.2M` because, when I
load `ABSLDR.SV` into core with GET, the contents of memory showed by
`ODT` are *DIFFERENT* from those shown by `FUTIL`. With deeper
understanding of the OS/8 Device Extensions kit, I see that the patch
was incorporated into the version 8 `FUTIL` source, and also that
`ODT` is expected to be updated in version 3S of the Keyboard Monitor.


## Then There's `MACREL`

I've gone into detail on the explorations and understandings with
regard to `MACREL` in a [sister document to this one][macreldoc].

Originally I reviewed the patches for `MACREL` v1, because that's all
we had.  But the version numbers of the patches did not match the
version numbers of the executables.  A little diversion into the guess
work surrounding patch verification:

Version number mismatches sometimes do occur with patches. For
example, `TECO 31.20.11 M` says that it upgrades `TECO` to version
`5.06`, but got the bits wrong.  Instead of changing contents from
`0771` to `0772`, it looked to change from `0772` to `0773`.  `772`
octal is `506` decimal, and the `TECO` version number is represented
with a 12 bit number.  It's called "5.06" but it's represented as
`0772` octal, or `506` decimal.

With that TECO patch, I simply changed the version amendment line in
that `TECO` patch, because the rest was correct.  Whoever published
the patch got the version number wrong, and nobody complained.

With no `MACREL` v1 source code, verification was not really possible,
so applying those patches was postponed.  But then we found both binary
and source of `MACREL` v2!

None of the available `MACREL` v2 patches are currently applied. We may
get to that later.

After further testing of `MACREL`, I have concluded that integrating the
source-level patch `41.5.1M` will reduce uncertainty, so I have
hand-integrated that patch into the `MACREL` tu56 image as well.

[macreldoc]:https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-macrel.md


## `FUTIL`

I was dubious of some of the `FUTIL` patches, but with finding source
to version 8A, I gained confidence in the version 7 patches, and
understood how seriously important the first patch was to version 8.

The `MACREL` v2 tape shipped with version 8A of `FUTIL`. That was
necessary because V2 of `MACREL` supported the latest memory expansion,
and so the OS/8 Core Control Block needed to change.

Unfortunately, the `FUTIL.SV` distributed as version 8A had the wrong
starting address and Job Status Word settings. It *hangs* when run
under `BATCH`.  Our automated pack builder and patcher script
`v3d-rk05.os8` runs `FUTIL` under `BATCH`.

The `MACREL` v2 DECtape image we use with automated building contains a
hand-applied patch `35.13.1M` that fixes this problem.

Currently if you opt in to having `MACREL` on the system packs, you
get `FUTIL` version 8B. If not, you get `FUTIL` version 7 and
`v3d-rk05.os8` applies the relevant patches. If `FUTIL` version 8 is
installed, the automated patch applier recognizes the version 7
patches don't fit and fails to install them.

## One-off Patches

Most of the patches are parsed and applied in an automated manner
by `v3d-rk05.os8`.  However some are one-offs.

See the `FUTIL` section above with regards to patch `35.13.1M`.

`FORLIB 51.10.1 M` is a one line source change to `DLOG.RA`. The patch
file provides that line. It also provides instructions on how to use
`RALF` to assemble the source and on how to to use `LIBRA` to replace
the old version of `DLOG` with the new one in `FORLIB.RL`.  I followed
the instructions to hand-tool a patched `FORLIB.RL` which I then put
in the source tree at `.../src/os8/v3d/LANGUAGE/FORTRAN4/FORLIB.RL SYS:FORLIB.RL`
The `patch-rk05.os8` script has conditional code to replace `FORLIB.RL`
on `SYS:` if installation of FORTRAN IV is enabled.


## Unfinished Business

There remain the following patches that are still under development,
because they are not simple binary overlays on executables that could
be applied with simple scripts driving `ODT` or `FUTIL`.  Instead they
are either batch scripts, or are applied to source code that is
rebuilt either with an assembler or high level language compiler.

`LQP 21.49.1 M` patches a device driver `.BN` file, then using `BUILD`
to insert it into the system.  At the present time the OS/8 V3D packs
we build do not use the `LPQ` driver.  (We ran out of device ID space
and so we don't have anywhere to put an active `LPQ` driver.)


## The Tracking Spreadsheet

Below is the latest snapshot of the tracking spreadsheet.

Status column key:

| **A** | Patch Applies Successfully                                   |
| **V** | Patch Source Verified                                        |
| **K** | Patch Source Probably OK. Weaker confidence than "Verified". |
| **P** | Patch Source Plausible. Weaker confidence than "OK".         |
| **N** | Not recommended                                              |
| **O** | OCR Cleaned up. No other verification or application done.   |
| **D** | Does not apply.                                              |
| **B** | Bad patch. DO NOT APPLY.                                     |


### OS/8 V3D Patches

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  `HANDLER` | `CTRL/Z` and `NULL` | `01 O *` | Oct-77 | Optional. Not going to apply. |  |
|  `CREF` | Bug with `FIXTAB` | `21.15.1M` | Apr/May-78 | `CREF-21.15.1-v2B.patch8` Corrects bad patch | AV |
|   | Input and output file specifications | `21.15.2M` | Feb/Mar-80 | `CREF-21.15.2-v2C.patch8` | AK |
|  `EDIT` | `EDIT` Problem with no `FORMFEED` at end of the input file | `21.17.1M` | Mar-78 | `EDIT-21.17.1M-v12B.patch8` | AV |
|   | `EDIT` `Q` command after `L` command | `21.17.2M` | Jun/Jul-79 | `EDIT-21.17.2M-v12C.patch8` | AV |
|   | `EDIT` `Q` command patch | `21.17.3M` | Jun/Jul-79 | `EDIT-21.17.3M-v12D.patch8` | AV |
|   | `EDIT.SV` `V` option will not work with `LPT DKC8-AA` | `21.17.4M` | Feb/Mar-80 | `EDIT-21.17.4M-v12C.patch8` Overwrites patch `21.12.2M` | AVB |
|  `FOTP` | Incorrect directory validation | `21.19.1M` | Jun/Jul-79 | `FOTP-21.19.1M-v9B.patch8` (Corrected from Aug/Sep 1978, Detailed in Apr/May 79) | AV |
|  `MCPIP` | `DATE-78` Patch for `MCPIP` | `21.21.1M` | Mar-78 | `MCPIP-21.21.1M-v6B.patch8` | AV |
|  `PAL8` | Incorrect core size routine | `21.22.1M` | Aug/Sep-78 | `PAL8-21.22.1M-v10B.patch8` | AV |
|   | Erroneous `LINK` generation noted on `PAGE` directive | `21.22.2M` | Aug/Sep-78 | `PAL8-21.22.2M-v10C.patch8` | AV |
|   | `EXPUNGE` patch to `PAL8` | `21.22.3M` | Feb/Mar-80 | `PAL8-21.22.3M-v10D.patch8` | AK |
|   | `TAB`s are translated incorrectly | `21.22.4M` | Oct/Nov-80 | `PAL8-21.22.4M` (Supercedes June/July 1980 (which had wrong contents of memory.)) Bad! Wrong version of `PAL8`! Breaks list output. | AB |
|  `PIP` | `PIP` `/Y` option does not work properly when transferring a system | `21.23-1M` | Aug/Sep-78 | `PIP-21.23.1M-V12B.patch8` | AK |
|  `PIP10` | `DATE-78` Patch to `PIP 10` | `21.24.1M` | Jun/Jul-79 | `PIP10-21.24.1M-V3B.patch8` (Corrected from Dec 78/Jan 79) | AV |
|  `SET` | Using `SET` with two-page system handlers | `21.26.1M` | Apr/May-78 | `SET-21.26.1M-v1C.patch8` | AV |
|   | `SCOPE` `RUBOUT`s fail in `SET` | `21.26.2M` | Apr/May-78 | `SET-21.26.2M-v1D.patch8` | AV |
|   | Parsing of `=` in `TTY WIDTH` option | `21.26.3M` | Aug/Sep-78 | `SET-21.26.3M-v1E.patch8` | AV |
|  `LPQ` | `LDP01` Handler fails to recognize `TAB`s | `21.49.1M` | Dec/Jan-80 | `LQP-21.49.1M-vB.patch8` (supercedes Mar 1978) | O |
|  `TM8E` | Write protect patch to `TM8E.PA` | `21.61.1H` | Feb/Mar-80 | New `TM8E` Source.  Too hard to correct. |  |


### OS/8 Extension Kit V3D Patches

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  `SABR` | Line buffer problem in `SABR` | `21.91.1M` | Oct/Nov-79 | `SABR-21.91.1M-v18B.patch8` | AV |
|  `BASIC.UF` | `BASIC.UF` Incompatible from OS/8 V3C | `31.5.1M` | Aug/Sep-78 | `BASIC.UF-31.5.1M-V5B.patch8` Source also in _DSN_. | AV |
|  `BLOAD` | `BLOAD` Will not build `CCB` properly | `31.10.1M` | Feb/Mar-80 | `BLOAD-31.10.1M-v5B.patch8` | AV |
|  `BRTS` | `IOTABLE` Overflow | `31.11.1M` | Mar-78 | `BRTS-31.11.1-M-v5b.patch8` | AV |
|   | `BASIC` `PNT` Function | `31.11.2O` | Jun/Jul-78 | `BRTS-31.11.2-O.patch8` (superceds/corrects Mar 1978) | AV |
|   | Line size on output of `BASIC` | `31.11.3O` | Jun/Jul-78 | `BRTS-31.11.3-O.patch8` | AV |
|   | Change line printer width | `31.11.4F` | Oct/Nov-79 | Optional change of width to 132 columns |  |
|   | Patch to `BRTS` for addressing `LAB 8/E` functions | `31.11.5M` | Oct/Nov-79 | `BRTS-31.11.5-x.patch8` (`BASIC.UF` patch is a prerequisite.) | AV |
|  `TECO` | Changing the default `EU` value for no `case` flagging | `31.20.1O` | Mar-78 | `TECO-31.20.01O.patch8` | AVN |
|   | Changing the default `EH` value for one line error printouts | `31.20.2O` | Mar-78 | `TECO-31.20.02O.patch8` | AVN |
|   | Removing `YANK` protection | `31.20.3O` | Mar-78 | `TECO-31.20.03O.patch8` | AVN |
|   | `SCOPE` Support for `VT05` users | `31.20.4O` | Mar-78 | `TECO-31.20.04O.patch8` | AP N |
|   | Problem with `AY` command | `31.20.5M` | Mar-78 | `TECO-31.20.05M-v5A.patch8` | AV |
|   | Conditionals inside iterations | `31.20.6M` | Mar-78 | `TECO-31.20.06M-v5B.patch8` | AV |
|   | Echoing of warning bells | `31.20.7M` | Mar-78 | `TECO-31.20.07M-v5B.patch8` | AV |
|   | `CTRL/U` Sometimes fails after `*` | `31.20.8M` | Apr/May-78 | `TECO-31.20.08M-v5.04.patch8` | AK |
|   | Multiplying by `0` in `TECO` | `31.20.10M` | Apr/May-78 | `TECO-31.20.10M-v5.05.patch8` | AV |
|   | `Q` registers don't work in 8K | `31.20.11M` | Apr/May-78 | `TECO-31.20.11M-v5.06.patch8` | AV |
|   | Can't skip over `W` | `31.20.12M` | Apr/May-78 | `TECO-31.20.12M-v5.07.patch8` | AV |
|   | Unspecified iterations after inserts | `31.20.13M` | Oct/Nov-78 | `TECO-31.20.13M-v5.08.patch8` (Corrected from Jun/Jul 78) | AV |
|   | New features in `TECO V5` | `31.20.14` N | Aug/Sep-78 | Documentation Only |  |
|  `FUTIL` | `FUTIL` Patch | `31.21.1M` | Apr/May-78 | `FUTIL-31.21.1M-v7B.patch8` | AV |
|   | Fix `SHOW CCB` and mapping of `CD` modules | `31.21.2M` | Oct/Nov-78 | `FUTIL-31.21.2M-v7D.patch8` (Corrected from Aug/Sep 78) | AV |
|   | Optional: change `XS` format from `excess-240` to `excess-237`. Useful for viewing `COS` data files. | `31.21.3O` | Aug/Sep-78 | `FUTIL-31.21.3O.patch8` | AVN |
|   | `FUTIL` Patch to `MACREL`/`LINK` overlays | `31.21.4 N` | Jun/Jul-79 | Documentation Only |  |
|  `MSBAT` | `DIM` Statement not working in `MSBAT` | `31.22.1M` | Dec 78/Jan-79 | `MSBAT-31.22.1M-v3B.patch8` | AV |
|  `BATCH` | `MANUAL INTERVENTION REQUIRED` Erroneously | `31.23.1M` | Aug/Sep-78 | `BATCH-31.23.1M-v7B.patch8` | AV |


### OS/8 FORTRAN IV V3D Patches

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  `F4` | `EQUIVALENCE` Statement | `02M` / `21.1.2M` | Dec/Jan-80 | `F4-21.1.2M-v4B.patch8` (Revised, Oct 77: `F4` and `PASS3` not `FRTS` patched.) | AP |
|   | `FORTRAN` Compiler fails to recognize `"` as an error | `51.3.1M` | Jun/Jul-78 | `F4-51.3.1M-v4C.patch8` (Corrects March 1978) | AP |
|   | `FORTRAN` Compiler not recognizing syntax error | `51.3.2M` | Jun/Jul-78 | `F4-51.3.2M-v4x.patch8` | AP |
|   | `FORTRAN` runtime system 2-page handler | `51.3.3O` | Oct/Nov-78 | `FRTS-51.3.3-O.patch8` Needed for RL02. (Corrected from Aug/Sep 78) | A |
|   | Restriction with subscripted variables | `51.3.4R` | Aug/Sep-80 | Documentation: `FIV` `FORTRAN IV` will not allow subscripting to be used on both sides of an arithmetic expression. |  |
|  `FORLIB` | `FORTRAN IV` `DLOG` Patch | `51.10.1M` | Feb/Mar-80 | `FORLIB-51.10.1M.patch8` (apply to `DLOG.RA`) | AV |


### OS/8 MACREL/LINKER V1A Patches

These patches are listed for completeness. The version numbers don't
match.  We lack source so we cannot verify them. we've moved on to
`MACREL` v2 as canon.  

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  `LINK` | Patch `V1D` to `LINK` | `40.2.1M` | Apr/May-78 | `LINK-40.2.1M-v1D.patch8` | O |
|   | Patch `VIE` to `LINK` | `40.2.2M` | Apr/May-78 | `LINK-40.2.2M-v1E.patch8` | O |
|   | `LINK` Corrections | `40.2.3M` | Apr/May-78 | `LINK-40.2.3M-v1F.patch8` | O |
|  `MACREL` | Patch `V1D` to `MACREL` | `40.5.1M` | Apr/May-78 | `MACREL-40.5.1M-v1D.patch8` | OD |
|   | Patch `V1E` to `MACREL` | `40.5.2M` | Apr/May-78 | `MACREL-40.5.2M-v1E.patch8` | OD |
|  `OVRDRV` | Patch `V1B` to `OVRDRV.MA` | `40.6.1M` | Apr/May-78 | `OVRDRV-40.6.1M-v1B-8srccom` | O |


### OS/8 V3D Device Extensions December 1978 Patches

**WARNING**: Do not use this kit without first consulting _DSN_  Apr/May 1979.
See also: [Our OS/8 Device Extensions documentation][os8ext]

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  `FRTS` | `FRTS` Patch | `35.1.3M` | Apr/May-79 |  |  |
|  `MONITOR` | `MONITOR` `V3S` Patch | `35.2.1M` | Apr/May-79 |  |  |
|  `FUTIL` | `FUTIL` hangs under `BATCH` | `35.13.1M` CRITICAL! | Apr/May-79 |  | AV |
|  `PAL8` | `EXPUNGE` Patch to `PAL8` | `35.14.1M` | Feb/Mar-80 | `PAL8-35.14.1M-v13B.patch8` | AN |
|  `ABSLDR` | Loader problem with `SAVE` image files | `21.29.1M` | Oct/Nov-80 | `ABSLDR-21.29.1M-v6C.patch8` (Supercedes June/July 1980) Bad: v6B was with OS/8 Device Extensions. | OB |
|  `ABSLDR` | `ABSLDR` Patch | `35.18.1M` | Apr/May-79 |  |  |
|  `BLOAD` | `BLOAD` Will not build `CCB` properly | `35.51.1M` | Feb/Mar-80 | `BLOAD-35.51.1M-v5C.patch8` | ON |


### OS/8 MACREL/LINKER V2A Patches

These patches have not been turned into files.  Armed with newly
discovered sources verification is possible.  Work on these will begin
soon.

| Component | Issue | Sequence | Mon/Yr | Notes | Status |
| ------ | ------ | ------ | ------ | ------ | ------ |
|  User's |`EXPUNGE` Documentation error | `41.1.1N` | Jun/Jul-79 |  |  |
|  Guide  | `MACREL` Version numbers: `MACREL` is `V2C` not `V2D`; `LINK` is `V2A` not `V2B`. | `41.1.2N` | Jun/Jul-79 |  |  |
|   | Macro restriction in `MACREL` | `41.1.3N` | Aug/Sep-79 |  |  |
|   | Error in `.MCALL` macro example | `41.1.4N` | Feb/Mar-80 |  |  |
|  `KREF` | Correct printing of numeric local symbols | `41.3.1M` | Apr/May-80 |  |  |
|  `MACREL` | `EXPUNGE` Patch to `MACREL` | `41.4.1F` | Jun/Jul-79 |  |  |
|   | Inconsistencies in `MACREL` error reporting | `41.4.2N` | Aug/Sep-79 |  |  |
|   | Forward reference patch to `MACREL` | `41.4.3M` | Aug/Sep-79 |  |  |
|   | Correct macro substring problem | `41.4.4M` | Apr/May-80 |  |  |
|   | Correct printing of numeric local symbols | `41.4.5M` | Apr/May-80 |  |  |
|  `OVRDRV` | Correct `CDF` problem | `41.5.1M` | Dec/Jan-80 | Source change applied by hand. | AV |
|  `FUTIL` | `FUTIL` hangs under `BATCH` | `35.13.1M` | Apr/May-79 | Critical to proper operation of our automated builder. Applied by hand to the `MACREL` v2 integration.  | AV |



### <a id="license"></a>License

Copyright © 2017 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].

[sl]: https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
[os8ext]: https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-v3d-device-extensions.md

