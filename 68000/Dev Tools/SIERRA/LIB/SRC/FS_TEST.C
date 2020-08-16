#include <stdio.h>

char *file_descriptor_table = (void *)FDTAB;	/* address of fd table */

main()
{
    char buffer[512];
    FILE *fp;
    int count;

    /* initialize file systems */

#ifndef FS_REOPEN
    *(long *)file_descriptor_table = 0;	/* reset fd count    */
#endif
    fopen("dev_tty", "r");		/* open stdin	     */
    fopen("dev_tty", "w");		/* open stdout	     */
    fopen("dev_tty", "w");		/* open stderr	     */
    setvbuf(stdin, NULL, _IOLBF, 256);	/* line buffer stdin */
    setvbuf(stdout, NULL, _IONBF, 0);	/* no buffering	     */
    setvbuf(stderr, NULL, _IONBF, 0);	/* no buffering	     */

#ifdef FS_WRITE

    /* write the file */

    fp = fopen("ABC.123", "w");
    printf("\nEnter Data For File ABC.123 (blank line terminates entry)\n\n");
    for( ; ; ) {
	gets(buffer);			/* get a line from stdin */
	if( !*buffer )			/* check for blank line	 */
	    break;
	fprintf(fp, "%s\n", buffer);	/* write line to file	 */
    }		    
    fclose(fp);

#else

    /* read the file */

    fp = fopen("ABC.123", "r");
    while( count = fread(buffer, 1, 512, fp) )
	fwrite(buffer, 1, count, stdout);
    fclose(fp);

#endif
    fclose(stdin);
    fclose(stdout);
    fclose(stderr);
}		    /* EnDoFfIlE <-- end-of-file marker */

