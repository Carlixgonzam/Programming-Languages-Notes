# <<loopvar>>
funcs = []
for i in range(3):
    funcs.append(lambda: i)          # every lambda refers to the same i

fixed = []
for i in range(3):
    fixed.append(lambda i=i: i)      # the default value copies i now
# <<loopvar.end>>

assert [f() for f in funcs] == [2, 2, 2]
assert [f() for f in fixed] == [0, 1, 2]
