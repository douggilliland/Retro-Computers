# Ohio-C1P_UK101_Archive
UK101 - Ohio C1P archive

Initial entry is a 6502 memory test program:

I have been running Doug's UK101 with 40k ram and Cegmon. I wanted to test the memory test program I found described here: http://archive.6502.org/…/high_speed_memory_test_for_6502.p… I assembled it using an online assembler here: https://www.masswerk.at/6502/assembler.html To transfer the code to the UK101 I loaded the output into a text editor, did a global search and replace 'space' to '\r' and added the head '.0000/' and tail '.0002G' manually so it can be loaded and run using the ascii loader command 'L' I found the Cegmon manual here: http://uk101.sourceforge.net/docs/pdf/cegmon.pdf
