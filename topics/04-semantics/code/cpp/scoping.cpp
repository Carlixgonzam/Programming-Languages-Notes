#include <cassert>
#include <functional>
#include <iostream>
#include <sstream>
#include <vector>

std::string holes() {
    std::ostringstream cout;
    int a = 1;
    int b = 1;
    {
        int b = 2;
        {
            int a = 3;
            cout << a << b << " ";
        }
        {
            int b = 4;
            cout << a << b << " ";
        }
        cout << a << b << " ";
    }
    cout << a << b;
    return cout.str();
}

void swapByValue(int x, int y) { int t = x; x = y; y = t; }
void swapByReference(int &x, int &y) { int t = x; x = y; y = t; }

void p1Ref(int a, int &b, int &c) { b = b + 1; c = a; }

void p1Name(int a, int &b, std::function<int&()> c) { b = b + 1; c() = a; }

void p1VR(int a, int &bOut, std::function<int&()> c) {
    int b = bOut;
    b = b + 1;
    c() = a;
    bOut = b;
}

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
