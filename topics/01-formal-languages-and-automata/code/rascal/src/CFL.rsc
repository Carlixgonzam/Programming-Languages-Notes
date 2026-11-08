module CFL

import ParseTree;
import String;
import List;
import Automata;

lexical S2 = "a" B2 | "b" A2 | ;
lexical A2 = "a" S2 | "b" A2 A2;
lexical B2 = "b" S2 | "a" B2 B2;

lexical S3 = A3 B3 C3;
lexical A3 = "a" A3 "b" | B3;
lexical B3 = "b" B3 | ;
lexical C3 = "cc" C3 | B3;

layout Spaces = [\ ]* !>> [\ ];
lexical Num = [0-9]+ !>> [0-9];

syntax E
  = E "+" E
  | E "*" E
  | "(" E ")"
  | Num
  ;

syntax Exp    = Exp "+" Term | Term;
syntax Term   = Term "*" Factor | Factor;
syntax Factor = "(" Exp ")" | Num;

syntax Exp1   = Term1 ExpR;
syntax ExpR   = "+" Term1 ExpR | ;
syntax Term1  = Factor1 TermR;
syntax TermR  = "*" Factor1 TermR | ;
syntax Factor1 = "(" Exp1 ")" | Num;

keyword Reserved = "if" | "then" | "else";
lexical Id = [a-z]+ !>> [a-z] \ Reserved;

syntax Stmt = "if" Id "then" Stmt | "if" Id "then" Stmt "else" Stmt | Id;

syntax Stmt2     = OpenStmt | ClosedStmt;
syntax OpenStmt  = "if" Id "then" Stmt2
                 | "if" Id "then" ClosedStmt "else" OpenStmt;
syntax ClosedStmt = Id
                  | "if" Id "then" ClosedStmt "else" ClosedStmt;

syntax WFF    = Prop | Neg | Binary | "(" WFF ")";
syntax Neg    = "¬" WFF;
syntax Binary = WFF Op WFF;
lexical Op    = "∨" | "∧" | "⇒";
lexical Prop  = [p-s];

lexical SC = AC XC | AC BC;
lexical XC = SC BC;
lexical AC = "a";
lexical BC = "b";

bool parses(type[&T <: Tree] t, str x) {
  try { parse(t, x, allowAmbiguity = true); return true; }
  catch ParseError(_): return false;
}

bool ambiguous(type[&T <: Tree] t, str x) = /amb(_) := parse(t, x, allowAmbiguity = true);

int count(str x, str c) = size([ i | i <- [0 .. size(x)], x[i] == c ]);
list[str] words(set[str] sigma, int n) = [ intercalate("", x) | x <- wordsUpTo(sigma, n) ];

test bool g2primeWord() = parses(#S2, "abaabb");
test bool g2primeAll() = all(x <- words({"a", "b"}, 8),
  parses(#S2, x) == (count(x, "a") == count(x, "b")));

bool inG2(str x) = /^(a*)(b*)((?:cc)*)(b*)$/ := x
  && size(x) == count(x, "a") + count(x, "b") + count(x, "c")
  && firstBs(x) >= count(x[..firstBs(x) + count(x, "a")], "a");
int firstBs(str x) {
  int i = count(x, "a"); int n = 0;
  while (i < size(x) && x[i] == "b") { n += 1; i += 1; }
  return n;
}

test bool g2Word() = parses(#S3, "aabbccccbbb");
test bool g2All() = all(x <- words({"a", "b", "c"}, 7), parses(#S3, x) == inG2(x));

test bool ambiguousSum() = ambiguous(#E, "2+3*1");
test bool unambiguousNum() = !ambiguous(#E, "23");

int eval((Exp) `<Exp e> + <Term t>`)       = eval(e) + eval(t);
int eval((Exp) `<Term t>`)                 = eval(t);
int eval((Term) `<Term t> * <Factor f>`)   = eval(t) * eval(f);
int eval((Term) `<Factor f>`)              = eval(f);
int eval((Factor) `( <Exp e> )`)           = eval(e);
int eval((Factor) `<Num n>`)               = toInt("<n>");

test bool precedence() = !ambiguous(#Exp, "2+3*4") && eval(parse(#Exp, "2+3*4")) == 14;
test bool parentheses() = eval(parse(#Exp, "(2+3)*4")) == 20;
test bool leftAssoc() = (Exp) `<Exp e> + <Term _>` := parse(#Exp, "1+2+3") && "<e>" == "1+2";

test bool sameLanguage() = all(x <- words({"1", "+", "*", "(", ")"}, 6), parses(#Exp, x) == parses(#Exp1, x));

test bool danglingAmbiguous() = ambiguous(#Stmt, "if x then if y then z else w");
test bool openClosedUnique() = !ambiguous(#Stmt2, "if x then if y then z else w");
test bool elseInner() = (Stmt2) `if <Id _> then <Stmt2 s>` := parse(#Stmt2, "if x then if y then z else w")
  && "<s>" == "if y then z else w";
test bool sameStatements() = all(x <- ["if x then y", "if x then y else z", "if a then if b then c else d else e"],
  parses(#Stmt, x) && parses(#Stmt2, x));

test bool wffOk() = parses(#WFF, "¬(p ∧ q) ⇒ r") && !parses(#WFF, "p ∧") && !parses(#WFF, "(p");
test bool wffAmbiguous() = ambiguous(#WFF, "p ∧ q ∨ r");

test bool cnfAll() = all(x <- words({"a", "b"}, 8),
  parses(#SC, x) == (x != "" && /^a*b*$/ := x && count(x, "a") == count(x, "b")));
