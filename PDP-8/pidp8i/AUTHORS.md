# Creators of and Major Contributors to the PiDP-8/I Project

*   **[Oscar Vermeulen](mailto:oscar.vermeulen@hotmail.com)**:

    -   Creator of the project (both hardware and software)
    
    -   Author of the initial modifications to the SIMH PDP-8 simulator
        necessary to make it use the PiDP-8/I front panel hardware

    -   Curator of the default set of binary demo media

    -   Author of the simulator setup scripts

    -   Initiator of much else in the project

    -   Author of the bulk of the documentation

    -   Host and major contributor to the PiDP-8/I support forum on
        Google Groups

    -   Hardware kit assembler and distributor

*   **Robert M Supnik** is the primary author of the SIMH PDP-8
    simulator upon which this project is based.

*   **Mike Barnes** ported Oscar Vermeulen's SIMH 3.9 based PiDP-8/I
    simulator to the new SIMH 4.0 code base.  (September 2015.)

*   **Dylan McNamee** ported the software to Buildroot for the official
    2015.12.15 binary OS images and helped to merge the James L-W
    "alt-serial" mode in.

*   **Mark G. Thomas** wrote the installation scripts for the 2015.12.15
    release, which were folded into the `make install` handler within
    the current `Makefile.in`. He also wrote the version of the SysV
    init script shipped here as `etc/pidp8i-init.in`.

*   **[Ian Schofield](mailto:isysxp@gmail.com)** modified the LED lamp
    driving code in the simulator to better simulate the incandescent lamps
    in the original PDP-8/I hardware.  (The bulk of his original code
    has since been rewritten, but the core idea remains, and it is
    doubtful whether the current method would exist without his
    instigation.)

*   **[Henk Gooijen](mailto:henk.gooijen@boschrexroth.nl)** pushed the
    PDP-8 simulator's internal EAE step counter value down into the
    PiDP-8/I's LED manipulation code, without which the step counter
    LEDs remain dark even when using the EAE.

*   **[Paul R. Bernard](mailto:prb@downspout.ca)** wrote `src/test.c`
    and the core of what now appears as `doc/pidp8i-test.md`. (The program
    builds and installs as `pidp8i-test`.)  He also provided a one-line
    fix that completes the work of Henk Gooijen's step counter patch.

*   **[Rick Murphy](mailto:k1mu.nospam@gmail.com)** is the current
    maintainer of [OS/8 Adventure][advent] which we've included in our
    OS/8 disk image. He's also provided several other files which have
    landed in the distribution such as the [VTEDIT][vtedit] feature. He
    also optimized the `pep001.pal` example so that it fits into a
    single page of PDP-8 core.

*   **[Tony Hill](mailto:hill.anthony@gmail.com)** merged all the
    upstream SIMH changes produced between late September 2015 and late
    December 2016 into the PiDP-8/I simulator. This is the basis for the
    current automatic upstream feature merge capability, which is why
    many releases since December 2016 include an update to the latest
    version of upstream SIMH. His contributions are made to the project
    [as `tony`][thcomm].

*   **[Jonathan Trites](mailto:tritesnikov@gmail.com)** wrote the
    initial version of the script `mkos8` which built the OS/8 disk
    images from source tapes.  `mkos8` evolved into `os8-run`.

*   **[Bill Cattey](mailto:bill.cattey@gmail.com)** is the project lead
    and primary developer of the system that builds the OS/8 media
    images from source tapes. He first greatly extended the `mkos8`
    script then replaced it entirely as `os8-run`. He curated the tape
    collections we ship as `media/.../*.tu56`, created some of those
    tapes, and more. He has also contributed to other areas of the
    software project. His contributions are made to the project [as
    `poetnerd`][pncomm].

*   **[Bill Silver](mailto:bsilver@tidewater.net)** created E8, an
    Emacs-like editor for the PDP-8.  See [its `AUTHORS.md` file][e8au]
    for more info.

*   **[Warren Young](mailto:tangentsoft@gmail.com)** Did everything
    listed in [the change log][cl] that is not attributed to anyone
    else.

    His contributions are made to the project [as `tangent`][wycomm],
    though keep in mind that some of those are commits of external
    contributions made by people who do not have commit rights on our
    software repository. The changelog provides proper attribution for
    these where the checkin comments do not.

[advent]: http://www.rickmurphy.net/advent/
[cl]:     https://tangentsoft.com/pidp8i/doc/trunk/ChangeLog.md
[e8au]:   ./src/e8/AUTHORS.md
[pncomm]: https://tangentsoft.com/pidp8i/timeline?u=poetnerd
[thcomm]: https://tangentsoft.com/pidp8i/timeline?u=tony
[vtedit]: https://tangentsoft.com/pidp8i/wiki?name=Using+VTEDIT
[wycomm]: https://tangentsoft.com/pidp8i/timeline?u=tangent
