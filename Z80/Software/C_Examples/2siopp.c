/* 2siopp.c - STB389 */
#define sio1Ctl 0x80 	/* ACIA ports */
#define sio1Dat 0x81
#define sio2Ctl 0x82
#define sio2Dat 0x83
#define sioRst 0x02		/* Controls for UART */
#define sio8N1 0x15
#define exitChr 0x1B
#define chrRdy	0x03

int main()
{
	char s1 = 0x00;
	char d1 = 0x00;
	char s2 = 0x00;
	char d2 = 0x00;
	/* reset ACIAs and set to n,8,1 */ 
	out(sio1Ctl,sioRst);
	out(sio2Ctl,sioRst);
	out(sio1Ctl,sio8N1);
	out(sio2Ctl,sio8N1);
	/* printf("s1:d1 s2:d2\n"); */
	do
	{
		s1 = in(sio1Ctl);
		if (s1 == chrRdy)
		{
			d1 = in(sio1Dat);
			out(sio2Dat,d1);
		}
		s2 = in(sio2Ctl);
		if (s2 == chrRdy)
		{
			d2 = in(sio2Dat);
			out(sio1Dat,d2);
		}
		/* printf("%02x:%02x %02x:%02x\r",s1,d1,s2,d2); */
	}
	while((s2!=chrRdy) || (d2!=exitChr));
}
