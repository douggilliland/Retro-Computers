#include <init.h>
#include <libc.h>

int main ()
{
    int i, st;
    st = 0;

    for (i = 3; i < 1000; i++) {
        if ((i % 3 == 0) | (i % 5 == 0)) st = st + i;

        if (st > 1000) {
            printf("%d + ", st);
            st = 0;
        }
    }

    printf("%d\n", st);
}
