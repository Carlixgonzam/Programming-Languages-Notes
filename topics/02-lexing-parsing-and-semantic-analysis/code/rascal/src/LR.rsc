module LR

import List;
import Set;
import String;
import LL1;

public Grammar exprLR = [
  <"Exp\'",  ["Exp"]>,
  <"Exp",    ["Exp", "+", "Term"]>,
  <"Exp",    ["Term"]>,
  <"Term",   ["Term", "*", "Factor"]>,
  <"Term",   ["Factor"]>,
  <"Factor", ["(", "Exp", ")"]>,
  <"Factor", ["num"]>
];

alias Item = tuple[Rule rule, int dot];
alias State = set[Item];

str afterDot(Item i) = i.dot < size(i.rule.rhs) ? i.rule.rhs[i.dot] : "";

State closure(Grammar g, State items) {
  solve (items) {
    for (i <- items, b := afterDot(i), b in nonterminals(g), r:<b, _> <- g) {
      items += {<r, 0>};
    }
  }
  return items;
}

State goTo(Grammar g, State items, str x)
  = closure(g, { <i.rule, i.dot + 1> | i <- items, afterDot(i) == x });

list[State] collection(Grammar g) {
  list[State] states = [closure(g, {<g[0], 0>})];
  set[str] symbols = { x | r <- g, x <- r.rhs };
  solve (states) {
    for (s <- states, x <- symbols) {
      State next = goTo(g, s, x);
      if (next != {} && next notin states) states += [next];
    }
  }
  return states;
}

str showItem(Item i) = "<i.rule.lhs> ::= <intercalate(" ", i.rule.rhs[..i.dot] + ["."] + i.rule.rhs[i.dot..])>";

rel[int, str, str] actions(Grammar g) {
  list[State] states = collection(g);
  map[str, set[str]] fo = follow(g, g[0].lhs);
  rel[int, str, str] act = {};
  for (k <- index(states), i <- states[k]) {
    str x = afterDot(i);
    if (x != "" && isTerminal(g, x)) {
      act += <k, x, "shift <indexOf(states, goTo(g, states[k], x))>">;
    } else if (x == "" && i.rule == g[0]) {
      act += <k, "$", "accept">;
    } else if (x == "") {
      for (a <- fo[i.rule.lhs]) act += <k, a, "reduce <indexOf(g, i.rule)>">;
    }
  }
  return act;
}

bool hasConflict(Grammar g) = any(<k, a> <- actions(g)<0, 1>, size(actions(g)[k, a]) > 1);

list[str] shiftReduce(Grammar g, list[str] input) {
  list[State] states = collection(g);
  rel[int, str, str] act = actions(g);
  list[int] stack = [0];
  list[str] symbols = [];
  input += ["$"];
  list[str] trace = [];
  while (true) {
    set[str] options = act[head(stack), head(input)];
    if (size(options) != 1) return trace + ["error"];
    str a = getOneFrom(options);
    if (a == "accept") return trace + ["accept"];
    if (/shift <n:[0-9]+>/ := a) {
      trace += ["shift <head(input)>"];
      symbols = [head(input)] + symbols;
      stack = [toInt(n)] + stack;
      input = tail(input);
    } else if (/reduce <n:[0-9]+>/ := a) {
      Rule r = g[toInt(n)];
      trace += ["reduce <r.lhs> ::= <intercalate(" ", r.rhs)>"];
      int k = size(r.rhs);
      stack = stack[k..];
      symbols = [r.lhs] + symbols[k..];
      State next = goTo(g, states[head(stack)], r.lhs);
      stack = [indexOf(states, next)] + stack;
    }
  }
}

test bool twelveStates() = size(collection(exprLR)) == 12;
test bool noConflicts() = !hasConflict(exprLR);

test bool firstState() = { showItem(i) | i <- collection(exprLR)[0] } == {
  "Exp\' ::= . Exp", "Exp ::= . Exp + Term", "Exp ::= . Term",
  "Term ::= . Term * Factor", "Term ::= . Factor",
  "Factor ::= . ( Exp )", "Factor ::= . num" };

test bool trace32() = shiftReduce(exprLR, ["num", "*", "num"]) == [
  "shift num", "reduce Factor ::= num", "reduce Term ::= Factor",
  "shift *", "shift num", "reduce Factor ::= num", "reduce Term ::= Term * Factor",
  "reduce Exp ::= Term", "accept" ];

test bool rejects() = last(shiftReduce(exprLR, ["num", "+", "*"])) == "error";

public Grammar ifElse = [
  <"S\'",   ["Stmt"]>,
  <"Stmt",  ["if", "Cond", "then", "Stmt"]>,
  <"Stmt",  ["if", "Cond", "then", "Stmt", "else", "Stmt"]>,
  <"Stmt",  ["num"]>,
  <"Cond",  ["Var", "Op", "num"]>,
  <"Var",   ["x"]>, <"Var", ["y"]>,
  <"Op",    ["\>"]>, <"Op", ["="]>
];

test bool ifElseConflict() = hasConflict(ifElse);
