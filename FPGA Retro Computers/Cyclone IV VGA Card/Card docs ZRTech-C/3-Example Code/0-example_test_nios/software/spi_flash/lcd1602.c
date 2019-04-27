#include "lcd1602.h"

void Lcd_CheckBusy()		//读液晶的忙标志位并检测
{
    alt_u8 status=0xff;
    do
    {
        status=IORD_ALTERA_AVALON_LCD_16207_STATUS(LCD_BASE);
        usleep(1);
    }while(status&0x80);
}

void Lcd_WriteCommand(alt_u8 com)
{
	Lcd_CheckBusy();
    IOWR_ALTERA_AVALON_LCD_16207_COMMAND(LCD_BASE, com);
    usleep(1);
    IOWR_ALTERA_AVALON_LCD_16207_COMMAND(LCD_BASE, com<<4);
    usleep(1);
}

void Lcd_WriteData(alt_u8 data)
{
	Lcd_CheckBusy();
	IOWR_ALTERA_AVALON_LCD_16207_DATA(LCD_BASE, data);
    usleep(1);
    IOWR_ALTERA_AVALON_LCD_16207_DATA(LCD_BASE, data<<4);
    usleep(1);
}

//设置字符显示区域的显示位置 re必须为0
void Lcd_LocateXY(alt_u8 x, alt_u8 y)
{
	alt_u8 temp = 0;

	if(y == 0) temp = 0x80 + x;
	if(y == 1) temp = 0x90 + x;
	if(y == 2) temp = 0xc0 + x;

	Lcd_WriteCommand(temp);
}

void Lcd_IconAddr(alt_u8 x)
{
	alt_u8 temp = 0;
	temp = 0x40 + x;
	Lcd_WriteCommand(temp);
}

//设置特殊图标显示区域的显示位置 re必须为1
void Lcd_Icon(alt_u8 addr, alt_u8 mark)
{
	Lcd_IconAddr(addr);
	Lcd_WriteData(mark);
}

void DisplayOneChar(alt_u8 x, alt_u8 y, alt_u8 data)
{
	Lcd_LocateXY(x, y);
	Lcd_WriteData(data);
}

void Lcd_Prints(alt_u8 x, alt_u8 y, alt_u8 *string)		//打印字符串
{
	Lcd_LocateXY(x, y);

	while(*string)
	{
		Lcd_WriteData(*string);
		string++;
	}
}

void Lcd_Init()			//液晶1602初始化
{
	Lcd_WriteCommand(0x22);
	Lcd_WriteCommand(0x2c); //re=1,2c
	Lcd_WriteCommand(0x07);
	Lcd_WriteCommand(0x08);
	Lcd_WriteCommand(0x28); //re=0,28
	Lcd_WriteCommand(0x0c);
	Lcd_WriteCommand(0x07);
}
