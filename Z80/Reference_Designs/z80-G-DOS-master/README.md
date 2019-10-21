-------------------------------------------------------------------------------
                    G-DOS (Prototype) Operating System

  A firmware OS designed specifically for the G80-S, G80 family z80 Computers.

  By:  Doug Gabbard ( 2017 - 20XX )
  Dev-Team:    Mike Veit
               Amardeep Chana

  Current Version:  v0.52b
  
-------------------------------------------------------------------------------
	   ABOUT
-------------------------------------------------------------------------------
  The G80 Computer project was started in the the spring of 2017 as a learning
   experience for the creator, Doug Gabbard.  Based upon the leasons learned in
   his previous experiments with the Zilog z80 Processor, the G80-S was meant
   to be a bare bones computer, not based on a previous design.  Previous
   boards designed by the creator were overly complex, and used primarily as a
   means to learn how the processor interacted with different components.  The
   new design was meant to be a fully functional computer, with a very simple
   machine code monitor.
   
  The original board was designed over the course of two days, and sent off to
   a board fabrication service in China for manufacturing.  Though, the
   fundimental design was layed out in previous projects.  Including a Zilog
   z80 Processor at 6mhz, 32Kb SRAM, 32Kb EEPROM, Zilog Dual Asynchronous
   Receiver/Transmitter (DART), Intel 8255 Parallel Input/Output (PIO), and
   minimal support logic using the GAL22V10 Programmable Logic Device (PLD).
   The resulting design proved extremely reliable.  And with minor
   modifications the G80-S v1.0 computer was born.  Few of the G80-S 'Beta'
   boards were produced.  But were identical to the v1.0 boards in all but the
   silkscreen and a missing pull-up resistor on the IEI line of the Zilog DART.
   
  The first version of the software was written before the board had been
   received.  Consisting of a rudimentary Input/Output routine for receiving
   data over serial, and displaying it on the screen.  This worked out of the
   box, and the rest of the original monitor was built around this very
   primative software. Over the following few weeks, the software was rewritten
   and tweeked until a basic monitor had been written.  Complete with word
   recognition for instructions, the software had the following features:
   
		Clear Screen
		Dump Memory Page
		Modify Memory
		Software Restart
		Help Display
  
  The G80-S board was redesigned several months later as the G80-USB.
   Sacrificing one RS-232 port for use as a USB Serial Port, it allowed the
   G80 computer to communicate more readily with modern computers.  And has
   been the standard version since mid-2018.  Future boards are expected to
   take advantage of much more complex IO options to include adding video and
   keyboard inputs, as well as file storage capability.
  
  The monitor was expanded, and eventually included routines to load Intel
   HEX files over serial, read in and output to IO and memory locations,
   and memory clearing routines.  Though the big change came when the creator
   ported the origal Palo Alto Tiny Basic v2.0 to Zilog mnemonics, and
   integrated it into the already existing monitor.  It was at this time the
   goal of morphing this small monitor into a Disk Operating System (DOS) was
   formed.  This software project is the evolution of that goal.

  Software development was done using zDevStudio, as PASMO language compiler
   IDE for Windows.  That software can be found here:

				https://sourceforge.net/projects/zdevstudio/

-------------------------------------------------------------------------------
	   FEATURES
-------------------------------------------------------------------------------
  The Prototype G-DOS has many features of interest to those designing z80
   based systems.  However, it was specifically designed for the G80 family of
   computers.  This does not mean that it cannot be modified for use with other
   computer designs.  In fact it's modularity is such that it is easy to design
   your own routines to support your computer's hardware.
  
  The monitor currently contains all of the routines mentioned above, with the
   addition of selectable languages: TinyBASIC 2.5g and CamelFORTH. Other items
   of interest are the built in system calls, which help the programmer save
   space and use pre-proofed languages.
   
  In addition to the items above, the software is easily expandable.  A user
   can add additional instructions to the software by adding their routines
   to and updating the cmd_recogn.asm file to include the proper keywords, 
   token sums, and jump locations.  This feature creates an enviroment that is
   desirable for vintage computing fans and makers alike.

-------------------------------------------------------------------------------
       BOARD SETTINGS
-------------------------------------------------------------------------------
  Due to the growing design of this computer project, it has become necessary
   to begin conditional assembly for specific boards.  This can be done easily
   in code to allow for different sets of code to be compiled depending on the
   specific board.  The 'BOARD' equate is the key.  Depending on the value
   given, the board will either compile for either the G80-S/USB variants, or
   the G80-UVK (and G80-S/USB with add-on cards for compatibility).  To specify
   which board is to be used, please set 'BOARD' to one of the following
   settings:

       0 = G80-S or G80-USB
       1 = G80-UVK (or G80-S/USB with add-on card)

  A second setting is available to allow serial communication for the G80-S/USB
   over either Port A or B.  On the G80-USB the USB Serial Port is Port A, and
   the RS-232 port is Port B. To enable serial over a specific serial port
   choose one of the following settings for 'SERIAL':

       0 = Serial Port A
       1 = Serial Port B

  Option 3 is the BAUD Rate settings for both Port A, and Port B.  These can be
   mixed however the user chooses:  115200 Baud, 57600 Baud, and 28800 Baud.
   This allows for a greater window of communication options.  Changing the
   frequency oscillator for Serial Communication can allow for other varieties
   of combinations.  The settings for SIOA_BAUD and SIOB_BAUD are:

       DEFAULT = X32 - MOST RELIABLE
       0 = Divide by 16
       1 = Divide by 32
       2 = Divide by 64

  NOTE:  If compiling for z80 Computers other than the G80 family, care should
   be taken in modifying the code for the board definitions.  All of the
   conditional assembly would need to be modified to suit your specific
   hardware requirements.  While this software may be modified to work on your
   design, thought will have to go into making it compatible.  You own IO
   routines will be required if they differ from that of the G80 computer
   family.
   
-------------------------------------------------------------------------------
	   MONITOR OPTIONS
-------------------------------------------------------------------------------
  The monitor offers built in instructions designed to help debug and assist
   with programming.  These simple yet powerful tools can help anyone in their
   connected hardware or software projects.
   
  CALL
   Use: CALL HHHH
   Where HHHH is a hexidecimal value of an address location.
  
  CALL is a routine that allows the execution of a machine code program at the
   specified address location.  Return from a CALL is still has bugs.  But will
   allow the user to execute programs either saved in ROM or loaded by the
   HEXLOAD instruction.
 
 
  CLS
   Use: CLS
   
  CLS is a routine to clear the screen, and print a fresh prompt.  Nothing
   special here.  It is literally used to clear the garbage from the screen.

   
  DUMP
   Use: DUMP HHHH
   Where HHHH is a hexidecimal value of an address location.
   
  DUMP displays the data contained in 256 address locations starting at the
   address given.  Of consideration to the user, the least significant 
   hexidecimal number is irrelevant.  The DUMP routine will always begin with
   a '0' in the least significant slot.  So if you were to request a DUMP from
   address 8008h, the DUMP routine would display 8000h to 80FFh.

   
  HELP
   Use: HELP
   
  HELP is a routine that displays a listing of available routines and their
   syntax on the screen.  Though documentation for the monitor may not always
   be in the hands of the user, the HELP instruction is always at their finger
   tips.

   
  HEXLOAD
   Use: HEXLOAD
   
  HEXLOAD is a routine originally written by Andrew Lynch of the RetroBrew
   Computer Project.  This code was then modified by Bernd Ulmann for his
   own z80 computer project.  And then further modified for use in the G80
   computer family. This routine loads an Intel HEX file into memory, and
   reverts back to the monitor.  It is useful for uploading programs to the
   computer.
   
   
  IN
   Use: IN HH
   Where HH is a hexidecimal value of an IO Port.
   
  IN is useful as an IO space tool, allowing the user to read in values from
   a specific port.  This can be of use for the hardware designer to test
   connected IO to ensure proper functionality.
   
   
  MODMEM
   Use: MODMEM HHHH
   Where HHHH is a hexidecimal value of an address location.
   
  MODMEM is a routine to modify the contents of memory manually.  When given
   an address location, it will display a prompt which includes the address
   location currently modifying, as well as the current value of that
   memory location.  Typing hexidecimal values will update that location
   with the given values.  Or typing 'x' or 'X' will exit from the utility.
   
   
  OUT XX HH
   Use:  OUT 8A FF
   Where XX is a Hex Value of a Port, and HH is a Hex value to write.
   
  Out is another useful IO routine for writing a value to an IO port.  The
   use is straightforward.  This utility can be used in conjunction with
   the IN routine to test hardware connected to the computer.
   
   
  RAMCLR
   Use: RAMCLR
   
  RAMCLR is a RAM Clearing utility.  It will write the value FF to the entire
   RAM memory space.  This is useful to clear garbage from the SRAM so that 
   memory activity can be detected.
   
  
  RESTART
   Use: RESTART
   
  RESTART is a routine for a software restart of the system.  This can be
   useful at times. But is likely seldom used.
   
-------------------------------------------------------------------------------
	   BASIC EXTENSION INSTRUCTIONS
-------------------------------------------------------------------------------
  TinyBASIC 2.5g is an extended version of Palo Alto TinyBASIC 2.0, by
   Dr. Li-Chen Wang.  Modified by Doug Gabbard, it has many features that were
   not present in the original code. These instruction provide the BASIC User
   more flexibility with their programming.  And much greater power to the
   BASIC programs.
   
  OUT
   Use: OUT PP,V
		OUT PP V
		OUT PP=V
   Where PP is a hexidecimal value of a port, and V is a BASIC Variable.
   
  OUT is an IO routine that allows writing of a value stored in a BASIC
   Variable to the port defined by PP.  TinyBASIC, originally written for the
   Intel 8080, did not have any IO functions.  This feature makes for a very
   useful addition to the z80 version of the Interpreter.
   
   
  IN
   Use: IN PP,V
		IN PP V
		IN PP=V
   Where PP is a hexidecimal value of a port, and V is a BASIC Variable.
   
  IN is another IO routine that was not originally included in the i8080 code.
   This instruction allows the BASIC programmer to read a value from an IO
   port as defined by the PP variable.
   
   
  HEX
   Use: HEX HH,V
		HEX HH V
		HEX HH=V
   Where HH is a hexidecimal value, and V is a BASIC Variable.
   
  HEX, unlike it is used in other BASIC Languages, is for storing a value
   into a BASIC Variable by use of hexidecimal format.  Most other Basic
   Interpreters use the HEX instruction as a Function within a Statement.
   TinyBASIC 2.5g currently does not support that method.  Instead allowing
   programmer to directly store the value into a Variable.
  
  
  POKE
   Use: POKE AAAA,V
		POKE AAAA V
		POKE AAAA=V
		POKE AAAA,(HH...)
		POKE AAAA (HH...)
		POKE AAAA=(HH...)
   Where AAAA is a hexidecimal address, V is a Variable, and 'HH...' is a
    hexidecimal string of characters.
	
  POKE was not included in the original TinyBASIC code.  It is used to store
   either a the contents of a variable, or a hexidecimal string, into memory.
   This is not only useful for storing data in BASIC programs, but allows the
   user to store machine code into memory that can be run by the Interpreter
   later in the code.  This is a very powerful routine to the experienced
   BASIC and Assembly programmer.
   
   
  PEEK
   Use: PEEK AAAA,V
		PEEK AAAA V
		PEEK AAAA=V
   Where AAAA is a hexidecimal address, and V is a Variable.
   
  PEEK is an instruction that allows the programmer to fetch data from storage
   in memory.  An advanced feature of BASIC, this was not included in the
   original code.  It can be useful for obtaining data that was initially
   written to memory by the POKE instruction.
   
   
  DELAY
   Use: DELAY
   
  DELAY is an instruction which will execute a timed delay of approximately
   2 milliseconds.  The best use of this instruction would be nested in a
   FOR loop.  Allowing the programmer to time delay between instructions.
   
  
  CLS
   Use: CLS
   
  CLS is just like it's counter part in the core monitor.  It is used to clear
   the screen, erasing any data that was there prior to it's calling.
   
  
  CALL
   Use: CALL AAAA
   Where AAAA is a hexidecimal Address location.
   
  CALL is an instruction for calling a machine code routine that has either
   been stored in the memory space by POKE, or has been programmed into the
   ROM data.  A return instruction must be used to return to the monitor.
   Any data left in the registers will be overwritten, as the routine pushes
   all of the register pairs (AF, BC, DE, and HL) onto the stack before
   jumping to the machine code routine. And then POPS them back into the
   registers upon return.  Any data to be save should be stored in a memory
   location to be PEEK'ed by BASIC at a later point in the code.
   
  
  QUIT
   Use: QUIT
   
  QUIT is an instruction to exit out of TinyBASIC, and return to the G80's
   monitor.  This is simply used for quitting BASIC.
   
-------------------------------------------------------------------------------
	   CamelFORTH
-------------------------------------------------------------------------------
  CamelFORTH documentation may be provided in the future by Mike Veit.  At this
   time, please refer to the following website:
   
			http://www.camelforth.com/news.php
			
-------------------------------------------------------------------------------
	   FURTHER DOCUMENTATION
-------------------------------------------------------------------------------
  Further documentation will be provided as it becomes relevant to the use of
   this software.
