module LL1

import List;
import Set;
import String;

alias Rule = tuple[str lhs, list[str] rhs];
alias Grammar = list[Rule];

public Grammar expr = [
  <"Exp",    ["Term", "Exp\'"]>,
  <"Exp\'",  ["+", "Term", "Exp\'"]>,
  <"Exp\'",  []>,
  <"Term",   ["Factor", "Term\'"]>,
  <"Term\'", ["*", "Factor", "Term\'"]>,
  <"Term\'", []>,
  <"Factor", ["(", "Exp", ")"]>,
  <"Factor", ["Num"]>
] + [ <"Num", ["<d>"]> | d <- [0 .. 10] ];

set[str] nonterminals(Grammar g) = { r.lhs | r <- g };
bool isTerminal(Grammar g, str x) = x notin nonterminals(g);

set[str] firstSeq(Grammar g, map[str, set[str]] f, list[str] alpha) {
  set[str] result = {};
  for (x <- alpha) {
    set[str] fx = isTerminal(g, x) ? {x} : f[x];
    result += fx - {"λ"};
    if ("λ" notin fx) return result;
  }
  return result + {"λ"};
}

map[str, set[str]] first(Grammar g) {
  map[str, set[str]] f = ( a : {} | a <- nonterminals(g) );
  solve (f) {
    for (<a, rhs> <- g) f[a] += firstSeq(g, f, rhs);
  }
  return f;
}

map[str, set[str]] follow(Grammar g, str s0) {
  map[str, set[str]] f = first(g);
  map[str, set[str]] fo = ( a : {} | a <- nonterminals(g) );
  fo[s0] = {"$"};
  solve (fo) {
    for (<a, rhs> <- g, i <- index(rhs), !isTerminal(g, rhs[i])) {
      set[str] fBeta = firstSeq(g, f, rhs[i + 1 ..]);
      fo[rhs[i]] += fBeta - {"λ"};
      if ("λ" in fBeta) fo[rhs[i]] += fo[a];
    }
  }
  return fo;
}

rel[str, str, Rule] table(Grammar g, str s0) {
  map[str, set[str]] f = first(g);
  map[str, set[str]] fo = follow(g, s0);
  rel[str, str, Rule] m = {};
  for (r:<a, alpha> <- g) {
    set[str] fa = firstSeq(g, f, alpha);
    for (s <- fa - {"λ"}) m += <a, s, r>;
    if ("λ" in fa) {
      for (s <- fo[a]) m += <a, s, r>;
    }
  }
  return m;
}

bool isLL1(Grammar g, str s0) {
  m = table(g, s0);
  return all(<a, s> <- m<0, 1>, size(m[a, s]) == 1);
}

alias Step = tuple[str stack, str input, str action];

list[Step] parse(Grammar g, str s0, list[str] input) {
  rel[str, str, Rule] m = table(g, s0);
  map[str, set[str]] fo = follow(g, s0);
  list[str] stack = [s0, "$"];
  input += ["$"];
  list[Step] trace = [];
  str show(list[str] xs) = intercalate("", xs);
  while (head(stack) != "$") {
    str x = head(stack);
    str a = head(input);
    str action = "";
    if (x == a) {
      action = "match <a>";
      stack = tail(stack); input = tail(input);
    } else if (isTerminal(g, x)) {
      action = "error, pop <x>";
      stack = tail(stack);
    } else if (m[x, a] == {}) {
      if ((a in fo[x] || a == "$") && tail(stack) != ["$"]) {
        action = "error, M[<x>,<a>] = synch";
        stack = tail(stack);
      } else {
        action = "error, skip <a>";
        input = tail(input);
      }
    } else {
      Rule r = getOneFrom(m[x, a]);
      action = "<r.lhs> ::= <r.rhs == [] ? "λ" : intercalate(" ", r.rhs)>";
      stack = r.rhs + tail(stack);
    }
    trace += [<show(stack), show(input), action>];
  }
  return trace;
}

list[str] errors(list[Step] trace) = [ s.action | s <- trace, startsWith(s.action, "error") ];
bool accepted(Grammar g, str s0, list[str] input) = errors(parse(g, s0, input)) == [];

list[str] w(str x) = [ x[i] | i <- [0 .. size(x)] ];
set[str] digits = { "<d>" | d <- [0 .. 10] };

test bool firstSets() {
  f = first(expr);
  return f["Num"] == digits && f["Factor"] == {"("} + digits && f["Term"] == {"("} + digits
      && f["Exp"] == {"("} + digits && f["Exp\'"] == {"+", "λ"} && f["Term\'"] == {"*", "λ"};
}

test bool followSets() {
  fo = follow(expr, "Exp");
  return fo["Exp"] == {")", "$"} && fo["Exp\'"] == {")", "$"}
      && fo["Term"] == {"+", ")", "$"} && fo["Term\'"] == {"+", ")", "$"}
      && fo["Factor"] == {"+", "*", ")", "$"};
}

test bool ll1() = isLL1(expr, "Exp");
test bool tableEntries() {
  m = table(expr, "Exp");
  return m["Exp\'", ")"] == {<"Exp\'", []>} && m["Term\'", "+"] == {<"Term\'", []>}
      && m["Factor", "("] == {<"Factor", ["(", "Exp", ")"]>};
}

test bool parses() = accepted(expr, "Exp", w("2+3*1")) && accepted(expr, "Exp", w("(4+2)*3"));
test bool rejects() = !accepted(expr, "Exp", w("2+*1"));

test bool panic() = errors(parse(expr, "Exp", w(")4*+2"))) == ["error, skip )", "error, M[Factor,+] = synch"];

test bool leftRecursive() = !isLL1([<"E", ["E", "+", "T"]>, <"E", ["T"]>, <"T", ["1"]>], "E");

Grammar equalAB = [
  <"S", ["a", "B"]>, <"S", ["b", "A"]>, <"S", []>,
  <"A", ["a", "S"]>, <"A", ["b", "A", "A"]>,
  <"B", ["b", "S"]>, <"B", ["a", "B", "B"]>
];
test bool equalABFollow() = follow(equalAB, "S") == ("S": {"a", "b", "$"}, "A": {"a", "b", "$"}, "B": {"a", "b", "$"});
test bool equalABNotLL1() = !isLL1(equalAB, "S") && size(table(equalAB, "S")["S", "a"]) == 2;
