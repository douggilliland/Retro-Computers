
#include "lcd1602.h"

int main (void) __attribute__ ((weak, alias ("alt_main")));     //将程序的入口改为alt_main()，可以使
                                                                //很多驱动不会加载，可以大大减小代码长度
void alt_main()
{
    alt_u8 i;

    Lcd_Init();

	//清除特殊符号的显示*****************
	Lcd_WriteCommand(0x2c); //re=1,2c
	for(i=0; i<16; i++)
	{
		Lcd_Icon(i,0x00);
		usleep(1);
	}

	//显示特殊符号****************************
	Lcd_Icon(13, 0xff);		//13,是信封图标，可以查给的图片，0xff中，低5位控制图标，
	Lcd_Icon(0, 0xff);		//信封图标只有一个，天线图标5位控制天线+4格信号
	//******************************************
	Lcd_WriteCommand(0x2a);	//显示正常字符，re=0,2a

	//以下是字符串显示
	Lcd_Prints(0, 0, "Hello World!");
	Lcd_Prints(0, 1, "Espire_I V2.00");

	while(1);
}
