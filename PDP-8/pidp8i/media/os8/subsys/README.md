# Software Subsystems


## Directory Contents

The files in this directory are used during the PiDP-8/I software build
process along with the DEC original tape images in [our parent
directory](/files/media/os8) to build the `v3d.rk05` disk image
used by boot options IF=0 and IF=7.

These files are here rather than one level up because they are not part
of OS/8 *per se*, but one way or another, they do currently require
OS/8. Some of the data on these tapes could potentially be used with
other PDP-8 operating systems, but at minimum, it would require
translating the data from OS/8 tape format.


| DECtape Image File Name | Content Description
| ----------------------------------------------------------------------------
| `music.tu56`            | [RFI-based][rfi] music playback programs


## Controlling the Build Process

Most of these files are merged into the OS/8 binary disk image by
default, but can be excluded by giving a `--disable-os8-NAME` flag to
the `configure` script, where `NAME` is the file name above without the
`.tu56` extension. (e.g. `--disable-os8-k12` excludes Kermit-12.)

Only one of the files above is currently excluded by default, that being
`music.tu56`, because we have not yet received any report of reliable
playback. We believe this is because the PiDP-8/I realization does not
lend itself to creation of suitable AM frequency RFI. These programs
were written for real PDP-8 hardware which had much longer wires backed
by much stronger drivers than a PiDP-8/I, and which ran at lower
frequencies than a Raspberry Pi. These problems are not insurmountable,
so someone interested in the project may force inclusion of these files
on the OS/8 RK05 boot disk with

     $ ./configure --enable-os8-music

Solving this problem may require hardware modifications. If so, we'll
still exclude these programs by default since not all PiDP-8/I machines
will have these modifications.

See the [top-level `README.md` file][tlrm] for further information about
the `--enable-os8-*` and `--disable-os8-*` configuration options.


[k12]:  http://www.columbia.edu/kermit/pdp8.html
[rfi]:  https://en.wikipedia.org/wiki/Electromagnetic_interference
[tlrm]: /doc/trunk/README.md
