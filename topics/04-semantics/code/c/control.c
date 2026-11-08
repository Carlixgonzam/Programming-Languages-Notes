#include <assert.h>
#include <stdio.h>
#include <string.h>

static int calls = 0;
int index_fn(int i) { calls++; return (i + calls) % 4; }

void gen_new_name(char *s, char l) {
    static short int name_nums[52];
    int index = (l >= 'a' && l <= 'z') ? l - 'a' : 26 + l - 'A';
    name_nums[index]++;
    sprintf(s, "%c%d", l, name_nums[index]);
}

struct node { int key; struct node *next; };

struct node *find(struct node *p, int val) {
    while (p && p->key != val)
        p = p->next;
    return p;
}

int gcd(int a, int b) {
    if (a == b) return a;
    else if (a > b) return gcd(a - b, b);
    else return gcd(a, b - a);
}

int gcd_loop(int a, int b) {
start:
    if (a == b) return a;
    else if (a > b) { a = a - b; goto start; }
    else { b = b - a; goto start; }
}

int main(void) {
    int A[4] = {0, 0, 0, 0}, B[4] = {0, 0, 0, 0};
    calls = 0;
    int j = index_fn(1);
    A[j] = A[j] + 1;
    calls = 0;
    B[index_fn(1)] = B[index_fn(1)] + 1;
    assert(A[2] == 1);
    int total = B[0] + B[1] + B[2] + B[3];
    assert(calls == 2 && total == 1);

    char name[8];
    gen_new_name(name, 'p'); assert(strcmp(name, "p1") == 0);
    gen_new_name(name, 'p'); assert(strcmp(name, "p2") == 0);
    gen_new_name(name, 'l'); assert(strcmp(name, "l1") == 0);

    struct node c = {3, NULL}, b = {2, &c}, a = {1, &b};
    assert(find(&a, 2) == &b);
    assert(find(&a, 9) == NULL);

    assert(gcd(12, 18) == 6 && gcd_loop(12, 18) == 6);
    printf("ok\n");
    return 0;
}
