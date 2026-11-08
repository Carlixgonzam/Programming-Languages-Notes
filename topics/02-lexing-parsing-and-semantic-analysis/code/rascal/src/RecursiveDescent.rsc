module RecursiveDescent

import List;
import String;

alias Result = tuple[int val, list[str] rest];

Result exp(list[str] input) {
  <v, rest> = term(input);
  return expPrime(v, rest);
}

Result expPrime(int left, list[str] input) {
  if (["+", *rest] := input) {
    <v, rest2> = term(rest);
    return expPrime(left + v, rest2);
  }
  return <left, input>;
}

Result term(list[str] input) {
  <v, rest> = factor(input);
  return termPrime(v, rest);
}

Result termPrime(int left, list[str] input) {
  if (["*", *rest] := input) {
    <v, rest2> = factor(rest);
    return termPrime(left * v, rest2);
  }
  return <left, input>;
}

Result factor(list[str] input) {
  if (["(", *rest] := input) {
    <v, rest2> = exp(rest);
    if ([")", *rest3] := rest2) return <v, rest3>;
    throw "expected )";
  }
  if ([n, *rest] := input, /^[0-9]+$/ := n) return <toInt(n), rest>;
  throw "unexpected <input == [] ? "end of input" : head(input)>";
}

int evaluate(list[str] tokens) {
  <v, rest> = exp(tokens);
  if (rest != []) throw "unexpected <head(rest)>";
  return v;
}

list[str] w(str x) = [ x[i] | i <- [0 .. size(x)] ];

test bool sum() = evaluate(w("2+3*1")) == 5;
test bool precedence() = evaluate(w("2+3*4")) == 14;
test bool parens() = evaluate(w("(2+3)*4")) == 20;
test bool error() {
  try { evaluate(w("2+*1")); return false; }
  catch str _: return true;
}
