/*  coco.h - Utility functions for interface with CoCo Disk Basic

    By Pierre Sarrazin <http://sarrazip.com/>.
    This file is in the public domain.
*/

#ifndef _coco_h_
#define _coco_h_

#include <cmoc.h>


#ifndef NULL
#define NULL ((void *) 0)
#endif


enum { FALSE, TRUE };

#ifndef _CMOC_HAVE_BOOL_
typedef unsigned char BOOL;
#define _CMOC_HAVE_BOOL_
#endif


#ifndef _CMOC_BASIC_TYPES_
#define _CMOC_BASIC_TYPES_

typedef unsigned char byte;
typedef signed char   sbyte;
typedef unsigned int  word;
typedef signed int    sword;
typedef unsigned long dword;
typedef signed long   sdword;

#endif

typedef unsigned char uint8_t;
typedef signed char   int8_t;
typedef unsigned int  uint16_t;
typedef signed int    int16_t;
typedef unsigned long uint32_t;
typedef signed long   int32_t;


#ifdef _COCO_BASIC_


/*  Registers U and Y must be saved in the stack
    while calling CoCo BASIC routines.
*/

byte isCoCo3 = FALSE;


// May be called more than once.
//
void initCoCoSupport()
{
    word irqServiceRoutineAddress = * (word *) 0xFFF8;
    isCoCo3 = (irqServiceRoutineAddress == 0xFEF7);
}


void setHighSpeed(byte fast)
{
    asm
    {
        ldx     #65494
        tst     fast
        beq     setHighSpeed_010
        leax    1,x
setHighSpeed_010:
        tst     isCoCo3
        beq     setHighSpeed_020
        leax    2,x
setHighSpeed_020:
        clr     ,x
    }
}


byte resetPalette(byte isRGB)
{
    if (!isCoCo3)
        return FALSE;

    // Fix bug in CoCo 3 BASIC's RGB and CMP commands.
    if (* (byte *) 0xE649 == 15)
        * (byte *) 0xE649 = 16;

    // Jump to RGB or CMP routine.
    asm("PSHS", "U,Y");  // protect against BASIC routine
    if (isRGB)
        asm("JSR", "$E5FA");
    else
        asm("JSR", "$E606");
    asm("PULS", "Y,U");
    return TRUE;  // success
}


// slot: 0..15.
// color: 0..63.
// Returns true for success, false if args are invalid.
// See also paletteRGB().
//
byte palette(byte slot, byte color)
{
    if (!isCoCo3)
        return FALSE;
    if (slot > 15)
        return FALSE;
    if (color > 63)
        return FALSE;
    byte *palette = (byte *) 0xFFB0;
    palette[slot] = color;
    return TRUE;
}


// Easier interface when assuming an RGB monitor.
// slot: 0..15.
// red, green, blue: 0..3.
//
void paletteRGB(byte slot, byte red, byte green, byte blue)
{
    if (!isCoCo3)
        return;
    if (slot > 15)
        return;
    * (((byte *) 0xFFB0) + slot) = ((red   & 2) << 4)
                                   | ((red   & 1) << 2)
                                   | ((green & 2) << 3)
                                   | ((green & 1) << 1)
                                   | ((blue  & 2) << 2)
                                   |  (blue  & 1);
}


// Sets the given 6-bit color code as the border color
// for the 40 and 80 column modes.
//
byte setBorderColor(byte color)
{
    if (!isCoCo3)
        return FALSE;

    * (byte *) 0xFF9A = color;
    return TRUE;
}


byte textScreenWidth  = 32;
byte textScreenHeight = 16;


// Returns true for success, false if arg is invalid.
//
byte width(byte columns)
{
    if (!isCoCo3)
        return FALSE;

    if (columns != 32 && columns != 40 && columns != 80)
        return FALSE;

    asm("PSHS", "U,Y");  // protect against BASIC routine
    asm("LDB", columns);
    asm("JSR", "$F643");  // inside the WIDTH command
    asm("PULS", "Y,U");

    textScreenWidth = columns;
    textScreenHeight = (columns == 32 ? 16 : 24);

    return TRUE;
}


// Returns 32, 40 or 80.
//
byte getTextMode()
{
    if (isCoCo3)
    {
        byte hrWidth = * (byte *) 0x00E7;
        if (hrWidth == 1)
            return 40;
        if (hrWidth == 2)
            return 80;
    }
    return 32;
}


// color: Argument that would be passed to BASIC's CLS command.
//        Pass 255 to signify no argument.
//
void cls(byte color)
{
    asm("PSHS", "U,Y");  // protect against BASIC routine
    byte hrwidth;
    if (isCoCo3)
        hrwidth = * (byte *) 0x00E7;
    else
        hrwidth = 0;

    if (hrwidth != 0)
    {
        if (color > 8)
            color = 1;
        // This is the hi-res CLS routine,
        // which must not be called in 32 column mode.
        asm("LDB", color);
        asm("JSR", "$F6B8");
    }
    else if (color > 8)
    {
        asm("JSR", "$A928");
    }
    else
    {
        asm("LDB", color);
        asm("JSR", "$A91C");
    }
    asm("PULS", "Y,U");
}


// foreColor: 0-7.
// backColor: 0-7.
// blink, underline: booleans.
//
byte attr(byte foreColor, byte backColor, byte blink, byte underline)
{
    if (!isCoCo3)
        return FALSE;

    // Bits 0-2: background color (0-7)
    // Bits 3-5: foreground color (0-7)
    // Bits 6: underline if set.
    // Bits 7: blink if set.
    //
    asm
    {
        ldb     foreColor
        lslb
        lslb
        lslb
        orb     backColor
        tst     blink
        beq     attr_no_b
        orb     #$80
attr_no_b:
        tst     underline
        beq     attr_no_u
        orb     #$40
attr_no_u:
        stb     $FE08
    }

    return TRUE;
}


byte locate(byte column, byte row)
{
    byte hrwidth;
    if (isCoCo3)
        hrwidth = * (byte *) 0x00E7;
    else
        hrwidth = 0;

    if (hrwidth == 0)  // if 32 col mode
    {
        if (column >= 32)
            return FALSE;
        if (row >= 16)
            return FALSE;
        * (word *) 0x0088 = 1024 + (((word) row) << 5) + column;
    }
    else
    {
        if (column >= 80)
            return FALSE;
        if (row >= 24)
            return FALSE;
        if (hrwidth == 1)  // if 40 col mode
            if (column >= 40)
                return FALSE;
        asm("PSHS", "U,Y");  // protect against BASIC routine
        asm("LDA", column);
        asm("LDB", row);
        asm("JSR", "$F8F7");  // inside the LOCATE command
        asm("PULS", "Y,U");
    }
    return TRUE;
}


byte hscreen(byte mode)
{
    if (!isCoCo3)
        return FALSE;

    if (mode > 4)
        return FALSE;
    asm("PSHS", "U,Y");  // protect against BASIC routine
    asm("LDB", mode);
    asm("JSR", "$E69C");
    asm("PULS", "Y,U");
    return TRUE;
}


byte hset(word x, word y, byte color)
{
    if (x >= 640 || y >= 192 || color >= 16)
        return FALSE;
    byte hrmode = * (byte *) 0x00E6;
    if (hrmode == 0)
        return FALSE;  // hi-res mode not enabled
    if (hrmode <= 2)
        if (x >= 320)
            return FALSE;
    * (byte *) 0x00C2 = 1;  // SETFLG: 1 = HSET, 0 = HRESET
    * (word *) 0x00BD = x;  // HORBEG
    * (word *) 0x00BF = y;  // VERBEG
    asm("PSHS", "U,Y");  // protect against BASIC routine
    asm("LDB", color);
    asm("JSR", "$E73B");  // save the working color
    asm("JSR", "$E785");  // put the pixel on the screen
    asm("PULS", "Y,U");
    return TRUE;
}


void setCaseFlag(byte upperCase)
{
    if (upperCase != 0)
        upperCase = 0xFF;
    * (byte *) 0x11a = upperCase;
}


#if 0  // Untested.

// Calls BASIC's NEW command.
//
void newBasicProgram()
{
    asm("PSHS", "U,Y");  // protect against BASIC routine
    asm("JSR", "$AD19");
    asm("PULS", "Y,U");
}


void warmStart()
{
    asm("JMP", "$A027");  // EXEC 40999
}

#endif  // Untested


void coldStart()
{
    asm("CLR", "$71");    // POKE 113,0
    asm("JMP", "$A027");  // EXEC 40999
}


// Returns 0 if no key is currently pressed.
//
byte asm inkey()
{
    asm
    {
        jsr     [$A000]     // POLCAT
        tfr     a,b         // byte return value goes in B
    }
}


// Waits for a key to be pressed and returns its code.
//
byte waitkey(byte blinkCursor)
{
    byte key;
    if (blinkCursor)
    {
        asm
        {
            jsr $A1B1  // blink cursor while waiting for a keystroke
            sta key
        }
        return key;
    }

    for (;;)
    {
        key = inkey();
        if (key)
            return key;
    }
}


// Names for values that can be passed to isKeyPressed()
// to test if a key is down or not.
//
enum KeyboardBits
{
    KEY_PROBE_AT        = 0xFE, KEY_BIT_AT        = 0x01,
    KEY_PROBE_A         = 0xFD, KEY_BIT_A         = 0x01,
    KEY_PROBE_B         = 0xFB, KEY_BIT_B         = 0x01,
    KEY_PROBE_C         = 0xF7, KEY_BIT_C         = 0x01,
    KEY_PROBE_D         = 0xEF, KEY_BIT_D         = 0x01,
    KEY_PROBE_E         = 0xDF, KEY_BIT_E         = 0x01,
    KEY_PROBE_F         = 0xBF, KEY_BIT_F         = 0x01,
    KEY_PROBE_G         = 0x7F, KEY_BIT_G         = 0x01,
    KEY_PROBE_H         = 0xFE, KEY_BIT_H         = 0x02,
    KEY_PROBE_I         = 0xFD, KEY_BIT_I         = 0x02,
    KEY_PROBE_J         = 0xFB, KEY_BIT_J         = 0x02,
    KEY_PROBE_K         = 0xF7, KEY_BIT_K         = 0x02,
    KEY_PROBE_L         = 0xEF, KEY_BIT_L         = 0x02,
    KEY_PROBE_M         = 0xDF, KEY_BIT_M         = 0x02,
    KEY_PROBE_N         = 0xBF, KEY_BIT_N         = 0x02,
    KEY_PROBE_O         = 0x7F, KEY_BIT_O         = 0x02,
    KEY_PROBE_P         = 0xFE, KEY_BIT_P         = 0x04,
    KEY_PROBE_Q         = 0xFD, KEY_BIT_Q         = 0x04,
    KEY_PROBE_R         = 0xFB, KEY_BIT_R         = 0x04,
    KEY_PROBE_S         = 0xF7, KEY_BIT_S         = 0x04,
    KEY_PROBE_T         = 0xEF, KEY_BIT_T         = 0x04,
    KEY_PROBE_U         = 0xDF, KEY_BIT_U         = 0x04,
    KEY_PROBE_V         = 0xBF, KEY_BIT_V         = 0x04,
    KEY_PROBE_W         = 0x7F, KEY_BIT_W         = 0x04,
    KEY_PROBE_X         = 0xFE, KEY_BIT_X         = 0x08,
    KEY_PROBE_Y         = 0xFD, KEY_BIT_Y         = 0x08,
    KEY_PROBE_Z         = 0xFB, KEY_BIT_Z         = 0x08,
    KEY_PROBE_UP        = 0xF7, KEY_BIT_UP        = 0x08,
    KEY_PROBE_DOWN      = 0xEF, KEY_BIT_DOWN      = 0x08,
    KEY_PROBE_LEFT      = 0xDF, KEY_BIT_LEFT      = 0x08,
    KEY_PROBE_RIGHT     = 0xBF, KEY_BIT_RIGHT     = 0x08,
    KEY_PROBE_SPACE     = 0x7F, KEY_BIT_SPACE     = 0x08,
    KEY_PROBE_0         = 0xFE, KEY_BIT_0         = 0x10,
    KEY_PROBE_1         = 0xFD, KEY_BIT_1         = 0x10,
    KEY_PROBE_2         = 0xFB, KEY_BIT_2         = 0x10,
    KEY_PROBE_3         = 0xF7, KEY_BIT_3         = 0x10,
    KEY_PROBE_4         = 0xEF, KEY_BIT_4         = 0x10,
    KEY_PROBE_5         = 0xDF, KEY_BIT_5         = 0x10,
    KEY_PROBE_6         = 0xBF, KEY_BIT_6         = 0x10,
    KEY_PROBE_7         = 0x7F, KEY_BIT_7         = 0x10,
    KEY_PROBE_8         = 0xFE, KEY_BIT_8         = 0x20,
    KEY_PROBE_9         = 0xFD, KEY_BIT_9         = 0x20,
    KEY_PROBE_COLON     = 0xFB, KEY_BIT_COLON     = 0x20,
    KEY_PROBE_SEMICOLON = 0xF7, KEY_BIT_SEMICOLON = 0x20,
    KEY_PROBE_COMMA     = 0xEF, KEY_BIT_COMMA     = 0x20,
    KEY_PROBE_HYPHEN    = 0xDF, KEY_BIT_HYPHEN    = 0x20,
    KEY_PROBE_PERIOD    = 0xBF, KEY_BIT_PERIOD    = 0x20,
    KEY_PROBE_SLASH     = 0x7F, KEY_BIT_SLASH     = 0x20,
    KEY_PROBE_ENTER     = 0xFE, KEY_BIT_ENTER     = 0x40,
    KEY_PROBE_CLEAR     = 0xFD, KEY_BIT_CLEAR     = 0x40,
    KEY_PROBE_BREAK     = 0xFB, KEY_BIT_BREAK     = 0x40,
    KEY_PROBE_ALT       = 0xF7, KEY_BIT_ALT       = 0x40,
    KEY_PROBE_CTRL      = 0xEF, KEY_BIT_CTRL      = 0x40,
    KEY_PROBE_F1        = 0xDF, KEY_BIT_F1        = 0x40,
    KEY_PROBE_F2        = 0xBF, KEY_BIT_F2        = 0x40,
    KEY_PROBE_SHIFT     = 0x7F, KEY_BIT_SHIFT     = 0x40,
};


// Writes 'out' to $FF02 and tests the bit specified by 'testBit'.
// Returns non-zero iff the designated key is currently pressed.
// Example: isKeyPressed(0x7F, 0x08) checks for the space key.
// For details, look for a CoCo keyboard grid diagram.
//
asm byte isKeyPressed(byte probe, byte testBit)
{
    asm
    {
        ldb     3,s     ; probe
        stb     $FF02
        ldb     $FF00
        andb    5,s     ; testBit
        eorb    5,s
    }
}


// Indices into the POTVAL array whose address is returned
// by readJoystickPositions().
//
enum
{
    JOYSTK_RIGHT_HORIZ = 0,
    JOYSTK_RIGHT_VERT  = 1,
    JOYSTK_LEFT_HORIZ  = 2,
    JOYSTK_LEFT_VERT   = 3,
};


enum
{
    JOYSTK_MAX = 63,  // max value in a POTVAL entry (min is 0)
};


// Reads the joysticks and returns the address of a 4-byte array
// that contains the 0..63 values that would be returned by
// JOYSTK(0..3) in Color Basic.
//
asm const byte *readJoystickPositions()
{
    asm
    {
        pshs    u,y     ; protect against Color Basic
        jsr     $A9DE   ; GETJOY
        jsr     $A976   ; turn audio back on (GETJOY turns it off)
        puls    y,u
        ldd     #$015A  ; return POTVAL
    }
}


// Bit names to be used on the value returned by readJoystickButtons().
//
enum
{
    JOYSTK_BUTTON_1_RIGHT = 0x01,
    JOYSTK_BUTTON_2_RIGHT = 0x02,
    JOYSTK_BUTTON_1_LEFT  = 0x04,
    JOYSTK_BUTTON_2_LEFT  = 0x08,
};


// Reads the state of all 4 supported joystick buttons.
// Returns a 4-bit value:
// - bit 0: button 1 of right joystick;
// - bit 1: button 2 of right joystick;
// - bit 2: button 1 of left joystick;
// - bit 3: button 2 of left joystick.
//
asm byte readJoystickButtons()
{
    asm
    {
        ldb     #$FF    ; set column strobe to check buttons
        stb     $FF02   ; PIA0+2
        ldb     $FF00   ; PIA0
        andb    #$0F    ; return low 4 bits
    }
}


// Same arguments as Color Basic's SOUND command.
//
void sound(byte tone, byte duration)
{
    asm("PSHS", "U");  // protect U from Color Basic code
    * (byte *) 0x8C = tone;
    * (word *) 0x8D = ((word) duration) << 2;
    asm("JSR", "$A956");
    asm("PULS", "U");
}


#define DEV_SCREEN     0
#define DEV_CASSETTE (-1)
#define DEV_SERIAL   (-2)
#define DEV_PRINTER  DEV_SERIAL

void asm setOutputDevice(sbyte deviceNum)
{
    asm
    {
        ldb     3,s     // deviceNum
        stb     $6F     // Color Basic's DEVNUM
    }
}


// newValue: word value.
//
#define setTimer(newValue) (* (word *) 0x112 = (newValue))

// Returns a word.
//
#define getTimer() (* (word *) 0x112)


// seconds: 0..1092.
//
void sleep(int seconds)
{
    if (!seconds)
        return;
    unsigned limit = 60 * (unsigned) seconds; 
    setTimer(0);
    while (getTimer() < limit)
        ;
}


// samAddr: Base address to write to (0xFFC0 for screen mode,
//          0xFFC6 for graphics page address).
// value:   Value to write.
// numBits: Number of bits to write to samAddr. (Refers to the
//          least significant bits of 'value'.)
// 
void setSAMRegisters(byte *samAddr, byte value, byte numBits)
{
    while (numBits)
    {
        // Write at even address to send a 0, odd to send a 1.
        //
        *(samAddr + (value & 1)) = 0;

        value = value >> 1;

        --numBits;

        // Next SAM bit is two addresses further.
        //
        samAddr += 2;
    }
}


// Writes the given byte in the 6k PMODE 4 screen buffer (0x1800 bytes long)
// starting at the address given by 'textScreenBuffer'.
//
void pcls(byte *buffer, byte byteToClearWith)
{
    word *end = (word *) (buffer + 0x1800);

    asm {
        lda     byteToClearWith
        tfr     a,b
        ldx     buffer
pcls_loop:
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        std     ,x++
        cmpx    end
        bne     pcls_loop
    }
}


// pageNum: 512-byte page index in 0..127.
// Sets the SAM registers to show the PMODE 4 graphics
// at address pageNum * 512.
//
void showGraphicsAddress(byte pageNum)
{
    setSAMRegisters((byte *) 0xFFC6, pageNum, 7);
    setSAMRegisters((byte *) 0xFFC0, 6, 3);
}


// Set "PMODE 4 : SCREEN 1,colorset", where colorset is 0 (green/black)
// or 1 (white/black).
//
void showPmode4(byte colorset)
{
    byte *pia1bData = (byte *) 0xff22;
    byte b = *pia1bData & 7 | 0xf0;
    if (colorset)
         b |= 8;
    *pia1bData = b;
}


// Select the 32x16 text mode and position the screen buffer at address 1024.
//
void showLowResTextAddress()
{
    setSAMRegisters((byte *) 0xFFC6, 2, 7);  // 2 == 0x0400 / 512
    setSAMRegisters((byte *) 0xFFC0, 0, 3);  // 0 == 32x16 mode
}


// Show the text mode.
//
void asm showPmode0()
{
    asm
    {
        ldb     $FF22
        andb    #7
        stb     $FF22
    }
}


#else  /* !defined _COCO_BASIC_ */


byte textScreenWidth  = 80;
byte textScreenHeight = 24;


void coldStart()
{
    asm { sync }  // stops usim
}


byte asm inkey()
{
    asm
    {
        ldb $ff00   // assumed a properly modified usim 6809 simulator
    }
}


// Waits for a key to be pressed and returns its code.
//
byte waitkey(byte blinkCursor)
{
    byte key;
    for (;;)
    {
        key = inkey();
        if (key)
        {
            if (key != '\n')
                while (inkey() != '\n')  //PATCH: need cbreak mode
                    ;
            return key;
        }
    }
}


#endif  /* !defined _COCO_BASIC_ */


#define disableInterrupts() asm("ORCC",  "#$50")
#define enableInterrupts()  asm("ANDCC", "#$AF")


#endif  /* _coco_h_ */
