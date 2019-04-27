

#include <stdio.h>
#include <alt_types.h>
#include <io.h>
#include <system.h>
#include <string.h>

#include "spi_flash.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_pio_regs.h"
#include "lcd1602.h"


 /* Private typedef -----------------------------------------------------------*/
 typedef enum {FAILED = 0, PASSED = !FAILED} TestStatus;

 /* Private define ------------------------------------------------------------*/
 #define SPI_FLASH_WriteAddress		0x000000
 #define SPI_FLASH_ReadAddress		SPI_FLASH_WriteAddress
 #define SPI_FLASH_SectorToErase	SPI_FLASH_WriteAddress
 #define W25Q128_FLASH_ID			0xEF4018
 #define BufferSize					16384
 #define BankSize					4096

 /* Private macro -------------------------------------------------------------*/
 /* Private variables ---------------------------------------------------------*/
 alt_u8 Tx_Buffer[BufferSize];
 alt_u8 Rx_Buffer[BufferSize];
 volatile TestStatus TransferStatus = FAILED;
 volatile alt_u32 FLASH_ID = 0;
 alt_u32 i;

 /*******************************************************************************
 * Function Name  : Buffercmp
 * Description    : Compares two buffers.
 * Input          : - pBuffer1, pBuffer2: buffers to be compared.
 *                : - BufferLength: buffer's length
 * Output         : None
 * Return         : PASSED: pBuffer1 identical to pBuffer2
 *                  FAILED: pBuffer1 differs from pBuffer2
 *******************************************************************************/
 TestStatus Buffercmp(alt_u8* pBuffer1, alt_u8* pBuffer2, alt_u16 BufferLength)
 {
   while (BufferLength--)
   {
     if (*pBuffer1 != *pBuffer2)
     {
       return FAILED;
     }

     pBuffer1++;
     pBuffer2++;
   }

   return PASSED;
 }


 /*******************************************************************************
  * Function Name  : Main
  * Description    :
  * Input          :
  * Output         :
  * Return         :
  *******************************************************************************/
int main(void)
{
  alt_u8 j;

  IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, 0xF);

  /* Print the Header */
  printf( "\nTest SPI FLASH.\n");

  SPI_FLASH_INIT();
  Lcd_Init();

  //清除特殊符号的显示*****************
  Lcd_WriteCommand(0x2c); //re=1,2c
  for(j=0; j<16; j++)
  {
	 Lcd_Icon(j,0x00);
	 usleep(1);
  }

  //显示特殊符号****************************
  Lcd_Icon(13, 0xff);		//13,是信封图标，可以查给的图片，0xff中，低5位控制图标，
  Lcd_Icon(0, 0xff);		//信封图标只有一个，天线图标5位控制天线+4格信号
  //******************************************
  Lcd_WriteCommand(0x2a);	//显示正常字符，re=0,2a

  /* Get SPI Flash ID */
  FLASH_ID = SPI_FLASH_ReadID();
  /* Check the SPI Flash ID */
  if (FLASH_ID == W25Q128_FLASH_ID)
  {
    printf( "\nGet SPI FLASH ID Successful.\n");
  }
  else
  {
	printf( "\nGet SPI FLASH ID Failed.\n");
  }

  for(i=0; i<BufferSize; i++)
  {
  	Tx_Buffer[i] = i;
  	Rx_Buffer[i] = 0;
  }

  /* Perform a write in the Flash followed by a read of the written data */
  for(i=0; i<BufferSize/BankSize; i++)
  {
	/* Erase SPI FLASH Sector to write on */
  	SPI_FLASH_SectorErase(SPI_FLASH_SectorToErase + i*BankSize);

    /* Write Tx_Buffer data to SPI FLASH memory */
    SPI_FLASH_BufferWrite(Tx_Buffer + i*BankSize, SPI_FLASH_WriteAddress + i*BankSize, BankSize);

    /* Read data from SPI FLASH memory */
    SPI_FLASH_BufferRead(Rx_Buffer + i*BankSize, SPI_FLASH_ReadAddress + i*BankSize, BankSize);
  }

  /* Check the corectness of written dada */
  TransferStatus = Buffercmp(Tx_Buffer, Rx_Buffer, BankSize);
  /* TransferStatus = PASSED, if the transmitted and received data by SPI are the same */
  /* TransferStatus = FAILED, if the transmitted and received data by SPI are different */

  if(TransferStatus == PASSED)
  {
    printf( "\nTransferStatus = PASSED.\n");
    IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, 0xA);
	Lcd_Prints(0, 0, "Espire_I V2.00");
	Lcd_Prints(0, 1, "SPI_Flash OK!");
  }
  else
  {
    printf( "\nTransferStatus = FAILED.\n");
    IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, 0xe);
	Lcd_Prints(0, 0, "Espire_I V2.00");
	Lcd_Prints(0, 1, "SPI_Flash ERROR!");
  }

  while (1)
  {
  }

  return (0);
}

