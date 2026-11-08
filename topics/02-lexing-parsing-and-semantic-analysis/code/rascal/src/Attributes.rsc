module Attributes

import ParseTree;
import String;

layout Spaces = [\ ]* !>> [\ ];
lexical Num = [0-9]+ !>> [0-9];

syntax Exp    = Exp "+" Term | Exp "-" Term | Term;
syntax Term   = Term "*" Factor | Term "/" Factor | Factor;
syntax Factor = "(" Exp ")" | "-" Factor | Num;

syntax ExpI = Num ExpT;
syntax ExpT = "-" Num ExpT | ;

syntax ExpTD    = TermTD Terms;
syntax Terms    = "+" TermTD Terms | "-" TermTD Terms | ;
syntax TermTD   = Fact FactTerm;
syntax FactTerm = "*" Fact FactTerm | "/" Fact FactTerm | ;
syntax Fact     = "(" ExpTD ")" | Num;

int val((Exp) `<Exp e> + <Term t>`)      = val(e) + val(t);
int val((Exp) `<Exp e> - <Term t>`)      = val(e) - val(t);
int val((Exp) `<Term t>`)                = val(t);
int val((Term) `<Term t> * <Factor f>`)  = val(t) * val(f);
int val((Term) `<Term t> / <Factor f>`)  = val(t) / val(f);
int val((Term) `<Factor f>`)             = val(f);
int val((Factor) `( <Exp e> )`)          = val(e);
int val((Factor) `- <Factor f>`)         = -val(f);
int val((Factor) `<Num n>`)              = toInt("<n>");

test bool synthesized() = val(parse(#Exp, "7+3*4")) == 19;
test bool leftAssoc() = val(parse(#Exp, "9-4-3")) == 2;

int val((ExpI) `<Num n> <ExpT t>`) = syn(t, toInt("<n>"));

int syn((ExpT) `- <Num n> <ExpT t>`, int inh) = syn(t, inh - toInt("<n>"));
default int syn(ExpT _, int inh) = inh;

test bool inherited() = val(parse(#ExpI, "9-4-3")) == 2;

data AST = leaf(int n) | binOp(str op, AST lhs, AST rhs) | unOp(str op, AST arg);

AST makeLeaf(int n) = leaf(n);
AST makeBinOp(str op, AST l, AST r) = binOp(op, l, r);
AST makeUnOp(str op, AST a) = unOp(op, a);

AST ptr((Exp) `<Exp e> + <Term t>`)      = makeBinOp("+", ptr(e), ptr(t));
AST ptr((Exp) `<Exp e> - <Term t>`)      = makeBinOp("-", ptr(e), ptr(t));
AST ptr((Exp) `<Term t>`)                = ptr(t);
AST ptr((Term) `<Term t> * <Factor f>`)  = makeBinOp("*", ptr(t), ptr(f));
AST ptr((Term) `<Term t> / <Factor f>`)  = makeBinOp("/", ptr(t), ptr(f));
AST ptr((Term) `<Factor f>`)             = ptr(f);
AST ptr((Factor) `( <Exp e> )`)          = ptr(e);
AST ptr((Factor) `- <Factor f>`)         = makeUnOp("-", ptr(f));
AST ptr((Factor) `<Num n>`)              = makeLeaf(toInt("<n>"));

AST ptr((ExpTD) `<TermTD t> <Terms ts>`) = ptrTerms(ts, ptr(t));

AST ptrTerms((Terms) `+ <TermTD t> <Terms ts>`, AST st) = ptrTerms(ts, makeBinOp("+", st, ptr(t)));
AST ptrTerms((Terms) `- <TermTD t> <Terms ts>`, AST st) = ptrTerms(ts, makeBinOp("-", st, ptr(t)));
default AST ptrTerms(Terms _, AST st) = st;

AST ptr((TermTD) `<Fact f> <FactTerm ft>`) = ptrFT(ft, ptr(f));

AST ptrFT((FactTerm) `* <Fact f> <FactTerm ft>`, AST st) = ptrFT(ft, makeBinOp("*", st, ptr(f)));
AST ptrFT((FactTerm) `/ <Fact f> <FactTerm ft>`, AST st) = ptrFT(ft, makeBinOp("/", st, ptr(f)));
default AST ptrFT(FactTerm _, AST st) = st;

AST ptr((Fact) `( <ExpTD e> )`) = ptr(e);
AST ptr((Fact) `<Num n>`)       = makeLeaf(toInt("<n>"));

AST expected = binOp("*", binOp("+", leaf(1), leaf(2)), leaf(4));

test bool bottomUp() = ptr(parse(#Exp, "(1+2)*4")) == expected;
test bool topDown() = ptr(parse(#ExpTD, "(1+2)*4")) == expected;
test bool topDownLeftAssoc() = ptr(parse(#ExpTD, "9-4-3")) == binOp("-", binOp("-", leaf(9), leaf(4)), leaf(3));
test bool sameTree() = ptr(parse(#Exp, "1-2*3+4/2")) == ptr(parse(#ExpTD, "1-2*3+4/2"));
