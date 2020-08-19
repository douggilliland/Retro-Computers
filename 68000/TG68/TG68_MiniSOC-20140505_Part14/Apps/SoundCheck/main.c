#include "uart.h"
#include "soundhw.h"

char *soundbuffer=0x100000;

int main(int argc, char **argv)
{
	int i;
	puts("Sound check\n");

	for(i=0;i<255;++i)
	{
		soundbuffer[i]=i;
	}

	REG_SOUNDCHANNEL[0].DAT=soundbuffer;
	REG_SOUNDCHANNEL[0].LEN=256;
	REG_SOUNDCHANNEL[0].VOL=63;
	REG_SOUNDCHANNEL[0].PERIOD=200;
	REG_SOUNDCHANNEL[0].TRIGGER=0;

	REG_SOUNDCHANNEL[1].DAT=soundbuffer;
	REG_SOUNDCHANNEL[1].LEN=256;
	REG_SOUNDCHANNEL[1].VOL=63;
	REG_SOUNDCHANNEL[1].PERIOD=199;
	REG_SOUNDCHANNEL[1].TRIGGER=0;

	return(0);
}

