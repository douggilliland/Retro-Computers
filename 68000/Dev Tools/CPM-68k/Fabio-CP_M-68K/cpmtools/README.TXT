In this folder there is the "diskdefs" file for the cpmtools or cpmtoolsGUI utilities to access 
to virtual disk files (.DSK) using a PC to add, extract or delete files inside a virtual disk.

I suggest to use the cpmtoolsGUI (only for Windows) because is very easy.
You can download it (english version) from:

http://star.gmobb.jp/koji/cgi/wiki.cgi?action=ATTACH&page=CpmtoolsGUI&file=CPMTG20190501%2Ezip

Then unzip it into a folder and put the diskdefs file in the same folder.



For CP/M-68K:

select "68kMBC-D0-15" for any disk (disk 0 - 15);


Remember that virtual disks filenames are "DSyNxx.DSK", where "xx" is the disk number 
(00 = A:, 01 = B:, 02 = C:, etc.), and "y" is the Disk Set (0 = CP/M-68K).

NOTE: do not create new virtual disk files with cpmtools
because further processing is required for a valid virtual disk file.
