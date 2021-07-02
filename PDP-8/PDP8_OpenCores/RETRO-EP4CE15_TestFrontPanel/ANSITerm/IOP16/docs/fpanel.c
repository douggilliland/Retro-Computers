#define MCP23017_IODIRA_REGADR   0x00
#define MCP23017_IODIRB_REGADR   0x01
#define MCP23017_IPOLA_REGADR    0x02
#define MCP23017_IPOLB_REGADR    0x03
#define MCP23017_GPINTENA_REGADR 0x04
#define MCP23017_GPINTENB_REGADR 0x05
#define MCP23017_DEFVALA_REGADR  0x06
#define MCP23017_DEFVALB_REGADR  0x07
#define MCP23017_INTCONA_REGADR  0x08
#define MCP23017_INTCONB_REGADR  0x09
#define MCP23017_IOCONA_REGADR   0x0a
#define MCP23017_IOCONB_REGADR   0x0b
#define MCP23017_GPPUA_REGADR    0x0c
#define MCP23017_GPPUB_REGADR    0x0d
#define MCP23017_INTFA_REGADR    0x0e
#define MCP23017_INTFB_REGADR    0x0f
#define MCP23017_INTCAPA_REGADR  0x10
#define MCP23017_INTCAPB_REGADR  0x11
#define MCP23017_GPIOA_REGADR    0x12
#define MCP23017_GPIOB_REGADR    0x13
#define MCP23017_OLATA_REGADR    0x14
#define MCP23017_OLATB_REGADR    0x15

#define MCP23017_IODIR_DEFVAL    0xff       // Initially set all channels to inputs
#define MCP23017_IODIR_ALL_INS   0xff
#define MCP23017_IODIR_ALL_OUTS  0x00

#define MCP23017_IPOL_INVERT     0xFF       // Input polarity = invert jumpers
#define MCP23017_GPINTEN_DISABLE 0x00       // Disable GPIO for interrupt on change
#define MCP23017_GPINTEN_ENABLE  0xFF       // Enable GPIO for interrupt on change
#define MCP23017_DEFVALA_DEFVAL  0x00       // Default vales of interrupt state
#define MCP23017_INTCON_DEFVAL   0xFF       // Int for different from default value
#define MCP23017_INTCON_PREVPIN  0x00       // Int for change from previous pin
#define MCP23017_IOCON_DEFVAL    0x04       // Disable sequential,  active-low
#define MCP23017_GPPU_DISABLE    0x00       // Disable pull-ups
#define MCP23017_GPPU_ENABLE     0xFF       // Enable pull-ups

#define MCP23017_0  0x24    // Base address of the first MCP23017 (status/control bits)
#define MCP23017_1  0x25    // Base address of the second MCP23017 (address bus a8-a15)
#define MCP23017_2  0x26    // Base address of the third MCP23017 (address bus a0-a7)
#define MCP23017_3  0x27    // Base address of the fourth MCP23017 (data bus d0-d7)

unsigned long chipAddr;
unsigned long regAdr;
unsigned long regVal;

// 0x24

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);
// IO: Port A is switches = inputs
chipAddr = MCP23017_0;
regAdr = MCP23017_IODIRA_REGADR;
regVal = MCP23017_IODIR_ALL_INS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);
// IO: Port B is LEDs = outputs
chipAddr = MCP23017_0;
regAdr = MCP23017_IODIRB_REGADR;
regVal = MCP23017_IODIR_ALL_OUTS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);
// IP: Invert input pins on Port A
chipAddr = MCP23017_0;
regAdr = MCP23017_IPOLA_REGADR;
regVal = MCP23017_IPOL_INVERT;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);
// GPINT: Enable interrupts for switches
chipAddr = MCP23017_0;
regAdr = MCP23017_GPINTENA_REGADR;
regVal = MCP23017_GPINTEN_ENABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE);
// GPINT: Disable interrupts for LED outputs
chipAddr = MCP23017_0;
regAdr = MCP23017_GPINTENB_REGADR;
regVal = MCP23017_GPINTEN_DISABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,MCP23017_DEFVALA_DEFVAL);
// Default value for pin (interrupt)
chipAddr = MCP23017_0;
regAdr = MCP23017_DEFVALA_REGADR;
regVal = MCP23017_DEFVALA_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_PREVPIN);
// Int for change from default value
chipAddr = MCP23017_0;
regAdr = MCP23017_INTCONA_REGADR;
regVal = MCP23017_INTCON_PREVPIN;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      
chipAddr = MCP23017_0;
regAdr = MCP23017_IOCONA_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);
// Int for change from previous pin
chipAddr = MCP23017_0;
regAdr = MCP23017_IOCONB_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);
// Pull-up to switches
chipAddr = MCP23017_0;
regAdr = MCP23017_GPPUA_REGADR;
regVal = MCP23017_GPPU_ENABLE;
writeRegister_MCP23017();

// readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);
// Clears interrupt
chipAddr = MCP23017_0;
regAdr = MCP23017_GPPUA_REGADR;
readRegister_MCP23017();

// 0x25

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);
// IO: Port A is switches = inputs
chipAddr = MCP23017_1;
regAdr = MCP23017_IODIRA_REGADR;
regVal = MCP23017_IODIR_ALL_INS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);
// IO: Port B is LEDs = outputs
chipAddr = MCP23017_1;
regAdr = MCP23017_IODIRB_REGADR;
regVal = MCP23017_IODIR_ALL_OUTS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);
// IP: Invert input pins on Port A
chipAddr = MCP23017_1;
regAdr = MCP23017_IPOLA_REGADR;
regVal = MCP23017_IPOL_INVERT;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);
// GPINT: Enable interrupts for switches
chipAddr = MCP23017_1;
regAdr = MCP23017_GPINTENA_REGADR;
regVal = MCP23017_GPINTEN_ENABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE);
// GPINT: Disable interrupts for LED outputs
chipAddr = MCP23017_1;
regAdr = MCP23017_GPINTENB_REGADR;
regVal = MCP23017_GPINTEN_DISABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,MCP23017_DEFVALA_DEFVAL);
// Default value for pin (interrupt)
chipAddr = MCP23017_1;
regAdr = MCP23017_DEFVALA_REGADR;
regVal = MCP23017_DEFVALA_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_PREVPIN);
// Int for change from default value
chipAddr = MCP23017_1;
regAdr = MCP23017_INTCONA_REGADR;
regVal = MCP23017_INTCON_PREVPIN;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      
chipAddr = MCP23017_1;
regAdr = MCP23017_IOCONA_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);
// Int for change from previous pin
chipAddr = MCP23017_1;
regAdr = MCP23017_IOCONB_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);
// Pull-up to switches
chipAddr = MCP23017_1;
regAdr = MCP23017_GPPUA_REGADR;
regVal = MCP23017_GPPU_ENABLE;
writeRegister_MCP23017();

// readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);
// Clears interrupt
chipAddr = MCP23017_1;
regAdr = MCP23017_GPPUA_REGADR;
readRegister_MCP23017();

// 0x26

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);
// IO: Port A is switches = inputs
chipAddr = MCP23017_2;
regAdr = MCP23017_IODIRA_REGADR;
regVal = MCP23017_IODIR_ALL_INS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);
// IO: Port B is LEDs = outputs
chipAddr = MCP23017_2;
regAdr = MCP23017_IODIRB_REGADR;
regVal = MCP23017_IODIR_ALL_OUTS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);
// IP: Invert input pins on Port A
chipAddr = MCP23017_2;
regAdr = MCP23017_IPOLA_REGADR;
regVal = MCP23017_IPOL_INVERT;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);
// GPINT: Enable interrupts for switches
chipAddr = MCP23017_2;
regAdr = MCP23017_GPINTENA_REGADR;
regVal = MCP23017_GPINTEN_ENABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE);
// GPINT: Disable interrupts for LED outputs
chipAddr = MCP23017_2;
regAdr = MCP23017_GPINTENB_REGADR;
regVal = MCP23017_GPINTEN_DISABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,MCP23017_DEFVALA_DEFVAL);
// Default value for pin (interrupt)
chipAddr = MCP23017_2;
regAdr = MCP23017_DEFVALA_REGADR;
regVal = MCP23017_DEFVALA_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_PREVPIN);
// Int for change from default value
chipAddr = MCP23017_2;
regAdr = MCP23017_INTCONA_REGADR;
regVal = MCP23017_INTCON_PREVPIN;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      
chipAddr = MCP23017_2;
regAdr = MCP23017_IOCONA_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);
// Int for change from previous pin
chipAddr = MCP23017_2;
regAdr = MCP23017_IOCONB_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);
// Pull-up to switches
chipAddr = MCP23017_2;
regAdr = MCP23017_GPPUA_REGADR;
regVal = MCP23017_GPPU_ENABLE;
writeRegister_MCP23017();

// readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);
// Clears interrupt
chipAddr = MCP23017_2;
regAdr = MCP23017_GPPUA_REGADR;
readRegister_MCP23017();

// 0x27

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);
// IO: Port A is switches = inputs
chipAddr = MCP23017_3;
regAdr = MCP23017_IODIRA_REGADR;
regVal = MCP23017_IODIR_ALL_INS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);
// IO: Port B is LEDs = outputs
chipAddr = MCP23017_3;
regAdr = MCP23017_IODIRB_REGADR;
regVal = MCP23017_IODIR_ALL_OUTS;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);
// IP: Invert input pins on Port A
chipAddr = MCP23017_3;
regAdr = MCP23017_IPOLA_REGADR;
regVal = MCP23017_IPOL_INVERT;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);
// GPINT: Enable interrupts for switches
chipAddr = MCP23017_3;
regAdr = MCP23017_GPINTENA_REGADR;
regVal = MCP23017_GPINTEN_ENABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE);
// GPINT: Disable interrupts for LED outputs
chipAddr = MCP23017_3;
regAdr = MCP23017_GPINTENB_REGADR;
regVal = MCP23017_GPINTEN_DISABLE;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,MCP23017_DEFVALA_DEFVAL);
// Default value for pin (interrupt)
chipAddr = MCP23017_3;
regAdr = MCP23017_DEFVALA_REGADR;
regVal = MCP23017_DEFVALA_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_PREVPIN);
// Int for change from default value
chipAddr = MCP23017_3;
regAdr = MCP23017_INTCONA_REGADR;
regVal = MCP23017_INTCON_PREVPIN;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      
chipAddr = MCP23017_3;
regAdr = MCP23017_IOCONA_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);
// Int for change from previous pin
chipAddr = MCP23017_3;
regAdr = MCP23017_IOCONB_REGADR;
regVal = MCP23017_IOCON_DEFVAL;
writeRegister_MCP23017();

// writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);
// Pull-up to switches
chipAddr = MCP23017_3;
regAdr = MCP23017_GPPUA_REGADR;
regVal = MCP23017_GPPU_ENABLE;
writeRegister_MCP23017();

// readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);
// Clears interrupt
chipAddr = MCP23017_3;
regAdr = MCP23017_GPPUA_REGADR;
readRegister_MCP23017();
