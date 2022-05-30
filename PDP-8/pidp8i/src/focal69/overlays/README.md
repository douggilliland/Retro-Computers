# FOCAL69 Overlays

## Features

There are 3 features available here as overlays:

4WORD -- Extends floating point calculation precision from 6 to 10 digits.
8K    -- Allows FOCAL69 to use an additional 4K of memory for program and data.
VTRUB -- For use on video terminals, to overwrite rubbed out characters.

All three features can be enabled at the same time but to do so they
overlays must be loaded in the proper order.

## Source files

The source for 4WORD has not been recoverd yet.  It is available only as a binary patch.

4KVT.PA genrates a video terminal overlay suitable for use without the 8K
overlay.

8KVT.PA generates the 8K overlay with and without video terminal rubout
depending on whether or not VTRUB=1 is defined.

VTRUB.PA is a one line define of VTRUB=1 for use in assembling 8KVT.PA
to make it emit an 8K overlay with the video terminal rubout support.

## Loading overlays

To get 8K without video terminal rubout support:

    PAL8 8KNOVT.BN<8KVT.PA

To get 8K with video terminal rubout support:

    PAL8 8KVT.BN<VTRUB.PA,8KVT.PA

To get both 4WORD and 8K use the following:

    LOAD FOCAL.BN,4WORD.BN,8KNOVT.BN

If or use 8KVT.BN instead:

    LOAD FOCAL.BN,4WORD.BN,8KVT.BN

If you want to use stock 4K FOCAL69 with video terminal rubout:

    LOAD FOCAL.BN,4KVT.BN

If you want 4k FOCAL69 with both 4-word floating point ant video terminal
rubout support:

    LOAD FOCAL.BN,4WORD.BN,BKVT.BN

