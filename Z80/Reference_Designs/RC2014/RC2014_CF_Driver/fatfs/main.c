#include "main.h"
#include "cf/cf.h"
#include <stdio.h>
#include "fat/pff.h"

void die (		/* Stop with dying message */
	FRESULT rc	/* FatFs return value */
)
{
	printf("Failed with rc=%u.\n", rc);
	for (;;) ;
}

void main()
{
	FRESULT rc;
	FATFS fatfs;
	DIR dir;
	FILINFO fno;
	UINT bw, br, i;
	BYTE buff[64];

	printf("\nMount a volume.\n");
	rc = pf_mount(&fatfs);
	if (rc) die(rc);

	printf("\nOpen a test file (TEST.TXT).\n");
	rc = pf_open("TEST.TXT");
	if (rc) die(rc);

	printf("\nType the file content.\n");
	for (;;) {
		rc = pf_read(buff, sizeof(buff), &br);	/* Read a chunk of file */
		if (rc || !br) break;			/* Error or end of file */
		for (i = 0; i < br; i++)		/* Type the data */
			putchar(buff[i]);
	}
	if (rc) die(rc);

	printf("\nOpen a file to write (write.txt).\n");
	rc = pf_open("TEST.TXT");
	if (rc) die(rc);

	printf("\nWrite a text data. (Hello world!)\n");
	for (;;) {
		rc = pf_write("Miau :3\r\n", 10, &bw);
		if (rc || !bw) break;
	}
	if (rc) die(rc);

	printf("\nTerminate the file write process.\n");
	rc = pf_write(0, 0, &bw);
	if (rc) die(rc);


	while(1)
	{

	}
}