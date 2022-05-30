This directory contains the sources for the CC8 cross-compiler, which is
based on Ron Cain's Small-C system.

It is built by the top-level build system as `bin/cc8` and is installed
to `$prefix/bin/cc8`.

Call it as:

    cc8 myfile.c

The compiler does not have any consequential command line options.

The output file is `myfile.s` which is in SABR assembly code, intended
to be assembled within the PiDP-8/I OS/8 environment. See the `test`
subdirectory and [the CC8 manual][/doc/trunk/doc/cc8-manual.md] for
further details.
