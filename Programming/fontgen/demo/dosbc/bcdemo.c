
#include <graphics.h>
#include <conio.h>  

#include "../../lib/demofont.h"

static void my_draw_pixel(int x, int y, int color)
{
	if(color == 0)
	{
		color = GREEN;
	}
	else
	{
		color = RED;
	}

	putpixel(x, y, color);
}

int main(void )
{
   int graphdriver = DETECT, graphmode;
   initgraph(&graphdriver, &graphmode, "C:\\BORLANDC\\BGI");

   InstallFont(my_draw_pixel);
   TestDrawText();

   getch();

   closegraph();
   return 0;
}

