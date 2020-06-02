/*
			DISKTRAN

	This is a utility to convert nonstandard disk sector
interleave patterns to the standard (i.e., CP/M 1-to-6 weave) 
or vice versa.  The first two tracks are not included in the 
copy.

*/

#include "bdscio.h"

#define MCOS 4	/* MCOS skew factor */
#define CPM 6	/* Standard CP/M skew factor */

main()
{
	char buffer[26*SECSIZ];	/* Track buffer */

	int toskew,fromskew;
	int track,sector;
	int index;

	char answer;

	puts("\t\tDISKTRAN\n\n");
	puts("A: Convert MCOS to CP/M\n\n");
	puts("B: Convert CP/M to MCOS\n");
	puts("\nEnter choice: ");
	while((answer=toupper(getchar()))!='A'&&answer!='B'){
		puts("\nPlease enter A or B\n");
		puts("Enter choice: ");
		}
	if(answer=='A'){
		toskew=CPM;
		fromskew=MCOS;
		}
	else{
		toskew=MCOS;
		fromskew=CPM;
		}

	puts("\n\nInsert source disk in drive A\n");
	puts("and destination disk in drive B, then hit a key\n");

	while(!kbhit());
		getchar();

	for(track=2;track<77;track++)
		{
		printf("Track %d\n",track);
		bios(SELECT_DISK,0);
		bios(SET_TRACK,track);
		sector=1;
		for(index=0;index<26;index++)
			{
			bios(SET_SECTOR,sector);
			bios(SET_DMA,&buffer[SECSIZ*index]);
			bios(READ_SECTOR);
			sector+=fromskew;
			if(sector>26)sector-=26;
			if(sector==1)sector=2;
			}
		bios(SELECT_DISK,1);
		sector=1;
		for(index=0;index<26;index++){
			bios(SET_SECTOR,sector);
			bios(SET_DMA,&buffer[SECSIZ*index]);
			bios(WRITE_SECTOR);
			sector+=toskew;
			if(sector>26)sector-=26;
			if(sector==1)sector=2;
			}
		}

	puts("Translation done\n");
	puts("Place system disk in drive A, and hit any key\n");
	while(!kbhit());
		getchar();
}
