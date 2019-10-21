/* RC2014 Specific Emulation Part */

#include "emul.h"

uint8 Acia_ctrl;

void RC2014Main(void)
{
  if ((Acia_ctrl&0x80)&&(UART_GetRxBufferSize()!=0))
    if (nINT_ReadDataReg()!=0) { nINT_Write(0); }
  if (((Acia_ctrl&0x60)==0x20)&&(UART_GetTxBufferSize()<UART_TX_BUFFER_SIZE))
    if (nINT_ReadDataReg()!=0) { nINT_Write(0); }        
}

void RC2014Reset(void)
{
    //Acia_ctrl=0;
}

CY_ISR(RC2014Int)
{
    uint8 port,stat;
    uint8 data;

    stat=IOStat_Status;                     // Idem IOPort_Read();  // WR,RD,M1,A4,A3,A2,A1,A0

    IORQ_ClearInterrupt();
    
    if ((stat&M1MASK)==0)
    {
        nINT_Write(1);
        IOOut_Control=0x12;            // IMx a verifier
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

      // ACIA Version        
      case _WR+1:                        // Out (0x80)
        UART_PutChar(data);
        break;
      case _RD+0:
        data=0;
        if (UART_GetRxBufferSize()!=0) data |=1;
        if (UART_GetTxBufferSize()<UART_TX_BUFFER_SIZE) data|=0x02;
        IOOut_Control=data;
        break;
      case _RD+1:
        //status("key",SIO_key);
        IOOut_Control=UART_ReadRxData();
        break;       
      case _WR+0:                        // Out (0x81)
        Acia_ctrl=data;
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
