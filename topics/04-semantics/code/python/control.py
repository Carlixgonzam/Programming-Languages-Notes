def risky(x):
    if x == 0:
        raise ValueError("boom")
    return 10 // x

try:
    r = risky(0)
    r = 100
except ValueError:
    r = -1
assert r == -1

def countdown(n):
    while n > 0:
        yield n
        n -= 1
assert list(countdown(3)) == [3, 2, 1]
