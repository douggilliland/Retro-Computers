/***************************************************************************//**
* \file I2CS_BOOT.h
* \version 4.0
*
* \brief
*  This file provides constants and parameter values of the bootloader
*  communication APIs for the SCB Component.
*
* Note:
*
********************************************************************************
* \copyright
* Copyright 2014-2017, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_SCB_BOOT_I2CS_H)
#define CY_SCB_BOOT_I2CS_H

#include "I2CS_PVT.h"

#if (I2CS_SCB_MODE_I2C_INC)
    #include "I2CS_I2C.h"
#endif /* (I2CS_SCB_MODE_I2C_INC) */

#if (I2CS_SCB_MODE_EZI2C_INC)
    #include "I2CS_EZI2C.h"
#endif /* (I2CS_SCB_MODE_EZI2C_INC) */

#if (I2CS_SCB_MODE_SPI_INC || I2CS_SCB_MODE_UART_INC)
    #include "I2CS_SPI_UART.h"
#endif /* (I2CS_SCB_MODE_SPI_INC || I2CS_SCB_MODE_UART_INC) */


/***************************************
*  Conditional Compilation Parameters
****************************************/

/* Bootloader communication interface enable */
#define I2CS_BTLDR_COMM_ENABLED ((CYDEV_BOOTLOADER_IO_COMP == CyBtldr_I2CS) || \
                                             (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_Custom_Interface))

/* Enable I2C bootloader communication */
#if (I2CS_SCB_MODE_I2C_INC)
    #define I2CS_I2C_BTLDR_COMM_ENABLED     (I2CS_BTLDR_COMM_ENABLED && \
                                                            (I2CS_SCB_MODE_UNCONFIG_CONST_CFG || \
                                                             I2CS_I2C_SLAVE_CONST))
#else
     #define I2CS_I2C_BTLDR_COMM_ENABLED    (0u)
#endif /* (I2CS_SCB_MODE_I2C_INC) */

/* EZI2C does not support bootloader communication. Provide empty APIs */
#if (I2CS_SCB_MODE_EZI2C_INC)
    #define I2CS_EZI2C_BTLDR_COMM_ENABLED   (I2CS_BTLDR_COMM_ENABLED && \
                                                         I2CS_SCB_MODE_UNCONFIG_CONST_CFG)
#else
    #define I2CS_EZI2C_BTLDR_COMM_ENABLED   (0u)
#endif /* (I2CS_EZI2C_BTLDR_COMM_ENABLED) */

/* Enable SPI bootloader communication */
#if (I2CS_SCB_MODE_SPI_INC)
    #define I2CS_SPI_BTLDR_COMM_ENABLED     (I2CS_BTLDR_COMM_ENABLED && \
                                                            (I2CS_SCB_MODE_UNCONFIG_CONST_CFG || \
                                                             I2CS_SPI_SLAVE_CONST))
#else
        #define I2CS_SPI_BTLDR_COMM_ENABLED (0u)
#endif /* (I2CS_SPI_BTLDR_COMM_ENABLED) */

/* Enable UART bootloader communication */
#if (I2CS_SCB_MODE_UART_INC)
       #define I2CS_UART_BTLDR_COMM_ENABLED    (I2CS_BTLDR_COMM_ENABLED && \
                                                            (I2CS_SCB_MODE_UNCONFIG_CONST_CFG || \
                                                             (I2CS_UART_RX_DIRECTION && \
                                                              I2CS_UART_TX_DIRECTION)))
#else
     #define I2CS_UART_BTLDR_COMM_ENABLED   (0u)
#endif /* (I2CS_UART_BTLDR_COMM_ENABLED) */

/* Enable bootloader communication */
#define I2CS_BTLDR_COMM_MODE_ENABLED    (I2CS_I2C_BTLDR_COMM_ENABLED   || \
                                                     I2CS_SPI_BTLDR_COMM_ENABLED   || \
                                                     I2CS_EZI2C_BTLDR_COMM_ENABLED || \
                                                     I2CS_UART_BTLDR_COMM_ENABLED)


/***************************************
*        Function Prototypes
***************************************/

#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_I2C_BTLDR_COMM_ENABLED)
    /* I2C Bootloader physical layer functions */
    void I2CS_I2CCyBtldrCommStart(void);
    void I2CS_I2CCyBtldrCommStop (void);
    void I2CS_I2CCyBtldrCommReset(void);
    cystatus I2CS_I2CCyBtldrCommRead       (uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
    cystatus I2CS_I2CCyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);

    /* Map I2C specific bootloader communication APIs to SCB specific APIs */
    #if (I2CS_SCB_MODE_I2C_CONST_CFG)
        #define I2CS_CyBtldrCommStart   I2CS_I2CCyBtldrCommStart
        #define I2CS_CyBtldrCommStop    I2CS_I2CCyBtldrCommStop
        #define I2CS_CyBtldrCommReset   I2CS_I2CCyBtldrCommReset
        #define I2CS_CyBtldrCommRead    I2CS_I2CCyBtldrCommRead
        #define I2CS_CyBtldrCommWrite   I2CS_I2CCyBtldrCommWrite
    #endif /* (I2CS_SCB_MODE_I2C_CONST_CFG) */

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_I2C_BTLDR_COMM_ENABLED) */


#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_EZI2C_BTLDR_COMM_ENABLED)
    /* Bootloader physical layer functions */
    void I2CS_EzI2CCyBtldrCommStart(void);
    void I2CS_EzI2CCyBtldrCommStop (void);
    void I2CS_EzI2CCyBtldrCommReset(void);
    cystatus I2CS_EzI2CCyBtldrCommRead       (uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
    cystatus I2CS_EzI2CCyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);

    /* Map EZI2C specific bootloader communication APIs to SCB specific APIs */
    #if (I2CS_SCB_MODE_EZI2C_CONST_CFG)
        #define I2CS_CyBtldrCommStart   I2CS_EzI2CCyBtldrCommStart
        #define I2CS_CyBtldrCommStop    I2CS_EzI2CCyBtldrCommStop
        #define I2CS_CyBtldrCommReset   I2CS_EzI2CCyBtldrCommReset
        #define I2CS_CyBtldrCommRead    I2CS_EzI2CCyBtldrCommRead
        #define I2CS_CyBtldrCommWrite   I2CS_EzI2CCyBtldrCommWrite
    #endif /* (I2CS_SCB_MODE_EZI2C_CONST_CFG) */

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_EZI2C_BTLDR_COMM_ENABLED) */

#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_SPI_BTLDR_COMM_ENABLED)
    /* SPI Bootloader physical layer functions */
    void I2CS_SpiCyBtldrCommStart(void);
    void I2CS_SpiCyBtldrCommStop (void);
    void I2CS_SpiCyBtldrCommReset(void);
    cystatus I2CS_SpiCyBtldrCommRead       (uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
    cystatus I2CS_SpiCyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);

    /* Map SPI specific bootloader communication APIs to SCB specific APIs */
    #if (I2CS_SCB_MODE_SPI_CONST_CFG)
        #define I2CS_CyBtldrCommStart   I2CS_SpiCyBtldrCommStart
        #define I2CS_CyBtldrCommStop    I2CS_SpiCyBtldrCommStop
        #define I2CS_CyBtldrCommReset   I2CS_SpiCyBtldrCommReset
        #define I2CS_CyBtldrCommRead    I2CS_SpiCyBtldrCommRead
        #define I2CS_CyBtldrCommWrite   I2CS_SpiCyBtldrCommWrite
    #endif /* (I2CS_SCB_MODE_SPI_CONST_CFG) */

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_SPI_BTLDR_COMM_ENABLED) */

#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_UART_BTLDR_COMM_ENABLED)
    /* UART Bootloader physical layer functions */
    void I2CS_UartCyBtldrCommStart(void);
    void I2CS_UartCyBtldrCommStop (void);
    void I2CS_UartCyBtldrCommReset(void);
    cystatus I2CS_UartCyBtldrCommRead       (uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
    cystatus I2CS_UartCyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);

    /* Map UART specific bootloader communication APIs to SCB specific APIs */
    #if (I2CS_SCB_MODE_UART_CONST_CFG)
        #define I2CS_CyBtldrCommStart   I2CS_UartCyBtldrCommStart
        #define I2CS_CyBtldrCommStop    I2CS_UartCyBtldrCommStop
        #define I2CS_CyBtldrCommReset   I2CS_UartCyBtldrCommReset
        #define I2CS_CyBtldrCommRead    I2CS_UartCyBtldrCommRead
        #define I2CS_CyBtldrCommWrite   I2CS_UartCyBtldrCommWrite
    #endif /* (I2CS_SCB_MODE_UART_CONST_CFG) */

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_UART_BTLDR_COMM_ENABLED) */

/**
* \addtogroup group_bootloader
* @{
*/

#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_BTLDR_COMM_ENABLED)
    #if (I2CS_SCB_MODE_UNCONFIG_CONST_CFG)
        /* Bootloader physical layer functions */
        void I2CS_CyBtldrCommStart(void);
        void I2CS_CyBtldrCommStop (void);
        void I2CS_CyBtldrCommReset(void);
        cystatus I2CS_CyBtldrCommRead       (uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
        cystatus I2CS_CyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut);
    #endif /* (I2CS_SCB_MODE_UNCONFIG_CONST_CFG) */

    /* Map SCB specific bootloader communication APIs to common APIs */
    #if (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_I2CS)
        #define CyBtldrCommStart    I2CS_CyBtldrCommStart
        #define CyBtldrCommStop     I2CS_CyBtldrCommStop
        #define CyBtldrCommReset    I2CS_CyBtldrCommReset
        #define CyBtldrCommWrite    I2CS_CyBtldrCommWrite
        #define CyBtldrCommRead     I2CS_CyBtldrCommRead
    #endif /* (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_I2CS) */

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2CS_BTLDR_COMM_ENABLED) */

/** @} group_bootloader */

/***************************************
*           API Constants
***************************************/

/* Timeout unit in milliseconds */
#define I2CS_WAIT_1_MS  (1u)

/* Return number of bytes to copy into bootloader buffer */
#define I2CS_BYTES_TO_COPY(actBufSize, bufSize) \
                            ( ((uint32)(actBufSize) < (uint32)(bufSize)) ? \
                                ((uint32) (actBufSize)) : ((uint32) (bufSize)) )

/* Size of Read/Write buffers for I2C bootloader  */
#define I2CS_I2C_BTLDR_SIZEOF_READ_BUFFER   (64u)
#define I2CS_I2C_BTLDR_SIZEOF_WRITE_BUFFER  (64u)

/* Byte to byte time interval: calculated basing on current component
* data rate configuration, can be defined in project if required.
*/
#ifndef I2CS_SPI_BYTE_TO_BYTE
    #define I2CS_SPI_BYTE_TO_BYTE   (160u)
#endif

/* Byte to byte time interval: calculated basing on current component
* baud rate configuration, can be defined in the project if required.
*/
#ifndef I2CS_UART_BYTE_TO_BYTE
    #define I2CS_UART_BYTE_TO_BYTE  (2500u)
#endif /* I2CS_UART_BYTE_TO_BYTE */

#endif /* (CY_SCB_BOOT_I2CS_H) */


/* [] END OF FILE */
