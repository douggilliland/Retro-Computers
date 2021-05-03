/*	@(#)config.c	3.1		*/
/*
 * this program sets up the baud rate of
 * the lst: serial port.
 */

#define BAUDCTL ((char *)0xf1c1c5)

main()
{
  int baudval;

  printf("\n\rBaud rate selection options:\n\r");
  printf("   0 =    50,  1 =    75,  2 =   110,  3 =   134,\n\r");
  printf("   4 =   150,  5 =   300,  6 =   600,  7 =  1200,\n\r");
  printf("   8 =  1800,  9 =  2000, 10 =  2400, 11 =  3600,\n\r");
  printf("  12 =  4800, 13 =  7200, 14 =  9600, 15 = 19200\n\r");
  printf("\n\rEnter number of desired baud rate: ");
  scanf("%d",&baudval);
  if ( (baudval < 0) || (baudval > 15) )
  {
    printf("\n\rError: %d is not a valid baud selection.\n\r",baudval);
    return;
  }
  *BAUDCTL = (*BAUDCTL & 0xf0) | baudval;
  printf("\n\rBaud rate reconfigured.\n\r");
}
\n\r",baudval);
    return;
  }
  *BAUDCTL = (*BAUDCTL & 0xf0) | baudval;
  printf("\n\rB