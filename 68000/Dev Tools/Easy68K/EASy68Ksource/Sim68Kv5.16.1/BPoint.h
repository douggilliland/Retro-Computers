
/***************************** 68000 SIMULATOR ****************************

File Name: BPoint.h
Version: 1.0
Debugger Component

This file contains the definitions of various routines and data members
to store and access the BPoint data structure that contains breakpoint
information entered manually by the user.

***************************************************************************/

#include <vcl.h>
#pragma hdrstop

#ifndef BPOINT
#define BPOINT

const int BREAK_CONDITIONS = 2;

class BPoint {

	public:
				BPoint();
				~BPoint();
				int getId();
				void setId(int);
				int getType();
				void setType(int);
				long getTypeId();
				void setTypeId(long);
				int getOperator();
				void setOperator(int);
				long getValue();
				void setValue(long);
				int getReadWrite();
				void setReadWrite(int);
                                long getSize();
				void setSize(long);
                                bool isBreak();
                                bool isEnabled();
                                void isEnabled(bool);
                              //  BPoint & operator=(const BPoint &);

	private:
				int id;	   // Uniquely identifies breakpoint within PC/Reg and Addr
                                          // breakpoint categories (0-49, 50-99)  Keeps track
                                          // of its place in the main breakpoints array
				int type;     // PC/Reg, Addr
				long typeId;  // Combination of id, type, and typeId = unique breakpoint.
                                             // D0-7, A8-15, 16 => PC/Reg; 00000000-FFFFFFFF => Addr
				int op;	     // The relationship of the value to the target breakpoint.
                                            // ==, !=, <, <=, >, >=
				long value;  // The value sought at the specified breakpoint
                                             // 00000000 - FFFFFFFF
				int readWrite;	// Specifies whether a read or write is needed for
                                               // the break condition to be met.
				long size;    // Specifies the size of the value to test
                                bool isEnab;  // Should the break condition be tested?
};

#endif