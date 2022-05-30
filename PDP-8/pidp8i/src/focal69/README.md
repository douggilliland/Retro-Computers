# FOCAL69

Significant work to recover original codeline and lore by Charles Lasner (cjl)
Upstream is a repository at [ibiblio.org][ibiblio].

The recovery of the 8K overlay was a collaboration between Bill Cattey
and Charles Lasner for the purpose of preservation of the history and disseminating
the lore of how FOCAL-69 was crafted.

# Manifest

 * `DEC-08-AJAD-D.pdf` has been certfied by cjl as the definitive FOCAL 69 manual.
   This in spie of its front cover saying it is FOCAL-8. Apparently FOCAL-8 was
   a product based on FOCAL-69 that had some changes of dubious value.
 
 * `overlays` contains overlays to add features to FOCAL69.

# Assembling

    PAL8 FOCAL.BN<FOCAL.ZM,FLOAT.ZM

You will get a non-fatal error:

    RD  C100  +0001

This is just a redefinition of a symbol. The new definition is accepted.

To Load

    LOAD FOCAL.BN/G

We use run from a load of `FOCAL.BN` because we often use overlays.

[ibiblio]: http://www.ibiblio.org/pub/academic/computer-science/history/pdp-8/FOCL69%20Files/
