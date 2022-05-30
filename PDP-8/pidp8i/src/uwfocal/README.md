# U/W FOCAL

FOCAL, the FORmula CALculator was an early interpreted language, pioneered on the PDP-8.

We have a historically accurate FOCAL69 package elsewhere.  The University of Washington
extended FOCAL significantly. This package is the latest version found of that work,
U/W FOCAL.

Upstream is a [linctape image on Dave Gesswein's Archive Site][uwf-linc]

Unfortunately the archive is incomplete.

Assembly instructions found in 16KCPR.PA, say:

    /    UWF.BN<16KCPR,12KFNS,8KFIO,8KFPP,16KLIB/L/K=100
    /    EAE VERSION:      8XFIO,8XFPP

The non-EAE versions of FIO and FPP have been lost.

The assembly, load, and save lines used are:

    UWF16K.BN<16KCPR.PA,12KFNS.PA,8XFIO.PA,8XFPP.PA,16KLIB.PA/K
    LOAD RKA1:UWF16K.BN
    SAVE RKA1:UWF16K.SV;100

## Documentation

`CARD1.DA`, `CARD2.DA`, `CARD3.DA`, and `CARD4.DA` are reference card text files
suitable for display under OS/8.  They have been unpacked and reformatted
into this tree as `doc/uwfocal-refcards.md`.

The Latest version of the U/W FOCAL V4E manual was found on [archive.org][archive],
unpacked, and reformatted into this tree as `doc/uwfocalmanual.md`.

Additional explanations of how to use U/W FOCAL under SIMH have been crafted
into `doc/uwfocal-manual-supp.md`.

## Notes

As of this date, every version of FOCAL I've tried can't accept paste-in
from other windows.  The characters come in too fast and overrun the
input buffer.

I do not like U/W FOCAL's approach to program load and save.

However this archive should build, run, and allow overlays following
instructions in NOTE1.TX, NOTE2.TX.

[uwf-linc]: http://www.pdp8online.com/pdp8cgi/os8_html?act=dir;fn=linctape-images/os8l/uw_focal_4e.linc;sort=name
[archive]: https://archive.org/details/bitsavers_decpdp8focct78_4144912/mode/2up