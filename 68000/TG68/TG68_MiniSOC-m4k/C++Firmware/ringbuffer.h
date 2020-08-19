#ifndef RINGBUFFER_H
#define RINGBUFFER_H

#include "stdlib.h"

class RingBuffer
{
	public:
	RingBuffer(int size=32) : buf(0)
	{
		in=0;
		out=0;
		int s=1;
		while(s<size)
			s<<=1;
		buf=(char *)malloc(s);	// Buffer size should be a power of 2...
		this->size=s-1;	// ... while size should be that power of 2, minus 1, so we can use it as a mask.
	}
	virtual ~RingBuffer()
	{
		if(buf)
			free(buf);
	}
	inline char operator[](unsigned int idx)
	{
		return(*(buf+idx));
	}
	inline bool WriteReady()
	{
		return(out!=((in+1)&size));
	}
	virtual void PutC(unsigned char c)
	{
		while(!WriteReady())
		{
			// FIXME yield here - for now we'll just busy wait.
		}
		buf[in]=c;
		in=(in+1) & size;
	}
	inline int ReadReady()
	{
		return((in-out) & size);	// Return the number of bytes in the buffer
	}
	virtual char GetC()
	{
		while(!ReadReady())
		{
			// FIXME yield here - for now we'll just busy wait.
		}
		char c;
		c=buf[out];
		out=(out+1) & size;
		return(c);
	}
	protected:
	char *buf;
	int size;
	int in;
	int out;
};

#endif

