#include <assert.h>
#include <stddef.h>
#include <stdio.h>

struct Point { double x; double y; };

int fact(int n) {
    if (n == 0) return 1;
    return n * fact(n - 1);
}

int main(void) {
    assert(offsetof(struct Point, x) == 0);
    assert(offsetof(struct Point, y) == sizeof(double));
    assert(fact(3) == 6);
    assert(fact(0) == 1);
    printf("layout: ok\n");
    return 0;
}
