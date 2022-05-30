# How the PiDP-8/i Software Is Tested

How do we gain confidence that what we will release is working with
minimal regressions?

The buld process operates in layers starting with SIMH and the OS/8
distribution DECtape image files as the lowest level. The layering goes like this:

1.  Boot the OS/8 V3D Distribution DECtape image,
    `.../media/os8/v3d/al-4711c-ba-os8-v3d-1.1978.tu56`. This creates
    `v3d-dist.rk05` which is booted to continue the build process.

2.  Boot `v3d-dist.rk05` to apply patches to create a useful image with
    the latest bug fixes, `v3d-patched.rk05`. Strictly speaking, this is
    the optimal, but minimum platform for continuing to build, and to
    operate utilities.

3.  Boot `v3d-patched.rk05` to build `e8`, `cc8`, and anything else that
    needs OS/8. This is the platform that should be used to build V3F
    from source, and the OS/8 Combined Kit (OCK) from source. Creating
    the images used to assemble V3F and OCK from source requires
    `os8-cp`.

4.  Install packages built with OS/8 onto runable packs. This is where
    `v3d-patched.rk05` becomes `v3d.rk05`. At the present moment, the
    component RK05 images that will be gathered into `ock-dist.rk05`
    have been built using `v3d-patched.rk05`. They could have been built
    using `v3d.rk05`. The choice is made in the build scripts. The
    `ock-dist.rk05` image is constructed similarly to layer 1. The
    `al-4711c-ba-os8-v3d-1.1978.tu56` image is booted, and used to
    create an RK05 image, which is then populated with the other
    components built in layer 3. At this point we have bootable TU56
    images for V3D and V3F built from `v3d.rk05`. We also have
    `ock-dist.rk05` built from source.

5.  Boot `ock-dist.rk05` and apply patches to create `ock-patched.rk05`.

6.  Install packages such as `cc8` and `e8` on `ock-patched.rk05` to
    create `ock.rk05`. This completes all building.

Layer 1 shows that SIMH basically works.  Each subsequent layer is proof
that the basic operation of the previous layer works.  So a successful
build of everything has provided a fair bit of coverage.

The next challenge is functional tests for leaf node packages like
`cc8` and `advent`.  The `os8-progtest` tool tests these.

The leaf node package management files live in the `pspec` subdirectory
of the source tree.  Tests for the packages live in `scripts/os8-progtest`.
`auto.def` knows how to discover new packages and new tests and
incorporate them into the `Makefile`.

`Makefile` contains a `make test` target that runs `os8-progtest`
on all discovered tests.
