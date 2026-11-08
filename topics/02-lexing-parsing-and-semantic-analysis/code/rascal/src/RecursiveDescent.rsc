module RecursiveDescent

import List;
import String;

// <<rd>>
// One function per nonterminal of the grammar without left recursion:
//   Exp ::= Term Exp'    Exp' ::= + Term Exp' | λ
//   Term ::= Factor Term'   Term' ::= * Factor Term' | λ
//   Factor ::= ( Exp ) | Num
// Each function receives the remaining input and returns it after reading
// its part. The value computed along the way is returned with it.
alias Result = tuple[int val, list[str] rest];

Result exp(list[str] input) {
  <v, rest> = term(input);
  return expPrime(v, rest);
}

Result expPrime(int left, list[str] input) {
  if (["+", *rest] := input) {             // Exp' ::= + Term Exp'
    <v, rest2> = term(rest);
    return expPrime(left + v, rest2);
  }
  return <left, input>;                    // Exp' ::= λ
}

Result term(list[str] input) {
  <v, rest> = factor(input);
  return termPrime(v, rest);
}

Result termPrime(int left, list[str] input) {
  if (["*", *rest] := input) {             // Term' ::= * Factor Term'
    <v, rest2> = factor(rest);
    return termPrime(left * v, rest2);
  }
  return <left, input>;                    // Term' ::= λ
}

Result factor(list[str] input) {
  if (["(", *rest] := input) {             // Factor ::= ( Exp )
    <v, rest2> = exp(rest);
    if ([")", *rest3] := rest2) return <v, rest3>;
    throw "expected )";
  }
  if ([n, *rest] := input, /^[0-9]+$/ := n) return <toInt(n), rest>;   // Factor ::= Num
  throw "unexpected <input == [] ? "end of input" : head(input)>";
}

int evaluate(list[str] tokens) {
  <v, rest> = exp(tokens);
  if (rest != []) throw "unexpected <head(rest)>";
  return v;
}
// <<rd.end>>

list[str] w(str x) = [ x[i] | i <- [0 .. size(x)] ];

test bool sum() = evaluate(w("2+3*1")) == 5;
test bool precedence() = evaluate(w("2+3*4")) == 14;
test bool parens() = evaluate(w("(2+3)*4")) == 20;
test bool error() {
  try { evaluate(w("2+*1")); return false; }
  catch str _: return true;
}
