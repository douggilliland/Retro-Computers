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
// externs for the EPROM image - Only 1 image is actually used
// All images have the same variable name

extern const unsigned char Z80_eeprom[];

////////////////////////////////////////////////////////////////////////////
// externs for the Front Panel

#ifdef USING_FRONT_PANEL
extern uint32 fpIntVal;
#endif

#ifdef USING_EXP_MCCP23017
extern uint8 pioAIntVals;
extern uint8 pioBIntVals;
#endif

////////////////////////////////////////////////////////////////////////////
// Function prototypes for Z80_PSoC_3Chips.c file

void PostLed(uint32);
void putStringToUSB(char *);
void I2CIntISR(void);

/* [] END OF FILE */
