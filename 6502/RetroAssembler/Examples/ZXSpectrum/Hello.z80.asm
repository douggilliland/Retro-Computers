/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Hello ZX Spectrum
*
* Target: ZX Spectrum
*
* This sample shows how to create a really simple Hello World application,
* using the ZX Spectrum's ROM functions to print on the screen.
*
****************************************************************************/

                    //Setup for ZX Spectrum (Z80 CPU mode)
                    .target "z80"

                    .format "tap"                       //TAP output format for ZX Spectrum 48KB
                    .setting "TapStart", Start          //The start address of the program.
                    .setting "TapClear", $5fff          //The CLEAR VAL address in the BASIC
                                                        //loader which clears up the RAM
                                                        //before the binary code loads.

                    //If needed, the default memory bank can be reconfigured
                    //as a 48KB bank, mapped at $4000.
                    //But the default setup as 64KB, mapped at $0000 is fine.
                    //.bank 0, 48, $4000


                    //Spectrum programs typically start at $8000 or around that address.
                    //They can go as low as $4000, but below $6000 it starts to write into
                    //the graphics memory area, where this example would look messy.

                    .org $8000

Start               ld a,2          //Channel 2 = "S" for screen.
                    call $1601      //Select print channel using ROM.

                    ld hl,Line      //Print this line of text...
                    call PrintLine  //Using this subroutine.
                    jp *            //Do an endless loop here to stop the program.


                    //Subroutine to print out a line of text, terminated by $00
PrintLine           ld a,(hl)       //Get character to print.
                    cp $00          //See if it's the $00 terminator byte.
                    jp z,@PrintEnd  //We're done if it is...
                    rst $10         //Spectrum: Print the character stored in register A.
                    inc hl          //Move onto the next character.
                    jp PrintLine    //Loop back to read and print the next character.
@PrintEnd           ret


                    //Text to print.
Line                .byte "Hello ZX Spectrum!", 0
