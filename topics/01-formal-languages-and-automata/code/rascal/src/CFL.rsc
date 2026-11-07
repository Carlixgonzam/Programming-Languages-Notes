module CFL

import ParseTree;
import String;
import List;
import Automata;

// ---------------------------------------------------------------------------
// Two grammars from the lecture
// ---------------------------------------------------------------------------

// <<g2prime>>
// S ::= aB | bA | lambda,  A ::= aS | bAA,  B ::= bS | aBB
lexical S2 = "a" B2 | "b" A2 | ;
lexical A2 = "a" S2 | "b" A2 A2;
lexical B2 = "b" S2 | "a" B2 B2;
// <<g2prime.end>>

// <<g2>>
// S ::= ABC,  A ::= aAb | B,  B ::= bB | lambda,  C ::= ccC | B
lexical S3 = A3 B3 C3;
lexical A3 = "a" A3 "b" | B3;
lexical B3 = "b" B3 | ;
lexical C3 = "cc" C3 | B3;
// <<g2.end>>

// ---------------------------------------------------------------------------
// Expressions: ambiguity, precedence, left recursion
// ---------------------------------------------------------------------------

layout Spaces = [\ ]* !>> [\ ];
lexical Num = [0-9]+ !>> [0-9];

// <<ambiguous>>
syntax E
  = E "+" E
  | E "*" E
  | "(" E ")"
  | Num
  ;
// <<ambiguous.end>>

// <<precedence>>
syntax Exp    = Exp "+" Term | Term;
syntax Term   = Term "*" Factor | Factor;
syntax Factor = "(" Exp ")" | Num;
// <<precedence.end>>

// <<noleftrec>>
syntax Exp1   = Term1 ExpR;
syntax ExpR   = "+" Term1 ExpR | ;
syntax Term1  = Factor1 TermR;
syntax TermR  = "*" Factor1 TermR | ;
syntax Factor1 = "(" Exp1 ")" | Num;
// <<noleftrec.end>>

// ---------------------------------------------------------------------------
// Dangling else
// ---------------------------------------------------------------------------

keyword Reserved = "if" | "then" | "else";
lexical Id = [a-z]+ !>> [a-z] \ Reserved;

// <<dangling>>
syntax Stmt = "if" Id "then" Stmt | "if" Id "then" Stmt "else" Stmt | Id;
// <<dangling.end>>

// <<openclosed>>
syntax Stmt2     = OpenStmt | ClosedStmt;
syntax OpenStmt  = "if" Id "then" Stmt2
                 | "if" Id "then" ClosedStmt "else" OpenStmt;
syntax ClosedStmt = Id
                  | "if" Id "then" ClosedStmt "else" ClosedStmt;
// <<openclosed.end>>

// ---------------------------------------------------------------------------
// Well-formed formulas
// ---------------------------------------------------------------------------

// <<wff>>
syntax WFF    = Prop | Neg | Binary | "(" WFF ")";
syntax Neg    = "¬" WFF;
syntax Binary = WFF Op WFF;
lexical Op    = "∨" | "∧" | "⇒";
lexical Prop  = [p-s];
// <<wff.end>>

// ---------------------------------------------------------------------------
// Chomsky normal form of S ::= aSb | ab
// ---------------------------------------------------------------------------

// <<cnf>>
lexical SC = AC XC | AC BC;
lexical XC = SC BC;
lexical AC = "a";
lexical BC = "b";
// <<cnf.end>>

// ---------------------------------------------------------------------------
// Functions and tests
// ---------------------------------------------------------------------------

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

// a^n b^m (cc)^k b^l with m >= n
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

// <<eval>>
int eval((Exp) `<Exp e> + <Term t>`)       = eval(e) + eval(t);
int eval((Exp) `<Term t>`)                 = eval(t);
int eval((Term) `<Term t> * <Factor f>`)   = eval(t) * eval(f);
int eval((Term) `<Factor f>`)              = eval(f);
int eval((Factor) `( <Exp e> )`)           = eval(e);
int eval((Factor) `<Num n>`)               = toInt("<n>");
// <<eval.end>>

test bool precedence() = !ambiguous(#Exp, "2+3*4") && eval(parse(#Exp, "2+3*4")) == 14;
test bool parentheses() = eval(parse(#Exp, "(2+3)*4")) == 20;
// Left associativity: in 1+2+3 the left operand of the top + is 1+2.
test bool leftAssoc() = (Exp) `<Exp e> + <Term _>` := parse(#Exp, "1+2+3") && "<e>" == "1+2";

test bool sameLanguage() = all(x <- words({"1", "+", "*", "(", ")"}, 6), parses(#Exp, x) == parses(#Exp1, x));

test bool danglingAmbiguous() = ambiguous(#Stmt, "if x then if y then z else w");
test bool openClosedUnique() = !ambiguous(#Stmt2, "if x then if y then z else w");
// The else belongs to the inner if.
test bool elseInner() = (Stmt2) `if <Id _> then <Stmt2 s>` := parse(#Stmt2, "if x then if y then z else w")
  && "<s>" == "if y then z else w";
test bool sameStatements() = all(x <- ["if x then y", "if x then y else z", "if a then if b then c else d else e"],
  parses(#Stmt, x) && parses(#Stmt2, x));

test bool wffOk() = parses(#WFF, "¬(p ∧ q) ⇒ r") && !parses(#WFF, "p ∧") && !parses(#WFF, "(p");
test bool wffAmbiguous() = ambiguous(#WFF, "p ∧ q ∨ r");

test bool cnfAll() = all(x <- words({"a", "b"}, 8),
  parses(#SC, x) == (x != "" && /^a*b*$/ := x && count(x, "a") == count(x, "b")));
