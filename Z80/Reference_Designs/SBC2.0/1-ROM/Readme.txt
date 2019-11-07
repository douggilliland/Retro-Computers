ROM MONITOR
Functions:
load a hex file record by copy-paste an Intel HEX file into the monitor screen. The function works line by line, an error only inicates the line it was presented on. 
Gxxxx:	(Go) Run starting at address xxxx
Sddd:	System boot from volume ddd. Load address is retrieved from the system
	image.
Iddd:	Format volume ddd (this does not overwrite system track)
Pddd,xxxx	Put RAM image xxxx-FFFF onto system track. xxxx is stored
Lddd:	Load system track to RAM at address xxxx-FFFF. xxxx is retrieved
Dxxxx[,yyyy]:	Dump memory contents from xxxx [to yyyy]. D by itself will dump 
		the next block of 128 bytes
Cxxxx:	Change/show memory byte at location xxxx. type new value to change, CR 
	to advance, ,(comma) to quit. Changes are instantaneous.

In more detail:
the Pddd,xxxx function copies the image from xxxx-FFFF to 8000- then writes xxxx in address BFFE-BFFF. Then 8000-BFFF (16 kByte) is copied on the system track of volume ddd. 
Pddd by itself skips the first actions and just copies 8000-BFFF onto the system track of volume ddd. When there was no valid start address in the last two bytes this image will not boot correctly. Use a startaddress to be sure.

The L and S commands work in reverse. Th system track is copied to 8000-BFFF, the load address is read from the last two bytes (BFFE-BFFF) and the image is then copied to the correct location.

The S-command will load the image (as in the L-command) push the volume number and the current IOBYTE and jump to the address given in location FFFE/FFFF.
Additionally the volume number is stored in the B' register and the IOBYTE in the C' register (alternate register set).

The D-command and the C-command work like the DDT D- and S-commands they provide a hexdump facility and a memory inspect/change function.
