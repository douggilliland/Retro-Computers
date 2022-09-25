# 6502 Tiny BASIC

This is Bob Applegate's (bob@corshamtech.com) spin of a Tiny BASIC interpreter for the 6502.  It uses an IL approach, like proposed by Dr Dobb's Journal in the first few issues.  This is not fancy, it's not bug free, and it's not amazing by any means, but it was fun to write and decent enough to do fun stuff and run demos.

## Features
* Pure 6502 code.
* Small, as per Tiny.  Intepreter and user code fits in 0200-13FF.
* Can support Corsham Technologies SD Card System to save/load files.
* 16 bit integer math.
* Built using IL, so you can change the languge by changing just the IL.

## Keywords
* LET
* GOTO
* GOSUB
* PRINT
* IF
* INPUT
* RETURN
* END
* LIST
* RUN
* NEW
* EXIT
* REM

And if the SD functions are enabled:

* SAVE
* LOAD

Functions:

* FREE()
* RND(x)
* ABS(x)

## Requirements

* RAM from 0200 to 13FF.
* Must have xKIM for the SD related commands to work.

# Nota Bene

I've been slowly doing bug fixes but there are probably plenty more.  Since it is tiny, there is minimal error checking and little tolerance for odd errors.

Send bug reports to bob@corshamtech.com.

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
