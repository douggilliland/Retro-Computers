REM	Do not use "-c -f00" switches when assembling applications to be launched
REM	by the ROM BIOS or ROM Monitor because the apps do not contain ".END" to limit
REM	the zeroing out function.
REM	tasm -80 -x -g3   test.asm
REM
REM	Default machine language file is .obj. Add "test.bin" to end of command line if you prefer .bin instead of .obj
REM
REM
REM
	tasm -80 -x -g3 -c -f00   test.asm

PAUSE
