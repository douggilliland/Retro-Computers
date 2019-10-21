/* ========================================
 *
 * Z80 SBC with PSoC5 Glue (CY8CKIT-059)
 * Jean-Jacques Michel / 2017
 *
 * ========================================
*/
#include <project.h>
#include <stdio.h>

#define MAIN
#include "emul.h"


FATFS fatFs;
uint8 resultF;

struct emulation
{
 char *bootfile;
 void (*reset)(void);
 void (*mainloop)(void);
 void (*interrupt)(void);    
} emul;

extern void GrantMain(void);
extern void GrantReset(void);
extern void GrantInt(void);

extern void RC2014Main(void);
extern void RC2014Reset(void);
extern void RC2014Int(void);

extern void Cpm3Main(void);
extern void Cpm3Reset(void);
extern void Cpm3Int(void);

uint8 running;

/* Z80 BOOT LOADER CODE
// 00 DI
// 01 JMP 0x0004
// 04 LD HL,0
// 07 LD DE,0x4000
// 0A LD BC,0x24
// 0D LDIR          [ (DE++) <= (HL++), (BC--) ]
// 0F JMP 0x4012
// 12 LD HL,0
// 15 LD BC,0x4000
// 18 IN A,(FF)
// 1A LD (HL),A
// 1B INC HL
// 1C DEC BC
// 1D LD A,B
// 1E OR C
// 1F JR NZ,F7 (-9=>@18)
// 21 JMP 0x0000
*/

const uint8 bootprg[]={ 0xf3,0xc3,0x04,0x00,0x21,0x00,0x00,0x11,
                        0x00,0x40,0x01,0x24,0x00,0xed,0xb0,0xc3,
                        0x12,0x40,0x21,0x00,0x00,0x01,0x00,0x40,
                        0xdb,0xff,0x77,0x23,0x0b,0x78,0xb1,0x20,
                        0xf7,0xc3,0x00,0x00 };

void ResetZ80(void)
{
    emul.reset();
    
    ResetOut_Write(0);      // <RESET>
    Control_Write(0x01);    // Clear nWait
    CyDelay(1);
    Control_Write(0x00);    // nWait ok
    ResetOut_Write(1);      // </RESET>
    Rw_Ptr=0;
}

void pstatus(uint32 addr)
{
    uint8 i;
    uint8 data;
    
    for(i=0;i<8;i++)
    {
        data=*(uint8 *)(addr+i);
        sprintf(buffer," %02x",data); UART_PutString(buffer);
    }
    CRLF;
}    

void Info(void)
{
    print("Port 0 : "); pstatus(CYREG_PRT0_DR);
    print("Port 1 : "); pstatus(CYREG_PRT1_DR);
    print("Port 2 : "); pstatus(CYREG_PRT2_DR);
    print("Port 3 : "); pstatus(CYREG_PRT3_DR);
    print("Port 12: "); pstatus(CYREG_PRT12_DR);
    print("Port 15: "); pstatus(CYREG_PRT15_DR);

    status("Control Data",Control_Read());
    status("IOStat Data",IOStat_Read());
    status("IOPort Data",IOPort_Read());    
}

void bootload_ram(void)
{
    uint8  addr,data;
    uint8 p1dr,p1dm0,p1dm1,p1dm2,p1byp;
    uint8 p2dr,p2dm0,p2dm1,p2dm2,p2byp;
    uint8 p3dr,p3dm0,p3dm1,p3dm2,p3byp,p3bie;
    uint8 p15dr,p15dm0,p15dm1,p15dm2,p15byp;
            
    // Reset Low
    ResetOut_Write(0);
    
    // Info();
    
    // A0,A1,A2,A3,A4,A5 from input to output   
    // Rd,Wr             from input to outputs   
    
    // PORT 1 : A0=.2 A5=.7 (inputs)
    p1dr =*(uint8*)CYREG_PRT1_DR;
    p1dm0=*(uint8*)CYREG_PRT1_DM0;
    p1dm1=*(uint8*)CYREG_PRT1_DM1;
    p1dm2=*(uint8*)CYREG_PRT1_DM2;
    p1byp=*(uint8*)CYREG_PRT1_BYP;
    
    *(uint8*)CYREG_PRT1_DR =*(uint8*)CYREG_PRT1_PS;
    *(uint8*)CYREG_PRT1_DM0&=0x03;
    *(uint8*)CYREG_PRT1_DM1|=0xFC;
    *(uint8*)CYREG_PRT1_DM2|=0xFC;
    *(uint8*)CYREG_PRT1_BYP&=0x03;
    // A0-A5=0
    *(uint8*)CYREG_PRT1_DR =(p1dr&3);
    
    // PORT 2 : CSRAM=.0 Rd/Wr=.3&.4 (inputs)
    p2dr =*(uint8*)CYREG_PRT2_DR;
    p2dm0=*(uint8*)CYREG_PRT2_DM0;
    p2dm1=*(uint8*)CYREG_PRT2_DM1;
    p2dm2=*(uint8*)CYREG_PRT2_DM2;
    p2byp=*(uint8*)CYREG_PRT2_BYP;

    *(uint8*)CYREG_PRT2_DR =*(uint8*)CYREG_PRT2_PS;
    *(uint8*)CYREG_PRT2_DM0&=0xE6;
    *(uint8*)CYREG_PRT2_DM1|=0x19;
    *(uint8*)CYREG_PRT2_DM2|=0x19;
    *(uint8*)CYREG_PRT2_BYP&=0xE6;
    // CS=Wr=Rd=1
    *(uint8*)CYREG_PRT2_DR |=0x19;

    // PORT 3 : Data (inputs)
    p3dr =*(uint8*)CYREG_PRT3_DR;
    p3dm0=*(uint8*)CYREG_PRT3_DM0;
    p3dm1=*(uint8*)CYREG_PRT3_DM1;
    p3dm2=*(uint8*)CYREG_PRT3_DM2;
    p3byp=*(uint8*)CYREG_PRT3_BYP;
    p3bie=*(uint8*)CYREG_PRT3_BIE;

    *(uint8*)CYREG_PRT3_DR =*(uint8*)CYREG_PRT3_PS;
    *(uint8*)CYREG_PRT3_DM0=0;
    *(uint8*)CYREG_PRT3_DM1=0xff;
    *(uint8*)CYREG_PRT3_DM2=0xff;
    *(uint8*)CYREG_PRT3_BYP=0;
    *(uint8*)CYREG_PRT3_BIE=0;  

    // PORT 15 : B0,B1,B2=.0 .1 .5 (inputs)
    p15dr =*(uint8*)CYREG_PRT15_DR;
    p15dm0=*(uint8*)CYREG_PRT15_DM0;
    p15dm1=*(uint8*)CYREG_PRT15_DM1;
    p15dm2=*(uint8*)CYREG_PRT15_DM2;
    p15byp=*(uint8*)CYREG_PRT15_BYP;

    *(uint8*)CYREG_PRT15_DR =*(uint8*)CYREG_PRT15_PS;
    *(uint8*)CYREG_PRT15_DM0&=0xDC;
    *(uint8*)CYREG_PRT15_DM1|=0x23;
    *(uint8*)CYREG_PRT15_DM2|=0x23;
    *(uint8*)CYREG_PRT15_BYP&=0xDC;
    // B0,B1,B2=0
    *(uint8*)CYREG_PRT15_DR &=0xDC;
    
    // Info();

    // => Program Loop
    print("Write BL");CRLF;

    CSRAM_Write(0);        
    for(addr=0;addr<sizeof(bootprg);addr++)
    {
        *(uint8*)CYREG_PRT1_DR=(addr<<2)|(p1dr&0x03);
        *(uint8*)CYREG_PRT3_DR=bootprg[addr];
        CyDelay(1);
        Wr_Write(0);
        CyDelay(1);
        Wr_Write(1);
    }
    // Verif.
    *(uint8*)CYREG_PRT3_DM0=0xff;
    *(uint8*)CYREG_PRT3_DM1=0x00;
    *(uint8*)CYREG_PRT3_DM2=0x00;

    print("Verif. BL");CRLF;

    
    for(addr=0;addr<sizeof(bootprg);addr++)
    {
        *(uint8*)CYREG_PRT1_DR=(addr<<2)|(p1dr&0x03);
        Rd_Write(0);
        CyDelay(1);
        data=*(uint8*)CYREG_PRT3_PS;
        Rd_Write(1);
        if (data!=bootprg[addr]) { status("A",addr); status("D",data); status("E",bootprg[addr]); }
    }
    CSRAM_Write(1);
    
    *(uint8*)CYREG_PRT1_DM0=p1dm0;
    *(uint8*)CYREG_PRT1_DM1=p1dm1;
    *(uint8*)CYREG_PRT1_DM2=p1dm2;
    *(uint8*)CYREG_PRT1_BYP=p1byp;
    *(uint8*)CYREG_PRT1_DR =p1dr;

    *(uint8*)CYREG_PRT2_DM0=p2dm0;
    *(uint8*)CYREG_PRT2_DM1=p2dm1;
    *(uint8*)CYREG_PRT2_DM2=p2dm2;
    *(uint8*)CYREG_PRT2_BYP=p2byp;
    *(uint8*)CYREG_PRT2_DR =p2dr;

    *(uint8*)CYREG_PRT3_BIE=p3bie;
    *(uint8*)CYREG_PRT3_DM0=p3dm0;
    *(uint8*)CYREG_PRT3_DM1=p3dm1;
    *(uint8*)CYREG_PRT3_DM2=p3dm2;
    *(uint8*)CYREG_PRT3_BYP=p3byp;
    *(uint8*)CYREG_PRT3_DR =p3dr;

    *(uint8*)CYREG_PRT15_DM0=p15dm0;
    *(uint8*)CYREG_PRT15_DM1=p15dm1;
    *(uint8*)CYREG_PRT15_DM2=p15dm2;
    *(uint8*)CYREG_PRT15_BYP=p15byp;
    *(uint8*)CYREG_PRT15_DR =p15dr;

    // Info();
    
    print("Go");CRLF;
}    


void Run(void)
{
    ResetZ80();

    running=1;
    
    while (Button_Read()) {
      // Mode Specific MainLoop
      emul.mainloop();
      // Generic functions MainLoop
          
      if (sdcard_op==SD_READ) {
          resultF=f_lseek(&fileO,cpm_offset);
          if (resultF != RES_OK) {print("Read Seek not OK");CRLF;}
          resultF=f_read(&fileO,rw_buf,512,&rdbytes); 
          if (resultF != RES_OK) {print("Read not OK");CRLF;}
          Rw_Ptr=0; 
          sdcard_op=SD_IDLE;
      }
      if (sdcard_op==SD_WRITE) {            
          resultF=f_lseek(&fileO,cpm_offset);
          if (resultF != RES_OK) {print("Wr Seek not OK");CRLF;}
          resultF=f_write(&fileO,rw_buf,512,&rdbytes);
          if (resultF != RES_OK) {print("Wr not OK");CRLF;}
          Rw_Ptr=0;
          sdcard_op=SD_IDLE;
      }
      if (sdcard_op==SD_OPEN) {            
          resultF=f_open(&fileO,"cpm.bin",FA_READ|FA_WRITE);
          if (resultF == RES_OK) { print("cpm.bin opened for RW Ok");CRLF;
                                  lstatus("File size ",f_size(&fileO));}
          sdcard_op=SD_IDLE;
      }
      if (sdcard_op==SD_OPEN3) {            
          resultF=f_open(&fileO,"cpm3.bin",FA_READ|FA_WRITE);
          //if (resultF == RES_OK) { print("cpm3.bin opened for RW Ok");CRLF;
          //                        lstatus("File size ",f_size(&fileO));}
          sdcard_op=SD_IDLE;
      }

    };

    running=0;

    print("END RUN");CRLF;
    CyDelay(1000);
    
    while (!Button_Read()) ;
}

int main()
{
    uint32 counter=0;
    uint8 chr;
    uint8 prompt[]="/-\\|";
        
    CyGlobalIntEnable;      /* Enable global interrupts */
    
    UART_Start();
    
    NMI_Write(1);
    nINT_Write(1);
    ResetOut_Write(0);
    z80clk_Start();

    SPIM_Start();
    
    emul.bootfile ="ROM.bin";
    emul.interrupt=GrantInt;
    emul.mainloop =GrantMain;
    emul.reset    =GrantReset;
    
Restart:
    /* Enable the Interrupt component connected to Timer interrupt */
    IOirq_StartEx(emul.interrupt);
  
    running=0;
    ResetOut_Write(0);
    
    print("Starting");CRLF;

    /* Mount sdcard. */
    resultF = f_mount(&fatFs, "", 1);
    
    if (resultF == RES_OK) 
    { //print("SDCard Open Ok");CRLF;
      resultF=f_open(&fileO,emul.bootfile,FA_READ);
      if (resultF == RES_OK) { print("ROM file \"");print(emul.bootfile);print("\" opened");CRLF; }
      resultF=f_read(&fileO,rw_buf,512,&rdbytes);      
      if (resultF == RES_OK) { print("ROM read"); status("bytes ",rdbytes); }
    }
    
    for(;;)
    {         
        // _R_eset
        // _D_ebug
        // _B_ootloader        
        // _I_nfo
        if ((counter&0xFFFF)==0)
        { UART_PutChar(13);        
          UART_PutChar(prompt[counter>>16]);
          UART_PutChar('>');
        }
        
        chr=UART_GetChar();
        if (chr!=0)
        {
            UART_PutChar(chr);CRLF;
            switch(chr)
            {
                case 'R':
                    Run(); break;
                case 'D':
                    break;
                case 'B':
                    bootload_ram();break;
                case 'I':
                    Info(); break;
                case 'X':
                    goto Restart;
                case '1':
                    emul.bootfile ="ROM.bin";
                    emul.interrupt=GrantInt;
                    emul.mainloop =GrantMain;
                    emul.reset    =GrantReset;
                    goto Restart;
                case '2':
                    emul.bootfile ="RC2014.bin";
                    emul.interrupt=RC2014Int;
                    emul.mainloop =RC2014Main;
                    emul.reset    =RC2014Reset;
                    goto Restart;                    
                case '3':
                    emul.bootfile ="boot3.bin";
                    emul.interrupt=Cpm3Int;
                    emul.mainloop =Cpm3Main;
                    emul.reset    =Cpm3Reset;
                    goto Restart;                    
                    
                default:
                    print("?");CRLF;                    
            }
            CRLF;
        }
        
        counter++;
        counter &= 0x3FFFF;
        
    }
}
