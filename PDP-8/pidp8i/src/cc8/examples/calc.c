#include <init.h>
#include <libc.h>

int main()
{
    int x, y, ans;
    int choice;
    int bfr[10];

    /* CC8 doesn't let you initialize variables at declaration time. */
    ans = 'Y';                            

    /* This would be clearer as a do/while loop, but CC8 doesn't support
     * that yet. */
    while (1) {
        /* Force answer from tail end of loop to uppercase since CC8
         * doesn't know the || operator yet.  CC8's libc doesn't have
         * toupper(), and I can't seem to get its cupper() alternative
         * to work.  Don't rewrite with the -= operator: that doesn't
         * work yet, either. */
        if (ans > 'Z') ans = ans - 32;

        /* You might be tempted to write "if (ans != 'Y') break;" and
         * then do away with one indent level for the main body of code
         * that follows, but CC8 doesn't know the != operator yet. */
        if (ans == 'Y') {
            printf("\r\nENTER ANY TWO NUMBERS.\r\n");

            printf("ENTER THE FIRST NUMBER: ");
            gets(bfr);
            sscanf(bfr, "%d", &x);

            printf("ENTER THE SECOND NUMBER: ");
            gets(bfr);
            sscanf(bfr, "%d", &y);

            printf("SELECT THE OPERATION:\r\n");

            printf("1: ADDITION\r\n");
            printf("2: SUBTRACTION\r\n");
            printf("3: MULTIPLICATION\r\n");
            printf("4: DIVISION\r\n");

            printf("CHOICE: ");
            gets(bfr);
            sscanf(bfr, "%d", &choice);

            if (choice == 1) printf("Result: %d\r\n", x + y);
            if (choice == 2) printf("Result: %d\r\n", x - y);
            if (choice == 3) printf("Result: %d\r\n", x * y);
            if (choice == 4) printf("Result: %d\r\n", x / y);

            printf("DO YOU WISH TO CONTINUE (Y/N): ");
            ans = getc();
        }
        else {
            break;
        }
    }
}
