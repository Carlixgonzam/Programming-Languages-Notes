
class Tokens:
    def __init__(self, items):
        self.items = items
        self.pos = 0

    def peek(self):
        return self.items[self.pos] if self.pos < len(self.items) else None

    def advance(self):
        tok = self.peek()
        self.pos += 1
        return tok

    def expect(self, tok):
        assert self.advance() == tok, "expected " + tok

PRECEDENCE = {"+": 1, "-": 1, "*": 2, "/": 2}

def parse_expr(tokens, min_bp=0):
    left = parse_atom(tokens)
    while True:
        op = tokens.peek()
        if op not in PRECEDENCE or PRECEDENCE[op] < min_bp:
            break
        tokens.advance()
        right = parse_expr(tokens, PRECEDENCE[op] + 1)
        left = (op, left, right)
    return left

def parse_atom(tokens):
    tok = tokens.advance()
    if tok == "(":
        e = parse_expr(tokens, 0)
        tokens.expect(")")
        return e
    return int(tok)

def parse(text):
    return parse_expr(Tokens(list(text.replace(" ", ""))))

assert parse("1 + 2 * 3") == ("+", 1, ("*", 2, 3))
assert parse("1 - 2 - 3") == ("-", ("-", 1, 2), 3)
assert parse("(1 + 2) * 3") == ("*", ("+", 1, 2), 3)
