/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Blue Background
*
* Target: Nintendo Entertainment System
*
* This sample shows how to create a basic framework for a NES ROM
* with PRG (program) and CHR (graphics) memory banks.
*
* The code is clean, without any trickery for easy understanding.
*
****************************************************************************/

                    //Use the 6502 CPU.
                    .target "6502"


                    //Build a NES ROM file with header and banks.
                    .format "nes"

                    //NES ROM setup with cartridge type and flags.
                    .setting "NESMapper", $00
                    .setting "NESSubMapper", $00
                    .setting "NESVerticalMirroring", false
                    .setting "NESBatteryBackedWRAM", false
                    .setting "NESFourScreenMode", false
                    .setting "NESPlayChoice10", false
                    .setting "NESVsUnisystem", false
                    .setting "NESPal", false
                    .setting "NESNtsc", true
                    .setting "NESByte10", $00
                    .setting "NESByte11", $00
                    .setting "NESByte13", $00
                    .setting "NESByte14", $00


                    //Reconfigure the default Bank 0 to be 16KB, mapped at $c000
                    //Label it as "PRG0" for the NES ROM builder, as this will be
                    //the first PRG bank in the NES ROM file.
                    .bank 0, 16, $c000, "NES_PRG0"

                    //Use the already created Code segment in Bank 0.
                    .code

                    //Set the start address for code entry to $c000
                    .org $c000

Start               sei             //Disable interrupts
                    cld             //Disable decimal mode
                    ldx #$40
                    stx $4017       //Disable APU frame IRQ

                    ldx #$ff
                    txs             //Set up the stack pointer to $ff

                    lda #$00
                    sta $2000       //Disable NMI
                    sta $2001       //Disable rendering
                    sta $4010       //Disable DMC IRQs

                    //First wait for vblank to make sure the PPU is ready.
@VBlankWait1        bit $2002
                    bpl @VBlankWait1

                    //Clear the 2KB internal RAM of the NES.
                    ldx #$00
@ClearRAM           lda #$00
                    sta $0000,x
                    sta $0100,x
                    sta $0200,x
                    sta $0400,x
                    sta $0500,x
                    sta $0600,x
                    sta $0700,x
                    lda #$fe
                    sta $0300,x
                    inx
                    bne @ClearRAM

                    //Second wait for vblank, PPU is ready after this.
@VBlankWait2        bit $2002
                    bpl @VBlankWait2


                    //Set the background color to Blue.
                    lda #%10000000
                    sta $2001

                    //Infinite loop...
                    jmp *


                    //-----------------------------------------------------------------------------
                    // Interrupt handlers to implement.
                    //-----------------------------------------------------------------------------

                    //Handle NMI here, then return with RTI
NMI                 rti

                    //Handle IRQ here, then return with RTI
IRQ                 rti


                    //-----------------------------------------------------------------------------
                    // Location of Interrupt vectors.
                    //-----------------------------------------------------------------------------

                    //We are still in Bank 0, mapped at $c000. Make a gap up to $fffa
                    .org $fffa

                    //NMI vector (Non-Maskable Interrupt)
                    //When an NMI happens (once per frame if enabled),
                    //the processor will jump to this memory address.
                    .word NMI

                    //Reset vector
                    //When the processor first turns on or is reset,
                    //it will jumpto this memory address.
                    .word Start

                    //IRQ vector (External Interrupt Request)
                    //When an IRQ happens, the processor will jump to this memory address.
                    .word IRQ


                    //-----------------------------------------------------------------------------
                    // NOTE: You may create more PRG banks and map them to $8000, like this:
                    //-----------------------------------------------------------------------------

                    // .bank 1, 16, $8000, "NES_PRG1"
                    // .segment "My_Code_in_Bank1"

                    // .bank 2, 16, $8000, "NES_PRG2"
                    // .segment "My_Code_in_Bank2"

                    // .bank 3, 16, $8000, "NES_PRG3"
                    // .segment "My_Code_in_Bank3"


                    //-----------------------------------------------------------------------------
                    // Character ROM banks (Just make them Bank 100+, the linker does not care)
                    //-----------------------------------------------------------------------------

                    //Map this 8 KB bank to $0000, it doesn't matter because it isn't code.
                    .bank 100, 8, 0, "NES_CHR0"

                    //Every Bank needs at least one Segment to place code or data bytes into.
                    //If the bank number is not specified for the segment, it's created for
                    //the "current Bank", according to the last .bank or last used Segment.
                    .segment "Graphics_Bank0"

                    //Load a graphics file to the beginning of this segment.
                    //No need to fuss with .org, especially if the file is as big
                    //as the whole bank (8 KB)
                    .incbin "graphics.bin"


                    //-----------------------------------------------------------------------------
                    // NOTE: You may create more CHR banks, like this:
                    //-----------------------------------------------------------------------------

                    // .bank 101, 16, 0, "NES_CHR1"
                    // .segment "My_Graphics_in_Bank101"

                    // .bank 102, 16, 0, "NES_CHR2"
                    // .segment "My_Graphics_in_Bank102"

                    // .bank 103, 16, 0, "NES_CHR3"
                    // .segment "My_Graphics_in_Bank103"


                    //-----------------------------------------------------------------------------
                    // Optional Trainer ROM bank for $7000-$71ff, set 1 KB bank size for it!
                    //-----------------------------------------------------------------------------

                    .bank 200, 1, $7000, "NES_Trainer"

                    .segment "Trainer"
                    
                    nop
                    jmp *
