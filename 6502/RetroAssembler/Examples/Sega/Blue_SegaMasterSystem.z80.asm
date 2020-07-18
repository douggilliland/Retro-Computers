/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Blue Background
*
* Target: Sega Master System
*
* This sample shows how to create a basic framework for a this Sega console.
*
* The code is clean, without any trickery for easy understanding.
*
****************************************************************************/

                    .target "z80"

                    .format "sms"                       //Sega Master System
                    .setting "SMSCountryCode", 4        //USA (Export)
                    .setting "SMSProductCode", 0        //A product code
                    .setting "SMSVersion", 0            //Version number


VDPControlPort      = $bf
VDPDataPort         = $be
VRAMWrite           = $4000
CRAMWrite           = $c000


                    //The CPU executes the cartridge code at $0000 upon booting up.

                    .org $0000

Reset               di              //Disable interrupts.
                    im 1            //Select Interrupt Mode 1.
                    jp Start        //Jump to the actual start address of our code.


                    //Non-Maskable Interrupt for the pressing of the Pause button.

                    .org $0066

PauseNMI            retn            //Dummy, handle it properly if necessary.


                    //The actual start address of our code.
                    //Could be right at $0067 but it's nicer at $0100...

                    .org $0100

Start               ld sp,$dff0     //Set up the stack pointer (almost) to the top of the RAM.


                    //Initialize the Video Display Processor with some acceptable values...

                    ld hl,VDP_Data      //Data bytes for the Video Display Processor initialization.
                    ld b,$12            //The number of VDP_Data bytes.
                    ld c,VDPControlPort //Choose the VDP Control Port ($bf)
                    otir                //Transfer the selected data bytes into the chosen Port.


                    //Clear the 16KB VRAM (Video RAM) to remove junk residue after a cold boot...

                    //Set VRAM write address to 0 by outputting $4000 into Port $bf
                    ld a,<VRAMWrite
                    out (VDPControlPort),a
                    ld a,>VRAMWrite
                    out (VDPControlPort),a

                    ld bc,$4000         //Counter for 16KB of VRAM ($4000 bytes)
                    ld a,$00            //Value to put into each of the VRAM's bytes.
@ClearVRAM          out (VDPDataPort),a //Output to VRAM, into the current VRAM memory address.
                    dec c               //Decrease C and B until they are both $00.
                    jp nz,@ClearVRAM
                    dec b
                    jp nz,@ClearVRAM


                    //Set up our custom color palette values...

                    //Set VRAM write address to CRAM's Palette Index 0 by outputting $c000 into Port $bf
                    ld a,<CRAMWrite
                    out (VDPControlPort),a
                    ld a,>CRAMWrite
                    out (VDPControlPort),a

                    ld hl,Palette_Data  //Data bytes for the Color Palette to set our custom colors.
                    ld b,2              //The number of Palette_Data bytes.
                    ld c,VDPDataPort    //Choose the VDP Data Port ($be)
                    otir                //Transfer the selected data bytes into the chosen Port.


                    //Turn on the screen by writing this bit field into VDP Register 1.

                    ld a,%01000000      //Turn on the screen, VBlank interrupts disabled etc.
                    out (VDPControlPort),a
                    ld a,$81
                    out (VDPControlPort),a

                    //Now the screen is on, empty with Blue background color.
                    jp *


                    //Data bytes for the display.

VDP_Data            .byte $04, $80, $00, $81, $ff, $82, $ff, $85
                    .byte $ff, $86, $ff, $87, $00, $88, $00, $89
                    .byte $ff, $8a

Palette_Data        .byte %11_10_00     //B-G-R values for Blue
                    .byte %11_11_11     //B-G-R values for White
                    .byte %00_00_00     //B-G-R values for Black
