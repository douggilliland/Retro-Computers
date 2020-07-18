/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Blue Background
*
* Target: Super Nintendo Entertainment System
*
* This sample shows how to create a basic framework for an SNES ROM
* with LoROM cartridge configuration (32KB banks mapped to $8000)
*
* The code is clean, without any trickery for easy understanding.
*
* Based on this tutorial:
* https://en.wikibooks.org/wiki/Super_NES_Programming/Initialization_Tutorial
* 
****************************************************************************/

                    //SNES cartridge setup
                    .format "sfc"                      //The output file will be in SFC ROM format

                    //Note: These values are used to build the SNES ROM header at $ffc0-$ffdf in Bank 0.

                    .setting "SNESTitle", "My ROM!"    //A sample title for the ROM (max 21 characters)
                    .setting "SNESPadding", true       //Enable padding for a valid ROM size and correct checksum calculation
                    .setting "SNESHiROM", false        //LoROM configuration (32KB banks mapped to $8000)
                    .setting "SNESExLoROM", false      //Not an Extended ROM
                    .setting "SNESExHiROM", false      //Not an Extended ROM
                    .setting "SNESFastROM", false      //Slow ROM mode with 200ns timing
                    .setting "SNESCartridgeType", $00  //ROM only
                    .setting "SNESSRAMSize", $00       //No SRAM on the cartridge
                    .setting "SNESCountry", $01        //USA (NTSC)
                    .setting "SNESLicenseeCode", $01   //Nintendo
                    .setting "SNESVersion", $00        //Version 1.0


                    //Use the 65816 CPU
                    .target "65816"


                    //Reconfigure the default Bank 0 to be 32KB, mapped at $8000
                    .bank 0, 32, $8000

                    //Use the already created Code segment in Bank 0.
                    .code

                    //Set the start address for code entry to $8000 (Could be anywhere between $8000 - $ffc0)
                    .org $8000


Start               sei         //Disable all interrupts.
                    clc         //Clear carry to turn on native mode (the CPU starts in 6502 Emulation mode)
                    xce         //Exchange carry & emulation bit to turn on native mode.
                    cld         //Turn off Decimal mode (to be on the safe side)
                    sep #$30    //X,Y,A are 8 bit numbers (just to have a known start state)

                    rep #$10    //X,Y are 16 bit numbers
                    ldx #$1fff  //Set the stack pointer to $1fff
                    txs

                    jsr Init    //Initialize the SNES hardware registers.

                    sep #$30    //X,Y,A are 8 bit numbers (Init already did this but... safe side)

                    lda #%10000000  //Force VBlank by turning off the screen.
                    sta $2100

                    //Set the background color (as Color 0, index set up in Init)
                    //by a 24 bit RGB value for easier readability.
                    //Each color can be between $00-$1f (5 bit)
                    //R=$00, G=$1f, B=$1f
                    SetColor($000f1f)

                    lda #%00001111  //End VBlank, setting brightness to 15 (100%).
                    sta $2100

                    jmp *       //Infinite loop...



                    //-----------------------------------------------------------------------------
                    // Subroutine to initialize the SNES hardware registers.
                    //-----------------------------------------------------------------------------

Init                sep #$30    //X,Y,A are 8 bit numbers
                    lda #$8f    //screen off, full brightness
                    sta $2100   //brightness + screen enable register 
                    stz $2101   //Sprite register (size + address in VRAM) 
                    stz $2102   //Sprite registers (address of sprite memory [OAM])
                    stz $2103
                    stz $2105   //Mode 0, = Graphic mode register
                    stz $2106   //noplanes, no mosaic, = Mosaic register
                    stz $2107   //Plane 0 map VRAM location
                    stz $2108   //Plane 1 map VRAM location
                    stz $2109   //Plane 2 map VRAM location
                    stz $210a   //Plane 3 map VRAM location
                    stz $210b   //Plane 0+1 Tile data location
                    stz $210c   //Plane 2+3 Tile data location
                    stz $210d   //Plane 0 scroll x (first 8 bits)
                    stz $210d   //Plane 0 scroll x (last 3 bits) #$0 - #$07ff
                    lda #$ff    //The top pixel drawn on the screen isn't the top one in the tilemap, it's the one above that.
                    sta $210e   //Plane 0 scroll y (first 8 bits)
                    sta $2110   //Plane 1 scroll y (first 8 bits)
                    sta $2112   //Plane 2 scroll y (first 8 bits)
                    sta $2114   //Plane 3 scroll y (first 8 bits)
                    lda #$07    //Since this could get quite annoying, it's better to edit the scrolling registers to fix this.
                    sta $210e   //Plane 0 scroll y (last 3 bits) #$0 - #$07ff
                    sta $2110   //Plane 1 scroll y (last 3 bits) #$0 - #$07ff
                    sta $2112   //Plane 2 scroll y (last 3 bits) #$0 - #$07ff
                    sta $2114   //Plane 3 scroll y (last 3 bits) #$0 - #$07ff
                    stz $210f   //Plane 1 scroll x (first 8 bits)
                    stz $210f   //Plane 1 scroll x (last 3 bits) #$0 - #$07ff
                    stz $2111   //Plane 2 scroll x (first 8 bits)
                    stz $2111   //Plane 2 scroll x (last 3 bits) #$0 - #$07ff
                    stz $2113   //Plane 3 scroll x (first 8 bits)
                    stz $2113   //Plane 3 scroll x (last 3 bits) #$0 - #$07ff
                    lda #$80    //increase VRAM address after writing to $2119
                    sta $2115   //VRAM address increment register
                    stz $2116   //VRAM address low
                    stz $2117   //VRAM address high
                    stz $211a   //Initial Mode 7 setting register
                    stz $211b   //Mode 7 matrix parameter A register (low)
                    lda #$01
                    sta $211b   //Mode 7 matrix parameter A register (high)
                    stz $211c   //Mode 7 matrix parameter B register (low)
                    stz $211c   //Mode 7 matrix parameter B register (high)
                    stz $211d   //Mode 7 matrix parameter C register (low)
                    stz $211d   //Mode 7 matrix parameter C register (high)
                    stz $211e   //Mode 7 matrix parameter D register (low)
                    sta $211e   //Mode 7 matrix parameter D register (high)
                    stz $211f   //Mode 7 center position X register (low)
                    stz $211f   //Mode 7 center position X register (high)
                    stz $2120   //Mode 7 center position Y register (low)
                    stz $2120   //Mode 7 center position Y register (high)
                    stz $2121   //Color number register ($0-ff)
                    stz $2123   //BG1 & BG2 Window mask setting register
                    stz $2124   //BG3 & BG4 Window mask setting register
                    stz $2125   //OBJ & Color Window mask setting register
                    stz $2126   //Window 1 left position register
                    stz $2127   //Window 2 left position register
                    stz $2128   //Window 3 left position register
                    stz $2129   //Window 4 left position register
                    stz $212a   //BG1, BG2, BG3, BG4 Window Logic register
                    stz $212b   //OBJ, Color Window Logic Register (or,and,xor,xnor)
                    sta $212c   //Main Screen designation (planes, sprites enable)
                    stz $212d   //Sub Screen designation
                    stz $212e   //Window mask for Main Screen
                    stz $212f   //Window mask for Sub Screen
                    lda #$30
                    sta $2130   //Color addition & screen addition init setting
                    stz $2131   //Add/Sub sub designation for screen, sprite, color
                    lda #$e0
                    sta $2132   //color data for addition/subtraction
                    stz $2133   //Screen setting (interlace x,y/enable SFX data)
                    stz $4200   //Enable V-blank, interrupt, Joypad register
                    lda #$ff
                    sta $4201   //Programmable I/O port
                    stz $4202   //Multiplicand A
                    stz $4203   //Multiplier B
                    stz $4204   //Multiplier C
                    stz $4205   //Multiplicand C
                    stz $4206   //Divisor B
                    stz $4207   //Horizontal Count Timer
                    stz $4208   //Horizontal Count Timer MSB (most significant bit)
                    stz $4209   //Vertical Count Timer
                    stz $420a   //Vertical Count Timer MSB
                    stz $420b   //General DMA enable (bits 0-7)
                    stz $420c   //Horizontal DMA (HDMA) enable (bits 0-7)
                    stz $420d   //Access cycle designation (slow/fast rom)
                    cli         //Enable interrupts
                    rts


                    //-----------------------------------------------------------------------------
                    // Interrupt handlers.
                    //-----------------------------------------------------------------------------

                    //Dummy interrupt handler, create your own for each supported interrupt type.
                    //Also I think putting $ffff into an unused interrupt vector is an OK default value.

Dummy               rti



                    //-----------------------------------------------------------------------------
                    // Location of Interrupt vectors.
                    //-----------------------------------------------------------------------------

                    //Native vectors (Used when the CPU is in native 65816 mode)
                    * = $ffe0
                    
                    .word 0
                    .word 0
                    .word Dummy  //COP  (at $ffe4)
                    .word Dummy  //BRK
                    .word Dummy  //ABORT
                    .word Dummy  //NMI
                    .word 0      //(No RESet vector)
                    .word Dummy  //IRQ
                    
                    
                    //Emulation vectors (The CPU always starts up in Emulation mode)
                    //* = $fff0 (Not needed)
                    
                    .word 0
                    .word 0
                    .word Dummy  //COP  (at $fff4)
                    .word 0      //(No BRK vector)
                    .word Dummy  //ABORT
                    .word Dummy  //NMI
                    .word Start  //RESet  <-- THIS SETS THE STARTING POINT OF THE PROGRAM
                    .word Dummy  //IRQ or BRK



                    //-----------------------------------------------------------------------------
                    // Make another bank, just to show how it's done.
                    //-----------------------------------------------------------------------------

                    .bank 1, 32, $8000

                    .segment "Bank1"

                    .text "HELLO!"


                    
                    //-----------------------------------------------------------------------------
                    // The SetColor() macro which enters an RGB value into the selected color.
                    // The color palette index is selected in $2121 ($00 is for the background)
                    // and the color value is entered through $2122 as a 16 bit value, meaning
                    // it has to be entered as a series of two 8 bit values.
                    //-----------------------------------------------------------------------------

                    //Sets the currently selected SNES color using a 24 bit RGB value.
                    .macro SetColor(RGB, Address=$2122)

                    //All done in a verbose way because at the end readability
                    //is better than brievity, and the assembler does not care.
                    //It will be 4 instructions at the end either way.

                    //Get the separated RGB colors out of the 24 bit RGB value.
                    //Example: RGB = $000f1f (R=$00, G=$0f, B=$1f) for a nice Blue
                    //Each color value can be between $00-$1f (5 bits), but keep
                    //all 8 bits for correction below.

@@Red               .var (RGB & $00ff0000) >> 16
@@Green             .var (RGB & $0000ff00) >> 8
@@Blue              .var (RGB & $000000ff) >> 0


                    //Repair the color values if they are outside the 5 bit limit.
                    //Instead of just cropping the bits, use the highest intensity.

                    //NOTE: This macro easily could be converted to something that
                    //takes real 24 bit color values with $00-$ff intensity and
                    //converts them to 5-bit intensity by bit shifting ($ff >> 3 = $1f)

                    .if @@Red > $1f
                    @@Red = $1f
                    .endif

                    .if @@Green > $1f
                    @@Green = $1f
                    .endif

                    .if @@Blue > $1f
                    @@Blue = $1f
                    .endif


                    //Combine these potentially repaired values into 15 bit RGB colors for SNES.

@@Color             .var (@@Blue << 10) | (@@Green << 5) | (@@Red << 0)


                    //Set the lower byte of the 16 bit color value...
                    lda #<@@Color
                    sta Address

                    //Then set the higher byte of the 16 bit color value to enter the full color.
                    lda #>@@Color
                    sta Address

                    .endmacro
