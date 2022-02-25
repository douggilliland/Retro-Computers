
/***************************** 68000 SIMULATOR ****************************

File Name: CODE9.C
Version: 1.0

The instructions implemented in this file are the exception processing
related operations:

        CHK, ILLEGAL, RESET, STOP, TRAP, TRAPV

   Modified: Charles Kelly
             www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <Printers.hpp>

#include "extern.h"         // contains global "extern" declarations
#include "simIOu.h"
#include "SIM68Ku.h"
#include "hardwareu.h"
#include "logU.h"


extern uchar keyDownCode;       // defined in simIOu, used by Trap #15,19
extern uchar keyUpCode;         // "
extern bool disableKeyCommands;  // defined in SIM68Ku

// global variables for printing
TPrinter *Prntr;
bool printing = false;
int pageRowHeight;
int pageColWidth;
int pageTop;
int pageBot;
int pageLeft;
int pageRight;
int pageX;
int pageY;


void __fastcall formFeed()
{
  if (!printing) {
    initPrint();
    Prntr->BeginDoc();
  }
  Prntr->EndDoc();
  printing = false;
  pageY = pageTop;
}

void __fastcall lineFeed()
{
  pageY += pageRowHeight;
  if (pageY > pageBot) {
    formFeed();
  }
}

void __fastcall nextX()
{
  pageX += pageColWidth;
  if (pageX > pageRight) {
    pageX = pageX - pageRight + pageLeft;
    lineFeed();
  }
}

void __fastcall initPrint()
{
  Prntr = Printer();
  printing = false;
  Prntr->Canvas->Font->Assign(Form1->FontDialogPrinter->Font);
  pageRowHeight = Prntr->Canvas->TextHeight("Xp");
  pageColWidth  = Prntr->Canvas->TextWidth("W");
  pageTop = Prntr->PageHeight / 11;
  pageBot = Prntr->PageHeight - pageTop;
  pageLeft = Prntr->PageWidth / 8;
  pageRight = Prntr->PageWidth - pageLeft;
  pageX = pageLeft;
  pageY = pageTop;
}

//---------------------------------------------------------------------------
//  printChar
//  Print character at pageX, pageY
//  Handle control characters
//  \b	0x08	BS	Backspace
//  \f	0x0C	FF	Formfeed
//  \n	0x0A	LF	Newline (linefeed)
//  \r	0x0D	CR	Carriage return
//  \t	0x09	HT	Tab (horizontal)
//  \v	0x0B	VT	Vertical tab
void __fastcall printChar(char ch)
{
  if (!printing) {
    initPrint();
    Prntr->BeginDoc();
    printing = true;
  }
  switch (ch) {
    case '\b':                  // if Backspace
      pageX -= pageColWidth;
      if (pageX < pageLeft)
        pageX = pageLeft;
      break;
    case '\f':                  // if Formfeed
      formFeed();
      break;
    case '\n':                  // if LF
      lineFeed();
      break;
    case '\r':                  // if CR
      pageX = pageLeft;
      break;
    case '\t':                  // if Tab
      pageX += 4 * pageColWidth;
      nextX();
      break;
    case '\v':                  // if Vertical tab
      pageY += 4 * pageRowHeight;
      if (pageY > pageBot) {
        int tempY = pageY - pageBot + pageTop;
        formFeed();
        pageY = tempY;
      }
      break;
    default:
      if (ch >= ' ') {          // if not control char
        Prntr->Canvas->TextOut(pageX,pageY,AnsiString(ch));
        nextX();
      }
  } // end switch
}

//-----------------------------------------------------
int	CHK()
{
  int	reg;
  long	temp;

  reg = (inst >> 9) & 0x07;

  int error = eff_addr((long)WORD_MASK, DATA_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  from_2s_comp (EV1, (long) WORD_MASK, &source);
  dest = D[reg] & WORD_MASK;

  cc_update (N_A, GEN, UND, UND, UND, source, D[reg], D[reg], WORD_MASK, 0);

  /* perform the CHK operation */
  if ((dest < 0) || (dest > source))
	return(CHK_EXCEPTION);

  inc_cyc (10);

  return SUCCESS;

}


//-----------------------------------------------------
int	ILLEGAL()
{

return (BAD_INST);

}



int	RESET()
{

if (!(SR & sbit))
	return (NO_PRIVILEGE);

/* assert the reset line to reset external devices */

inc_cyc (132);

return SUCCESS;

}



//-----------------------------------------------------------
//  STOP
int	STOP()
{
  long	temp;
  int	tr_on;
  //AnsiString str;

  inc_cyc (4);

  mem_request (&PC, (long) WORD_MASK, &temp);

  if (!(SR & sbit))
    return (NO_PRIVILEGE);

  if (SR & tbit)
    tr_on = true;
  else
    tr_on = false;

  SR = temp & WORD_MASK;
  if (tr_on)
    SR = SR | tbit;

  if (!(SR & sbit))
    return (NO_PRIVILEGE);

  if (tr_on)
    return (TRACE_EXCEPTION);

  //if (tr_on)
  //  return (SUCCESS);
  //else
  return (STOP_TRAP);
}

/*-------------------------------------------------------------------
 TRAP handler
 TRAP #15 is used for I/O.
 D0 contains the task number:

 Trap codes 0 - 12 are designed to be compatible with the Teesside simulator.

  0 - Display string at (A1), D1.W bytes long (max 255) with CRLF.
  1 - Display string at (A1), D1.W bytes long (max 255) without CRLF.
  2 - Read keyboard string starting at (A1) length returned in D1.W (max 80)
  3 - Display number in D1.L in decimal in smallest field.
  4 - Read a number from keyboard into D1.L.
  5 - Read single char from keyboard into D1.B.
  6 - Display single char in D1.B.
  7 - Set D1.B to 1 if keyboard input is pending, otherwise set to 0.
      Use code 5 to read pending key.
  8 - Return time in hundredths of a second since midnight in D1.L.
  9 - Terminate the program.

 10 - (not Teeside compatible)
      Print null terminated character string at (A1) to default printer.
      D1.B = 00 to print
      D1.B = 01 to end printing and feed form

-SCREEN HANDLING-
 11 - Set Cursor Position; Return Cursor Position, Clear Screen.
      Set Cursor Position: The high byte of D1.W holds the COL
      number (0-79), the low byte holds the ROW number (0-24). 0,0 is top
      left 79,24 is the bottom right. Out of range coordinates are ignored.
      Return Cursor Position: Set D1.W to $00FF. Returns COL in high byte of
      D1.W and ROW in low byte of D1.W.
      Clear Screen : Set D1.W to $FF00.

 12 - Keyboard Echo. Setting D1.B to 0 will turn off keyboard echo, D1.B to
      non zero will enable it (default). Echo is restored on 'Reset' or when
      a new file is loaded.

      ***************************************************************
      ***** The following Trap Codes are NOT Teeside compatible *****
      ***************************************************************

 13 - Display the NULL terminated string at (A1) (max 255) with CRLF.
 14 - Display the NULL terminated string at (A1) (max 255) without CRLF.
 15 - Display the contents of D1.L converted to number base (2 to 36) contained
      in D2.B. For example, to display D1.L in base16 put 16 in D2.B
      Values of D2.B outside the range 2 to 36 inclusive are ignored.
 16 - Turn on/off the display of the input prompt.
      D1.B = 0 to turn off the display of the input prompt.
      D1.B = 1 to turn on the display of the input prompt.(default)
      D1.B = 2 do not display line feed on Enter key during Trap code #2 input
      D1.B = 3 display line feed on Enter key during Trap code #2 input (default)
      Other values of D1 reserved for future use.
      Input prompt display is enabled by default and by 'Reset' or when a
      new file is loaded.
 17 - Combination of Trap codes 14 & 3. Displays the NULL terminated string at
      (A1) without CRLF then displays the decimal number in D1.L.
 18 - Combination of Trap codes 14 & 4. Displays the NULL terminated string at
      (A1) without CRLF then reads a number from the keyboard into
      D1.L.
 19 - Return keypress state for specified keys.
      pre:  D1.L = up to 4 bytes of keycodes to check
      post: D1.L = corresponding byte set to $00 if key up, $FF if key down
        or
      pre:  D1.L = 0
      post: D1.L upper word contains key code of last key up. (Sim68K v4.7.3 and newer)
            D1.L lower word contains key code of last key down.

 20 - Display signed number in D1.L in decimal in field D2.B columns wide.
 21 - Set font properties where
        D1.L is color as 0x00BBGGRR
          BB is amount of blue from 0x00 to 0xFF
          GG is amount of green from 0x00 to 0xFF
          RR is amount of red from 0x00 to 0xFF
        D2.L
          Low word is style by bits 0 = off, 1 = on
          bit0 is Bold
          bit1 is Italic
          bit2 is Underline
          bit3 is StrikeOut

          High word (low byte) is Size (High word = 0, keep current font)
          8, 9, 10, 11, 12, 14, 16, 18
          Font sizes in multiples of valid sizes ( size * n) results in a scaled
          appearance. For example: in Fixedsys font sizes of 9*2, 9*3, ..9*n
          will result in larger characters but the characters will have very
          pixelated edges.

          High word (high byte) is Font
          1 is Fixedsys       (valid sizes: 9)
          2 is Courier        (valid sizes: 10, 12, 15)
          3 is Courier New    (valid sizes 8,9,10,11,12,14,16,18)
          4 is Lucida Console (valid sizes 8,9,10,11,12,14,16,18)
          5 is Lucida Sans Typewriter (valid sizes 8,9,10,11,12,14,16,18)
 22 - Return character from screen at Row, Col where
      D1.L High 16 bits = Row (max 128)
           Low 16 bits  = Col (max 256)
      Character is returned in D1.B
 23 - Delay n/100 of a second.
        D1.W is n, unsigned
 24 - Text I/O control.
      D1.L = 0, Enable simulator key commands. (default)
      D1.L = 1, Disable simulator key commands. All of the key codes are
                made available for 68000 program read using task 19.
      D1.L = all other values reserved.
 25 - Scroll text area
      D1.L High 16 bits = Row (max 128)
           Low 16 bits  = Col (max 256)
      D2.L High 16 bits = Height (Row + Height max 128)
           Low 16 bits  = Width  (Col + Width max 256)
      D3.W 0 = Up, 1 = Down, other values reserved

-SIMULATOR ENVIRONMENT-
 30 - Clear cycle counter
 31 - Return cycle counter in D1.L.
 32 - Hardware
           D1.B = 00, display hardware window
           D1.B = 01, return address of 7-segment display in D1.L
           D1.B = 02, return address of LEDs in D1.L
           D1.B = 03, return address of switches in D1.L
           D1.B = 04, return Sim68K version number in D1.L
           D1.B = 05, enable exception processing
           D1.B = 06, set auto IRQ
                D2.B = 00 to disable all auto IRQs
                  or   Bit 7 = 0 to disable individual IRQ
                       Bit 7 = 1 to enable individual IRQ
                       Bits 6-0 = IRQ number 1 through 7
                D3.L = Auto Interval in mS, 1 through 99999999

 33 - Get/Set Output Window Size
        D1.L High 16 bits = Width in pixels, min = 640
             Low 16 bits  = Height in pixels, min = 480
        D1.L = 0, get current window size as
             High 16 bits = Width
             Low 16 bits  = Height
        D1.L = 1, set windowed mode
        D1.L = 2, set full screen mode

-SERIAL I/O-
The success of the calls below is determined from D0.W in each case. A value
of zero indicates success.

40 : INIT PORT. This should be called once for each COM port to be used
     before any other serial I/O function.
     The port defaults to 9600 baud, 8 Databits, No parity, One stop bit
     Pre:
       High 16 bits of D0 contain comm port identifier CID, (0 through 15).
       The comm port identifier is used to identify the comm port in all other
       comm tasks. It is not used to specify the comm port number,
       (e.g. A CID of 4 does not mean the same thing as COM4)
       (A1) name of serial port as null terminated string (e.g. COM4).
     Post:
       D0.W is 0 on success, 1 on invalid CID, 2 on error.
41 : SET PORT PARAMETERS
     Pre:
       High 16 bits of D0 contain comm port identifier CID, (0 through 15).
       D1.L
       Bits 0-7 (D1.B)
            port speed: 0=default, 1=110 baud, 2=300, 3=600,
            4=1200, 5=2400, 6=4800, 7=9600, 8=19200, 9=38400,
            10=56000, 11=57600, 12=115200, 13=128000, 14=256000.
       Bits 8-9
            parity: 0=no, 1=odd, 2=even, 3=mark
       Bits 10-11
            number of data bits: 0=8 bits, 1=7 bits, 2=6 bits
       Bit  12
            stop bits: 0=1 stop bit, 1=2 stop bits
       The higher bits of D1.L are reserved for future use.
     Post:
       D0.W is 0 on success, 1 on invalid CID, 2 on error
       3 on comm port not initialized.
42 : READ STRING.
     Pre:
       CID required as used in 40.
       (A1) buffer address,
       D1.B number of characters to read.
       If no char has been received it will timeout after 100 milli-seconds.
     Post:
       D0.W is 0 on success, 1 on invalid CID, 2 on error
       3 on comm port not initialized, 4 on timeout.
       D1.B number of characters read.
       (A1) null terminated string of characters
43 : SEND STRING.
     Pre:
       CID required as used in 40.
       (A1) buffer address,
       D1.B number of characters to send.
       If unable to send characters it will timeout after 100 milli-seconds.
     Post:
       D0.W is 0 on success, 1 on invalid CID, 2 on error
       3 on comm port not initialized, 4 on timeout.
       D1.B number of characters sent.

-FILE HANDLING-
  The success of the file handling calls is returned in D0.W as follows:
        0 = success
        1 = EOF encountered
        2 = Error
        3 = File is Read-Only (task 51 & 59 only)
  A maximum of 8 files may be open at any one time.

 50 - CLOSE ALL FILES. It is recommended to use this at the start of any
      program using file handling.
 51 - OPEN EXISTING file. (A1) null terminated path address. On return, D1.L
      contains the File-ID (FID). The FID is unique to each file and is a
      required arg for the other calls.
 52 - OPEN NEW FILE. As above except the file is created if not found. If
      the file exists it will be overwritten.
 53 - READ FILE. FID in D1 as returned from 51/52. (A1) buffer address, D2.L
      no. of bytes to read. On return D2 holds number of bytes actaully read.
      EOF will cause a shortened read.
 54 - WRITE FILE. As above except D2.L holds number of bytes to write
      (unaltered upon return).
 55 - POSITION FILE. Sets the file position where the next read/write will take
      place. Files begin at byte 0. FID in D1 as returned from 51/52, D2
      contains the file position to be set.
 56 - CLOSE FILE. FID in D1 as returned from 51/52.
 57 - DELETE FILE. (A1) null terminated path address.
 58 - DISPLAY FILE DIALOG
      Pre:
        D1 = 0 to display 'Open' dialog
        D1 = 1 to display 'Save' dialog
        (A1)    Points to a null terminated string that will be used as the
                request title string or A1=$00000000 to use the default
                'Load file' or 'Save file' depending on D1
        (A2)    Points to a null terminated string containing semicolon seperated
                list of file extensions for use in dialog, e.g. '*.txt;*.pcb',0
                or A2=$00000000 for all file types.
        (A3)    Points to a buffer of sufficient size to hold the zero
                terminated full file path and name.
                On calling, if this contains a file path and name this will be
                used as the original file path and name.
                If the user exits via the cancel button this buffer will
                remain unchanged.
      Post:
        D1 = 0 if user cancelled or just closed
        D1 = 1 if user hit open/save
 59 - FILE OPERATION. (A1) null terminated path address.
        D1.L = 0 does file exist, all other values reserved


-PERIPHERAL I/O-
 60 - MOUSE IRQ. Enable/Disable mouse IRQ
      An IRQ is created when a mouse button is pressed or released in the output window.
      D1.W High Byte = IRQ level (1-7), 0 to turn off
      D1.W Low Byte = Mouse event that triggers IRQ:
                      Bit2 = Move, Bit1 = Button Up, Bit0 = Button Down
      (Example D1.W = $0107, Enable mouse IRQ level 1 for Move, Button Up and Button Down)
      (Example D1.W - $0002, Disable mouse IRQ for Button Up)

 61 - MOUSE READ.
      The state of mouse buttons and position.
      D1.B = 00 to read current state of mouse
           = 01 to read mouse up state
           = 02 to read mouse down state
      The mouse data is contained in the following registers
      D0 as bits = Ctrl, Alt, Shift, Double, Middle, Right, Left
           Left is Bit0, Right is Bit 1 etc.
           1 = true, 0 = false
           Shift, Alt, Ctrl represent the state of the corresponding keys.
        D1.L = 16 bits Y, 16 bits X in pixel coordinates. (0,0 is top left)

 62 - Key IRQ. Enable/Disable keyboard IRQ
      An IRQ is created when a key is pressed or released in the output window.
      D1.W High Byte = IRQ level (1-7), 0 to turn off
      D1.W Low Byte = Key event that triggers IRQ:
                      Bit1 = Button Up, Bit0 = Button Down
      (Example D1.W = $0103, Enable Key IRQ level 1 for Key Up and Key Down)
      (Example D1.W - $0002, Disable Key IRQ for Key Up)

-SOUND-
 70 - Play the WAV file using standard player.
      Only one sound may be played at a time.
    pre: (A1) null terminated path address.
         Invalid file names are ignored.
    post:  D0.W = non zero if sound played successfully
           D0.W = 0 if player was busy, sound is not played
 71 - Load a WAV file into PC memory (not 68000 memory).
     pre: (A1) null terminated path address. Invalid file names are ignored.
          Set D1.B to reference number to use for sound file 0-255.
      A maximum of 256 sounds may be loaded at any one time.
      Reusing a reference number causes the previous sound to be erased.
 72 - Play sound from memory loaded with trap code 71 using standard player.
      Only one sound may be played at a time.
    pre :  D1.B must contain sound reference number used in trap code 71.
    post:  D0.W = non zero if sound played successfully
           D0.W = 0 if player was busy, sound is not played
 73 - Play the WAV file using DirectX player, if available.
      Multiple sounds may be played at the same time.
    pre: (A1) null terminated path address.
         Invalid file names are ignored.
    post:  D0.W = non zero if sound played successfully
           D0.W = 0 if DirectX player not available, sound is not played
 74 - Load a WAV file into DirectX sound memory (not 68000 memory).
     pre: (A1) null terminated path address. Invalid file names are ignored.
          Set D1.B to reference number to use for sound file 0-255.
      A maximum of 256 sounds may be loaded at any one time.
      Reusing a reference number causes the previous sound to be erased.
     post: DO.W = non zero if sound loaded successfully.
           D0.W = 0 if DirectX sound not available.
 75 - Play sound from DirectX memory loaded with trap code 74 using DirectX player.
      Multiple sounds may be played at the same time.
    pre :  D1.B must contain sound reference number used in trap code 74.
    post:  D0.W = non zero if sound played successfully
           D0.W = 0 if DirectX player not available, sound is not played
 76 - Control standard player
      Sounds must be in memory loaded with trap code 71.
      Only one sound may be played at a time.
    pre :  D1.B contains sound reference number used in trap code 71.
           D2.L = 0, play sound once (this is the same as trap task 72)
           D2.L = 1, play sound in loop, returns error if sound already playing in loop
           D2.L = 2, stop D1.B referenced sound, returns error on bad reference number
           D2.L = 3, stop all sounds, returns success (D1.B ignored)
           D2.L = other values reserved for future use
    post:  D0.W = non zero on success
           D0.W = 0 on error
 77 - Control DirectX player, if available.
      Sounds must be in DirectX memory loaded with trap code 74.
      Multiple sounds may be played at a time.
    pre :  D1.B contains sound reference number used in trap code 74.
           D2.L = 0, play sound once (this is the same as trap task 75)
           D2.L = 1, play sound in loop, even if sound already playing
           D2.L = 2, stop D1.B referenced sound, returns error on bad reference number
           D2.L = 3, stop all DirectX sounds, returns success (D1.B ignored)
           D2.L = other values reserved for future use
    post:  D0.W = non zero on success
           D0.W = 0 on error

-GRAPHICS-
 The graphics resolution is 640 x 480 with 0,0 at the top left.

 80 - Set pen color where D1.L is color as 0x00BBGGRR
      BB is amount of blue from 0x00 to 0xFF
      GG is amount of green from 0x00 to 0xFF
      RR is amount of red from 0x00 to 0xFF
 81 - Set fill color where D1.L is color as 0x00BBGGRR
 82 - Draw pixel at X,Y in current pen color where X = D1.W & Y = D2.W.
      Not affected by drawing mode.
 83 - Get pixel color at X,Y and place in D0.L where X = D1.W & Y = D2.W.
 84 - Draw line from X1,Y1 to X2,Y2
      where X1 = D1.W, Y1 = D2.W, X2 = D3.W, Y2 = D4.W
 85 - Draw line to X,Y where X = D1.W & Y = D2.W
 86 - Move to X,Y where X = D1.W & Y = D2.W
 87 - Draw rectangle defined by (Left X, Upper Y, Right X, Lower Y). 
      where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W
      The rectangle is drawn using line color and filled using fill color.
 88 - Draw ellipse bounded by the rectangle (Left X, Upper Y, Right X, Lower Y)
      where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W
      The ellipse is drawn using line color and filled using fill color.
      A circle is drawn if the bounding rectangle is a square.
 89 - Flood Fill the area at X, Y with the fill color where X = D1.W & Y = D2.W
 90 - Draw unfilled rectangle defined by (Left X, Upper Y, Right X, Lower Y). 
      where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W
      The rectangle is drawn using line color and is not filled.
 91 - Draw unfilled ellipse bounded by the rectangle (Left X, Upper Y, Right X, Lower Y)
      where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W
      The ellipse is drawn using line color and is not filled.
      A circle is drawn if the bounding rectangle is a square.
 92 - Set drawing mode where D1.W is mode number as:
        0 - Always black
        1 - Always white
        2 - Unchanged
        3 - Inverse of background color
        4 - Use pen color specified with trap code 80
        5 - Inverse of pen color
        6 - Combination of pen color and inverse of background
        7 - Combination of colors common to both pen and inverse of background.
        8 - Combination of background color and inverse of pen color
        9 - Combination of colors common to both background and inverse of pen
       10 - Combination of pen color and background color
       11 - Inverse combination of pen color and background color
       12 - Combination of colors common to both pen and background
       13 - Inverse combination of colors common to both pen and background
       14 - Combination of colors in either pen or background, but not both
       15 - Inverse combination of colors in either pen or background, but not both
       16 - Turn off double buffering (default)
       17 - Enable double buffering. Draw on offscreen buffer
 93 - Set pen width where D1.B is width in pixels.
 94 - Repaint screen. Copies offscreeen buffer to visible screen.
 95 - Draw the NULL terminated string of text pointed to by (A1) to
      screen location X,Y where X = D1.W & Y = D2.W. The text is drawn as
      graphics and may not be read using trap task 22. Control characters are
      ignored. X,Y specifies the location of the top left corner of the text
 96 - Get X,Y pen position where D1.W = X & D2.W = Y


 -NETWORK I/O-

100 : CREATE CLIENT
     Pre:
       D1.L
       Bits (0-7) Low byte, 0 for UDP, all other values reserved
       Bits (8-15) = reserved
       Bits 16-31) contains port number
       Bits (16-31) reserved
       (A2) IP address to connect to as null terminated string (e.g. '192.168.1.100',0) or
            null terminated domain name (e.g. 'www.easy68k.com',0)
     Post:
       D0.L is 0 on success,
         non zero on error
         Low word (Bits 0-15)
           1 - general error
           2 - network init failed
           3 - invalid socket
           4 - get host by name failed
           5 - bind failed
           6 - connect failed
           7 - port in use
           8 - domain not found
           all other values reserved
         High word (Bits 16-31)
           extended error code
       (A2) IP address connected to as null terminated string

101 : CREATE SERVER
     Pre:
       D1.L
       Bits (0-7) Low byte, 0 for UDP, all other values reserved
       Bits (8-15) = reserved
       High word (Bits 16-31) contains port number
     Post:
       D0.L is 0 on success,
         non zero on error
         Low word (Bits 0-15)
           1 - general error
           2 - network init failed
           3 - invalid socket
           4 - get host by name failed
           5 - bind failed
           6 - connect failed
           7 - port in use
           8 - domain not found
           all other values reserved
         High word (Bits 16-31)
           extended error code

102 : SEND
     Pre:
       D1.L
       Low word (Bits 0-15) = number of bytes to send.
       High word (Bits 16-31) Reserved for future use.
       (A1) data to send
       If server
         (A2) IP address to send to as null terminated string (e.g. '192.168.1.100',0)
     Post:
       D0.L is 0 on success,
         non zero on error
         Low word (Bits 0-15)
           1 - send failed
           all other values reserved
         High word (Bits 16-31)
           extended error code
       D1.L number of bytes sent, may be 0. Unchanged on error.

103 : RECEIVE
     Pre:
       D1.L
       Low word (Bits 0-15) = number of bytes to receive.
       High word (Bits 16-31) Reserved for future use.
       (A1) receive buffer, must be large enough to hold D1.W bytes
     Post:
       D0.L is 0 on success,
         non zero on error
         Low word (Bits 0-15)
           1 - receive failed
           all other values reserved
         High word (Bits 16-31)
           extended error code
       D1.L number of bytes received, may be 0. Unchanged on error.
       (A2) IP address of sender as null terminated string

104 : CLOSE CONNECTION
     Pre:
       If TCP server
         D1.L IP address of connection to close, 0 to close all
     Post:
       D0.L is 0 on success, non zero on error

105 : GET LOCAL IP ADDRESS
     Pre: The network has been initialized with CREATE CLIENT or CREATE SERVER
     Post:
       D0.L is 0 on success,
         non zero on error
         Low word (Bits 0-15)
           1 - get local IP failed
           all other values reserved
         High word (Bits 16-31)
           extended error code
       (A2) contains local IP address as null terminated string (e.g. '192.168.1.100',0)
*/


int TRAP()
{
  int vector, cid, code;
  char *inStr;
  char buf[256];                        // temp buffer
  byte mouseIRQ, keyIRQ;

  vector = inst & 0x0F;
  if(vector == 15) {                    // if display vector
    switch ((char)D[0]) {               // which task ?
      case 0: case 1:                   // display D1.W chars
        inStr = &memory[A[1] & ADDRMASK];          // address of string
        strncpy(buf,inStr,255);         // make copy of string so we can terminate it
        if ((short)D[1] > 255)          // if D1 size > 255
          buf[255] = '\0';              // terminate at char 255
        else
          buf[(short)D[1]] = '\0';      // terminate at D1 char
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;

        if ((char)D[0])                 // if D0.B = 1
          simIO->textOut(buf);          // display string without CRLF
        else
          simIO->textOutCR(buf);        // display string with CRLF
        break;
      case 2:  // input
        inStr = &memory[A[1] & ADDRMASK];  // address of string
        simIO->textIn(inStr, &D[1], NULL); // read string into inStr, length in D1
        break;
      case 3:  // display number in D1.L
        itoa(D[1], buf, 10);            // convert D1.L to string, put in buf
        simIO->textOut(buf);            // display number without CRLF
        break;
      case 4:  // read number to D1.L   // inputBuf & inputSize must be global
        simIO->textIn(inputBuf, &inputSize, &D[1]); // read number to D1
        break;
      case 5:  // read char to D1.B
        simIO->charIn((char*)&D[1]);
        break;
      case 6:  // display char in D1.B
        simIO->charOut((char)D[1]);
        break;
      case 7:  // Set D1.B to 1 if keyboard input is pending, otherwise set to 0
        if(pendingKey) {
          D[1] &= 0xFFFFFF00;
          D[1] |= 0x00000001;
        } else {
          D[1] &= 0xFFFFFF00;
        }
        break;
      case 8:  // Return time in hundredths of a second since midnight in D1.L
        struct  time t;
        gettime(&t);
        D[1] = t.ti_hour * 60 * 60 * 100 +
               t.ti_min  * 60 * 100 +
               t.ti_sec  * 100 +
               t.ti_hund;
        break;
      case 9:  // terminate the program
        Form1->AutoTraceTimer->Enabled = false;
        trace = false;
        halt = true;
        Hardware->disable();
        Log->stopLogWithAnnounce();
        break;
      case 10:                  // print text at (A1)
          inStr = &memory[A[1] & ADDRMASK];        // address of string
          // check memory map
          code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
          if (code == BUS_ERROR)        // if bus error caused by memory map
            return code;
          while (*inStr)
            printChar(*inStr++);
        break;
      case 11: // position cursor at col,row. D1.W holds col,row as bytes
        if ((unsigned short)D[1] == 0xFF00)  // Clear Screen if D1.W is $FF00.
          simIO->clear();
        else if ((unsigned short)D[1] == 0x00FF) // Return cursor position
          simIO->getrc((short*)&D[1]);          // puts cursor position in D1.W
        else
          simIO->gotorc((char)D[1],(char)(D[1]>>8));
        break;
      case 12:  // keyboard echo (on/off)
        if ((char)D[1]==0)              // if D1.B = 0
          keyboardEcho = false;
        else
          keyboardEcho = true;
        break;
      case 13: case 14:           // Display NULL terminated string at (A1)
        inStr = &memory[A[1] & ADDRMASK];    // address of string
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        if ((char)D[0]==14)             // if D0.B = 14
          simIO->textOut(inStr);        // display string without CRLF
        else
          simIO->textOutCR(inStr);      // display string with CRLF
        break;
      case 15:                    // Display D1 converted to radix in D2.B
        if ((char)D[2]>=2 && (char)D[2]<=36) {   // if 2 <= D2.B <= 36
          ultoa(D[1], buf, (char)D[2]);  // convert D1.L to string, put in buf
          AnsiString hex = buf;
          hex = hex.UpperCase();         // convert to upper case
          simIO->textOut(hex.c_str());   // display number without CRLF
        }
        break;
      case 16:                    // turn input prompt on/off
        if ((char)D[1]==0)              // if D1.B = 0
          inputPrompt = false;
        else if ((char)D[1]==1)
          inputPrompt = true;
        else if ((char)D[1]==2)
          inputLFdisplay = false;
        else if ((char)D[1]==3)
          inputLFdisplay = true;
        break;
      // Displays the NULL terminated string at (A1) without CRLF
      //  then displays the decimal number in D1.L.
      case 17:
        inStr = &memory[A[1] & ADDRMASK];    // address of string
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->textOut(inStr);    // display string without CRLF
        itoa(D[1], buf, 10);      // convert D1.L to string, put in buf
        simIO->textOut(buf);      // display number without CRLF
        break;
      // Displays the NULL terminated string at (A1) without CRLF
      //  then reads a number from the keyboard into D1.L.
      case 18:
        inStr = &memory[A[1] & ADDRMASK];    // address of string
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->textOut(inStr);    // display string without CRLF
        simIO->textIn(inputBuf, &inputSize, &D[1]); // read number to D1
        break;
      // get keypress state
      case 19:
        simIO->getKeyState(&D[1]);
        break;
      case 20:
        sprintf(buf,"%*d",(char)D[2],D[1]);
        simIO->textOut(buf);            // display number without CRLF
        break;
      case 21:                          // if set font color
        simIO->setFontProperties(D[1], D[2]);
        break;
      case 22:                          // return character at Row, Col in D1
        simIO->getCharAt((ushort)(D[1]>>16), (ushort)D[1], (char*)&D[1]);
        break;
      case 23:                          // delay D1/100 second
        {uint n = (unsigned)D[1];
        while(n-- > 0 && runMode) {
          Application->ProcessMessages();
          Sleep(10);                    // delay 1/100 second
        }}
        break;
      case 24:
        if (D[1] == 0) {                // disable simulator key actions
          Form1->restoreMenuTask19();
        } else if (D[1] == 1) {
          Form1->setMenuTask19();
        }
        break;
      case 25:                          // scroll text window at Row, Col, Height, Width, Up or Down
        simIO->scrollRect( (ushort)(D[1]>>16), (ushort)D[1], (ushort)(D[2]>>16), (ushort)D[2], (ushort)D[3] );
        break;
      // ------------------SIMULATOR ENVIRONMENT------------------------
      case 30:                  // - Clear cycle counter
        cycles = 0;
        break;
      case 31:                  // - Return cycle counter in D1.L.
        if (cycles > 0xFFFFFFFF)        // if cycles > 32 bit
          D[1] = 0;             // return 0
        else
          D[1] = (uint)cycles;  // return cycles
        break;
      case 32:                  // - Hardware
        //AnsiString str = "0x";
        switch ((char)D[1]) {  // which sub task ?
          case 00:              // display hardware window
            Hardware->Show();
            break;
          case 01:              // return address of 7-segment display in D1.L
            D[1] = StrToInt("0x" + Hardware->seg7addr->EditText);
            break;
          case 02:              // return address of LEDs in D1.L
            D[1] = StrToInt("0x" + Hardware->LEDaddr->EditText);
            break;
          case 03:              // return address of toggle switches in D1.L
            D[1] = StrToInt("0x" + Hardware->switchAddr->EditText);
            break;
          case 04:              // return sim68k version number in D1.L
            D[1] = VERSION;
            break;
          case 05:              // enable exception processing
            exceptions = true;
            Form1->ExceptionsEnabled->Checked = true;
            Form1->SaveSettings();
            break;
          case 06:              // set auto IRQ
            Hardware->setAutoIRQ((uchar)D[2], D[3]);
            break;
          case 07:              // return address of push button switches in D1.L
            D[1] = StrToInt("0x" + Hardware->pbAddr->EditText);
            break;
        }
        break;
      case 33:                  // get/set Output Window Size
        if(D[1] == 1) {         // if set windowed mode
          simIO->fullScreen = false;
          simIO->setupWindow();
        } else if(D[1] == 2) {  // if set fullscreen mode
          simIO->fullScreen = true;
          simIO->setupWindow();
        } else if(D[1]) {       // if set size
          simIO->setWindowSize((short)(D[1]>>16),(short)D[1]);
        } else {                // get size
          ushort width, height;
          simIO->getWindowSize(width, height);
          D[1] = (((uint)width)<<16) + height;
        }
        break;

      // ---------------------- SERIAL I/O ----------------------------
      case 40:                  // if Init Serial Port
        inStr = &memory[A[1] & ADDRMASK];  // address of port name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(buf));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        cid = (unsigned int)D[0];
        cid = cid>>16;
        simIO->initComm(cid, buf, (short*)&D[0]);
        break;
      case 41:                  // if Set Port Parameters
        cid = (unsigned int)D[0];
        cid = cid>>16;
        simIO->setCommParams(cid, D[1], (short*)&D[0]);
        break;
      case 42:                  // if Read String
        cid = (unsigned int)D[0];
        cid = cid>>16;
        simIO->readComm(cid, (uchar*)&D[1], &memory[A[1] & ADDRMASK], (short*)&D[0]);
        break;
      case 43:                  // if Send String
        cid = (unsigned int)D[0];
        cid = cid>>16;
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), (uchar)D[1]);
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->sendComm(cid, (uchar*)&D[1], &memory[A[1] & ADDRMASK], (short*)&D[0]);
        break;

      // ----------------------FILE HANDLING----------------------------
      case 50:                          // CLOSE ALL FILES
        closeFiles((short*)&D[0]);
        break;
      case 51:                          // OPEN EXISTING file.
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        openFile(&D[1], buf, (short*)&D[0]);
        break;
      case 52:                          // OPEN NEW FILE.
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        newFile(&D[1], buf, (short*)&D[0]);
        break;
      case 53:                          // READ FILE.
        // if data would overflow 68000 memory space
        if ((unsigned int)((A[1] & ADDRMASK) + (unsigned int)D[2]) > MEMSIZE)
          D[0] = (D[0] & 0xFFFF0000) | F_ERROR; // set error code
        else {
          // check memory map
          code = memoryMapCheck(Invalid | Read | Rom, (A[1] & ADDRMASK), (unsigned int)D[2]);
          if (code == BUS_ERROR)        // if bus error caused by memory map
            return code;
          if (code == SUCCESS)
            readFile(D[1], &memory[A[1] & ADDRMASK], (unsigned int*)&D[2], (short*)&D[0]);
        }
        break;
      case 54:                          // WRITE FILE.
        // if write size goes beyond end of 68000 memory space
        if ((unsigned int)((A[1] & ADDRMASK) + (unsigned int)D[2]) > MEMSIZE)
          D[0] = (D[0] & 0xFFFF0000) | F_ERROR; // set error code
        else {
          // check memory map
          code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), (unsigned int)D[2]);
          if (code == BUS_ERROR)        // if bus error caused by memory map
            return code;
          writeFile(D[1], &memory[A[1] & ADDRMASK], (unsigned int)D[2], (short*)&D[0]);
        }
        break;
      case 55:                          // POSITION FILE.
        positionFile(D[1], D[2], (short*)&D[0]);
        break;
      case 56:                          // CLOSE FILE.
        closeFile(D[1], (short*)&D[0]);
        break;
      case 57:                          // DELETE FILE.
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        deleteFile(buf, (short*)&D[0]);
        break;
      case 58:                          // DISPLAY FILE DIALOG.
        simIO->displayFileDialog(&D[1], A[1], A[2], A[3], (short*)&D[0]);
        break;
      case 59:                          // file operation.
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        fileOp(&D[1], buf, (short*)&D[0]);
        break;

      // -------------------- MOUSE -----------------------------
      case 60:                  // enable/disable mouse IRQ
        mouseIRQ = (byte)(D[1] >> 8);
        if (mouseIRQ > 7)       // if invalid IRQ number
          break;
        if (D[1] & 0x0001)      // if button down IRQ
          mouseDownIRQ = mouseIRQ;
        if (D[1] & 0x0002)      // if button up IRQ
          mouseUpIRQ = mouseIRQ;
        if (D[1] & 0x0004)      // if move IRQ
          mouseMoveIRQ = mouseIRQ;
        break;
      case 61:                  // Mouse Read
        D[0] = 0;
        if ((char)D[1] == 0) {  // if current state of mouse
          if (mouseLeft)
            D[0] = 1;
          if (mouseRight)
            D[0] += 0x02;
          if (mouseMiddle)
            D[0] += 0x04;
          if (mouseDouble)
            D[0] += 0x08;
          if (keyShift)
            D[0] += 0x10;
          if (keyAlt)
            D[0] += 0x20;
          if (keyCtrl)
            D[0] += 0x40;
          D[1] = (mouseY << 16) | (ushort)mouseX;
        } else if ((char)D[1] == 1) {   // if mouse up state
          if (mouseLeftUp)
            D[0] = 1;
          if (mouseRightUp)
            D[0] += 0x02;
          if (mouseMiddleUp)
            D[0] += 0x04;
          if (mouseDoubleUp)
            D[0] += 0x08;
          if (keyShiftUp)
            D[0] += 0x10;
          if (keyAltUp)
            D[0] += 0x20;
          if (keyCtrlUp)
            D[0] += 0x40;
          D[1] = (mouseYUp << 16) | (ushort)mouseXUp;
        } else if ((char)D[1] == 2) {   // if mouse down state
          if (mouseLeftDown)
            D[0] = 1;
          if (mouseRightDown)
            D[0] += 0x02;
          if (mouseMiddleDown)
            D[0] += 0x04;
          if (mouseDoubleDown)
            D[0] += 0x08;
          if (keyShiftDown)
            D[0] += 0x10;
          if (keyAltDown)
            D[0] += 0x20;
          if (keyCtrlDown)
            D[0] += 0x40;
          D[1] = (mouseYDown << 16) | (ushort)mouseXDown;
        }
        break;

      // -------------------- Keyboard IRQ ---------------------------
      case 62:                  // enable/disable Key IRQ
        keyIRQ = (byte)(D[1] >> 8);
        if (keyIRQ > 7)         // if invalid IRQ number
          break;
        if (D[1] & 0x0001)      // if key down IRQ
          keyDownIRQ = keyIRQ;
        if (D[1] & 0x0002)      // if key up IRQ
          keyUpIRQ = keyIRQ;
        break;
      // -------------------- SOUND -----------------------------
      case 70:                  // if play WAV file
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->playSound(buf, (short*)&D[0]);
        break;
      case 71:                  // if load WAV file
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->loadSound(buf, (unsigned char) D[1]);
        break;
      case 72:                  // if play WAV from memory
        simIO->playSoundMem((unsigned char) D[1], (short*)&D[0]);
        break;
      case 73:                  // if play WAV file using DirectX
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->playSoundDX(buf, (short*)&D[0]);
        break;
      case 74:                  // if load WAV file into DirectX memory
        inStr = &memory[A[1] & ADDRMASK];  // address of file name string
        strncpy(buf,inStr,255); // make copy of string so we can terminate it
        buf[255] = '\0';        // Terminated!, in case it wasn't already
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->loadSoundDX(buf, (unsigned char) D[1], (short*)&D[0]);
        break;
      case 75:                  // if play WAV from DirectX memory
        simIO->playSoundMemDX((unsigned char) D[1], (short*)&D[0]);
        break;
      case 76:                  // control standard player
        simIO->controlSound((unsigned int) D[2], (unsigned char) D[1], (short*)&D[0]);
        break;
      case 77:                  // control DirectX player
        simIO->controlSoundDX((unsigned int) D[2], (unsigned char) D[1], (short*)&D[0]);
        break;

      // -------------------- GRAPHICS -----------------------------
      case 80:                  // if set line color
        simIO->setLineColor(D[1]);
        break;
      case 81:                  // if set fill color
        simIO->setFillColor(D[1]);
        break;
      case 82:                  // if drawPixel
        simIO->drawPixel((short)D[1],(short)D[2]);
        break;
      case 83:                  // if getPixel
        D[0] = simIO->getPixel((short)D[1], (short)D[2]);
        break;
      case 84:                  // if line
        simIO->line((short)D[1], (short)D[2], (short)D[3], (short)D[4]);
        break;
      case 85:                  // if lineTo
        simIO->lineTo((short)D[1], (short)D[2]);
        break;
      case 86:                  // if moveTo
        simIO->moveTo((short)D[1], (short)D[2]);
        break;
      case 87:                  // if rectangle
        simIO->rectangle((short)D[1], (short)D[2], (short)D[3], (short)D[4]);
        break;
      case 88:                  // if ellipse
        simIO->ellipse((short)D[1], (short)D[2], (short)D[3], (short)D[4]);
        break;
      case 89:                  // if flood fill
        simIO->floodFill((short)D[1], (short)D[2]);
        break;
      case 90:                  // if unfilled rectangle
        simIO->unfilledRectangle((short)D[1], (short)D[2], (short)D[3], (short)D[4]);
        break;
      case 91:                  // if unfilled ellipse
        simIO->unfilledEllipse((short)D[1], (short)D[2], (short)D[3], (short)D[4]);
        break;
      case 92:                  // if set pen mode
        simIO->setDrawingMode(D[1]);
        break;
      case 93:                  // if set pen width
        simIO->setPenWidth(D[1]);
        break;
      case 94:                  // if repaint
        simIO->FormPaint((TObject *)simIO);
        break;
      case 95:                  // Draw NULL terminated string at (A1) to X,Y in D1.W & D2.W
        inStr = &memory[A[1] & ADDRMASK];          // address of string
        // check memory map
        code = memoryMapCheck(Invalid, (A[1] & ADDRMASK), strlen(inStr));
        if (code == BUS_ERROR)        // if bus error caused by memory map
          return code;
        simIO->drawText(inStr, (short)D[1], (short)D[2]); // display string
        break;
      case 96:                  // Get X,Y pen position where D1.W = X & D2.W = Y
        simIO->getXY((short*)&D[1],(short*)&D[2]);
        break;

      // -------------------- NETWORK -----------------------------
      case 100:                  // if Create Client
        simIO->createNetClient(D[1], &memory[A[2] & ADDRMASK], (int*)&D[0]);
        break;
      case 101:                  // if Create Server
        simIO->createNetServer(D[1], (int*)&D[0]);
        break;
      case 102:                  // if Send (Deprecated)
        simIO->sendNet(D[1], &memory[A[1] & ADDRMASK], &memory[A[2] & ADDRMASK], (int*)&D[1], (int*)&D[0]);
        break;
      case 103:                  // if Receive (Deprecated)
        simIO->receiveNet(D[1], &memory[A[1] & ADDRMASK], (int*)&D[1], &memory[A[2] & ADDRMASK], (int*)&D[0]);
        break;
      case 104:                  // if Close Connection
        simIO->closeNetConnection(D[1], (int*)&D[0]);
        break;
      case 105:                  // if Get Local IP
        simIO->getLocalIP(&memory[A[2] & ADDRMASK], (int*)&D[0]);
        break;
      case 106:                  // if Send on port
        simIO->sendPortNet(&D[0], &D[1], &memory[A[1] & ADDRMASK], &memory[A[2] & ADDRMASK]);
        break;
      case 107:                  // if Receive data and port
        simIO->receivePortNet(&D[0], &D[1], &memory[A[1] & ADDRMASK], &memory[A[2] & ADDRMASK]);
        break;
      default:
        return (TRAP_TRAP);
    } // switch
    return SUCCESS;
  }else
    return (TRAP_TRAP);
}




int	TRAPV()
{

if (SR & vbit)
	return (TRAPV_TRAP);

inc_cyc (4);

return SUCCESS;

}

int     LINE1010()
{
  return LINE_1010;
}

// Fxxx instruction.
// A special case is FFFF FFFF the Sim68K command (SIMHALT) to stop execution.
int     LINE1111()
{
  long	temp;
  mem_req (PC, (long) WORD_MASK, &temp);
  if(inst == 0xFFFF && temp == 0xFFFF && simhalt_on)  // if SIMHALT command
  {
    PC += 2;    // position at next instruction
    Form1->AutoTraceTimer->Enabled = false;
    trace = false;
    halt = true;
    Hardware->disable();
    Log->stopLogWithAnnounce();
    return SUCCESS;
  }
  return LINE_1111;
}















