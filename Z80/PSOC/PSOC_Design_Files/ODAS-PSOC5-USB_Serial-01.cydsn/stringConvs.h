/* ========================================
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#if !defined(STRINGCONVS_H)
#include "proEnv.h"
#define STRINGCONVS_H

#include "project.h"

uint8 charToNibble(char);
uint32 stringToLong(char *);
int8 findInString(char *, char);
void longToString(uint32, char *);
void shortToString(uint16, char *);
void byteToString(uint8, char *);

#endif  /* STRINGCONVS_H */

/* [] END OF FILE */
