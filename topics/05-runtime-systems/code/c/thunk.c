#include <assert.h>
#include <stdio.h>

// <<thunk>>
typedef struct Thunk {
    int evaluated;              /* 0 until the first force */
    int (*code)(void *env);     /* the suspended expression */
    void *env;                  /* its free variables */
    int value;                  /* the result, kept after the first force */
} Thunk;

int force(Thunk *t) {
    if (!t->evaluated) {
        t->value = t->code(t->env);   /* the work is done once */
        t->evaluated = 1;
    }
    return t->value;
}
// <<thunk.end>>

static int calls = 0;
static int add(void *env) { int *xy = env; calls++; return xy[0] + xy[1]; }

int main(void) {
    int xy[2] = {3, 4};
    Thunk t = {0, add, xy, 0};
    assert(calls == 0);                      /* nothing computed yet */
    int sq = force(&t) * force(&t);          /* square (3+4) */
    assert(sq == 49 && calls == 1);          /* computed once */
    printf("ok\n");
    return 0;
}
