/***********************************************************************
 led-decay.cpp - Proof of concept for an LED brightness decay algorithm 
	that simulates the appearance of incandescent light bulbs when fed
	a stream of samples over a given time period.

 Copyright © 2016 Warren Young
 
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS LISTED ABOVE BE LIABLE FOR ANY CLAIM,
 DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
 THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 Except as contained in this notice, the names of the authors above
 shall not be used in advertising or otherwise to promote the sale, use
 or other dealings in this Software without prior written authorization
 from those authors.
***********************************************************************/

#include <iostream>
#include <vector>

using namespace std;

typedef vector<bool> vb;
typedef vb::const_iterator vbc;

// Keeping n samples.  To think about this concretely, imagine that it
// is 1 sample per millisecond over 0.1 sec, but realize that this is
// scaleable, so that how long 1/n seconds is doesn't affect the math.
static const size_t n = 100;

// Decay function is 1 - x^2, meaning the most recent event is
// considered 100%, with older events having increasingly lesser effect
// on the overall brightness until we hit 0% consideration at the end of
// the sample set.
//
// We need to scale that so that the total area under the decay
// function's curve is 1, so that if we feed a 50% duty cycle in, we
// get 50% out, but if we skew the 1s toward the front of the sample
// set (i.e. closer to "now"), we get greater brightness than if they
// are skewed toward the past.
//
// The Pi ships with Mathematica, which answers this question with:
//
//    Solve[Integrate[z * (1 - x^2), {x, 0, 1}] == 1, z]
//
// We get z = 1.5.
//
// If you want a different decay function, it needs to substitute for
// the 1 - x^2 bit.  It needs to start at 1 and decay to 0 over the
// range [0 <= x <= 1].  Run that through Mathematica to find the
// resulting value of z that gives a total of 1 over the sample span.
static double f(double x, bool v)
{
	return v ? (1.5 * (1 - x * x)) : 0;
}

// Given n bits representing the state of the LED at time x=1/n, return
// the total of applications of f on each bit.  Order is most recent
// event first, so it takes the strongest effect.
static double cdf(const vb& vl)
{
	double t = 0;
	for (size_t i = 0; i < n; ++i) {
		// We divide each f() return by n because it represents only 1/n
		// of the total area under the curve.  This is a crude form of
		// numeric integration.
		t += f(i / double(n), vl[i]) / n;
	}
	return t;
}

// Generate a series of sampled LED values, then run those sample sets
// through the above and show what brightness level that would generate.
int main()
{
	vb values(n);

	values.clear();
	for (size_t i = 0; i < n; ++i) {
		 values.push_back(true);
	}
	cout << "100% duty cycle: CDF = " << cdf(values) << endl;

	values.clear();
	for (size_t i = 0; i < n; ++i) {
		 values.push_back(i % 2 == 0);
	}
	cout << "50% duty cycle: CDF = " << cdf(values) << endl;

	values.clear();
	for (size_t i = 0; i < n; ++i) {
		 values.push_back(i % 4 == 0);
	}
	cout << "25% duty cycle: CDF = " << cdf(values) << endl;

	values.clear();
	for (size_t i = 0; i < n; ++i) {
		 values.push_back(i % 10 == 0);
	}
	cout << "10% duty cycle: CDF = " << cdf(values) << endl;

	values.assign(n, false);
	for (size_t i = 0; i < n / 2; ++i) {
		 values[i] = true;
	}
	cout << "First half 'on': CDF = " << cdf(values) << endl;

	values.assign(n, false);
	for (size_t i = n / 2; i < n; ++i) {
		 values[i] = true;
	}
	cout << "Second half 'on': CDF = " << cdf(values) << endl;

	values.assign(n, false);
	values[0] = true;
	cout << "1ms spike at the start: CDF = " << cdf(values) << endl;

	values.assign(n, false);
	values[n - 1] = true;
	cout << "1ms spike at the end: CDF = " << cdf(values) << endl;
}
