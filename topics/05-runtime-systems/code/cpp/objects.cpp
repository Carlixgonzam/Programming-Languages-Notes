#include <cassert>
#include <cstdio>

int count = 0;

class list {
public:
    int info;
    list *next;
    list(int x) {
        info = x;
        count++;
        next = nullptr;
    }
    virtual int last() {
        if (next == nullptr) return info;
        else return next->last();
    }
};

int main() {
    list *lst1 = new list(1);
    list *lst2 = new list(2);
    lst1->next = lst2;
    assert(count == 2);
    assert(lst1->last() == 2);
    assert(lst1 != lst2);
    std::printf("objects: ok\n");
    delete lst1;
    delete lst2;
    return 0;
}
