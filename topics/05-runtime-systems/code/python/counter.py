def make_counter(start):
    n = start
    def bump():
        nonlocal n
        n += 1
        return n
    return bump

c1 = make_counter(5)
c2 = make_counter(100)
assert c1() == 6
assert c1() == 7
assert c2() == 101
assert c1.__closure__[0] is not c2.__closure__[0]
print("counter: ok")
