/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include <project.h>
#include <Z80_PSoC_3Chips.h>


//////////////////////////////////////////////////////////////////////////////////////
// I2C Low Level Hardware access functions

//////////////////////////////////////////////////////////////////////////////////////
// uint8 readRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr) - Read MCP23017 register
//////////////////////////////////////////////////////////////////////////////////////

uint8 readRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr)
{
	uint8 rdBuff;

	I2C_MasterClearStatus();
	I2C_MasterSendStart(chipAddr,I2C_WRITE_XFER_MODE);
	I2C_MasterWriteByte(ctrlAdr);
	I2C_MasterSendStop();
	I2C_MasterSendStart(chipAddr,I2C_READ_XFER_MODE);
	rdBuff = I2C_MasterReadByte(I2C_NAK_DATA);
	I2C_MasterSendStop();
	I2C_MasterClearStatus();
	return rdBuff;

}

//////////////////////////////////////////////////////////////////////////////////////
//void writeRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr, uint8 ctrlVal) - Write
// to an MCP23017 register
//////////////////////////////////////////////////////////////////////////////////////

void writeRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr, uint8 ctrlVal)
{
	uint8 MCP23017_WrBuffer[2];
	I2C_MasterClearStatus();
	MCP23017_WrBuffer[0] = ctrlAdr;
	MCP23017_WrBuffer[1] = ctrlVal;
	I2C_MasterWriteBuf(chipAddr, MCP23017_WrBuffer, 2, I2C_MODE_COMPLETE_XFER);
	while (0u == (I2C_MasterStatus() & I2C_MSTAT_WR_CMPLT));
	I2C_MasterClearStatus();
}


/* [] END OF FILE */
