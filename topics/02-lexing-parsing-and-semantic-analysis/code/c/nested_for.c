#include <assert.h>
#include <stdio.h>

int main(void) {
    int lines = 0, last = -1;
    for (int i = 0; i < 10; i++) {
        for (int i = 0; i < 20; i++) {
            last = i;
            lines++;
        }
    }
    assert(lines == 200);
    assert(last == 19);
    printf("ok\n");
    return 0;
}
