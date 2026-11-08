#include <assert.h>
#include <stdio.h>

char with_case(int e) {
    switch (e) {
    case 1: return 'A';
    case 2: case 7: return 'B';
    case 3: case 4: case 5: return 'C';
    case 10: return 'D';
    default: return 'E';
    }
}

static const char T[10] = {'A', 'B', 'C', 'C', 'C', 'E', 'B', 'E', 'E', 'D'};

char with_table(int e) {
    if (e < 1) return 'E';
    if (e > 10) return 'E';
    return T[e - 1];
}

int main(void) {
    for (int e = -3; e <= 14; e++)
        assert(with_case(e) == with_table(e));
    assert(with_table(7) == 'B');
    assert(with_table(6) == 'E');
    printf("jump table: ok\n");
    return 0;
}
