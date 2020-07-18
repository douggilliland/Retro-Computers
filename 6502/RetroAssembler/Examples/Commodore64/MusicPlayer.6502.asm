/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 5/13/2020
* ==========================================================================
*
* Title: Music Player
*
* Target: Commodore 64, PAL System (European)
*
* This sample shows how to create a Raster Interrupt and play a typical
* SID Music file that you would find in the High Voltage SID Collection.
*
* The code is clean, without any trickery for easy understanding, and also
* serves as a small tutorial on raster interrupts.
*
****************************************************************************/

                //Setup for Commodore 64 (6502 CPU mode)
                .target "6502"

                //Generate a PRG file for the Commodore 64
                .format "prg"

                //Use the Code segment in Bank 0.
                //This would be default selected anyway.
                .code


                .org $0801  //Start building the code here for the BASIC line

                BasicRun()  //Macro that inserts bytes for a "10 SYS2064"
                            //BASIC program to make our code below RUN-able
                            //from $0810 (SYS2064 translates to jsr $0810)

                //Our code below will be placed at $0810 and onward, because
                //BasicRun() inserted 15 bytes from $0801 to $080f. Therefore
                //the next instruction "sei" will be placed at $0810.

                sei         //Disable interrupts by setting a flag.

                lda #$7f    //Turn off Timer interrupts on both CIA chips.
                sta $dc0d
                sta $dd0d

                lda $dc0d   //Clear queued CIA IRQs by reading the registers
                lda $dd0d
                asl $d019   //Clear VIC interrupts too, just in case.


                //Now that the system's old interrupts are cleared, we can
                //set up our own interrupt, that will execute a small chunk
                //of code on every screen refresh.

                lda #$01    //Request for a Raster Interrupt that we need.
                sta $d01a

                lda #<irq   //Point the IRQ Vector to our custom IRQ routine
                ldx #>irq   //that will be executed on every screen refresh.
                sta $0314   //IRQ is short for Interrupt ReQuest.
                stx $0315

                lda #$1b    //Set a normal character screen mode, but also
                sta $d011   //clear the 8th bit which acts as the 9th bit
                            //for the register value in $d012. See below.

                lda #$80    //Request to run our interrupt at raster line
                sta $d012   //$80, which is around the middle of the screen.
                            //The line number can go over 256, so the 9th
                            //bit of the value is stored in $d011's 8th bit.

                lda #$00    //Initialize the music player file at $1000.
                jsr $1000   //The $00 in A is usually a song selector.
                            //This address and value may vary per music file.

                cli         //Enable interrupts by clearing this flag.

                jmp *       //Do an endless loop here in the main program, as
                            //our code execution will happen in interrupts.



                //This is the chunk of code that will run in each raster
                //interrupt, that happens on each screen refresh.

irq             asl $d019   //Adjust this register value to acknowledge
                            //the raster interrupt when our code runs.

                lda #$0f    //Changing the background color to Light Gray
                sta $d020   //before calling the music player will show us
                            //how much "raster time" it takes to execute it.

                jsr $1003   //Call the actual music player to play it.
                            //It adjusts SID registers in each frame to make
                            //sound. This address may vary per music file.

                lda #$0e    //Changing the background color back to the
                sta $d020   //default Light Blue will mark the end of
                            //"raster time usage" of the music player code.

                jmp $ea81   //Return to the Kernel interrupt routine that
                            //will close things, until the next interrupt
                            //in the next frame when our code will run again.



                //Use the Data segment in Bank 0 to store the music file.
                //It's not necessary, but it's a good example.
                .data

                //Load the music file "music.prg" to $1000, according to its
                //load address header in the first 2 bytes of the file.
                .incbin "music.prg", auto


                //This macro inserts bytes to create a "10 SYS2064" BASIC
                //program line starting at $0801. Then the assembly code
                //will be entered from $0810 and can be launched by RUN.
                .macro BasicRun()
                .byte $0b, $08, $0a, $00, $9e, $32, $30
                .byte $36, $34, $00, $00, $00, $00, $00, $00
                .endmacro
