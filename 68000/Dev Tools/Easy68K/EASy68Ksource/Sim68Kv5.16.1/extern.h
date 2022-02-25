#ifndef externH
#define externH

/***************************** 68000 SIMULATOR ****************************

File Name: EXTERN.H
Version: 1.0

This file contains all extern global variable definitions for the
simulator program.  It is included in all modules other than the module
"SIM68Ku.cpp" which contains the main() function.


        BE CAREFUL TO KEEP THESE DECLARATIONS IDENTICAL TO THE GLOBAL
        VARIABLE DECLARATIONS IN "VAR.H"


***************************************************************************/

#include <stack>
using namespace std;

#include "def.h"       	/* constant declarations */
#include "proto.h"     	/* function prototypes */
#include "BPoint.h"
#include "BPointExpr.h"
#pragma hdrstop


extern char buffer[256];       // used to form messages for display in windows
extern char numBuf[20];        // "
//extern AnsiString errstr;

extern long     D[D_REGS], OLD_D[D_REGS], A[A_REGS], OLD_A[A_REGS];
extern long     PC, OLD_PC;
extern short    SR, OLD_SR;

extern char*	memory;
extern char	bpoints;
extern char	lbuf[SREC_MAX], *wordptr[20];
extern unsigned __int64	cycles;
extern int	brkpt[100];
extern int      stepToAddr;             // Step Over stopping address
extern int      runToAddr;              // runToCursor stopping address

extern char	p1dif;
extern char	*gettext();
extern int	wcount;
extern unsigned	int port1[4];
extern char	p1dif;
extern int	errflg;
extern int	trace, sstep, old_trace, old_sstep, exceptions;
extern bool     bitfield, simhalt_on;
extern bool     halt;                   // true, halts running program
extern bool     stopInstruction;        // true after running stop instruction

extern int	inst;
extern long	*EA1, *EA2;
extern long	EV1, EV2;

extern long	source, dest, result;

extern long    	global_temp;		/* to hold an immediate data operand */

extern bool     runMode;       // true when running 68000 program (not tracing)
extern bool     runModeSave;

extern bool    keyboardEcho;    // true, 68000 input is echoed (default)
extern char    pendingKey;      // pending key for char input
extern bool    inputPrompt;     // true, display prompt during input (default)
extern bool    inputLFdisplay;         // true, display LF on CR during input (default)

extern char    inputBuf[256];          // simulator input buffer
extern long    inputSize;              // number of characters input
extern bool    inputMode;       // true during 68000 program input

extern FileStruct files[MAXFILES];     // array of file structures

// log output
extern char ElogFlag;           // log file setting
extern FILE *ElogFile;		// Log file
extern char OlogFlag;           // log file setting
extern FILE *OlogFile;		// Log file
extern bool logging;            // true when logging
extern unsigned int logMemAddr;         // log memory address
extern unsigned int logMemBytes;        // log memory bytes

extern bool autoTraceInProgress;        // true when auto tracing

// Allocate array of breakpoints / expression groups.
// PC/Reg break points are in elements 0-49.  Addr => 50-99.
extern BPoint breakPoints[MAX_BPOINTS];
extern BPointExpr bpExpressions[MAX_BP_EXPR];
extern int bpCountCond[MAX_BPOINTS];
extern int regCount;
extern int addrCount;
extern int exprCount;

// Allocate array of ints for building a break expression.
// Elements of infixExpr represent relative indexes into the
// breakPoints array or represent and_node, or_node, not_node.
extern int infixExpr[MAX_LB_NODES];
extern int postfixExpr[MAX_LB_NODES];
extern int infixCount;
extern int postfixCount;
extern stack<int> s_operator;

// Used to efficiently calculate which GUI buttons are availabe as
// the user builds a breakpoint expression.
extern bool mruOperand;
extern bool mruOperator;
extern int parenCount;

// Read and write flags so when breakpoints are tested for read/write
// access, we know if this instruction caused a respective read/write.
extern bool bpRead;
extern bool bpWrite;
extern long * readEA;
extern long * writeEA;

// Interrupt and Reset Control
extern bool hardReset;
extern int irq;


// saves weather the ChangeDisplaySettingsEx() and other multi monitor apis exist
extern bool MultimonitorAPIsExist;

// what screen to use for full screen output   0 = primary  1 and up = secondaries
extern unsigned char FullScreenMonitor;

// screen device to use for full screen output
extern char FullScreenDeviceName[32];

// function pointers to APIs that don't always exist. (for compatibility with 95)
typedef HRESULT (CALLBACK* CHANGEDISPLAYSETTINGSEXAPROC)(LPCTSTR,LPDEVMODEA,HWND,DWORD,LPVOID);
extern CHANGEDISPLAYSETTINGSEXAPROC ChangeDisplaySettingsExAPtr;
typedef HRESULT (CALLBACK* ENUMDISPLAYSETTINGSEXAPROC)(LPCTSTR,DWORD,LPDEVMODE,DWORD);
extern ENUMDISPLAYSETTINGSEXAPROC EnumDisplaySettingsExAPtr;
typedef HRESULT (CALLBACK* ENUMDISPLAYDEVICESAPROC)(LPCTSTR,DWORD,PDISPLAY_DEVICE,DWORD);
extern ENUMDISPLAYDEVICESAPROC EnumDisplayDevicesAPtr;

// true if directSound may be used
extern bool dsoundExist;

// Mouse
extern int mouseX, mouseY;
extern bool mouseLeft, mouseRight, mouseMiddle, mouseDouble;
extern bool keyShift, keyAlt, keyCtrl;

extern int mouseXUp, mouseYUp;
extern bool mouseLeftUp, mouseRightUp, mouseMiddleUp, mouseDoubleUp;
extern bool keyShiftUp, keyAltUp, keyCtrlUp;

extern int mouseXDown, mouseYDown;
extern bool mouseLeftDown, mouseRightDown, mouseMiddleDown, mouseDoubleDown;
extern bool keyShiftDown, keyAltDown, keyCtrlDown;
extern byte mouseDownIRQ, mouseUpIRQ, mouseMoveIRQ;
extern byte keyDownIRQ, keyUpIRQ;

#endif
