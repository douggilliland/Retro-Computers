// A little utility to dump a binary file to the serial port.
// Copyright (c) 2012 by Alastair M. Robinson
// Released under the terms of the GNU General Public License, version 2 or later.
// See the file "COPYING" for more details.

#include <iostream>

#include <getopt.h>

#define FOpenUTF8 fopen
#define PACKAGE_STRING "SendSerial 0.0.1"

#include "rs232wrapper.h"
#include "binaryblob.h"

#include "debug.h"

class SendSerial_Options
{
	public:
	SendSerial_Options(int argc,char **argv) : serdevice("/dev/ttyUSB0")
	{
		ParseOptions(argc,argv);
	}
	void ParseOptions(int argc,char **argv)
	{
		static struct option long_options[] =
		{
			{"help",no_argument,NULL,'h'},
			{"version",no_argument,NULL,'v'},
			{"serdevice",required_argument,NULL,'s'},
			{"debug",required_argument,NULL,'d'},
			{0, 0, 0, 0}
		};

		while(1)
		{
			int c;
			c = getopt_long(argc,argv,"hvs:d:",long_options,NULL);
			if(c==-1)
				break;
			switch (c)
			{
				case 'h':
					printf("Usage: %s [options] image1 [image2] ... \n",argv[0]);
					printf("\t -h --help\t\tdisplay this message\n");
					printf("\t -v --version\t\tdisplay version\n");
					printf("\t -s --serdevice\t\tspecify device node for serial comms\n");
					printf("\t -d --debug\t\tset debug level (0 for errors only, 4 for verbose output)\n");
					throw 0;
					break;
				case 'v':
					printf("%s\n",PACKAGE_STRING);
					throw 0;
					break;
				case 's':
					serdevice=optarg;
					break;
				case 'd':
					Debug.SetLevel(DebugLevel(atoi(optarg)));
					break;
			}
		}
	}
	protected:
	std::string serdevice;
	std::string watchdir;
	bool wait;
};


class SerialStream : public SendSerial_Options, public RS232Wrapper
{
	public:
	SerialStream(int argc,char **argv) : SendSerial_Options(argc,argv), RS232Wrapper(serdevice)
	{
	}
	~SerialStream()
	{
	}
	void SendFile(const char *fn)
	{
		BinaryBlob blob(fn);
		size_t l=blob.GetSize();
		char *p=blob.GetPointer();
		Write(p,l);
	}
};


int main(int argc,char **argv)
{
	Debug.SetLevel(TRACE);

	try
	{
		SerialStream stream(argc,argv);
		for(int i=optind;i<argc;++i)
			stream.SendFile(argv[i]);
		return(0);
	}
	catch(const char *err)
	{
		Debug[ERROR] << "Error: " << err << std::endl;
	}
	catch(int rc)
	{
		return(rc);
	}
	return(0);
}

