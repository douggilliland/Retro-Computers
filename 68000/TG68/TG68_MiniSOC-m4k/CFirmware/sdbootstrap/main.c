#include "minisoc_hardware.h"
#include "textbuffer.h"
#include "spi.h"
#include "fat.h"

extern DIRENTRY DirEntry[MAXDIRENTRIES];
extern unsigned char sort_table[MAXDIRENTRIES];
extern unsigned char nDirEntries;
extern unsigned char iSelectedEntry;
extern unsigned long iCurrentDirectory;
extern char DirEntryLFN[MAXDIRENTRIES][261];
char DirEntryInfo[MAXDIRENTRIES][5]; // disk number info of dir entries
char DiskInfo[5]; // disk number info of selected entry

// print directory contents
void PrintDirectory(void)
{
	unsigned char i;
	unsigned char k;
	unsigned long len;
	char *lfn;
	char *info;
	char *p;
	unsigned char j;

	for (i = 0; i < 8; i++)
	{
		k = sort_table[i]; // ordered index in storage buffer
		lfn = DirEntryLFN[k]; // long file name pointer
		if (lfn[0]) // item has long name
		{
			puts(lfn);
		}
		else  // no LFN
		{
			puts(&DirEntry[k].Name);
		}

		if (DirEntry[k].Attributes & ATTR_DIRECTORY) // mark directory with suffix
			puts("<DIR>\n");
		else
			puts("\n");
	}
}


void c_entry()
{
	fileTYPE file;
	ClearTextBuffer();

	puts("Initialising SD card\n");
	spi_init();

	FindDrive();

	ChangeDirectory(DIRECTORY_ROOT);
	ScanDirectory(SCAN_INIT, "*", 0);
	PrintDirectory();

	if(FileOpen(&file,"TEST    IMG"))
	{
		short imgsize=file.size/512;
		int c=0;
		while(c<=((640*960*2-1)/512) && c<imgsize)
		{
//			FileRead(&file, fbptr);
//			c+=1;
//			FileNextSector(&file);
//			fbptr+=512;
		}
	}
	else
		printf("Couldn't load test.img\n");

	while(1)
	{
	}
}

