
Name: ptb2hex.c


Description:

The macro11 assembler outputs in a paper-tape-binary format and my simulation environment requires the program data to be in Intel hex format. I wrote this program to convert the macro11 output to Intel hex format.


Example command line:

ptb2hex -i t1.obj -o t1.hex


Compiling:

gcc ptb2hex.c -o ptb2hex


