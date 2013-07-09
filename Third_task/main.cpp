#include <assert.h>
#include <stdio.h>
#include <cmath>
#include <iostream>
#include <vector>
extern "C" {
    void dbl2str(double * in, char * out);
}

int main()
{
	double val = 0.045625;
    char * buffer = (char *) malloc(32);
    dbl2str(&val, buffer);
	return 0;
}
