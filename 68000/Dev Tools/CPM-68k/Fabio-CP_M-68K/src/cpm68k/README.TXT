In this folder the file CPM400.SR is the "patched" CPM400.SR s-record file (CCP+BDOS) needed to build the complete cpm68.bin system file.
The patch just change the "hard-wired" address of _init at $6200 (instead of $6000, so the BIOS can start outside the .BSS area...).
To build the cpm68.bin you have to do the following steps:

1: Copy the CPM400.SR file to a new file (cpm68.sr);
2: Assemble the provided BIOS source;
3: Append the content of the assembled BIOS in the S-record format (.S68) to the cpm68.sr file;
4: Convert the resulting cpm68.sr file to binary using the EASyBIN utility. Rename the binary file as cpm68.bin




NOTE: 

The resulting cpm68.sr file can also be loaded using the sLoad utility (for testing).



CREDITS:

https://hackaday.io/project/28504-reverse-engineering-soneplex-spx-mpu-sbc/log/71892-port-cpm-68k-to-mpu302-part-1
https://github.com/dwildie/cpm-68k
http://s100computers.com/Software%20Folder/CPM68K/CPM68K%20Software.htm


