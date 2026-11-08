#include <assert.h>
#include <stdio.h>

int main(void) {
    int lines = 0, last = -1;
    // <<nested>>
    for (int i = 0; i < 10; i++) {
        for (int i = 0; i < 20; i++) {   /* this i hides the outer one */
            last = i;                     /* the lecture prints i here  */
            lines++;
        }
    }
    // <<nested.end>>
    assert(lines == 200);   /* 0..19 printed ten times */
    assert(last == 19);
    printf("ok\n");
    return 0;
}
