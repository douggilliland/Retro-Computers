# C02-Pocket-SBC
A Pocket-sized 65C02 SBC with SCC2691 UART/USB console

This is small 4-layer PCB that is 3.8" x 2.5" in size.
  ExpressPCB was used for the schematic and PCB layout.
  
  Boards were acquired via their Miniboard Pro service.
  
Atmel Wincupl was used to create the files needed to program the ATF22V10CQZ.

WDC Tools was used to assemble and link all of assembler source files.

C02BIOS and C02Monitor are separate source files.

  C02BIOS provides a JMP table and access to the hardware.
    SCC2691 UART provides Console via USB/Serial.
    16-bit timer for RTC and accurate software delays.
    
  C02Monitor provides a JMP table for core functions accessible from other progams.
    A rich set of monitor features/functions are included.
    * see source code for details.

An updated C02 BIOS and Monitor version 2.04 has been added.
    Added code to support CMOS version of Enhanced Basic
    Added Xmodem-CRC entry points for access by Enhanced Basic

Enhanced Basic version 2.22p4C added
    Based on Lee Davison's original 2.22 code with fixes by Klaus Dorman (2.22p4)
    CMOS update only runs on a CMOS version 65C02
    Shorter code base plus some performance enhancements and less page zero usage
    LOAD/SAVE supported functions linking to C02 Monitor 2.04
