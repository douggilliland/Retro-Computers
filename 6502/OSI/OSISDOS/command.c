/* Command Handler	*/

#include <conio.h>
#include <stdlib.h>

extern const char text[];       /* In text.s */

int main (void)
{
    clrscr ();
    cprintf ("%s\r\nPress <RETURN>.\r\n", text);
    cgetc ();
    return EXIT_SUCCESS;
}
