module Factorial

int factorial(int n) = n < 2 ? 1 : n * factorial(n - 1);

test bool factorialZero() = factorial(0) == 1;
test bool factorialFive() = factorial(5) == 120;
test bool factorialTen()  = factorial(10) == 3628800;
