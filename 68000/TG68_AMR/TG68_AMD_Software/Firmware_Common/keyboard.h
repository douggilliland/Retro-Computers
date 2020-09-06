#ifndef KEYBOARD_H
#define KEYBOARD_H

#define KEY_EXT 0xe0
#define KEY_KEYUP 0xf0

#define KEY_F1  0x5
#define KEY_F2 	0x6
#define KEY_F3 	0x4
#define KEY_F4 	0x0C 
#define KEY_F5 	0x3
#define KEY_F6 	0x0B 
#define KEY_F7 	0x83
#define KEY_F8 	0x0A 
#define KEY_F9 	0x1
#define KEY_F10 0x9
#define KEY_F11 0x78
#define KEY_F12 0x7


char HandlePS2RawCodes();
void ClearKeyboard();

short TestKey(short rawcode);

// Each keytable entry has two bits: bit 0 - currently pressed, bit 1 - pressed since last test
extern unsigned char keytable[256];

#endif

