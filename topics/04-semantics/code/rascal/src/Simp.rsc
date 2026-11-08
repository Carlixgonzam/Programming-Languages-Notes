module Simp

import ParseTree;
import List;
import Map;
import String;

layout Layout = [\ \t\n]* !>> [\ \t\n];
keyword Reserved = "if" | "then" | "else" | "while" | "do" | "skip"
                 | "true" | "false" | "repeat" | "times"
                 | "for" | "begin" | "loc" | "end";
lexical Loc = ([a-z][a-z0-9]* !>> [a-z0-9]) \ Reserved;
lexical Num = [0-9]+ !>> [0-9];

start syntax C
  = assign: Loc ":=" E
  | skip: "skip"
  | ifC: "if" B "then" C "else" C
  | whileC: "while" B "do" C
  | repeat: "repeat" E "times" C
  | forC: "for" "(" C ";" B ";" C ")" "{" C "}"
  | block: "begin" "loc" Loc ":=" E ";" C "end"
  | bracket "(" C ")"
  > right seq: C ";" C
  ;

syntax E
  = lit: Num
  | deref: "!" Loc
  | bracket "(" E ")"
  > left (mul: E "*" E | div: E "/" E)
  > left (add: E "+" E | sub: E "-" E)
  ;

syntax B
  = tt: "true" | ff: "false"
  | gt: E "\>" E | lt: E "\<" E | eq: E "=" E
  | neg: "¬" B
  | bracket "(" B ")"
  > left and: B "∧" B
  ;

data Cmd = assign(str l, Exp e) | skip() | ifC(BExp b, Cmd c1, Cmd c2)
         | whileC(BExp b, Cmd c) | seq(Cmd c1, Cmd c2)
         | repeat(Exp e, Cmd c) | forC(Cmd init, BExp b, Cmd step, Cmd body)
         | block(str z, Exp e, Cmd c);

data Exp = lit(int n) | deref(str l)
         | add(Exp e1, Exp e2) | sub(Exp e1, Exp e2) | mul(Exp e1, Exp e2) | div(Exp e1, Exp e2);

data BExp = tt() | ff() | gt(Exp e1, Exp e2) | lt(Exp e1, Exp e2) | eq(Exp e1, Exp e2)
          | neg(BExp b) | and(BExp b1, BExp b2);

alias Store = map[str, int];

public Cmd cmd(str src) = implode(#Cmd, parse(#start[C], src).top);
public Exp expr(str src) = implode(#Exp, parse(#E, src));

int apply("+", int a, int b) = a + b;
int apply("-", int a, int b) = a - b;
int apply("*", int a, int b) = a * b;
int apply("/", int a, int b) = a / b;

tuple[str, Exp, Exp] parts(add(a, b)) = <"+", a, b>;
tuple[str, Exp, Exp] parts(sub(a, b)) = <"-", a, b>;
tuple[str, Exp, Exp] parts(mul(a, b)) = <"*", a, b>;
tuple[str, Exp, Exp] parts(div(a, b)) = <"/", a, b>;

data Item = cI(Cmd c) | eI(Exp e) | bI(BExp b)
          | opI(str op) | notI() | andI() | bopI(str op) | assignI() | ifI() | whileI();
data Val = n(int v) | b(bool truth) | l(str name) | cV(Cmd c) | bV(BExp b);
alias Config = tuple[list[Item] c, list[Val] r, Store m];

bool compare("\>", int x, int y) = x > y;
bool compare("\<", int x, int y) = x < y;
bool compare("=", int x, int y) = x == y;

Config machineStep(<[eI(lit(v)), *c], r, m>)  = <c, [n(v)] + r, m>;
Config machineStep(<[eI(deref(x)), *c], r, m>) = <c, [n(m[x])] + r, m>;
Config machineStep(<[eI(e), *c], r, m>) = <[eI(e1), eI(e2), opI(op)] + c, r, m>
  when <op, e1, e2> := parts(e);
Config machineStep(<[opI(op), *c], [n(n1), n(n2), *r], m>) = <c, [n(apply(op, n2, n1))] + r, m>;

Config machineStep(<[bI(tt()), *c], r, m>) = <c, [b(true)] + r, m>;
Config machineStep(<[bI(ff()), *c], r, m>) = <c, [b(false)] + r, m>;
Config machineStep(<[bI(neg(x)), *c], r, m>) = <[bI(x), notI()] + c, r, m>;
Config machineStep(<[notI(), *c], [b(v), *r], m>) = <c, [b(!v)] + r, m>;
Config machineStep(<[bI(and(x, y)), *c], r, m>) = <[bI(x), bI(y), andI()] + c, r, m>;
Config machineStep(<[andI(), *c], [b(v1), b(v2), *r], m>) = <c, [b(v2 && v1)] + r, m>;
Config machineStep(<[bI(gt(e1, e2)), *c], r, m>) = <[eI(e1), eI(e2), bopI("\>")] + c, r, m>;
Config machineStep(<[bI(lt(e1, e2)), *c], r, m>) = <[eI(e1), eI(e2), bopI("\<")] + c, r, m>;
Config machineStep(<[bI(eq(e1, e2)), *c], r, m>) = <[eI(e1), eI(e2), bopI("=")] + c, r, m>;
Config machineStep(<[bopI(op), *c], [n(n1), n(n2), *r], m>) = <c, [b(compare(op, n2, n1))] + r, m>;

Config machineStep(<[cI(skip()), *c], r, m>) = <c, r, m>;
Config machineStep(<[cI(seq(c1, c2)), *c], r, m>) = <[cI(c1), cI(c2)] + c, r, m>;
Config machineStep(<[cI(ifC(x, c1, c2)), *c], r, m>) = <[bI(x), ifI()] + c, [cV(c1), cV(c2)] + r, m>;
Config machineStep(<[ifI(), *c], [b(true), cV(c1), cV(_), *r], m>) = <[cI(c1)] + c, r, m>;
Config machineStep(<[ifI(), *c], [b(false), cV(_), cV(c2), *r], m>) = <[cI(c2)] + c, r, m>;
Config machineStep(<[cI(w:whileC(x, body)), *c], r, m>) = <[bI(x), whileI()] + c, [bV(x), cV(body)] + r, m>;
Config machineStep(<[whileI(), *c], [b(true), bV(x), cV(body), *r], m>)
  = <[cI(body), cI(whileC(x, body))] + c, r, m>;
Config machineStep(<[whileI(), *c], [b(false), bV(_), cV(_), *r], m>) = <c, r, m>;
Config machineStep(<[cI(assign(x, e)), *c], r, m>) = <[eI(e), assignI()] + c, [l(x)] + r, m>;
Config machineStep(<[assignI(), *c], [n(v), l(x), *r], m>) = <c, r, m + (x: v)>;

tuple[Store, int] runMachine(Cmd p, Store m) {
  Config conf = <[cI(p)], [], m>;
  int steps = 0;
  while (conf.c != []) { conf = machineStep(conf); steps += 1; }
  return <conf.m, steps>;
}

int evalMachine(Exp e) {
  Config conf = <[eI(e)], [], ()>;
  while (conf.c != []) conf = machineStep(conf);
  return conf.r[0].v;
}

list[tuple[Exp, Store]] stepE(deref(x), Store s) = x in s ? [<lit(s[x]), s>] : [];
list[tuple[Exp, Store]] stepE(lit(_), Store _) = [];
default list[tuple[Exp, Store]] stepE(Exp e, Store s) {
  <op, e1, e2> = parts(e);
  if (lit(n1) := e1, lit(n2) := e2) return [<lit(apply(op, n1, n2)), s>];
  if (lit(_) !:= e1) return [ <rebuild(e, e1p, e2), s1> | <e1p, s1> <- stepE(e1, s) ];
  return [ <rebuild(e, e1, e2p), s1> | <e2p, s1> <- stepE(e2, s) ];
}

Exp rebuild(add(_, _), Exp a, Exp b) = add(a, b);
Exp rebuild(sub(_, _), Exp a, Exp b) = sub(a, b);
Exp rebuild(mul(_, _), Exp a, Exp b) = mul(a, b);
Exp rebuild(div(_, _), Exp a, Exp b) = div(a, b);

list[tuple[BExp, Store]] stepB(tt(), Store _) = [];
list[tuple[BExp, Store]] stepB(ff(), Store _) = [];
list[tuple[BExp, Store]] stepB(neg(tt()), Store s) = [<ff(), s>];
list[tuple[BExp, Store]] stepB(neg(ff()), Store s) = [<tt(), s>];
default list[tuple[BExp, Store]] stepB(neg(x), Store s) = [ <neg(y), s1> | <y, s1> <- stepB(x, s) ];
list[tuple[BExp, Store]] stepB(and(x, y), Store s) {
  if (x in {tt(), ff()} && y in {tt(), ff()}) return [<x == tt() && y == tt() ? tt() : ff(), s>];
  if (x notin {tt(), ff()}) return [ <and(x1, y), s1> | <x1, s1> <- stepB(x, s) ];
  return [ <and(x, y1), s1> | <y1, s1> <- stepB(y, s) ];
}
default list[tuple[BExp, Store]] stepB(BExp x, Store s) {
  <op, e1, e2> = bparts(x);
  if (lit(n1) := e1, lit(n2) := e2) return [<compare(op, n1, n2) ? tt() : ff(), s>];
  if (lit(_) !:= e1) return [ <brebuild(x, e1p, e2), s1> | <e1p, s1> <- stepE(e1, s) ];
  return [ <brebuild(x, e1, e2p), s1> | <e2p, s1> <- stepE(e2, s) ];
}

tuple[str, Exp, Exp] bparts(gt(a, b)) = <"\>", a, b>;
tuple[str, Exp, Exp] bparts(lt(a, b)) = <"\<", a, b>;
tuple[str, Exp, Exp] bparts(eq(a, b)) = <"=", a, b>;
BExp brebuild(gt(_, _), Exp a, Exp b) = gt(a, b);
BExp brebuild(lt(_, _), Exp a, Exp b) = lt(a, b);
BExp brebuild(eq(_, _), Exp a, Exp b) = eq(a, b);

list[tuple[Cmd, Store]] stepC(skip(), Store _) = [];
list[tuple[Cmd, Store]] stepC(assign(x, lit(v)), Store s) = [<skip(), s + (x: v)>];
default list[tuple[Cmd, Store]] stepC(assign(x, e), Store s)
  = [ <assign(x, e1), s1> | <e1, s1> <- stepE(e, s) ];
list[tuple[Cmd, Store]] stepC(seq(skip(), c2), Store s) = [<c2, s>];
default list[tuple[Cmd, Store]] stepC(seq(c1, c2), Store s)
  = [ <seq(c1p, c2), s1> | <c1p, s1> <- stepC(c1, s) ];
list[tuple[Cmd, Store]] stepC(ifC(tt(), c1, _), Store s) = [<c1, s>];
list[tuple[Cmd, Store]] stepC(ifC(ff(), _, c2), Store s) = [<c2, s>];
default list[tuple[Cmd, Store]] stepC(ifC(x, c1, c2), Store s)
  = [ <ifC(y, c1, c2), s1> | <y, s1> <- stepB(x, s) ];
list[tuple[Cmd, Store]] stepC(w:whileC(x, c), Store s)
  = [<ifC(x, seq(c, w), skip()), s>];

list[tuple[Cmd, Store]] stepC(repeat(lit(v), c), Store s)
  = v <= 0 ? [<skip(), s>]
           : [<seq(c, repeat(lit(v - 1), c)), s>];
default list[tuple[Cmd, Store]] stepC(repeat(e, c), Store s)
  = [ <repeat(e1, c), s1> | <e1, s1> <- stepE(e, s) ];

list[tuple[Cmd, Store]] stepC(forC(skip(), x, st, body), Store s)
  = [<ifC(x, seq(body, seq(st, forC(skip(), x, st, body))), skip()), s>];
default list[tuple[Cmd, Store]] stepC(forC(init, x, st, body), Store s)
  = [ <forC(i1, x, st, body), s1> | <i1, s1> <- stepC(init, s) ];

list[tuple[Cmd, Store]] trace(Cmd c, Store s) {
  list[tuple[Cmd, Store]] t = [<c, s>];
  while ([next] := stepC(c, s)) { <c, s> = next; t += [<c, s>]; }
  return t;
}

int evalE(lit(v), Store _) = v;
int evalE(deref(x), Store s) = s[x];
default int evalE(Exp e, Store s) { <op, e1, e2> = parts(e); return apply(op, evalE(e1, s), evalE(e2, s)); }

bool evalB(tt(), Store _) = true;
bool evalB(ff(), Store _) = false;
bool evalB(neg(x), Store s) = !evalB(x, s);
bool evalB(and(x, y), Store s) = evalB(x, s) && evalB(y, s);
default bool evalB(BExp x, Store s) { <op, e1, e2> = bparts(x); return compare(op, evalE(e1, s), evalE(e2, s)); }

Store evalC(skip(), Store s) = s;
Store evalC(assign(x, e), Store s) = s + (x: evalE(e, s));
Store evalC(seq(c1, c2), Store s) = evalC(c2, evalC(c1, s));
Store evalC(ifC(x, c1, c2), Store s) = evalB(x, s) ? evalC(c1, s) : evalC(c2, s);
Store evalC(w:whileC(x, c), Store s) = evalB(x, s) ? evalC(w, evalC(c, s)) : s;

Store evalC(repeat(e, c), Store s) {
  int v = evalE(e, s);
  return v <= 0 ? s : evalC(repeat(lit(v - 1), c), evalC(c, s));
}

Store evalC(forC(init, x, st, body), Store s) = evalC(whileC(x, seq(body, st)), evalC(init, s));

Store evalC(block(z, e, c), Store s) {
  int v = evalE(e, s);
  str fresh = "l<size(s)>";
  while (fresh in s) fresh += "\'";
  Cmd body = visit (c) { case assign(z, ex) => assign(fresh, ex) case deref(z) => deref(fresh) };
  Store s2 = evalC(body, s + (fresh: v));
  return delete(s2, fresh);
}

Cmd factorial = cmd("while !l \> 0 do (fac := !fac * !l; l := !l - 1)");

test bool machineExpression() = evalMachine(expr("3 * (4 + 5)")) == 27;
test bool machineFactorial() = runMachine(factorial, ("l": 4, "fac": 1))[0] == ("l": 0, "fac": 24);
test bool machineSubtraction() = runMachine(cmd("x := 10 - 3"), ())[0] == ("x": 7);

Cmd swap = cmd("z := !x; (x := !y; y := !z)");
Store s0 = ("z": 0, "x": 1, "y": 2);

test bool smallSwap() = last(trace(swap, s0)) == <skip(), ("z": 1, "x": 2, "y": 1)>;
test bool smallSwapSteps() = size(trace(swap, s0)) == 9;
test bool bigSwap() = evalC(swap, s0) == ("z": 1, "x": 2, "y": 1);
test bool bigFactorial() = evalC(factorial, ("l": 4, "fac": 1)) == ("l": 0, "fac": 24);
test bool smallFactorial() = last(trace(factorial, ("l": 4, "fac": 1)))[1] == ("l": 0, "fac": 24);

test bool blocked() = assign("x", deref("w")) := last(trace(cmd("x := !w"), ()))[0];

test bool blockSwap() = evalC(cmd("begin loc z := !x; x := !y; y := !z end"), ("x": 1, "y": 2)) == ("x": 2, "y": 1);

Cmd rep = cmd("repeat !k times (x := !x + 1; k := !k + 1)");
test bool repeatOnce() = evalC(rep, ("x": 0, "k": 2)) == ("x": 2, "k": 4);
test bool repeatSmall() = last(trace(rep, ("x": 0, "k": 2)))[1] == ("x": 2, "k": 4);
test bool repeatNegative() = evalC(cmd("repeat 0 - 3 times x := 1"), ("x": 0)) == ("x": 0)
  && last(trace(cmd("repeat 0 - 3 times x := 1"), ("x": 0))) == <skip(), ("x": 0)>;

Cmd sumFor = cmd("for (i := 1; !i \< 5; i := !i + 1) { s := !s + !i }");
test bool forBig() = evalC(sumFor, ("s": 0)) == ("s": 10, "i": 5);
test bool forSmall() = last(trace(sumFor, ("s": 0)))[1] == ("s": 10, "i": 5);
