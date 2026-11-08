module Letrec

import ParseTree;
import String;

layout Layout = [\ \t\n]* !>> [\ \t\n];
keyword Reserved = "let" | "in" | "if" | "then" | "else" | "proc" | "letrec"
                 | "true" | "false" | "int" | "bool";
lexical Id  = ([a-z][a-zA-Z0-9]* !>> [a-zA-Z0-9]) \ Reserved;
lexical Num = "-"? [0-9]+ !>> [0-9];

start syntax Ex
  = Num
  | "true" | "false"
  | Id
  | "-" "(" Ex "," Ex ")"
  | "zero?" "(" Ex ")"
  | "if" Ex "then" Ex "else" Ex
  | "let" Id "=" Ex "in" Ex
  | "proc" "(" Id OptTy ")" Ex
  | "(" Ex Ex ")"
  | "letrec" OptTy Id "(" Id OptTy ")" "=" Ex "in" Ex
  ;

syntax OptTy = ":" Ty | Ty | ;
syntax Ty    = "int" | "bool" | "(" Ty "-\>" Ty ")";

data Exp
  = const(int n)
  | boolean(bool b)
  | var(str x)
  | diff(Exp lhs, Exp rhs)
  | zero(Exp arg)
  | ifExp(Exp cond, Exp thenExp, Exp elseExp)
  | let(str x, Exp val, Exp body)
  | proc(str x, OType xType, Exp body)
  | call(Exp rator, Exp rand)
  | letrec(OType resType, str f, str x, OType xType, Exp fBody, Exp body)
  ;

data OType = noType() | aType(Type t);

data Type = intType() | boolType() | procType(Type arg, Type res) | tvar(int n);

Exp ast((Ex) `<Num n>`)                                = const(toInt("<n>"));
Exp ast((Ex) `true`)                                   = boolean(true);
Exp ast((Ex) `false`)                                  = boolean(false);
Exp ast((Ex) `<Id x>`)                                 = var("<x>");
Exp ast((Ex) `-(<Ex l>, <Ex r>)`)                      = diff(ast(l), ast(r));
Exp ast((Ex) `zero?(<Ex e>)`)                          = zero(ast(e));
Exp ast((Ex) `if <Ex c> then <Ex t> else <Ex e>`)      = ifExp(ast(c), ast(t), ast(e));
Exp ast((Ex) `let <Id x> = <Ex v> in <Ex b>`)          = let("<x>", ast(v), ast(b));
Exp ast((Ex) `proc (<Id x> <OptTy t>) <Ex b>`)         = proc("<x>", opt(t), ast(b));
Exp ast((Ex) `(<Ex f> <Ex a>)`)                        = call(ast(f), ast(a));
Exp ast((Ex) `letrec <OptTy r> <Id f> (<Id x> <OptTy t>) = <Ex fb> in <Ex b>`)
  = letrec(opt(r), "<f>", "<x>", opt(t), ast(fb), ast(b));

OType opt((OptTy) `: <Ty t>`) = aType(ty(t));
OType opt((OptTy) `<Ty t>`)   = aType(ty(t));
default OType opt(OptTy _)    = noType();

Type ty((Ty) `int`)                  = intType();
Type ty((Ty) `bool`)                 = boolType();
Type ty((Ty) `(<Ty a> -\> <Ty r>)`)  = procType(ty(a), ty(r));

public Exp parseExp(str src) = ast(parse(#start[Ex], src).top);

str show(intType())  = "int";
str show(boolType()) = "bool";
str show(tvar(n))    = "t<n>";
str show(procType(a, r)) = showArg(a) + " -\> " + show(r);

str showArg(t:procType(_, _)) = "(<show(t)>)";
default str showArg(Type t)   = show(t);

alias TEnv = map[str, Type];

void checkEqual(Type t1, Type t2, Exp e) {
  if (t1 != t2) throw "Types did not match in <e>: <show(t1)> != <show(t2)>";
}

Type typeOf(const(_), TEnv _)   = intType();
Type typeOf(boolean(_), TEnv _) = boolType();
Type typeOf(var(x), TEnv env)   = env[x];

Type typeOf(e:zero(arg), TEnv env) {
  checkEqual(typeOf(arg, env), intType(), e);
  return boolType();
}

Type typeOf(e:diff(l, r), TEnv env) {
  checkEqual(typeOf(l, env), intType(), e);
  checkEqual(typeOf(r, env), intType(), e);
  return intType();
}

Type typeOf(let(x, v, body), TEnv env)
  = typeOf(body, env + (x: typeOf(v, env)));

Type typeOf(e:ifExp(c, t, f), TEnv env) {
  checkEqual(typeOf(c, env), boolType(), e);
  Type tt = typeOf(t, env);
  checkEqual(typeOf(f, env), tt, e);
  return tt;
}

Type typeOf(proc(x, aType(tx), body), TEnv env)
  = procType(tx, typeOf(body, env + (x: tx)));

Type typeOf(e:call(rator, rand), TEnv env) {
  Type tf = typeOf(rator, env);
  if (procType(targ, tres) := tf) {
    checkEqual(typeOf(rand, env), targ, e);
    return tres;
  }
  throw "Rator not a procedure in <e>: <show(tf)>";
}

Type typeOf(e:letrec(aType(tres), f, x, aType(targ), fBody, body), TEnv env) {
  TEnv env2 = env + (f: procType(targ, tres));
  checkEqual(typeOf(fBody, env2 + (x: targ)), tres, e);
  return typeOf(body, env2);
}

default Type typeOf(Exp e, TEnv _) { throw "Missing type annotation in <e>"; }

str check(str src) {
  try return show(typeOf(parseExp(src), ()));
  catch str msg: return "error: <msg>";
}

test bool double() = check("letrec int double (x : int) = if zero?(x) then 0 else -((double -(x,1)), -2) in double")
  == "int -\> int";
test bool doubleSix() = check("letrec int double (x : int) = if zero?(x) then 0 else -((double -(x,1)), -2) in (double 6)")
  == "int";
test bool letDiff() = check("let x = 3 in -(x, 1)") == "int";
test bool procType1() = check("proc (f : (int -\> int)) proc (x : int) -((f 3), (f x))") == "(int -\> int) -\> int -\> int";
test bool ifMismatch() = startsWith(check("if zero?(1) then 1 else zero?(0)"), "error: Types did not match");
test bool notProc() = startsWith(check("(3 4)"), "error: Rator not a procedure");
test bool missing() = startsWith(check("proc (x) x"), "error: Missing type annotation");

test bool loops() = check("letrec int f (x : int) = (f x) in (f 0)") == "int";
