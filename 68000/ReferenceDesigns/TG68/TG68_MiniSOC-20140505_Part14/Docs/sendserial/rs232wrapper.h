#ifndef RS232WRAPPER_H
#define RS232WRAPPER_H

#include <string>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "debug.h"

class RS232Wrapper
{
	public:
	RS232Wrapper(const std::string dev="/dev/ttyS0",int baud=115200, bool startbit=true)
		: fd(-1), device(dev), baud(baud), startbit(startbit), buffer(NULL), buffered(0), cursor(0), buffersize(64)
	{
		if(dev.length())
			InitSerial();
	}
	~RS232Wrapper()
	{
		if(buffer)
			delete[] buffer;
		if(fd>-1)
		{
			tcsetattr(fd,TCSANOW,&oldtio); // Restore port settings
			close(fd);
		}
	}
	void Reconnect()
	{
		if(fd>-1)
			close(fd);
		InitSerial();
	}

	void Read()
	{
		if(fd<0)
			throw "Serial device not opened";
		Shuffle();
		if(buffersize-buffered)
		{
//			Debug[TRACE] << "Asking for " << buffersize-buffered << " bytes" << std::endl;
			ssize_t r=read(fd,buffer+buffered,buffersize-buffered);
			if(r<=0)
				throw "RS232 read error";

			buffered+=r;
		}
//		Debug[TRACE] << "Buffer contains " << buffered << " bytes - " << buffer << std::endl;
	}

	void Write(char c)
	{
		if(fd<0)
			throw "Serial device not opened";
		Debug[TRACE] << "RS232: Sending " << c << std::endl;
		int l=write(fd,&c,1);
		if(l<0)
			throw "RS232 write error";
	}

	void Write(const char *c)
	{
		Debug[TRACE] << "RS232: Sending " << c << std::endl;
		Write(c,strlen(c));
	}

	void Write(const char *c,int l)
	{
		if(fd<0)
			throw "Serial device not opened";
		int w=0;
		while(w<l)
		{
			int t=write(fd,c+w,l-w);
			if(t<0)
				throw "RS232 write error";
			w+=t;
		}
	}

	char NextChar()
	{
		if(cursor<buffered)
			return(buffer[cursor++]);
		else
			return(0);
	}
	bool Ready()
	{
		return(cursor<buffered);
	}
	int GetFD()
	{
		return(fd);
	}
	protected:
	void InitSerial()
	{
		Debug[TRACE] << "Attempting to open serial device " << device << std::endl;
		fd = open(device.c_str(), O_RDWR | O_NOCTTY | O_NONBLOCK); // Work around hang with devices that don't bother with DCD
		if (fd <0)
		{
			perror(device.c_str());
			throw "Can't open serial device";
		}

		Debug[TRACE] << "Saving old port settings" << std::endl;
		tcgetattr(fd,&oldtio); /* save current port settings */

		memset(&newtio, 0,sizeof(newtio));
//		newtio.c_cflag = B9600 | CRTSCTS | CS8 | CLOCAL | CREAD;
//		newtio.c_iflag = IGNPAR;
//		newtio.c_oflag = IGNPAR;
		cfmakeraw(&newtio);
		switch(baud)
		{
			case 9600:
				cfsetspeed(&newtio,B9600);
				break;
			case 19200:
				cfsetspeed(&newtio,B19200);
				break;
			case 38400:
				cfsetspeed(&newtio,B38400);
				break;
			case 115200:
				cfsetspeed(&newtio,B115200);
				break;
			case 460800:
				cfsetspeed(&newtio,B460800);
				break;
			default:
				throw "Baud rate not yet supported";
				break;
		}
		newtio.c_cflag |= CREAD | CLOCAL;
		newtio.c_iflag |= IGNPAR | IGNBRK;
		newtio.c_oflag |= IGNPAR | IGNBRK;
		newtio.c_oflag &= ~(OPOST | ONLCR);
		if(startbit)
			newtio.c_cflag |= CS8 | CREAD;
		/* set input mode (non-canonical, no echo,...) */
		newtio.c_lflag = 0;

		newtio.c_cc[VTIME]    = 0;   /* inter-character timer unused */
		newtio.c_cc[VMIN]     = 1;   /* blocking read until 1 char received */

		newtio.c_cc[VINTR]='C'-'@';
		newtio.c_cc[VQUIT]=CQUIT;
		newtio.c_cc[VERASE]=CERASE;
		newtio.c_cc[VEOF]=CEOF;
		newtio.c_cc[VKILL]=CKILL;
		newtio.c_cc[VDISCARD]=CDISCARD;
		newtio.c_cc[VREPRINT]=CREPRINT;
		newtio.c_cc[VWERASE]=CWERASE;
		newtio.c_cc[VLNEXT]=CLNEXT;
		newtio.c_cc[VLNEXT]=CLNEXT;
		newtio.c_cc[VSTART]=CSTART;
		newtio.c_cc[VSTOP]=CSTOP;
		newtio.c_cc[VSUSP]=CSUSP;


		Debug[TRACE] << "Applying new port settings" << std::endl;
		tcflush(fd, TCIFLUSH);
		tcsetattr(fd,TCSANOW,&newtio);

		Debug[TRACE] << "Reopening port" << std::endl;
		close(fd); // Now open again in blocking mode...
		fd = open(device.c_str(), O_RDWR | O_NOCTTY);
		if (fd <0)
		{
			perror(device.c_str());
			throw "Can't open serial device";
		}
		Debug[TRACE] << "Setting parameters a second time" << std::endl;
		tcflush(fd, TCIFLUSH);
		tcsetattr(fd,TCSANOW,&newtio);

		buffer=new char[64];
	}
	void Shuffle()
	{
		if(cursor)
		{
			for(int i=cursor; i<buffered; ++i)
			{
				buffer[i-cursor]=buffer[i];
			}
			buffered-=cursor;
			cursor=0;
		}
		else
			buffered=0;
	}

	int fd;
	std::string device;
	struct termios oldtio,newtio;
	int baud;
	int startbit;
	char *buffer;
	int buffered;
	int cursor;
	int buffersize;
};

#endif

