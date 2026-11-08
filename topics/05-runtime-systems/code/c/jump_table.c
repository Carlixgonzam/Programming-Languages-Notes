#include <assert.h>
#include <stdio.h>

// <<case>>
/* case e of 1: A | 2,7: B | 3..5: C | 10: D else E end */
char with_case(int e) {
    switch (e) {
    case 1: return 'A';
    case 2: case 7: return 'B';
    case 3: case 4: case 5: return 'C';
    case 10: return 'D';
    default: return 'E';
    }
}
// <<case.end>>

// <<table>>
/* Jump table T: entry i-1 is the clause for the value i. */
static const char T[10] = {'A', 'B', 'C', 'C', 'C', 'E', 'B', 'E', 'E', 'D'};

char with_table(int e) {
    if (e < 1) return 'E';
    if (e > 10) return 'E';
    return T[e - 1];
}
// <<table.end>>

int main(void) {
    for (int e = -3; e <= 14; e++)
        assert(with_case(e) == with_table(e));
    assert(with_table(7) == 'B');
    assert(with_table(6) == 'E');
    printf("jump table: ok\n");
    return 0;
}
