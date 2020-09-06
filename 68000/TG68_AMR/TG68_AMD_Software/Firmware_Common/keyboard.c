#include "keyboard.h"
#include "ps2.h"
#include "textbuffer.h"
#include "ints.h"

// FIXME - create another ring buffer for ASCII keystrokes

unsigned char kblookup[2][128] =
{
	{
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,'\t',0,0,
	0,0,0,0,0,'q','1',0,
	0,0,'z','s','a','w','2',0,
	0,'c','x','d','e','4','3',0,
	0,' ','v','f','t','r','5',0,
	0,'n','b','h','g','y','6',0,
	0,0,'m','j','u','7','8',0,
	0,',','k','i','o','0','9',0,
	0,'.','/','l',';','p','-',0,
	0,0,'\'',0,'[','=',0,0,
	0,0,'\n',']',0,'#',0,0,
	0,0,0,0,0,0,'\b',0,
	0,'1',0,'4','7',0,0,0,
	'0','.','2','5','6','8',27,0,
	0,'+','3',0,'*','9',0,0
	},
	{
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,8,0,0,
	0,0,0,0,0,'Q','!',0,
	0,0,'Z','S','A','W','"',0,
	0,'C','X','D','E','$','£',0,
	0,' ','V','F','T','R','%',0,
	0,'N','B','H','G','Y','^',0,
	0,0,'M','J','U','&','*',0,
	0,'<','K','I','O',')','(',0,
	0,'>','?','L',':','P','_',0,
	0,0,'?',0,'{','+',0,0,
	0,0,'\n','}',0,'~',0,0,
	0,0,0,0,0,0,9,0,
	0,'1',0,'4','7',0,0,0,
	'0','.','2','5','6','8',27,0,
	0,'+','3',0,'*','9',0,0
	},
};

unsigned char keytable[256]={0};

#define QUAL_SHIFT 0

static short qualifiers=0;
static short leds=0;
static short fkeys=0;

char HandlePS2RawCodes()
{
	char result=0;
	static short keyup=0;
	static short extkey=0;
	short updateleds=0;
	short key;
	while((key=PS2KeyboardRead())>-1)
	{
		if(key==KEY_KEYUP)
			keyup=1;
		else if(key==KEY_EXT)
			extkey=1;
		else
		{
//			if(key<128)
//			{
				short keyidx=extkey ? 128+key : key;
				if(keyup)
					keytable[keyidx]&=0xfe;  // Mask off the "currently pressed" bit.
				else
					keytable[keyidx]=3;	// Currently pressed and pressed since last test.
//			}
			if(keyup==0)
			{
				char a=0;
				if(key<128)
				{
					a=kblookup[ (leds & 4) ? qualifiers | 1 : qualifiers][key];
					if(a)
						return(a);
				}
				extkey=0;
				switch(key)
				{
					case 0x58:	// Caps lock
						leds^=0x04;
						updateleds=1;
						break;
					case 0x7e:	// Scroll lock
						leds^=0x01;
						updateleds=1;
						break;
					case 0x77:	// Num lock
						leds^=0x02;
						updateleds=1;
						break;
					case 0x12:
					case 0x59:
						qualifiers|=(1<<QUAL_SHIFT);
						break;
				}
			}
			else
			{
				switch(key)
				{
					case 0x12:
					case 0x59:
						qualifiers&=~(1<<QUAL_SHIFT);
						break;
				}
			}
			keyup=0;
		}
	}
	if(updateleds)
	{
		PS2KeyboardWrite(0xed);
		PS2KeyboardWrite(leds);
	}
	return(result);
}


void ClearKeyboard()
{
	int i;
	for(i=0;i<256;++i)
		keytable[i]=0;
}

short TestKey(short rawcode)
{
	short result;
	DisableInterrupts();	// Make sure a new character doesn't arrive halfway through the read
	result=keytable[rawcode];
	keytable[rawcode]&=0xfd;	// Mask off the "pressed since last test" bit.
	EnableInterrupts();
	return(result);
}

