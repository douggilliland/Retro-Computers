#ifndef CHARDEVICE_H
#define CHARDEVICE_H

#include "string.h"
#include "ringbuffer.h"

class CharDevice
{
	public:
	CharDevice(int bufsize=32) : inbuffer(bufsize), outbuffer(bufsize)
	{

	}
	~CharDevice()
	{

	}
	void PutS(const char *buf)
	{
		int l=strlen(buf);
		while(l)
		{
			int w=Write(buf,l);
			buf+=w;
			l-=w;
		}			
	}
	virtual int Write(const char *buf,int count)
	{
		int result=0;
		while(outbuffer.WriteReady() && count)
		{
			outbuffer.PutC(*buf++);
			++result;
			--count;
		}
		return(result);
	}
	virtual int Read(char *buf,int count)
	{
		int result=0;
		while(inbuffer.ReadReady() && count)
		{
			*buf++=inbuffer.GetC();
			++result;
			--count;
		}
		return(result);
	}
	protected:
	RingBuffer inbuffer;
	RingBuffer outbuffer;
};


#endif
