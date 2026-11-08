# <<interp>>
# AST shapes:
#   ('num', n)                    literal
#   ('var', name)                 variable reference
#   ('add', e1, e2), ('mul', e1, e2)
#   ('let', name, e1, e2)         let name = e1 in e2
#   ('if', cond, e1, e2)          if cond then e1 else e2 (0 is false)

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
# <<interp.end>>

# <<program>>
# let x = 2 + 3 in if x then x * 10 else 0
program = ('let', 'x', ('add', ('num', 2), ('num', 3)),
           ('if', ('var', 'x'),
            ('mul', ('var', 'x'), ('num', 10)),
            ('num', 0)))
# <<program.end>>

assert evaluate(program, {}) == 50
# let x = 4 in let y = x * x in y + 1
nested = ('let', 'x', ('num', 4),
          ('let', 'y', ('mul', ('var', 'x'), ('var', 'x')),
           ('add', ('var', 'y'), ('num', 1))))
assert evaluate(nested, {}) == 17
# the else branch is not evaluated: an unbound variable there is never looked up
assert evaluate(('if', ('num', 1), ('num', 7), ('var', 'unbound')), {}) == 7
print("interp: ok")
