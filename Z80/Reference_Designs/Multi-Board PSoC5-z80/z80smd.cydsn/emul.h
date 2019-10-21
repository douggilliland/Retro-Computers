/* ========================================
*/

#include <project.h>
#include <stdio.h>

#include <ff.h>
#include <diskio.h>

#define _WR    0x40
#define _RD    0x80
#define M1MASK 0x04

#define SD_NINIT 0xFF 
#define SD_IDLE  0x00
#define SD_OPEN   0x01
#define SD_OPEN3  0x02
#define SD_READ  0x10
#define SD_WRITE 0x20


#define print(a) UART_PutString(a);
#define CRLF     UART_PutCRLF(' ');
#define printf(a,...) { sprintf(buffer,a); UART_PutString(buffer); }
#define status(a,b) { sprintf(buffer,"%s:%02x",a,b); UART_PutString(buffer); CRLF; }
#define lstatus(a,b) { sprintf(buffer,"%s:%08lx",a,b); UART_PutString(buffer); CRLF; }

#ifdef MAIN
    char buffer[60];
    volatile uint8 sdcard_op;
    FIL    fileO;
    uint32 Rw_Ptr=0;
    char   rw_buf[512];
    uint   rdbytes;
    uint32 cpm_offset;
#else
    extern char buffer[60];
    extern volatile uint8 sdcard_op;
    extern FIL    fileO;
    extern uint32 Rw_Ptr;
    extern char   rw_buf[512];
    extern uint   rdbytes;
    extern uint32 cpm_offset;
#endif



/* [] END OF FILE */
