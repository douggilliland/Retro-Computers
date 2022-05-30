# os8-run Scripts

This directory contains scripts to be run by the `os8-run` tool,
which provides a rich language to automate actions of OS/8
under SIMH.  See also the [os8-run documentation][os8-run-doc].


## OS/8 Scripts

The majority of these scripts are for building different distributions of OS/8
proper. 

| Name  | Distribution
|-------|-----------
| `v3d` | OS/8 V3D
| `v3f` | an unofficial V3D follow-on, never formally released as such by DEC
| `ock` | the [OS/8 Combined Kit][ockdoc] (OCK), the last formal DEC release of OS/8

Some of these scripts’ outputs are based purely on the input source file
contents, but some outputs vary based on [`configure --enable-os8-*`
parameters][os8cfg].

The OS/8 build scripts are stored in subdirectories of `os8` by distribution name.

The scripts are also classifiable into logical groupings:

[os8cfg]: /doc/trunk/README.md#disable-os8
[ockdoc]: /doc/trunk/src/os8/ock/README.md


### Installed Image Creation

These scripts create the primary OS/8 boot media, which are installed to
`$prefix/share/media/os8`:

| Script Name       | Build Product   | Function
|-------------------|-----------------|----------------------------
| `all-tu56`        | `v3[df]-*.tu56` | bootable OS/8 TU56 images
| `v3d/dist-rk05`   | `v3d-dist.rk05` | bootable OS/8 V3D on RK05
| `v3d/rk05`        | `v3d.rk05`      | `v3d-dist.rk05` with patches; default IF=0 boot option
| `v3d/src-rk05`    | `v3d-src.rk05`  | combined OS/8 V3D source tape contents
| `ock/dist-rk05`   | `ock-dist.rk05` | OCK analogue to `v3d-dist.rk05`
| `ock/rk05`        | `ock.rk05`      | OCK analogue to `v3d.rk05`

It should be noted that the `-dist` images are also used as internal
stable platforms to build other things atop, so their purpose blurs a
bit with the images in the next section.


### Intermediate Image Creation

Some of the above images are created in stages. The following scripts
generally assemble OS/8 source files to produce intermediate images that
are not installed:

| Script Name       | Build Product    | Function
|-------------------|------------------|------------------------
| `ock/cusps-build` | `ock-cusps.rk05` | Commonly Used System ProgramS (CUSPS)
| `ock/bf2-build`   | `ock-bf2.rk05`   | BASIC and FORTRAN II
| `ock/fiv-build`   | `ock-fiv.rk05`   | FORTRAN IV
| `ock/sys-build`   | `ock-sys.rk05`   | SYSTEM
| `v3f/control`     | `v3f-made.rk05`  | OS/8 V3F; input to `all-tu56` for `v3f-*.tu56`


### Utilities

| Script Name     | Function
|-----------------|-------------------------------------------
| v3d-reset-tc08  | Re-configure the IF=0 boot image to use TC08 DECtape instead of TD8E drivers
| cusp-copyin     | Included by `all-tu56` to copy CUSPS onto the TU56 image under construction


## Miscellaneous Scripts

There are a few one-off scripts for building individual components of
the software system in the `misc` subdirectory.  Their purpose is meant
to be obvious from their file name.


## Test Scripts

There are a number of scripts meant for testing `os8-run` itself. These
are in the `test` subdirectory:

| Script Name | Function
|-------------|-------------------------------------------
| version     | Test the `begin enabled version` functionality in `os8-run`
| copy        | Test the `cpto` and `cpfrom` os8-run commands.
| err         | Used to provoke errors in os8-run and test behavior.
| restart     | Test the `restart` os8-run command.
| patch       | Test the `patch` os8-run command.

[os8-run-doc]: /doc/trunk/doc/os8-run.md


## License

Copyright © 2016-2020 by Bill Cattey. This document is licensed under
the terms of [the SIMH license][sl].

[sl]:  https://tangentsoft.com/pidp8i/doc/trunk/SIMH-LICENSE.md
