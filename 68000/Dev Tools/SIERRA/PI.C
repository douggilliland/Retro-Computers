#include <math.h>
#define ITERATIONS  10000

main()
{
    int i;
    int sign = 0;
    double pi = 0.0;

#if 0
    extern int _dp_math_trap;
    *(int **)176 = &_dp_math_trap;	/* trap 12 */
#endif

    for( i = 1; i < ITERATIONS; i += 2 )
	pi += (sign ^= 1) ? 4. / i : -4. / i;
    pi += 2. / (ITERATIONS - 2);
    printf("pi is equal to %.12f (%.12f)\n", pi, 4. * atan(1.0));
}

