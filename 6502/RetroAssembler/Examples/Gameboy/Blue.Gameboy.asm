/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Blue Background
*
* Target: Nintendo Gameboy Color
*
* This sample shows how to create a basic framework for a Gameboy ROM.
*
* The code is clean, without any trickery for easy understanding.
*
****************************************************************************/

                    //Use the Gameboy CPU.
                    .target "Gameboy"

                    //Build a Gameboy ROM file with header and banks.
                    .format "gb"

                    //Gameboy ROM setup with cartridge type and flags.
                    .setting "GameboyStart", Start  //Could use Start label
                    .setting "GameboyTitle", "Blue Test"
                    .setting "GameboyLicenseeCode", "ED"
                    .setting "GameboyCartridgeRamKB", 0
                    .setting "GameboyCartridgeBattery", false
                    .setting "GameboyCartridgeRumble", false
                    .setting "GameboyRomVersion", 1
                    .setting "GameboyMonochromeEnabled", true
                    .setting "GameboyColorEnabled", true
                    .setting "GameboySuperGBEnabled", false


                    //Bank 0 is a 16KB bank mapped to $0000.
                    .bank 0, 16, $0000

                    //Or it could be like...
                    //Bank 0 is a 32KB bank for a Small ROM.
                    //.bank 0, 32, $0000


                    //-----------------------------------------------------------------------------
                    // Set up various RST and Interrupt vectors on the zero page.
                    //-----------------------------------------------------------------------------

                    .org $0000

                    //Little hack: $ff is the opcode of "RST $38",
                    //so all the RST instructions will just jump to
                    //the vector for "RST $38".
                    .storage $38, $ff

                    //Vector for RST $38
                    *= $38
                    jp Start

                    *= $40
                    jp Interrupt_VBlank

                    *= $48
                    jp Interrupt_LCD

                    *= $50
                    jp Interrupt_Timer

                    *= $58
                    jp Interrupt_Serial

                    *= $60
                    jp Interrupt_Joypad



                    //-----------------------------------------------------------------------------
                    // The main program starts here...
                    //-----------------------------------------------------------------------------

                    .org $0150

Start               di              //Disable all interrupts
                    ld hl,$d000     //Set up the Stack
                    ld sp,hl

                    ld a,$80        //Choose Background Palette 0 (Gameboy Color)
                    ld ($ff68),a    //and set up auto-increment mode for the color entry.

                    ld a,$00        //Enter a 16 bit value for a nice Blue color
                    ld ($ff69),a    //that will be set for Color 0 in this palette,
                    ld a,$7c        //the background uses this color by default.
                    ld ($ff69),a

HaltCPU             halt            //Halt the CPU, only interrupts would wake it up.
                    jp HaltCPU      //Just in case.


                    //-----------------------------------------------------------------------------
                    // Interrupt handlers to implement...
                    //-----------------------------------------------------------------------------

Interrupt_VBlank    ret

Interrupt_LCD       ret

Interrupt_Timer     ret

Interrupt_Serial    ret

Interrupt_Joypad    ret


                    //-----------------------------------------------------------------------------
                    // Additional memory banks, mapped to $4000
                    //-----------------------------------------------------------------------------

                    //Bank 1 is a 16KB bank mapped to $4000.
                    .bank 1, 16, $4000

                    //It must have at least one Segment where code and data goes into.
                    .segment "SomeData"

                    //Just to have something in here...
                    .byte "Put code and data into this bank..."

                    //Other banks outside the 32 KB Small ROM type.

                    //Bank 2 is a 16KB bank mapped to $4000.
                    //.bank 2, 16, $4000
                    //.segment "My stuff in Bank 2"

                    //Bank 3 is a 16KB bank mapped to $4000.
                    //.bank 3, 16, $4000
                    //.segment "My stuff in Bank 3"
