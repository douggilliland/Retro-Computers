/* ========================================
*
* Copyright Land Boards, LLC, 2019.
* All Rights Reserved
* UNPUBLISHED, LICENSED SOFTWARE.
*
* CONFIDENTIAL AND PROPRIETARY INFORMATION
* WHICH IS THE PROPERTY OF LAND BOARDS. LLC.
*
* ========================================
*/

#include <project.h>
#include <Z80_PSoC_3Chips.h>

//////////////////////////////////////////////////////////////////////////////
// Front Panel Handler
// Starts at CPU address = 0
//////////////////////////////////////////////////////////////////////////////

// Global variables
uint8 FPData;       // Data that is on the Front Panel (bottom 8 LEDs)
uint16 FPAddr;      // Address that is on the Front Panel (middle 16 lEDs)
uint8 FPCtrl;       // Control that is on the Front Panel (top 8 LEDs)
uint32 FPLong;      // Long value of the Front Panel
uint32 LEDsVal;         // Front Panel LEDs - copy here

//////////////////////////////////////////////////////////////////////////////
// init_FrontPanel() - Switches are on Port A, LEDs are on Port B

void init_FrontPanel(void)
{
	uint8 chipAddr;
	for (chipAddr = 0x24; chipAddr < 0x28; chipAddr++)
	{
		writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);     // IO: Port A is switches = inputs
		writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);    // IO: Port B is LEDs = outputs
		writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);        // IP: Invert input pins on Port A
		writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);  // GPINT: Enable interrupts for switches
		writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE); // GPINT: Disable interrupts for LED outputs
		writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,MCP23017_DEFVALA_DEFVAL);   // Default value for pin (interrupt)
		writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_DEFVAL);    // Int for change from default value
		writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      
        // BANK: Register addresses are in the same bank (addresses are sequential)
		// MIRROR: Int pins not connected (they are externally connected together on the Front Panel board)
		// SEQOP: Enable sequential operation (although the driver doesn't use it)
		// HAEN: (Not used on MCP23017)
		// ODR: Open Drain output (over-rides INTPOL)
		// INTPOL: Over-ridden by ODR
		writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);      // Int for change from previous pin
		writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);        // Pull-up to switches
		readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
	}
	FPData = 0;
	FPAddr = 0;
	FPCtrl = 0;
	FPLong = 0;
}

//////////////////////////////////////////////////////////////////////////////
// FrontPanelZ80Read() - Read the Front Panel switches to the Z80

void FrontPanelZ80Read(uint8 portSelect)
{
	uint32 fpVal = readFrontPanelSwitchesStatic();
	uint8 fpByte;
	switch (portSelect & 0x3)
	{
	case 0:
		fpByte = ((uint8) fpVal) & 0xff;
		break;
	case 1:
		fpByte = ((uint8) (fpVal>>8)) & 0xff;
		break;
	case 2:
		fpByte = ((uint8) (fpVal>>16)) & 0xff;
		break;
	case 3:
		fpByte = ((uint8) (fpVal>>24)) & 0xff;
		break;
	default:
		fpByte = 0;
	}
	Z80_Data_In_Write(fpByte);
	ackIO();
}

//////////////////////////////////////////////////////////////////////////////
// FrontPanelZ80Read() - Write to the Front Panel LEDs from the Z80

void FrontPanelZ80Write(uint8 portSelect)
{
	uint32 outVal = Z80_Data_Out_Read();
	switch (portSelect & 0x3)
	{
	case 0:
		LEDsVal = ((LEDsVal & 0xffffff00) | outVal);
		break;
	case 1:
		LEDsVal = ((LEDsVal & 0xffff00ff) | (outVal<<8));
		break;
	case 2:
		LEDsVal = ((LEDsVal & 0xff00ffff) | (outVal<<16));
		break;
	case 3:
		LEDsVal = ((LEDsVal & 0x00ffffff) | (outVal<<24));
		break;
	}
	writeFrontPanelLEDs(LEDsVal);
	ackIO();
}

//////////////////////////////////////////////////////////////////////////////////////
// runFrontPanel()
// Returns when run button is pressed on front panel
// Return value 0 = Z80 is left in reset
//              1 = Z80 is out of reset

uint8 runFrontPanel(void)
{
	uint32 switchesVal = 0;

	LEDsVal = 0;
	
	//    I2C_Start();
	init_FrontPanel();
	// Bounce LEDs
	for (LEDsVal = 1; LEDsVal != 0; LEDsVal <<= 1)
	{
		writeFrontPanelLEDs(LEDsVal);
		CyDelay(50);
	}
	LEDsVal |= ReadExtSRAM(0);
	writeFrontPanelLEDs(LEDsVal);       // clears LEDs
	for(;;)                     // Loop forever
	{
		switchesVal = waitFrontPanelSwitchesPressed();
		if ((switchesVal & 0xff000000) != 0)    // Control switch on top row was pressed
		{
			if ((switchesVal & 0x01000000) == 0x01000000)       // Incr address and read memory
			{
				LEDsVal |= 0x01000000;          // Flicker INCAD LED
				writeFrontPanelLEDs(LEDsVal);
				LEDsVal += 0x00000100;
				LEDsVal &= 0x00ffff00;
				LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
				writeFrontPanelLEDs(LEDsVal);
			}
			else if ((switchesVal & 0x02000000) == 0x02000000)  // Store to addr, incr address and read memory
			{
				LEDsVal |= 0x02000000;          // Flicker STINC LED
				writeFrontPanelLEDs(LEDsVal);
				WriteExtSRAM((LEDsVal >> 8) & 0xffff,LEDsVal&0xff);
				LEDsVal += 0x00000100;
				LEDsVal &= 0x00ffff00;
				LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
				writeFrontPanelLEDs(LEDsVal);
			}
			else if ((switchesVal & 0x04000000) == 0x04000000)  //Load address and read memory
			{
				LEDsVal |= 0x04000000;          // Flicker LDADR LED
				writeFrontPanelLEDs(LEDsVal);
				LEDsVal &= 0x00ffff00;
				LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
				writeFrontPanelLEDs(LEDsVal);
			}
			else if ((switchesVal & 0x08000000) == 0x08000000)  // Run program
			{
				ExtSRAMCtl_Control = 0;
				LEDsVal = 0x08000000;
				writeFrontPanelLEDs(LEDsVal);       // Leave Run LED on
				return (1);
			}
			else if ((switchesVal & 0x10000000) == 0x10000000)  // TBD
			{
				LEDsVal = 0x10000000;
				writeFrontPanelLEDs(LEDsVal);       // Leave LED on
				CyDelay(250);
				LEDsVal &= 0x00ffffff;
				writeFrontPanelLEDs(LEDsVal);       // Turn off LED
			}
			else if ((switchesVal & 0x20000000) == 0x20000000)  // TBD
			{
				LEDsVal = 0x20000000;
				writeFrontPanelLEDs(LEDsVal);       // Leave LED on
				CyDelay(250);
				LEDsVal &= 0x00ffffff;
				writeFrontPanelLEDs(LEDsVal);       // Turn off LED
			}
			else if ((switchesVal & 0x40000000) == 0x40000000)  // TBD
			{
				LEDsVal = 0x40000000;
				writeFrontPanelLEDs(LEDsVal);       // Leave LED on
				CyDelay(250);
				LEDsVal &= 0x00ffffff;
				writeFrontPanelLEDs(LEDsVal);       // Turn off LED
			}
			else if ((switchesVal & 0x80000000) == 0x80000000)  // Exit front panel without releasing reset to Z80
			{
				LEDsVal = 0x80000000;
				writeFrontPanelLEDs(LEDsVal);       // Leave LED on
				return(0);                          // Z80 still in reset
			}
		}
		else    // Non-control switch was pressed
		{
			LEDsVal ^= switchesVal;
			writeFrontPanelLEDs(LEDsVal);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////
// readFrontPanelSwitchesRegistered
//  Handler for the Pushbuttons and LEDs
//  Toggles the LED
//  Reads all four MCP23017 Port A's to make a 32-bit result
//  Looks for the switch to be pressed for 3 samples in a row
// Returns: 0 if there was no key pressed
//          1 if there was a key pressed

uint32 readFrontPanelSwitchesRegistered(void)
{
	uint32 rdVal;
	uint32 retVal = 0;
	uint32 valMin1 = 0;
	uint32 valMin2 = 0;
	uint32 valMin3 = 0;
	uint8 keyPressed = 0;
	rdVal = readFrontPanelSwitchesStatic();
	if (rdVal  == 0x00)     // No key is pressed at this polling
	{
		valMin1 = 0;
		valMin2 = 0;
		valMin3 = 0;
		return(0);
	}
	else    // key is now pressed
	{
		keyPressed = 1;
		while (keyPressed)  // stick around until key is no longer pressed
		{
			rdVal = readFrontPanelSwitchesStatic();
			if (rdVal == 0)
			{
				keyPressed = 0;
				valMin1 = 0;
				valMin2 = 0;
				valMin3 = 0;
				return(retVal);
			}
			valMin3 = valMin2;
			valMin2 = valMin1;
			valMin1 = rdVal;
			if ((valMin3 == 0) && (valMin2 != 0) && (valMin1 != 0) && (rdVal != 0))
			{
				return(valMin2);
			}
			CyDelay(10);    // 10 mS sampling for debouncing
		}
	}
	return (retVal);
}

//////////////////////////////////////////////////////////////////////////////////////
// waitFrontPanelSwitchesPressed() - Wait for switch to be pressed and return value

uint32 waitFrontPanelSwitchesPressed(void)
{
	uint32 switchVals = 0;
	while (readFrontPanelSwitchesRegistered() != 0);    // wait for previous key release
	while (switchVals == 0)
	{   
		switchVals = readFrontPanelSwitchesRegistered();
		if (switchVals != 0x0)
		return (switchVals);
	}
	return (0);
}

//////////////////////////////////////////////////////////////////////////////////////
// readFrontPanelSwitchesStatic() - Reads the current value of the actual switches
//  Reads all four MCP23017 Port A's to make a 32-bit result

uint32 readFrontPanelSwitchesStatic(void)
{
	uint32 switchVals = 0;
	switchVals = readRegister_MCP23017(MCP23017_0,MCP23017_GPIOA_REGADR);
	readRegister_MCP23017(MCP23017_0,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
	switchVals = switchVals<<8;
	switchVals |= readRegister_MCP23017(MCP23017_1,MCP23017_GPIOA_REGADR);
	readRegister_MCP23017(MCP23017_1,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
	switchVals = switchVals<<8;
	switchVals |= readRegister_MCP23017(MCP23017_2,MCP23017_GPIOA_REGADR);
  	readRegister_MCP23017(MCP23017_2,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
	switchVals = switchVals<<8;
	switchVals |= readRegister_MCP23017(MCP23017_3,MCP23017_GPIOA_REGADR);
    readRegister_MCP23017(MCP23017_3,MCP23017_INTCAPA_REGADR);                            // Clears interrupt

	return (switchVals);
}

//////////////////////////////////////////////////////////////////////////////////////
// writeFrontPanelLEDs(uint32) - Write a 32-bit value to the Front Panel LEDs

void writeFrontPanelLEDs(uint32 ledsVal)
{
	writeRegister_MCP23017(MCP23017_0,MCP23017_OLATB_REGADR,((ledsVal>>24) & 0xff));
	writeRegister_MCP23017(MCP23017_1,MCP23017_OLATB_REGADR,((ledsVal>>16) & 0xff));
	writeRegister_MCP23017(MCP23017_2,MCP23017_OLATB_REGADR,((ledsVal>>8) & 0xff));
	writeRegister_MCP23017(MCP23017_3,MCP23017_OLATB_REGADR,ledsVal&0xff);
}

//////////////////////////////////////////////////////////////////////////////////////
// I2C Low Level Hardware access functions

//////////////////////////////////////////////////////////////////////////////////////
//
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
//
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
