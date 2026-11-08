#include <assert.h>
#include <stdio.h>

// <<division>>
int divide(int numerator, int denominator) {
    assert(denominator != 0);          /* checked while the program runs */
    return numerator / denominator;
}
// <<division.end>>

int main(void) {
    assert(divide(10, 2) == 5);
    printf("ok\n");
    return 0;
}
