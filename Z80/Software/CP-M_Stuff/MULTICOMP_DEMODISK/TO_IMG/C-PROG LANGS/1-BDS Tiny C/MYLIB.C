/*
	Searches the buffer at buff of length len
	for character chr.  Returns pointer to first
	occurrence of chr in buff or NULL if chr is not
	in buff.  NOTE:  This could be done with 1 CPIR
	instruction in machine code.  Write one.
*/

#include <bdscio.h>

char *index(buff,len,chr)
	char *buff,chr;
	unsigned len;
{
	char *last;

	last = buff + len;  /* sentinel beyond buffer */

	while(*buff != chr)
		if(++buff == last)return(NULL);

	return(buff);
}


/*
	Searches buffer buff of length len for first character
	which does not match character chr.  Returns a pointer
	to first such character or NULL if no such character
	exists.
*/

char *nindex(buff,len,chr)
	char *buff,chr;
	unsigned len;
{
	char *last;

	last = buff + len;  /* sentinel beyond buffer */

	while(*buff == chr)
		if(++buff == last)return(NULL);

	return(buff);
}


/*
	Removes all occurrnces of character chr from the 
	buffer buff of length len, shrinking the buffer.
	Returns the new buffer length.
*/

unsigned compress(buff,len,chr)
	char *buff,chr;
	unsigned len;
{
	char *tp1,*tp2;
	unsigned tplen;

	/* first check if chr exists in buffer */

	if((tp1 = index(buff,len,chr)) == NULL)
		return(len); /* No, return original length */

	/* find next non-chr character */
	/* if none exists, tp1 is boundary of new buffer */

	if((tp2 = nindex(tp1,len-(tp1-buff),chr)) == NULL)
		return(tp1-buff);

	/* close gap, recursively compressing the remainder */
	/* of buff from tp2 on.  Isn't recursion neat? */

	movmem(tp2,tp1,tplen=compress(tp2,len-(tp2-buff),chr));

	return(tplen + (tp1 - buff));
}

/*
	Reads nsec sectors from drive disk starting at 
	track trk, sector sctr to address buff.  Returns
	number of sectors successfully read.  Note: Assumes
	you have enough space at buff to hold everything.
	If not, it will write over whatever else is beyond.
	Use with caution.
*/

rdsecs(disk,trk,sctr,nsec,buff)
char disk,trk,sctr,*buff;
int nsec;
{
	int count;
	count = 0;
	bios(SELECT_DISK,disk);
	while(nsec--){
		bios(SET_DMA,buff);
		bios(SET_TRACK,trk);
		bios(SET_SECTOR,sctr);
		if(bios(READ_SECTOR) == 255)
			return(count);
		count++;
		if(++sctr > 26){
			sctr = 1;
			trk++;
			}
		if(trk > 76)return(count);
		buff += SECSIZ;
	}
}


/*
	Writes nsec sectors to drive disk starting at 
	track trk, sector sctr from address buff.  Returns
	number of sectors successfully written.
	Use with caution.
*/

wrtsecs(disk,trk,sctr,nsec,buff)
char disk,trk,sctr,*buff;
int nsec;
{
	int count;
	count = 0;
	bios(SELECT_DISK,disk);
	while(nsec--){
		bios(SET_DMA,buff);
		bios(SET_TRACK,trk);
		bios(SET_SECTOR,sctr);
		if(bios(WRITE_SECTOR) == 255)
			return(count);
		if(++sctr > 26){
			sctr = 1;
			trk++;
			}
		if(trk > 76)return(count);
		count++;
		buff += SECSIZ;
	}
}

/*
	Cursor positioning for the H19;  gotoxy(x,y,c) where 1<=x<=25,
	1<=y<=80 and c is a string pointer.  This function is also in 
	DEFF.CRL.  NOTE:  the 25th line must be separately enabled.
	Also, no attempt is made to ensure that x and y are in the 
	proper range. 
*/

gotoxy(line,column,string)
	int line,column;
	char *string;
{
	line--; column--;
	puts("\033Y");
	putchar(line+0x20); putchar(column+0x20);
	puts(string);
}
