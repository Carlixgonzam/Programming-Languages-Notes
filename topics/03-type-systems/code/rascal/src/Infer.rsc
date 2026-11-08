module Infer

import Letrec;
import List;
import String;

alias Subst = map[int, Type];

Type substitution(intType(), int _, Type _)  = intType();
Type substitution(boolType(), int _, Type _) = boolType();
Type substitution(procType(a, r), int n, Type t1)
  = procType(substitution(a, n, t1), substitution(r, n, t1));
Type substitution(tvar(m), int n, Type t1)   = m == n ? t1 : tvar(m);

Type apply(tvar(n), Subst s)       = n in s ? apply(s[n], s) : tvar(n);
Type apply(procType(a, r), Subst s) = procType(apply(a, s), apply(r, s));
default Type apply(Type t, Subst _) = t;

bool noOccurrence(int n, tvar(m))         = n != m;
bool noOccurrence(int n, procType(a, r))  = noOccurrence(n, a) && noOccurrence(n, r);
default bool noOccurrence(int _, Type _)  = true;

Subst unifier(Type t1, Type t2, Subst s, Exp e) {
  t1 = apply(t1, s);
  t2 = apply(t2, s);
  if (t1 == t2) return s;
  if (tvar(n) := t1) {
    if (noOccurrence(n, t2)) return s + (n: t2);
    throw "No-occurrence violation: <show(t1)> occurs in <show(t2)>";
  }
  if (tvar(n) := t2) {
    if (noOccurrence(n, t1)) return s + (n: t1);
    throw "No-occurrence violation: <show(t2)> occurs in <show(t1)>";
  }
  if (procType(a1, r1) := t1, procType(a2, r2) := t2) {
    s = unifier(a1, a2, s, e);
    return unifier(r1, r2, s, e);
  }
  throw "Unification failure: <show(t1)> and <show(t2)>";
}

int counter = 0;
Type fresh() { counter += 1; return tvar(counter); }

Type otype2type(noType())   = fresh();
Type otype2type(aType(t))   = t;

alias Result = tuple[Type t, Subst s];

Result infer(const(_), TEnv _, Subst s)   = <intType(), s>;
Result infer(boolean(_), TEnv _, Subst s) = <boolType(), s>;
Result infer(var(x), TEnv env, Subst s)   = <env[x], s>;

Result infer(e:diff(l, r), TEnv env, Subst s) {
  <tl, s> = infer(l, env, s);  s = unifier(tl, intType(), s, e);
  <tr, s> = infer(r, env, s);  s = unifier(tr, intType(), s, e);
  return <intType(), s>;
}

Result infer(e:zero(arg), TEnv env, Subst s) {
  <ta, s> = infer(arg, env, s);  s = unifier(ta, intType(), s, e);
  return <boolType(), s>;
}

Result infer(e:ifExp(c, t, f), TEnv env, Subst s) {
  <tc, s> = infer(c, env, s);  s = unifier(tc, boolType(), s, e);
  <tt, s> = infer(t, env, s);
  <tf, s> = infer(f, env, s);  s = unifier(tt, tf, s, e);
  return <tt, s>;
}

Result infer(let(x, v, body), TEnv env, Subst s) {
  <tv, s> = infer(v, env, s);
  return infer(body, env + (x: tv), s);
}

Result infer(proc(x, ot, body), TEnv env, Subst s) {
  Type tx = otype2type(ot);
  <tb, s> = infer(body, env + (x: tx), s);
  return <procType(tx, tb), s>;
}

Result infer(e:call(rator, rand), TEnv env, Subst s) {
  Type tres = fresh();
  <tf, s> = infer(rator, env, s);
  <ta, s> = infer(rand, env, s);
  s = unifier(tf, procType(ta, tres), s, e);
  return <tres, s>;
}

Result infer(e:letrec(ores, f, x, ox, fBody, body), TEnv env, Subst s) {
  Type tres = otype2type(ores);
  Type tx = otype2type(ox);
  TEnv env2 = env + (f: procType(tx, tres));
  <tb, s> = infer(fBody, env2 + (x: tx), s);
  s = unifier(tb, tres, s, e);
  return infer(body, env2, s);
}

Type normalize(Type t) {
  list[int] seen = [];
  visit (t) { case tvar(n): if (n notin seen) seen += [n]; }
  return visit (t) { case tvar(n) => tvar(indexOf(seen, n)) };
}

str inferType(str src, TEnv env = ()) {
  counter = 0;
  try {
    <t, s> = infer(parseExp(src), env, ());
    return show(normalize(apply(t, s)));
  }
  catch str msg: return "error: <msg>";
}

test bool foo() = inferType("letrec foo (x) = if zero?(x) then 1 else -(x, (foo -(x,1))) in foo") == "int -\> int";
test bool fx() = inferType("proc (f) proc (x) -((f 3), (f x))") == "(int -\> int) -\> int -\> int";
test bool ifX() = startsWith(inferType("proc (x) if x then -(x,1) else 0"), "error: Unification failure");
test bool ff() = startsWith(inferType("proc (f) zero?((f f))"), "error: No-occurrence violation");

test bool identity() = inferType("proc (x) x") == "t0 -\> t0";
test bool double() = inferType("letrec double (x) = if zero?(x) then 0 else -((double -(x,1)), -2) in (double 6)") == "int";
test bool partial() = inferType("proc (x : int) proc (y) -(x, y)") == "int -\> int -\> int";

test bool subst() {
  Type t0 = procType(tvar(0), procType(tvar(1), procType(tvar(2), procType(intType(), tvar(0)))));
  return show(substitution(t0, 0, boolType())) == "bool -\> t1 -\> t2 -\> int -\> bool";
}
test bool twice() = inferType("proc (f) proc (x) (f (f x))") == "(t0 -\> t0) -\> t0 -\> t0";
test bool noLetPoly() = startsWith(inferType("let i = proc (x) x in if (i zero?(0)) then (i 1) else 2"), "error: Unification failure");
