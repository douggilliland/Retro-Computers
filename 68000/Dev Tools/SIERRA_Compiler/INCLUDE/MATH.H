/*--------------------------------- math.h ----------------------------------*

/*
 *  Copyright 1992 by Sierra Systems.  All rights reserved.
 */

#define HUGE_VAL    DP_HUGE
#define HUGE_VALF   FP_HUGE
#define HUGE_VALFF  FF_HUGE

/* the following are defined in mx_xcptn.s and h_xcptn.s */

extern double DP_HUGE;
extern float FP_HUGE;
extern float FF_HUGE;

double acos(double x);
double asin(double x);
double atan(double x);
double atan2(double y, double x);
double cos(double x);
double sin(double x);
double tan(double x);
double cosh(double x);
double sinh(double x);
double tanh(double x);
double exp(double x);
double frexp(double value, int *exp);
double ldexp(double x, int exp);
double log(double x);
double log10(double x);
double modf(double value, double *iptr);
double pow(double x, double y);
double sqrt(double x);
double ceil(double x);
double fabs(double x);
double floor(double x);
double fmod(double x, double y);
float _ieee2mot(float x);
float _mot2ieee(float x);

#if 1

float acosf(float x);
float asinf(float x);
float atanf(float x);
float atan2f(float y, float x);
float cosf(float x);
float sinf(float x);
float tanf(float x);
float coshf(float x);
float sinhf(float x);
float tanhf(float x);
float expf(float x);
float frexpf(float value, int *exp);
float ldexpf(float x, int exp);
float logf(float x);
float log10f(float x);
float modff(float value, float *iptr);
float powf(float x, float y);
float sqrtf(float x);
float ceilf(float x);
float fabsf(float x);
float floorf(float x);
float fmodf(float x, float y);

float acosff(float x);
float asinff(float x);
float atanff(float x);
float atan2ff(float y, float x);
float cosff(float x);
float sinff(float x);
float tanff(float x);
float coshff(float x);
float sinhff(float x);
float tanhff(float x);
float expff(float x);
float frexpff(float value, int *exp);
float ldexpff(float x, int exp);
float logff(float x);
float log10ff(float x);
float modfff(float value, float *iptr);
float powff(float x, float y);
float sqrtff(float x);
float ceilff(float x);
float fabsff(float x);
float floorff(float x);
float fmodff(float x, float y);

#endif
