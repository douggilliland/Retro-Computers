/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF LAND BOARDS, LLC.
 *
 * ========================================
*/

#include "ExtSRAM.h"
#include "FrontPanel.h"
#include "Hardware_Config.h"
#include "SDCard.h"
#include "Z80_6850_2_Emul.h"
#include "Z80_6850_Emul.h"
#include "Z80_IO_Handle.h"
#include "Z80_Mem_Mappers.h"
#include "Z80_PIO_emul.h"
#include "Z80_SDCard_Emul.h"
#include "Z80_SIO_emul.h"
#include "Z80_RTC.h"
#include "Z80_DAC.h"

////////////////////////////////////////////////////////////////////////////
// externs for the EPROM images - Only 1 image is actually used

extern unsigned char monitor_basic_eprom[];
extern unsigned char gs7chip_basic_eeprom[];
extern const unsigned char gs_fpga_basic_eeprom[];
extern const unsigned char multi_boot_eprom[];

////////////////////////////////////////////////////////////////////////////
// externs for the Front Panel

extern uint32 fpIntVal;
extern uint8 pioAIntVals;
extern uint8 pioBIntVals;

////////////////////////////////////////////////////////////////////////////
// Function prototypes for Z80_PSoC_3Chips.c file

void PostLed(uint32);
void putStringToUSB(char *);
void I2CIntISR(void);

/* [] END OF FILE */
