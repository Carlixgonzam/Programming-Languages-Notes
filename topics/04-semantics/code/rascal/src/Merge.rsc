module Merge

list[int] merge([], list[int] ys) = ys;
list[int] merge(list[int] xs, []) = xs;
list[int] merge(first:[int x, *xs], second:[int y, *ys])
  = x < y ? [x] + merge(xs, second) : [y] + merge(first, ys);

test bool merged() = merge([1, 4, 9], [2, 3, 10]) == [1, 2, 3, 4, 9, 10];
test bool empty() = merge([], [5]) == [5] && merge([5], []) == [5];
