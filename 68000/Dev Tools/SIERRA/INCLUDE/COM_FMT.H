/*------------------------------- com_fmt.h ---------------------------------*/

/*
 *  Copyright 1987 - 1992 by Sierra Systems. All rights reserved.
 *
 *  Macros for converting numeric data to and from common object files.
 */
    
/*  
 * CNVTREGS		-- defines pc & pn as registers.
 *  
 * COM2LNG( long_, com )    -- converts a common long to a host long
 *
 * COM2WRD( word_, com )    -- converts a common word to a host word
 *
 * COM2CHR( byte_, com )    -- converts a common char to a host char
 *
 *
 * LNG2COM( com, long_ )    -- converts a host long to a common long
 *
 * WRD2COM( com, word_ )    -- converts a host word to a common word
 *
 * CHR2COM( com, byte_ )    -- converts a host char to a common char
 *
 * The common object argument is always a character array address.
 * The host numeric is always a non-register variable.
 *	
 * These macros use the variables pn and pc declared in CNVTREGS.
 */

#if VAX | I286

#define CNVRTREGS register unsigned char *pn, *pc

#define LNG2COM(com, long_) { pn = (unsigned char*)&(long_); \
				pc = (unsigned char*)&(com)[3]; \
				*pc = *pn++; \
				*--pc = *pn++; \
				*--pc = *pn++; \
				*--pc = *pn; }

#define WRD2COM(com, word_) { pn = (unsigned char *)&(word_); \
				pc = (unsigned char *)&(com)[1]; \
				*pc = *pn++; \
				*--pc = *pn; }

#define CHR2COM(com, byte_) { (com)[0] = byte_; }

#define COM2LNG(long_, com) { pn = (unsigned char *)&(long_); \
				pc = (unsigned char *)&(com)[3]; \
				*pn++ = *pc; \
				*pn++ = *--pc; \
				*pn++ = *--pc; \
				*pn = *--pc; }

#define COM2WRD(word_, com) { pn = (unsigned char *)&(word_); \
				pc = (unsigned char *)&(com)[1]; \
				*pn++ = *pc; \
				*pn = *--pc; }

#define COM2CHR(byte_, com) { byte_ = (com)[0]; }

#endif

#if M68000

#define CNVRTREGS register unsigned char *pn, *pc

#define LNG2COM(com, long_) { pn = (unsigned char*)&(long_); \
				pc = (unsigned char*)&(com)[0]; \
				*pc++ = *pn++; \
				*pc++ = *pn++; \
				*pc++ = *pn++; \
				*pc = *pn; }

#define WRD2COM(com, word_) { pn = (unsigned char *)&(word_); \
				pc = (unsigned char *)&(com)[0]; \
				*pc++ = *pn++; \
				*pc = *pn; }

#define CHR2COM(com, byte_) { (com)[0] = byte_; }

#define COM2LNG(long_, com) { pn = (unsigned char *)&(long_); \
				pc = (unsigned char *)&(com)[0]; \
				*pn++ = *pc++; \
				*pn++ = *pc++; \
				*pn++ = *pc++; \
				*pn = *pc; }

#define COM2WRD(word_, com) { pn = (unsigned char *)&(word_); \
				pc = (unsigned char *)&(com)[0]; \
				*pn++ = *pc++; \
				*pn = *pc; }

#define COM2CHR(byte_, com) { byte_ = (com)[0]; }

#endif

#if M68020

#define CNVRTREGS typedef int keep_comp_from_complaining

#define LNG2COM(com, long_) { *((unsigned long*)&(com)[0]) = long_; }

#define WRD2COM(com, word_) { *((unsigned short*)&(com)[0]) = word_; }

#define CHR2COM(com, byte_) { (com)[0] = byte_; }

#define COM2LNG(long_, com) { long_ = *((unsigned long*)&(com)[0]); }

#define COM2WRD(word_, com) { word_ = *((unsigned short*)&(com)[0]); }

#define COM2CHR(byte_, com) { byte_ = (com)[0]; }

#endif
