#include <cassert>
#include <functional>
#include <iostream>
#include <sstream>
#include <vector>

std::string holes() {
    std::ostringstream cout;
    // <<shadows>>
    int a = 1;
    int b = 1;
    {
        int b = 2;
        {
            int a = 3;
            cout << a << b << " ";       // 3 2
        }
        {
            int b = 4;
            cout << a << b << " ";       // 1 4
        }
        cout << a << b << " ";           // 1 2
    }
    cout << a << b;                      // 1 1
    // <<shadows.end>>
    return cout.str();
}

// <<swap>>
void swapByValue(int x, int y) { int t = x; x = y; y = t; }
void swapByReference(int &x, int &y) { int t = x; x = y; y = t; }
// <<swap.end>>

// <<params>>
// p1(val a, ref b, ref c):  b = b + 1; c = a;
void p1Ref(int a, int &b, int &c) { b = b + 1; c = a; }

// p1(val a, ref b, name c): c is re-evaluated at every use.
void p1Name(int a, int &b, std::function<int&()> c) { b = b + 1; c() = a; }

// p1(val a, VR b, name c): b is copied in, and copied back at the end.
void p1VR(int a, int &bOut, std::function<int&()> c) {
    int b = bOut;          // copy in
    b = b + 1;
    c() = a;
    bOut = b;              // copy out (restore)
}
// <<params.end>>

int main() {
    assert(holes() == "32 14 12 11");

    int x = 1, y = 2;
    swapByValue(x, y);     assert(x == 1 && y == 2);
    swapByReference(x, y); assert(x == 2 && y == 1);

    std::vector<int> v = {0, 1, 2, 3, 4};
    int px = 10, py = 1;
    p1Ref(px, py, v[py]);
    assert(py == 2 && (v == std::vector<int>{0, 10, 2, 3, 4}));

    v = {0, 1, 2, 3, 4}; px = 10; py = 1;
    p1Name(px, py, [&]() -> int& { return v[py]; });
    assert(py == 2 && (v == std::vector<int>{0, 1, 10, 3, 4}));

    v = {0, 1, 2, 3, 4}; px = 10; py = 1;
    p1VR(px, py, [&]() -> int& { return v[py]; });
    assert(py == 2 && (v == std::vector<int>{0, 10, 2, 3, 4}));

    std::cout << "ok\n";
    return 0;
}
