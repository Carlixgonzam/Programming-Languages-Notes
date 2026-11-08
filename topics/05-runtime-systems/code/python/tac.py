OPS = {'add': '+', 'sub': '-', 'mul': '*'}

def tac(expr, code, counter, target=None):
    if expr[0] == 'var':
        return expr[1]
    left = tac(expr[1], code, counter)
    right = tac(expr[2], code, counter)
    if target is None:
        counter[0] += 1
        target = 't' + str(counter[0])
    code.append(target + ' = ' + left + ' ' + OPS[expr[0]] + ' ' + right)
    return target

def assign(name, expr):
    code = []
    tac(expr, code, [0], name)
    return code

a, b, c, d = ('var', 'a'), ('var', 'b'), ('var', 'c'), ('var', 'd')
assert assign('x', ('add', a, ('mul', b, c))) == ['t1 = b * c', 'x = a + t1']
assert assign('z', ('mul', ('add', a, b), ('sub', c, d))) == \
    ['t1 = a + b', 't2 = c - d', 'z = t1 * t2']
print("tac: ok")
