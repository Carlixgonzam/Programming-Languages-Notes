# <<exceptions>>
def risky(x):
    if x == 0:
        raise ValueError("boom")
    return 10 // x

try:
    r = risky(0)
    r = 100                     # never reached
except ValueError:
    r = -1
# <<exceptions.end>>
assert r == -1

# <<generator>>
def countdown(n):
    while n > 0:
        yield n                 # the function stops here until the next value is asked
        n -= 1
# <<generator.end>>
assert list(countdown(3)) == [3, 2, 1]
