#include <assert.h>
#include <stdio.h>

int divide(int numerator, int denominator) {
    assert(denominator != 0);
    return numerator / denominator;
}

int main(void) {
    assert(divide(10, 2) == 5);
    printf("ok\n");
    return 0;
}
