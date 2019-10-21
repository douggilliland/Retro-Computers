/* GRANT Specific Emulation Part */

#include "emul.h"

#define UART_BASE 0x00

uint8 SIO_A[8],SIO_B[8];

// Ctrl-S
#define RTS_LOW     0xEA
#define XON         0x11
// Ctrl-Q
#define RTS_HIGH    0xE8
#define XOFF        0x13

void GrantReset(void)
{
  SIO_A[0]=0; SIO_B[0]=0;
  SIO_A[5]=RTS_LOW;
  sdcard_op=SD_IDLE;
}
void GrantMain(void)
{
    if ((SIO_A[5]==RTS_LOW) && (UART_GetRxBufferSize()!=0))         // Char available
        {
            if (nINT_ReadDataReg()!=0) { nINT_Write(0); }
        }
}

CY_ISR(GrantInt)
{
    uint8 port,stat;
    uint8 data;

    stat=IOStat_Status;                     // Idem IOPort_Read();  // WR,RD,M1,A4,A3,A2,A1,A0

    IORQ_ClearInterrupt();
    
    if ((stat&M1MASK)==0)
    {
        nINT_Write(1);
        IOOut_Control=SIO_B[2];            // IM
    }
    else
    {
     port=IOPort_Status;
     data=CY_GET_XTND_REG32(CYREG_PRT3_PS);
    
     switch (port)
     { 
      // BOOTLOADER gets maximum of 0x4000 bytes from file via in a,(ff)
      case _RD+0x3F:                         // Wr=1,Rd=0 (=> in (0xFF))        
        if (rdbytes)
        {
         if (Rw_Ptr<rdbytes)
          IOOut_Control=rw_buf[Rw_Ptr++];
         else 
         { Rw_Ptr=0;
           f_read(&fileO,rw_buf,512,&rdbytes); 
           if (rdbytes>0) { IOOut_Control=rw_buf[Rw_Ptr++]; }
                   else   { f_close(&fileO); 
                            print("EoRom reached");CRLF; }
         }
        }
        break;        

      // SIO Version        
      case _WR+(UART_BASE+0):                        // Out (0x00)
        UART_PutChar(data);
        break;
      case _WR+(UART_BASE+2):                        // Out (0x02)
        //status("SIOA_C",data);
        if (SIO_A[0]&7) { SIO_A[SIO_A[0]&0x7]=data; SIO_A[0]&=0xF8; }
                   else { SIO_A[0]=data; }
        if (SIO_A[5]==RTS_LOW) {LED_Write(0);}
                          else {LED_Write(1);}
        break;
      case _RD+(UART_BASE+2):
        data=0;
        if (UART_GetRxBufferSize()!=0) data |=1;
        if (UART_GetTxBufferSize()<UART_TX_BUFFER_SIZE) data|=0x04;
        IOOut_Control=data;
        break;
      case _RD+(UART_BASE+0):
        //status("key",SIO_key);
        IOOut_Control=UART_ReadRxData();
        break;
        
      case _WR+(UART_BASE+1):                        // Out (0x01)
        break;
      case _WR+(UART_BASE+3):                        // Out (0x03)
        //status("SIOB_C",data);
        if (SIO_B[0]&7) { SIO_B[SIO_B[0]&0x7]=data; SIO_B[0]&=0xF8; }
                   else { SIO_B[0]=data; }
        break;
      case _RD+(UART_BASE+3):
        IOOut_Control=0x04; // TODO Check
        break;
      case _RD+(UART_BASE+1):
        IOOut_Control=0x00; // TODO Check
        break;

    
      case _WR+0x11:
        if (data==0x01)
          sdcard_op=SD_OPEN;        
        break;
      case _RD+0x17:
        IOOut_Control=(sdcard_op==SD_IDLE)?0x00:0x80;
        break;    
      case _WR+0x12:
        if (data!=1) {print("Rd/Wr > 1 sector"); CRLF; }
        break;
      case _WR+0x13:
        cpm_offset=(cpm_offset&0xFFFE0000)|(data<<9);
        break;
      case _WR+0x14:
        cpm_offset=(cpm_offset&0xFE01FE00)|(data<<17);
        break;
      case _WR+0x15: // only 2 bits
        cpm_offset=(cpm_offset&0x01FFFE00)|((data&3)<<25);
        break;
      case _WR+0x16:
        // Always E0
        break;
      case _WR+0x17:
        if (data==0x20)
        { //lstatus("Read @",cpm_offset);
          sdcard_op=SD_READ;            
        }
        else if (data==0x30)
        { //lstatus("Pre_Write @",cpm_offset);
          Rw_Ptr=0; }
        break;
      case _WR+0x10:
        rw_buf[Rw_Ptr++]=data;
        if (Rw_Ptr==512) { 
            sdcard_op=SD_WRITE;
        }
        break;
      case _RD+0x10:
        IOOut_Control=rw_buf[Rw_Ptr++];
        if (Rw_Ptr>rdbytes) { print("EoB"); Rw_Ptr=0;}
        break;
 
      // BANK Sel
      case _WR+0x38:            // Disable ROM - unused here
        break;

      default:
        status("Int Port",port);
        status("Int Data",data);  
     }
    }
    
    Control_Control|=0x01;                     // Clear nWait   
    Control_Control&=0xFE;                     // nWait ok
}


/* [] END OF FILE */
