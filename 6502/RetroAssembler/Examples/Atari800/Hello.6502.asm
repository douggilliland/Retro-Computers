/****************************************************************************
* Retro Assembler Sample Code                      Last changed on 6/16/2020
* ==========================================================================
*
* Title: Hello Atari 800
*
* Target: Atari 800
*
* This sample shows how to create a really simple Hello World application,
* using the Atari's ROM functions to print on the screen.
*
* The file is auto-started after loading, handled by the "Launcher" segment.
*
* The code is clean, without any trickery for easy understanding.
*
****************************************************************************/

                //Use the MOS 6502 CPU.
                .target "6502"

                //Use the Atari DOS "XEX" binary output format.
                .format "AtariDOS"
				
                //Save the Info file with the memory usage values.
                .setting "OutputSaveInfoFile", true


Command         = $0342
Buffer          = $0344
BufferLength    = $0348


//The context is set to the "Code" segment by default.

                .org $0600

Start           //This is the entry point of the program ($0600)
                //This "Start" Label will be referenced in the "Launcher" Segment.

                //Send PUT into ICCOM to display text on the screen.
                lda #$0b
                sta Command

                //Set the Buffer location to the Message's memory address.
                lda #<Message
                sta Buffer
                lda #>Message
                sta Buffer+1

                //Set the Buffer Length to the Message's calculated length.
                lda #<MessageEnd-Message
                sta BufferLength
                lda #>MessageEnd-Message
                sta BufferLength+1

                //Execute the IO command. This expects $00 in the X Register.
                ldx #$00
                jmp $e456

Message         .byte "Hello Atari World! :)", $9b
MessageEnd


//Create a new segment called "Launcher", which will get special handling.
//(Put this to the end of the code, or before another Segment definition/selection.)

                .segment "Launcher"

                //This is not strictly necessary, but it will make the optional
                //Info file look correct for this segment's memory address.
                .org $02e0

                //It only needs a pointer to the program's Start address ($0600 here).
                //The system will jump to it after loading the program file.

                .word Start
