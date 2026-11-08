
def evaluate(expr, env):
    tag = expr[0]
    if tag == 'num':
        return expr[1]
    elif tag == 'var':
        return env[expr[1]]
    elif tag == 'add':
        return evaluate(expr[1], env) + evaluate(expr[2], env)
    elif tag == 'mul':
        return evaluate(expr[1], env) * evaluate(expr[2], env)
    elif tag == 'let':
        _, name, e1, e2 = expr
        v1 = evaluate(e1, env)
        return evaluate(e2, {**env, name: v1})
    elif tag == 'if':
        _, cond, e1, e2 = expr
        if evaluate(cond, env) != 0:
            return evaluate(e1, env)
        else:
            return evaluate(e2, env)
    else:
        raise ValueError("unknown AST node: " + tag)

program = ('let', 'x', ('add', ('num', 2), ('num', 3)),
           ('if', ('var', 'x'),
            ('mul', ('var', 'x'), ('num', 10)),
            ('num', 0)))

assert evaluate(program, {}) == 50
nested = ('let', 'x', ('num', 4),
          ('let', 'y', ('mul', ('var', 'x'), ('var', 'x')),
           ('add', ('var', 'y'), ('num', 1))))
assert evaluate(nested, {}) == 17
assert evaluate(('if', ('num', 1), ('num', 7), ('var', 'unbound')), {}) == 7
print("interp: ok")
