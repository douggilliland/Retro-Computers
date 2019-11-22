#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/fb.h>
#include <errno.h>
#include <string.h>

#include "../lib/demofont.h"

static int g_xres = 0;
static int g_yres = 0;
static int g_bits_per_pixel = 0;
unsigned char* g_vedio_mem = NULL;

int fb = 0; 

static void deinit(void)
{
	close(fb);
	munmap(g_vedio_mem, 0);
}

static void init(void)
{
	struct fb_var_screeninfo var_screeninfo; 
	struct fb_fix_screeninfo fix_screeninfo; 
	long int screensize = 0; 
	
	fb = open("/dev/fb0", O_RDWR); 
	if(fb < 0)
	{
		printf("open /dev/fb0 failed.\n");
		exit(1);
	}
	
	ioctl(fb, FBIOGET_FSCREENINFO, &fix_screeninfo); 
	ioctl(fb, FBIOGET_VSCREENINFO, &var_screeninfo); 
	
	g_xres = var_screeninfo.xres;
	g_yres = var_screeninfo.yres;
	g_bits_per_pixel = 1;//var_screeninfo.bits_per_pixel;
	
	screensize = ((g_xres * g_bits_per_pixel) / 8) * g_yres; 
	int pagesize = getpagesize();

	screensize += pagesize - screensize % (pagesize);

	g_vedio_mem = (unsigned char*) mmap (0, 65536, PROT_READ|PROT_WRITE, MAP_SHARED, fb, 0);

	if((int)g_vedio_mem == (-1))
	{
		printf("errno=%d\n", errno);
		perror("mmap");
	}
	
	int n = 0;
	while(1)
	{
		int c = 0;
		if(read(fb, &c, 1) <= 0)
		{
			printf("n = %d\n", n);
			break;
		}
		else
		{
			n++;
		}
			
	}
	return;
}

static void my_draw_pixel(int x, int y, int color)
{
	if(x >= g_xres || y >= g_yres)
	{
		return;
	}

	
	unsigned char* mem = g_vedio_mem + x * y * g_bits_per_pixel / 8;
	unsigned char offset = x * y * g_bits_per_pixel % 8;

	switch(g_bits_per_pixel)
	{
		case 1:
		case 4:
			{
				*mem = (*mem & (0xF0 >> offset)) | ((unsigned char)color & 0x0F);
				break;
			}
		case 8:
			{
				*mem = (char)color;
				break;
			}
		case 16:
			{
				*(unsigned short*)mem = (unsigned short)color;
				break;
			}
		case 32:
			{
				*(unsigned long*)mem = (unsigned long)color;
				break;
			}
		default:
			{
				printf("not supported format.");
			}
	}

	return;
}

int main() 
{ 
	init();	

#if 0
	memset(g_vedio_mem+320, 0xFF, 640);
#else
	for(int x = 0; x < 640; x++)
	{
		for(int  y = 0; y < 10; y++)
		{
			my_draw_pixel(x, y, 1);
		}
	}
#endif
	getchar();

	deinit();
	return 0;
}
