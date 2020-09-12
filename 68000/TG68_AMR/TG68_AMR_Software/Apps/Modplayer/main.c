#include "uart.h"
#include "soundhw.h"

#include "fat.h"
#include "small_printf.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "replay.h"

fileTYPE *file;

static struct stat statbuf;


char *LoadFile(const char *filename)
{
	char *result=0;
	int fd=open(filename,0,O_RDONLY);
	printf("open() returned %d\n",fd);
	if((fd>0)&&!fstat(fd,&statbuf))
	{
		int n;
		printf("File size is %d\n",statbuf.st_size);
		result=(char *)malloc(statbuf.st_size);
		if(result)
		{
			if(read(fd,result,statbuf.st_size)<0)
			{
				printf("Read failed\n");
				free(result);
				result=0;
			}
		}
	}
	return(result);
}


int main(int argc, char **argv)
{
	char *ptr;
	if((ptr=LoadFile("SCARPTCHMOD")))
	{
		printf("File successfully loaded to %d\n",ptr);
		ptBuddyPlay(ptr,0);
//		REG_SOUNDCHANNEL[0].VOL=63;
//		REG_SOUNDCHANNEL[0].PERIOD=200;
//		REG_SOUNDCHANNEL[0].DAT=ptr;
//		REG_SOUNDCHANNEL[0].LEN=statbuf.st_size/2;
//		REG_SOUNDCHANNEL[0].TRIGGER=0;
	}
	else
		printf("Loading failedn\n");
	return(0);
}

