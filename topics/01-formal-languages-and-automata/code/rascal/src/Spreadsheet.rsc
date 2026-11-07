module Spreadsheet

import ParseTree;

// <<grammar>>
layout Spaces = [\ ]* !>> [\ ];

lexical Digit  = [0-9];
lexical Letter = [A-Z];
lexical Value  = Digit+ !>> [0-9];
lexical Ref    = "$"? Letter Letter? "$"? Digit Digit? !>> [0-9];

lexical Function = "MOD" | "SUM" | "AVERAGE";

syntax Operation = "+" | "-" | "*" | "/";

start syntax SS = Value | Formula;

syntax Formula = "=" Internal;

syntax Internal
  = Value
  | Ref
  | SimpleFormula
  | CompoundFormula
  | EnumeratedFormula
  ;

syntax SimpleFormula     = Internal Operation Internal;
syntax CompoundFormula   = EnumeratedFormula | Function "(" Ref ":" Ref ")";
syntax EnumeratedFormula = Function "(" Arg ("," Arg)* ")";
syntax Arg = Ref | Value;
// <<grammar.end>>

// The grammar is ambiguous (see the exercises), so recognition allows ambiguity.
bool inLanguage(str text) {
  try { parse(#start[SS], text, allowAmbiguity = true); return true; }
  catch ParseError(_): return false;
}

// Strings from the "Language symbols" slide.
test bool sum()      = inLanguage("=SUM(A1:A5)");
test bool plus()     = inLanguage("=B7 + 3");
test bool average()  = !inLanguage("=AVERAGE(AB$13, 9, 3.14, Z1480)");
test bool nine()     = inLanguage("9");
test bool modLower() = !inLanguage("=mod(M9,L8)");
test bool semicolon()= !inLanguage("=SUM(A1;A5) + 3");

// Strings from the "Generating language words" slide: none is in the language.
test bool gen1() = !inLanguage("=MOD(M9,L)");
test bool gen2() = !inLanguage("A5");
test bool gen3() = !inLanguage("=A3 ++ 7");
test bool gen4() = !inLanguage("=AVERAGE(A1:A5)SUM(A1:A5)");
test bool gen5() = !inLanguage("=SUM(A1,A2,)");
test bool gen6() = !inLanguage("=3A + B5");

// Two different trees for the same formula.
test bool ambiguous() = /amb(_) := parse(#start[SS], "=1 + 2 * 3", allowAmbiguity = true);
