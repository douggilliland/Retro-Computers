#include <system.h>
#include <altera_avalon_lcd_16207_regs.h>
#include <alt_types.h>
#include <unistd.h>

void Lcd_CheckBusy();	//读液晶的忙标志位并检测
void Lcd_WriteCommand(alt_u8 com);
void Lcd_WriteData(alt_u8 data);
void Lcd_LocateXY(alt_u8 x, alt_u8 y);
void Lcd_IconAddr(alt_u8 x);
void Lcd_Icon(alt_u8 addr, alt_u8 mark);
void Lcd_Prints(alt_u8 x, alt_u8 y, alt_u8 *string);	//打印字符串
void Lcd_Init();	//液晶1602初始化
