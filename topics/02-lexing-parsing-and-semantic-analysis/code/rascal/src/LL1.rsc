module LL1

import List;
import Set;
import String;

// <<grammar>>
// A rule A ::= X1 ... Xn. The empty right side is the rule A ::= λ.
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
// <<grammar.end>>

set[str] nonterminals(Grammar g) = { r.lhs | r <- g };
bool isTerminal(Grammar g, str x) = x notin nonterminals(g);

// <<first>>
// first(α) for a sequence α, given the first sets of the nonterminals.
set[str] firstSeq(Grammar g, map[str, set[str]] f, list[str] alpha) {
  set[str] result = {};
  for (x <- alpha) {
    set[str] fx = isTerminal(g, x) ? {x} : f[x];
    result += fx - {"λ"};
    if ("λ" notin fx) return result;
  }
  return result + {"λ"};          // every symbol can derive λ (or α is empty)
}

// first of every nonterminal: apply the rules until nothing changes.
map[str, set[str]] first(Grammar g) {
  map[str, set[str]] f = ( a : {} | a <- nonterminals(g) );
  solve (f) {
    for (<a, rhs> <- g) f[a] += firstSeq(g, f, rhs);
  }
  return f;
}
// <<first.end>>

// <<follow>>
map[str, set[str]] follow(Grammar g, str s0) {
  map[str, set[str]] f = first(g);
  map[str, set[str]] fo = ( a : {} | a <- nonterminals(g) );
  fo[s0] = {"$"};
  solve (fo) {
    for (<a, rhs> <- g, i <- index(rhs), !isTerminal(g, rhs[i])) {
      set[str] fBeta = firstSeq(g, f, rhs[i + 1 ..]);
      fo[rhs[i]] += fBeta - {"λ"};                  // A ::= αBβ
      if ("λ" in fBeta) fo[rhs[i]] += fo[a];        // A ::= αB, or β ⇒* λ
    }
  }
  return fo;
}
// <<follow.end>>

// <<table>>
// M[A, σ]: the rules to use when A is on top of the stack and σ is next.
rel[str, str, Rule] table(Grammar g, str s0) {
  map[str, set[str]] f = first(g);
  map[str, set[str]] fo = follow(g, s0);
  rel[str, str, Rule] m = {};
  for (r:<a, alpha> <- g) {
    set[str] fa = firstSeq(g, f, alpha);
    for (s <- fa - {"λ"}) m += <a, s, r>;
    if ("λ" in fa) {
      for (s <- fo[a]) m += <a, s, r>;      // includes $ when $ is in follow(A)
    }
  }
  return m;
}

bool isLL1(Grammar g, str s0) {
  m = table(g, s0);
  return all(<a, s> <- m<0, 1>, size(m[a, s]) == 1);
}
// <<table.end>>

// <<parse>>
// Nonrecursive predictive parser with panic-mode recovery. The stack is a
// list whose head is the top. Each step records stack, input and action.
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
      // synch: a is in follow(x). Popping the last nonterminal would end
      // the parse, so in that case the symbol is skipped instead.
      if ((a in fo[x] || a == "$") && tail(stack) != ["$"]) {
        action = "error, M[<x>,<a>] = synch";   // pop the nonterminal
        stack = tail(stack);
      } else {
        action = "error, skip <a>";             // skip the input symbol
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
// <<parse.end>>

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

// The trace of the lecture for )4*+2: two errors, and the parser reaches the end.
test bool panic() = errors(parse(expr, "Exp", w(")4*+2"))) == ["error, skip )", "error, M[Factor,+] = synch"];

// A left-recursive grammar is not LL(1).
test bool leftRecursive() = !isLL1([<"E", ["E", "+", "T"]>, <"E", ["T"]>, <"T", ["1"]>], "E");

// Exercise: the grammar of equal numbers of a's and b's is not LL(1).
Grammar equalAB = [
  <"S", ["a", "B"]>, <"S", ["b", "A"]>, <"S", []>,
  <"A", ["a", "S"]>, <"A", ["b", "A", "A"]>,
  <"B", ["b", "S"]>, <"B", ["a", "B", "B"]>
];
test bool equalABFollow() = follow(equalAB, "S") == ("S": {"a", "b", "$"}, "A": {"a", "b", "$"}, "B": {"a", "b", "$"});
test bool equalABNotLL1() = !isLL1(equalAB, "S") && size(table(equalAB, "S")["S", "a"]) == 2;
