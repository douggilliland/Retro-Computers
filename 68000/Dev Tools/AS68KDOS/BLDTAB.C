/*
        convert mnemonic/templates to C structures
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define NUM_OP 2000
char  mne[NUM_OP][12];
int  tidx[NUM_OP], tcount[NUM_OP];
int  GetFields(char *buff, char *fld[]);
int  nmne=0, lastidx=0;


/* ================================================================== */
void  TabStart(FILE *opf);
void  ReadCodes(char *fname, FILE *opf);
void  TabEnd(FILE *opf);
int  GetFields(char *buff, char *fld[]);


/* ================================================================== */
void  main(int argc, char *argv[])
{
  FILE  *opf;
  int  i, nxt=1;
  char  outname[80]="";


	if (argc < 2)
	{
		printf("Usage:  BLDTAB [-o outfile] file1 file2 file3 .......\n\n");
		exit(1);
	}
	else
	{
		for (i = 0; i < argc; i++)
			if (strcmpi(argv[i], "-O") == 0)
			{
				strcpy(outname, argv[i+1]);
				nxt = i+2;
			 	break;
			}

		if (strlen(outname) > 0)
		{
			if ((opf = fopen(outname, "wt")) == NULL)
			{
				fprintf(stderr, "Unable to open file <%s>\n", outname);
				exit(1);
			}
		}
		else
			opf = stdout;

		if (strlen(outname) > 0)
			printf("Output to file <%s>\n", outname);

		TabStart(opf);

		for (i = nxt; i < argc; i++)
			ReadCodes(argv[i], opf);

		TabEnd(opf);

		fclose(opf);

	}

	exit (0);

}  /* end of main() */


/* ================================================================== */
void  TabStart(FILE *opf)
{

	fprintf(opf, "#include \"table.h\"\n");
	fprintf(opf, "struct tmpl template[] = {\n\n");

}


/* ================================================================== */
void  ReadCodes(char *fname, FILE *opf)
{
  FILE  *inpf;
  int  num_fields;
  char  lastf[21], buff[257];
  char  *fld[5];


	if ((inpf = fopen(fname, "rt")) == NULL)
	{
		fprintf(stderr, "Unable to open file <%s>\n", fname);
		exit (1);
	}

	fgets(buff, 256, inpf);
	while (!feof(inpf))
	{
		buff[strlen(buff)-1] = 0;

		num_fields = GetFields(buff, fld);

		if( num_fields == 0 )
		;
		else if( num_fields == 1 )
		{             /* a new mnemonic */
			nmne++;
			strcpy(mne[nmne], fld[0]);
			tidx[nmne] = lastidx;
		}
		else
		{                           /* a template */
			if( num_fields == 4 )
				strcpy(lastf, "0");
			else
				strcpy(lastf, fld[4]);

			fprintf (opf, "{ %s, {%s}, %s, 0x%s, 0x%s },",
				    fld[0], fld[1], fld[2], fld[3], lastf);

			if( tidx[nmne] == lastidx )
				fprintf (opf, "        /* %d = %s */\n", lastidx, mne[nmne]);
			else
				fprintf (opf, "\n");

			tcount[nmne]++;
			lastidx++;

		}

		fgets(buff, 256, inpf);

	} /* read line from file */

}  /* end of ReadCodes() */


/* ================================================================== */
void  TabEnd(FILE *opf)
{
  FILE  *wkf;
  int  i;


	fprintf (opf, "};\n\n");
	fprintf (opf, "/*  %d mnemonics, %d templates  */\n\n",nmne,lastidx);
	fprintf (opf, "struct mne mnemonic[] = {\n");

	if ((wkf = fopen("mne.wk", "wt")) == NULL)
	{
		fprintf(stderr, "Unable to open file <MNE.WK>\n");
		exit (1);
	}

	for(i=1; i<=nmne; i++)
		fprintf (wkf, "\"%s\", %d, &template[%d],\n", mne[i], tcount[i], tidx[i]);

	fclose(wkf);
	system("SORT <MNE.WK >MNE.SOR");

}


/* ================================================================== */
int  GetFields(char *buff, char *fld[])
{
  int  i, nf=0;
  char  seps[]=" \x9";


	for (i = 0; i < 5; fld[i++] = NULL);

   fld[0] = strtok(buff, seps);
	if (fld[0] != NULL)
	{
		nf++;

		while (nf < 5)
			if ((fld[nf] = strtok(NULL, seps)) == NULL)
				break;
			else
				nf++;
			
	}

	return (nf);

}  /* end of GetFields() */

