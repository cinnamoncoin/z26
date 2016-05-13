#include <stdio.h>

void main(int argc,char *argv[])
{
int i,j;
FILE *f;
char szBuffer[64];
for (i = 1;i < argc;i++)
	{
	f = fopen(argv[i],"rb");
	if (f == NULL) exit(fprintf(stderr,"Can't open %s.\n",argv[i]));
	printf(";\n; Code for %s\n;\n",argv[i]);
	while (!feof(f))
		{
		if (fread(szBuffer,1,32,f) == -1) break;
		printf(" db ");
		for (j = 0;j < 32;j++)
			{
			printf("0%02xh",szBuffer[j] & 0xFF);
			if (j < 31) printf(",");
			}
		printf("\n");
		}
	fclose(f);
	}
}

/*
 * $Log: bintoasm.c,v $
 * Revision 1.2  2004/05/08 18:06:57  urchlay
 *
 * Added Log tag to all C and asm source files.
 *
 */
