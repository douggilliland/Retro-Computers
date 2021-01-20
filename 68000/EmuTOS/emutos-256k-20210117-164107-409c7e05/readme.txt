EmuTOS - 256 KB versions

These ROMs are suitable for the following hardware:
- STe
- Mega STe
- emulators of the above

Note: Extra hardware is autodetected, but the following TT- and
Falcon-specific hardware is not supported: memory control unit,
video, SCSI, NVRAM, and the second MFP of a TT.

The desktop features are comparable to Atari TOS 2.

Each ROM contains a single language:

etos256cz.img - Czech (PAL)
etos256de.img - German (PAL)
etos256es.img - Spanish (PAL)
etos256fi.img - Finnish (PAL)
etos256fr.img - French (PAL)
etos256gr.img - Greek (PAL)
etos256hu.img - Hungarian (PAL)
etos256it.img - Italian (PAL)
etos256nl.img - Dutch (PAL)
etos256no.img - Norwegian (PAL)
etos256pl.img - Polish (PAL)
etos256ru.img - Russian (PAL)
etos256se.img - Swedish (PAL)
etos256sg.img - Swiss German (PAL)
etos256us.img - English (NTSC)
etos256uk.img - English (PAL)

The following optional files are also supplied:
emuicon.rsc - contains additional icons for the desktop
emuicon.def - definition file for the above

Notes on possible points of confusion
1. The emuicon.rsc file format differs from deskicon.rsc used by later
versions of the Atari TOS desktop.
2. Selecting Norwegian/Swedish currently sets the language to English,
but the keyboard layout to Norwegian/Swedish.
3. The 'Shutdown' menu item is active when EmuTOS is run under an
emulator supporting NatFeats (under Hatari, you need to enable this
with the "--natfeats on" option).

These ROM images have been built using:
make all256

This release has been built on Linux Mint (a Ubuntu derivative), using
Vincent Rivière's GCC 4.6.4 cross-compiler.  The custom tools used in
the build process were built with native GCC 4.8.4.

The source package and other binary packages are available at:
https://sourceforge.net/projects/emutos/files/emutos/1.0/

The extras directory (if provided) contains:
(1) one or more alternate desktop icon sets, which you can use to replace
    the builtin ones.  You can use a standard resource editor to see what
    the replacement icons look like.
    To use a replacement set, move or rename the existing emuicon.rsc &
    emuicon.def files in the root directory, then copy the files containing
    the desired icons to the root, and rename them to emuicon.rsc/emuicon.def.
(2) a sample mouse cursor set in a resource (emucurs.rsc/emucurs.def).  This
    set is the same as the builtin ones, but you can use it as a basis to
    create your own mouse cursors.
    To use a replacement set, copy the files containing the desired mouse
    cursors to the root, and rename them to emucurs.rsc/emucurs.def.
For further information on the above, see doc/emudesk.txt.

If you want to read more about EmuTOS, please take a look at these files:

doc/announce.txt      - Introduction and general description, including
                        a summary of changes since the previous version
doc/authors.txt       - A list of the authors of EmuTOS
doc/bugs.txt          - Currently known bugs
doc/changelog.txt     - A summarised list of changes after release 0.9.4
doc/emudesk.txt       - A brief guide to the newer features of the desktop
doc/incompatible.txt  - Programs incompatible with EmuTOS due to program bugs
doc/license.txt       - The FSF General Public License for EmuTOS
doc/status.txt        - What is implemented and running (or not yet)
doc/todo.txt          - What should be done in future versions
doc/xhdi.txt          - Current XHDI implementation status

Additional information for developers (just in the source archive):

doc/install.txt       - How to build EmuTOS from sources
doc/coding.txt        - EmuTOS coding standards (never used :-) )
doc/country.txt       - An overview of i18n issues in EmuTOS
doc/fat16.txt         - Notes on the FAT16 filesystem in EmuTOS
doc/memdetect.txt     - Memory bank detection during EmuTOS startup
doc/nls.txt           - How to add a native language or use one
doc/old_changelog.txt - A summarised list of changes up to & including
                        release 0.9.4
doc/osmemory.txt      - All about OS internal memory in EmuTOS
doc/reschange.txt     - How resolution change works in the desktop
doc/resource.txt      - Modifying resources in EmuTOS
doc/startup.txt       - Some notes on the EmuTOS startup sequence
doc/tos14fix.txt      - Lists bugs fixed by TOS 1.04 & their status in EmuTOS

The following documents are principally of historical interest only:

doc/old_code.txt      - A museum of bugs due to old C language
doc/vdibind.txt       - Old information on VDI bindings

-- 
The EmuTOS development team
https://emutos.sourceforge.io/
