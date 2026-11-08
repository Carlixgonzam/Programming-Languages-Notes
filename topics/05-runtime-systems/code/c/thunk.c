#include <assert.h>
#include <stdio.h>

typedef struct Thunk {
    int evaluated;
    int (*code)(void *env);
    void *env;
    int value;
} Thunk;

int force(Thunk *t) {
    if (!t->evaluated) {
        t->value = t->code(t->env);
        t->evaluated = 1;
    }
    return t->value;
}

static int calls = 0;
static int add(void *env) { int *xy = env; calls++; return xy[0] + xy[1]; }

int main(void) {
    int xy[2] = {3, 4};
    Thunk t = {0, add, xy, 0};
    assert(calls == 0);
    int sq = force(&t) * force(&t);
    assert(sq == 49 && calls == 1);
    printf("ok\n");
    return 0;
}
