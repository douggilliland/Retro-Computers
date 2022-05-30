/* Print Pascal's triangle */
/* Invoke with .EXE CCR and enter this filenme */


#define COUNT 14

	int ar[20],i,j;

int main()
{
	for (i=1;i<COUNT;i++) {
		ar[i]=1;
		for (j=i-1;j>1;j--)
			ar[j]=ar[j-1]+ar[j];
		for (j=0;j<2*(COUNT-i-1);j++)
			putc(' ');
		for (j=1;j<i+1;j++)
			printf("%4d",ar[j]);
		printf("\r\n");
	}
	printf("Completed\r\n");
}
