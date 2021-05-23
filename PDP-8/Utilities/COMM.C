
#ifdef PC
PORT port_handle;


void (interrupt EN_FAR *(old_vect23))(void);
void (interrupt EN_FAR *(old_vect1b))(void);

/* Trap break etc to allow program to terminate  on PC */
void interrupt EN_FAR en_ctrl_brk()
{
   terminate = 1;
}
void interrupt EN_FAR en_ctrl_c() {
   terminate =  1;
}

int ser_read(int fd,char *buf,int bufsize)
{
   int bufcnt = 0;
   int t;

   t = com_getc(&port_handle);
   while (t != -1 && bufcnt < bufsize) {
      *(buf++) = t;
      t = com_getc(&port_handle);
      bufcnt++;
   }
   return bufcnt;
}

int ser_write(int fd,char *buf,int bufsize)
{
   int bufcnt = bufsize;

   while (bufsize-- > 0) {
      while (com_putc(*buf,&port_handle) != 0);
      buf++;
   }
   return bufcnt;
}

void cleanup(void)
{
   while (!terminate && port_handle.tx_cnt != 0)
      ;
   if (terminate)
      com_clear_que(RX | TX, &port_handle);
   suspend(50);
   printf("Parity err %d framing err %d overrun err %d dropped %d\n",
      port_handle.parity_errs,port_handle.framing_errs,
      port_handle.overrun_errs,port_handle.rx_overflow);
   com_port_destroy(&port_handle);
   end_clock();
   setvect(0x23, old_vect23);                    /* restore ^C, ^Break     */
   setvect(0x1b, old_vect1b);
}

int init_comm(char *cport,long baud,int two_stop)
{
   int port;
   int base,irq;

   if (sscanf(cport,"%x,%x",&base,&irq) == 2) {
      port = COM1;
      com_config(COM1,base,irq);
   } else {
      if (strlen(cport) != 4 || strnicmp(cport,"COM",3) != 0 ||
            (cport[3] > '4' || cport[3] < '1')) {
         printf("Illegal port %s, must be com1 to com4\n",cport);
         exit(1);
      }
      switch(cport[3])
      {
        case '1': port = COM1; break;
        case '2': port = COM2; break;
        case '3': port = COM3; break;
        case '4': port = COM4; break;
        default:
           printf("Illegal port %s, must be com1 to com4\n",cport);
           exit(1);
      }
   }
   if( com_port_create(port, baud,'N',8,1 + two_stop, 4096, 4096,
      &port_handle) < 0 )
   {
     printf("Cannot create COM port");
     exit(1);
   }

   init_clock(0x3333);

   /*--------- take over 0x23 and 0x1B to suppress CTRL-C and Break ---------*/
   old_vect23 = getvect(0x23);
   old_vect1b = getvect(0x1b);
   setvect(0x23, en_ctrl_c);
   setvect(0x1b, en_ctrl_brk);
   atexit(cleanup);

   com_clear_que(RX | TX, &port_handle);

   if (port_handle.uart_type == ID_16550) {
      fifo_enable(&port_handle);
      com_fifo_trigger(RX_TRIG_4,&port_handle);
   }

   return 0;
}

#else

#ifdef _STDC_
int init_comm(char *, long, int);
#endif

int init_comm(port,baud,two_stop)
   char *port;
   long baud;
   int two_stop;

{
   struct termios tios;              /* Serial port TERMIO structure */
   int port_fd;

   port_fd = open(port,O_RDWR,0);
   if (port_fd < 0) {
      fprintf (stderr,"init_comm: Open failed on port '%s': ",port);
      perror("");
      exit(1);
   }

      /* Set to 8 bit 9600 baud no parity with no special processing */
   if (tcgetattr(port_fd,&tios) < 0) {
      perror("tcgetattr failed");
      exit(1);
   }
   tios.c_cflag = CS8 | CREAD | HUPCL | CLOCAL | baud;
   if (two_stop)
      tios.c_cflag |= CSTOPB;
   tios.c_iflag = 0;
   tios.c_lflag = 0;
   tios.c_oflag = 0;
   tios.c_cc[VMIN] = 0;
   tios.c_cc[VTIME] = 20;

   if (cfsetispeed(&tios,baud) != 0)
      printf("init_comm: set ispeed failed\n");
   if (cfsetospeed(&tios,baud) != 0)
      printf("init_comm: set ospeed failed\n");

   if (tcsetattr(port_fd,TCSANOW,&tios) < 0) {
      perror("fixmouse: tcsetattr failed");
      exit(1);
   }
   tcflush(port_fd,TCIOFLUSH);
   return(port_fd);
}

#endif
