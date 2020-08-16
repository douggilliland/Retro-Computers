#include <stdio.h>
main()
{
    int i = 0;

    printf("\nWelcome to Sierra C\n\n");
    printf("\nHow many times would you like to see \"Hello World!\"? ");
    scanf("%d",&i);
    for( ; i; i-- )
	printf("%02d Hello World!\n",i);
}
