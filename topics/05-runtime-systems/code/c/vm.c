#include <assert.h>
#include <stdio.h>

enum { OP_CONSTANT, OP_ADD, OP_SUBTRACT, OP_MULTIPLY, OP_PRINT, OP_RETURN };

static double stack[256];
static int top = 0;                       /* number of values on the stack */
static void push(double v) { stack[top++] = v; }
static double pop(void) { return stack[--top]; }
static double printed;                    /* last value printed, for the tests */

// <<run>>
void run(const unsigned char *ip, const double *constants) {
    for (;;) {
        unsigned char instruction = *ip++;          /* fetch */
        switch (instruction) {                      /* dispatch */
        case OP_CONSTANT: push(constants[*ip++]); break;
        case OP_ADD:      { double b = pop(), a = pop(); push(a + b); break; }
        case OP_SUBTRACT: { double b = pop(), a = pop(); push(a - b); break; }
        case OP_MULTIPLY: { double b = pop(), a = pop(); push(a * b); break; }
        case OP_PRINT:    printed = pop(); printf("%g\n", printed); break;
        case OP_RETURN:   return;
        }
    }
}
// <<run.end>>

int main(void) {
// <<program>>
    /* print (2 + 3) * 4 */
    const double constants[] = {2, 3, 4};
    const unsigned char code[] = {
        OP_CONSTANT, 0, OP_CONSTANT, 1, OP_ADD,
        OP_CONSTANT, 2, OP_MULTIPLY, OP_PRINT, OP_RETURN
    };
// <<program.end>>
    run(code, constants);
    assert(printed == 20 && top == 0);

    const double constants2[] = {10, 4, 2};
    const unsigned char code2[] = {
        OP_CONSTANT, 0, OP_CONSTANT, 1, OP_SUBTRACT,
        OP_CONSTANT, 2, OP_MULTIPLY, OP_PRINT, OP_RETURN
    };
    run(code2, constants2);
    assert(printed == 12 && top == 0);
    printf("vm: ok\n");
    return 0;
}
