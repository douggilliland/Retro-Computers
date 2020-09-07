#ifndef SOUNDHW_H
#define SOUNDHW_H


struct SoundChannel
{
	char *DAT;	// 0-3
	unsigned short LEN;	// 4-5
	short TRIGGER; // 6-7
	short PERIOD;	// 8-9
	short VOL;	// 10-11
	long pad1; // 12-15
};	// 16 bytes long

#define REG_SOUNDCHANNEL ((volatile struct SoundChannel *)0x82000000)

#endif
