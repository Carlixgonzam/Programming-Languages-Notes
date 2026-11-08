funcs = []
for i in range(3):
    funcs.append(lambda: i)

fixed = []
for i in range(3):
    fixed.append(lambda i=i: i)

assert [f() for f in funcs] == [2, 2, 2]
assert [f() for f in fixed] == [0, 1, 2]
