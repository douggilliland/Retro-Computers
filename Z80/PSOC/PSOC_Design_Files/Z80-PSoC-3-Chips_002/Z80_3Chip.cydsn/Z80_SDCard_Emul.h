#if !defined(Z80SDCARDEMU_H)
#define Z80SDCARDEMU_H
/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/

#include <project.h>

void    SDInit(void);
void    SDReadData(void);
void    SDWriteData(void);
void    SDReadStatus(void);
void    SDWriteCommand(void);
void    SDWriteLBA0(void);
void    SDWriteLBA1(void);
void    SDWriteLBA2(void);
void    SdWriteLBA3(void);

/* [] END OF FILE */
#endif
