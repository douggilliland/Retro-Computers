
#include <stdarg.h>

int putchar(int c);

#ifndef DISABLE_PRINTF

static char temp[80];

static int
_cvt(int val, char *buf, int radix)
{
#ifdef PRINTF_HEX_ONLY
	int c;
	int i;
	int nz=0;
	if(val<0)
	{
		putchar('-');
		val=-val;
	}
	if(val)
	{
		for(i=0;i<8;++i)
		{
			c=(val>>28)&0xf;
			val<<=4;
			if(c)
				nz=1;	// Non-zero?  Start printing then.
			if(c>9)
				c+='A'-10;
			else
				c+='0';
			if(nz)	// If we've encountered only zeroes so far we don't print.
				putchar(c);
		}
	}
	else
		putchar('0');
	return(0);
#else
    char *cp = temp;
	const char *digits="0123456789ABCDEF";
    int length = 0;

	if(val<0)
	{
		putchar('-');
		val=-val;
	}
    if (val == 0) {
        /* Special case */
        *cp++ = '0';
    } else {
        while (val) {
			unsigned int c;
			c=val%radix;
            *cp++ = digits[c];
            val /= radix;
        }
    }
    while (cp != temp) {
        *buf++ = *--cp;
        length++;
    }
    *buf = '\0';
    return (length);
#endif
}

#define is_digit(c) ((c >= '0') && (c <= '9'))


static char vpfbuf[sizeof(long long)*8];

static int
_vprintf(const char *fmt, va_list ap)
{
    unsigned int c;
	int sign;
	int *s2;
	char *cp=vpfbuf;
    int left_prec, right_prec, zero_fill, pad, pad_on_right, 
        i, islong, islonglong;
    unsigned int val = 0;
    int res = 0, length = 0;
	int nextfmt;

	// Because we haven't implemented loadb from ROM yet, we can't use *<char*>++.
	// We work around this by reading 32 bits at a time and shift/masking the bytes
	// individually.
	// This is only necessary if using the hardware implementation of the
	// loadb/storeb instructions and running from BlockRAM.  Loadb/storeb from external
	// RAM is implemented.

	s2=(int*)fmt;
	nextfmt=0;
	do
	{
		int i;
		int cs=*s2++;
		for(i=0;i<4;++i)
		{
			char tmp[2];
			c=(cs>>24)&0xff;
			cs<<=8;
			if(c==0)
				return(res);

			if(nextfmt) // Have we encountered a %?
			{
				nextfmt=0;
		        left_prec = right_prec = pad_on_right = islong = islonglong = 0;
		        sign = '\0';
		        // Fetch value [numeric descriptors only]
		        switch (c) {
				    case 'd':
			            val = (long)va_arg(ap, unsigned int);
				        break;
				    default:
				        break;
		        }
		        // Process output
		        switch (c) {
				    case 'd':
				        length = _cvt(val, vpfbuf, 10);
				        break;
					    cp = vpfbuf;
					    break;
				    case 's':
				        cp = va_arg(ap, char *);
						puts(cp);
				        length = 0;
				        break;
				    case 'c':
				        c = va_arg(ap, int /*char*/);
				        putchar(c);
				        res++;
				        continue;
				    default:
				        putchar('%');
				        putchar(c);
				        res += 2;
				        continue;
		        }
		        while (length-- > 0) {
		            c = *cp++;
		            putchar(c);
		            res++;
		        }
		    }
			else
			{
			    if (c == '%')
					nextfmt=1;
				else
				{
			        putchar(c);
			        res++;
				}
			}
        }
    } while(c);
}


int
small_printf(const char *fmt, ...)
{
    va_list ap;
    int ret;

    va_start(ap, fmt);
    ret = _vprintf(fmt, ap);
    va_end(ap);
    return (ret);
}
#endif

