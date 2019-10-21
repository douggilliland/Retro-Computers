/* GRANT based CPM3 Specific Emulation Part */

#include "emul.h"

void Cpm3Reset(void)
{
    sdcard_op=SD_NINIT;
}
void Cpm3Main(void)
{
}

unsigned char bank=0;

CY_ISR(Cpm3Int)
{
    uint8 port,stat;
    uint8 data;

    stat=IOStat_Status;                     // Idem IOPort_Read();  // WR,RD,M1,A4,A3,A2,A1,A0

    IORQ_ClearInterrupt();
    
    if ((stat&M1MASK)==0)
    {
        nINT_Write(1);
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
        
      case _RD:
        data=0;
        if (UART_GetRxBufferSize()!=0) data|=2;
        if (UART_GetTxBufferSize()<UART_TX_BUFFER_SIZE) data|=0x04;
        IOOut_Control=data;
        break;
      case _WR+1:
        UART_PutChar(data);
        break;
      case _RD+1:
        //status("key",SIO_key);
        IOOut_Control=UART_ReadRxData();
        break;

        
      case _WR+0x10:
        cpm_offset=(cpm_offset&0xFFFF8000)|(data<<9);   //SECT (0..63) -- 0->32K
        break;
      case _WR+0x11:
        cpm_offset=(cpm_offset&0xFF807FFF)|(data<<15);  //TRK1 (0..255) -- 32K->8M
        break;
      //case _WR+0x12:
        //cpm_offset=(cpm_offset&0xFFFFFF00)|(0<<25);  //TRK2 (0) --
      //  break;
      case _WR+0x13:
        cpm_offset=(cpm_offset&0xF87FFF00)|(data<<23);  //DSK (0..15) -- 8M->128M
        break;
      case _WR+0x14:
        if (data==0x2)
        { //lstatus("Read @",cpm_offset);
          sdcard_op=SD_READ;            
        }
        else if (data==0x1)
        { //lstatus("Pre_Write @",cpm_offset);
          Rw_Ptr=0; 
        }
        break;

      case _RD+0x14:
        data=0;
        if (sdcard_op!=SD_IDLE) data=1;
        IOOut_Control=data;
        break;
        
      case _RD+0x15:
        IOOut_Control=rw_buf[Rw_Ptr++];
        if (Rw_Ptr>rdbytes) { print("EoB"); Rw_Ptr=0;}
        break;

      case _WR+0x15:
        if (Rw_Ptr>=512) {lstatus("EoB Writing byte:",Rw_Ptr);}
        rw_buf[Rw_Ptr++]=data;
        if (Rw_Ptr==512) { 
            sdcard_op=SD_WRITE;
            //lstatus("Writing @",cpm_offset);
        }
        break;

      case _WR+0x28:
        if (sdcard_op==SD_NINIT) sdcard_op=SD_OPEN3;
        //if (bank!=data) status("Bank",data);
        //bank=data;
        Control_Control&=0xF9;                 
        Control_Control|=(data<<1);
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
