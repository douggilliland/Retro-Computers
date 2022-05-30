# OS/8 V3F

This directory contains source files in `PAL-8` and `MACREL` labeled as OS/8 V3F.
It appears to be a nearly complete source distribution for the OS/8 V3D
Device Extensions Kit.

See also: [our documentation on theOS/8 V3D Device Extensions][extensions-doc].


## Recent Updates

### Cleanup Newlines

There were a couple places where, either in data transmission erorrs, or odd
formatting, an OS/8 newline was followed by an extra linefeed character. Because
we are going to be actively using these sources, copying them into and out of
OS/8, these files have been edited into canonical form.

Files affected:  `BUILD.PA`, `CCLTAB.MA`, `OS8.PA.` This does subtly
affect a `TECO` macro in `CCLTAB.MA`, but the change is in a print
message getting a `\r` changed to `\r\n`.  It should be totally benign.


### Improved Build Batch Files

`CCL.BI` and `RESORC.BI` have been modified to name different devices
for input and output files.  You still need to do the device assignments:

    ASSIGN RKA1 IN
    ASSIGN RKB1 OUT

`RESORC.BI` chained to a script, `MOVE.BI` that is supposed to move the
output from `LINK` from `DSK:` to `OUT:` but that script is not present.
So `COPY` and `DEL` commands to do that were added to the `RESORC.BI` and
`CCL.BI`.


## Utilization

The file `actions.txt` is to be submitted to our os8-cp utility as follows:

    ../../bin/os8-cp --action-file actions.txt

This will create the rk05 image file `v3f-build.rk05` with the sources
in partition A.  A script `v3f-control.os8`, run by `os8-run` will
build the components as they are validated.


## History

These sources were nearly lost.

ibiblio.org has a file, `readme.v3f` describing a self extracting archive,
`OS8V3F.EXE` that contains the sources.  But that file is not present.
However a [mirror site of Johnny Billquist's arcihve][rtk-mirror] had both readme and
the .exe.

I believe the designation, "fromnichols" means that the collection was from
Lee Nichols, a steering committee member of the 12-Bit SIG special interest group
for 12 bit computers.

The `readme.v3f` appears in this directory as `README.V3F`. We copy it into
the build RK05 image as `README.TX`.

[rtk-mirror]:http://rtk.mirrors.pdp-11.ru/ftp.update.uu.se/pdp8/pdp-8/fromnichols/
[extensions-doc]:https://tangentsoft.com/pidp8i/doc/trunk/doc/os8-v3d-device-extensions.md

## Contents of `readme.v3f`

<code>
OS/8 Version 3F                 27-Jul-1995



This archive directory contains the source files for the OS/8 
operating system version 3F that have been identified todate.
This is not the complete release and may have been released
as a maintenance update. The files listed below have been 
updated from the base V3D release and are useful in tracking
the development of OS/8.

The comments in `OS8.PA` denote this file as version 3F, 
but this file is NOT the same as the OS/78 V2 source. OS/8 V3F
and OS/78 V2 seem to be parallel developments, since neither 
refers to the other. It is not known just when these files 
were released. The primary change to OS8 is adding access to 
memory above 32K. 

Contained here is the last known release of `RESORC`,
which has been converted from the `PAL` to the `MACREL`
assembler. Also here are new handlers (not in V3D) for the 
RL disks, RX02 floppies in several flavors, and VX virtual
memory.

The `OS8V3F.EXE` file is a self extracting ZIP file of 
the V3F sources included here. Simply run `OS8V3F.EXE` on a PC 
to extract the V3F source files.

</code>

| `BLOAD.PA` |
| `BOOT.PA` |
| `BPAT.PA` |
| `BUILD.PA` |
| `CCL.BI` |
| `CCL.MA` |
| `CCLAT.MA` |
| `CCLCD.MA` |
| `CCLCDX.MA` |
| `CCLCOR.MA` |
| `CCLDAT.MA` |
| `CCLDRV.MA` |
| `CCLMSG.MA` |
| `CCLPS.MA` |
| `CCLREM.MA` |
| `CCLRUN.MA` |
| `CCLSB2.MA` |
| `CCLSEM.MA` |
| `CCLSIZ.MA` |
| `CCLSUB.MA` |
| `CCLTAB.MA` |
| `CCLTBL.MA` |
| `CD.PA` |
| `FPAT.PA` |
| `FUTIL.PA` |
| `KL8E.PA` |
| `OS78.BI` |
| `OS8.PA` |
| `PAL8.PA` |
| `PIP.PA` |
| `README.V3F` |
| `RESORC.BI` |
| `RESORC.MA` |
| `RESOV0.MA` |
| `RESOV1.MA` |
| `RESOV2.MA` |
| `RESOVD.MA` |
| `RKA0.DI` |
| `RKB0.DI` |
| `RL0.PA` |
| `RL1.PA` |
| `RL2.PA` |
| `RL3.PA` |
| `RLC.PA` |
| `RLFRMT.PA` |
| `RLSY.PA` |
| `RTL.PA` |
| `RTS.PA` |
| `RX78C.PA` |
| `RXCOPY.PA` |
| `RXNS.PA` |
| `RXSY1.PA` |
| `RXSY2.PA` |
| `SAVECB.PA` |
| `TECO.PA` |
| `VXNS.PA` |
| `VXSY.PA` |


### <a id="license"></a>License

Copyright © 2018 by Bill Cattey. Licensed under the terms of
[the SIMH license][sl].
