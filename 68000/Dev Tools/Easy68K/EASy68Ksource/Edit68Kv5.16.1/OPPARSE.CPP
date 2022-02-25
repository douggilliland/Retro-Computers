/***********************************************************************
 *
 *		OPPARSE.C
 *		Operand Parser for 68000 Assembler
 *
 *    Function: opParse()
 *		Parses an operand of the 68000 assembly language
 *		instruction and attempts to recognize its addressing
 *		mode. The p argument points to the string to be
 *		evaluated, and the function returns a pointer to the
 *		first character beyond the end of the operand.
 *		The function returns a description of the operands that
 *		it parses in an opDescriptor structure. The fields of
 *		the operand descriptor are filled in as appropriate for
 *		the mode of the operand that was found:
 *
 *		 mode      returns the address mode (symbolic values
 *			   defined in ASM.H)
 *		 reg       returns the address or data register number
 *		 data      returns the displacement or address or
 *			   immediate value
 *		 backRef   TRUE if data is the value of an expression
 *			   that contains only constants and backwards
 *			   references; FALSE otherwise.
 *		 index     returns the index register
 *			   (0-7 = D0-D7, 8-15 = A0-A7)
 *		 size      returns the size to be used for the index
 *			   register
 *
 *		The argument errorPtr is used to return an error code
 *		via the standard mechanism.
 *
 *	 Usage:	char *opParse(p, d, errorPtr)
 *		char *p;
 *		opDescriptor *d;
 *		int *errorPtr;
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 ************************************************************************/


#include <stdio.h>
#include <ctype.h>
#include "asm.h"

extern bool pass2;
extern char buffer[256];  //ck used to form messages for display in windows
extern char numBuf[20];
extern int loc;

//#define isTerm(c)   (isspace(c) || (c == ',') || c == '\0')
//#define isRegNum(c) ((c >= '0') && (c <= '7'))

char *opParse(char *p, opDescriptor *d, int *errorPtr)
{
  char *n;
  int parenCount;

  try {
    d->size = 0;
    // if addressing mode in ( )
    // remove spaces inside parenthesis       CK Oct-26-2008
    if (p[0] == '(' || p[1] == '(') {
      char *sr = p;
      char *ds = p;
      parenCount=1;
      *ds++ = *sr++;            // copy first char
      if (*sr == '(')           // if second char is '('
        *ds++ = *sr++;          // copy (
      while (*sr && parenCount) {
        if (*sr == '(')
          parenCount++;
        else if (*sr == ')')
          parenCount--;
        if (isspace(*sr))    // skip spaces
          sr++;
        else
          *ds++ = *sr++;
      }
      if (!*sr && parenCount) {         // if no ')' found
        NEWERROR(*errorPtr, SYNTAX);
        return NULL;
      }

      while( (*ds++ = *sr++) != 0);  // copy ')' and remaining text
    }

    // Check for immediate mode
    if (p[0] == '#') {
      p = eval(++p, &(d->data), &(d->backRef), errorPtr);
      // If expression evaluates OK, then return
      if (*errorPtr < SEVERE) {
        if (isTerm(*p) || p[0]=='.') {
	      d->mode = IMMEDIATE;
          // #n.L is used to prevent MOVEQ, ADDQ & SUBQ optimizations  ck 4-2006
          if (p[0]=='.' && p[1]=='L') {
            d->size = LONG_SIZE;
            p += 2;
          }
	      return p;
	    } else {
	      NEWERROR(*errorPtr, SYNTAX);
	      return NULL;
	    }
      } else
      return NULL;
    }

    // Check for address or data register direct
    if (isRegNum(p[1]) && isTerm(p[2])) {
      if (p[0] == 'D') {
        d->mode = DnDirect;
	    d->reg = p[1] - '0';
	    return (p + 2);
      } else if (p[0] == 'A') {
	    d->mode = AnDirect;
	    d->reg = p[1] - '0';
	    return (p + 2);
      }
    }
    // Check for Stack Pointer (i.e., A7) direct
    if (p[0] == 'S' && p[1] == 'P' && isTerm(p[2])) {
      d->mode = AnDirect;
      d->reg = 7;
      return (p + 2);
    }
    // Check for address register indirect
    if (p[0] == '(' && ((p[1] == 'A' && isRegNum(p[2])) ||
                        (p[1] == 'S' && p[2] == 'P')))
    {
      if (p[1] == 'S')
	    d->reg = 7;
      else
	    d->reg = p[2] - '0';
      if (p[3] == ')') {
	    // Check for plain address register indirect
	    if (isTerm(p[4])) {
	      d->mode = AnInd;
	      return p+4;
	    }
        // Check for postincrement
        else if (p[4] == '+') {
	      d->mode = AnIndPost;
	      return p+5;
        }
      }
      // Check for address register indirect with index  (An,Xi)
      else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D') && isRegNum(p[5])) {
        d->mode = AnIndIndex;
        // Displacement is zero
        d->data = 0;
        d->backRef = true;
        d->index = p[5] - '0';
        if (p[4] == 'A')
	      d->index += 8;
        if (p[6] == '.')
	      // Determine size of index register
	      if (p[7] == 'W') {
	        d->size = WORD_SIZE;
	        return p+9;
	      } else if (p[7] == 'L') {
            d->size = LONG_SIZE;
            return p+9;
          } else {
            NEWERROR(*errorPtr, SYNTAX);
            return NULL;
          }
        else if (p[6] == ')') {
          // Default index register size is Word
          d->size = WORD_SIZE;
          return p+7;
        } else {
          NEWERROR(*errorPtr, SYNTAX);
          return NULL;
        }
      }
    }
    // Check for address register indirect with predecrement -(An) or -(SP)
    if (p[0] == '-' && p[1] == '(' && p[4] == ')' &&
      ((p[2] == 'A' && isRegNum(p[3])) || (p[2] == 'S' && p[3] == 'P'))) {
      if (p[2] == 'S')
	    d->reg = 7;
      else
	    d->reg = p[3] - '0';
      d->mode = AnIndPre;
      return p+5;
    }

    // Check for (d,An) or (d,An,Xi)
    if (p[0] == '(' && p[1] != 'P' && p[2] != 'C') {    // CK 2018-2-7
      n = strchr(p,',');
      if (n) {
        if((n[1] == 'A' && isRegNum(n[2])) || (n[1] == 'S' && n[2] == 'P') ) {
          p++;                  // skip (
          // evaluate displacement, p points to ','
          p = eval(p, &(d->data), &(d->backRef), errorPtr);
        }
      }

      // Check for (d,An) or (d,An,Xi)
      if ( (p[1] == 'A' && isRegNum(p[2])) || (p[1] == 'S' && p[2] == 'P') ) {
        if (p[1] == 'S')
          d->reg = 7;
        else
          d->reg = p[2] - '0';
        // Check for (d,An)
        if (p[3] == ')') {
          d->mode = AnIndDisp;
          return p+4;
        }
        // Check for (d,An,Xi)
        else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D') && isRegNum(p[5])) {
          d->mode = AnIndIndex;
          d->index = p[5] - '0';
          if (p[4] == 'A')
            d->index += 8;
          if (p[6] == '.')
            // Determine size of index register
            if (p[7] == 'W') {
              d->size = WORD_SIZE;
              return p+9;
            } else if (p[7] == 'L') {
              d->size = LONG_SIZE;
              return p+9;
            } else {
              NEWERROR(*errorPtr, SYNTAX);
              return NULL;
            }
          else if (p[6] == ')') {
            // Default size of index register is Word
            d->size = WORD_SIZE;
            return p+7;
          } else {
            NEWERROR(*errorPtr, SYNTAX);
            return NULL;
          }
        }
      }
    }

    // Check for PC relative (disp,PC) or (disp,PC,Xi)    ck 4-16-2002
    //    PC relative disp(PC) & disp(PC,Xi) is checked later
    if (p[0] == '(') {
      n = strchr(p,',');
      if (n && n[1] == 'P' && n[2] == 'C') {
        p++;                  // skip (
        // evaluate displacement, p points to ','
        p = eval(p, &(d->data), &(d->backRef), errorPtr);
      }

      // Check for PC relative (PC) or (PC,Xi)
      if (p[1] == 'P' && p[2] == 'C') {
        if (n == NULL) {                // if no displacement
          d->data = 0;
          d->backRef = true;
        }
        // Check for plain PC relative
        if (p[3] == ')') {
          d->mode = PCDisp;
          return p+4;
        }
        // Check for PC relative with index
        else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D') &&
                                               isRegNum(p[5])) {
          d->mode = PCIndex;
          d->index = p[5] - '0';
          d->data = loc;            // CK 3-8-2018
          if (p[4] == 'A')
            d->index += 8;
          if (p[6] == '.')
            // Determine size of index register
            if (p[7] == 'W') {
              d->size = WORD_SIZE;
              return p+9;
            } else if (p[7] == 'L') {
              d->size = LONG_SIZE;
              return p+9;
            } else {
              NEWERROR(*errorPtr, SYNTAX);
              return NULL;
            }
          else if (p[6] == ')') {
            // Default size of index register is Word
            d->size = WORD_SIZE;
            return p+7;
          } else {
            NEWERROR(*errorPtr, SYNTAX);
            return NULL;
          }
        }
      }
    }

    // Check for Status Register direct
    if (p[0] == 'S' && p[1] == 'R' && isTerm(p[2])) {
      d->mode = SRDirect;
      return p+2;
    }
    // Check for Condition Code Register direct
    if (p[0] == 'C' && p[1] == 'C' && p[2] == 'R' && isTerm(p[3])) {
      d->mode = CCRDirect;
      return p+3;
    }
    // Check for User Stack Pointer direct
    if (p[0] == 'U' && p[1] == 'S' && p[2] == 'P' && isTerm(p[3])) {
      d->mode = USPDirect;
      return p+3;
    }
    // Check for Source Function Code register direct (68010)
    if (p[0] == 'S' && p[1] == 'F' && p[2] == 'C' && isTerm(p[3])) {
      d->mode = SFCDirect;
      return p+3;
    }
    // Check for Destination Function Code register direct (68010)
    if (p[0] == 'D' && p[1] == 'F' && p[2] == 'C' && isTerm(p[3])) {
      d->mode = DFCDirect;
      return p+3;
    }
    // Check for Vector Base Register direct (68010)
    if (p[0] == 'V' && p[1] == 'B' && p[2] == 'R' && isTerm(p[3])) {
      d->mode = VBRDirect;
      return p+3;
    }

    // All other addressing modes start with a constant expression
    p = eval(p, &(d->data), &(d->backRef), errorPtr);
    if (*errorPtr < SEVERE) {
      // Check for address register indirect with displacement
      if (p[0] == '(' &&
          ((p[1] == 'A' && isRegNum(p[2])) || (p[1] == 'S' && p[2] == 'P'))) {
        if (p[1] == 'S')
          d->reg = 7;
        else
          d->reg = p[2] - '0';
        // Check for plain address register indirect with displacement
        if (p[3] == ')') {
          d->mode = AnIndDisp;
          return p+4;
        }
        // Check for address register indirect with index
        else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
                               && isRegNum(p[5])) {
          d->mode = AnIndIndex;
          d->index = p[5] - '0';
          if (p[4] == 'A')
            d->index += 8;
          if (p[6] == '.')
            // Determine size of index register
            if (p[7] == 'W') {
              d->size = WORD_SIZE;
              return p+9;
            }	else if (p[7] == 'L') {
              d->size = LONG_SIZE;
              return p+9;
            }	else {
              NEWERROR(*errorPtr, SYNTAX);
              return NULL;
            }
          else if (p[6] == ')') {
            // Default size of index register is Word
            d->size = WORD_SIZE;
            return p+7;
          } else {
            NEWERROR(*errorPtr, SYNTAX);
            return NULL;
          }
        }
      }

      // Check for PC relative
      if (p[0] == '(' && p[1] == 'P' && p[2] == 'C') {
        // Check for plain PC relative
        if (p[3] == ')') {
          d->mode = PCDisp;
          return p+4;
        }
        // Check for PC relative with index
        else if (p[3] == ',' && (p[4] == 'A' || p[4] == 'D')
                               && isRegNum(p[5])) {
          d->mode = PCIndex;
          d->index = p[5] - '0';
          if (p[4] == 'A')
            d->index += 8;
          if (p[6] == '.')
            // Determine size of index register
            if (p[7] == 'W') {
              d->size = WORD_SIZE;
              return p+9;
            } else if (p[7] == 'L') {
              d->size = LONG_SIZE;
              return p+9;
            } else {
              NEWERROR(*errorPtr, SYNTAX);
              return NULL;
            }
          else if (p[6] == ')') {
            // Default size of index register is Word
            d->size = WORD_SIZE;
            return p+7;
          } else {
            NEWERROR(*errorPtr, SYNTAX);
            return NULL;
          }
        }
      }
      // Check for absolute   (check this last ck 12-11-2002)
      if (isTerm(p[0]) || *errorPtr == INCOMPLETE || p[0]=='.' || p[0]=='{') {
        // Determine size of absolute address
        if (p[0]=='.' && p[1]=='L') {
          d->mode = AbsLong;
          p += 2;
        } else if (p[0]=='.' && p[1]=='W') {
          d->data = short(d->data);   // force short addressing
          d->mode = AbsShort;
          p += 2;
          NEWERROR(*errorPtr, FORCING_SHORT); // forcing short addressing warning
        }
        //(must be long if the symbol isn't defined or if the value is too big
        else if (!d->backRef || d->data > 32767 || d->data < -32768)
          d->mode = AbsLong;
        else
          d->mode = AbsShort;
        return p;
      }
    } // endif error not severe
    // If the operand doesn't match any pattern, return an error status
    NEWERROR(*errorPtr, SYNTAX);
    return NULL;
  }
  catch( ... ) {
    NEWERROR(*errorPtr, EXCEPTION);
    sprintf(buffer, "ERROR: An exception occurred in routine 'opParse'. \n");
    return NULL;
  }

}



