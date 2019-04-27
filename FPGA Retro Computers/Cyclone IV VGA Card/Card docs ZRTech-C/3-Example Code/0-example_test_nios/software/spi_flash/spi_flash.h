
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __SPI_FLASH_H
#define __SPI_FLASH_H

/* Includes ------------------------------------------------------------------*/
#include <alt_types.h>
#include <altera_avalon_spi.h>
#include <system.h>
#include <altera_avalon_spi_regs.h>

/* Exported types ------------------------------------------------------------*/
/* Exported constants --------------------------------------------------------*/


/* Exported functions ------------------------------------------------------- */
/*----- High layer function -----*/
void SPI_FLASH_Init(void);
void SPI_FLASH_SectorErase(alt_u32 SectorAddr);
void SPI_FLASH_BulkErase(void);
void SPI_FLASH_PageWrite(alt_u8* pBuffer, alt_u32 WriteAddr, alt_u16 NumByteToWrite);
void SPI_FLASH_BufferWrite(alt_u8* pBuffer, alt_u32 WriteAddr, alt_u16 NumByteToWrite);
void SPI_FLASH_BufferRead(alt_u8* pBuffer, alt_u32 ReadAddr, alt_u16 NumByteToRead);
alt_u32 SPI_FLASH_ReadID(void);
void SPI_FLASH_StartReadSequence(alt_u32 ReadAddr);

/*----- Low layer function -----*/
alt_u8 SPI_FLASH_SendByte(alt_u8 byte);
void SPI_FLASH_WriteEnable(void);
void SPI_FLASH_WaitForWriteEnd(void);
void SPI_FLASH_CS_LOW(void);
void SPI_FLASH_CS_HIGH(void);
void SPI_FLASH_INIT(void);

#endif /* __SPI_FLASH_H */

