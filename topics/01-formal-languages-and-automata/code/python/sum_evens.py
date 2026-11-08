def sum_evens(xs):
    total = 0
    for x in xs:
        if x % 2 == 0:
            total += x
    return total

assert sum_evens([]) == 0
assert sum_evens([1, 2, 3, 4]) == 6
assert sum_evens([5, 7]) == 0
