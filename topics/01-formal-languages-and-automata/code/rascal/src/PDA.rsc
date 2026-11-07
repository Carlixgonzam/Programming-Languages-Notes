module PDA

import List;
import Set;
import String;
import Automata;

// <<types>>
// A transition <from, read, top, push, to>.
//   read == ""  : lambda, nothing is read from the input
//   top  == ""  : the stack is ignored; otherwise top is popped and
//                 the list push is put in its place (head = new top).
// The stack operations of the lecture are special cases:
//   push(e)          top == "",  push == [e]
//   pop(e)           top == e,   push == []
//   ignore           top == "",  push == []
//   changeTop(e, s)  top == e,   push == s
alias PTrans = rel[str from, str read, str top, list[str] push, str to];

data PDA = pda(str initial, set[str] finals, PTrans delta);

// A configuration: state, stack (head = top) and the input still to read.
alias Config = tuple[str state, list[str] stack, list[str] input];
// <<types.end>>

// <<run>>
// A word is recognized if from (initial, empty stack, word) the automaton can
// reach a final state with an empty stack after reading the whole word.
// The search explores configurations breadth first; maxStack bounds the
// stack so that lambda transitions that push cannot loop forever.
bool recognizes(PDA m, list[str] word, int maxStack = size(word) + 3) {
  Config first = <m.initial, [], word>;
  list[Config] pending = [first];
  set[Config] seen = {first};
  while (pending != []) {
    Config c = head(pending);
    pending = tail(pending);
    if (c.state in m.finals && c.stack == [] && c.input == []) return true;
    for (<q, r, t, p, q2> <- m.delta, q == c.state) {
      if (r != "" && (c.input == [] || head(c.input) != r)) continue;
      if (t != "" && (c.stack == [] || head(c.stack) != t)) continue;
      list[str] rest = t == "" ? c.stack : tail(c.stack);
      Config next = <q2, p + rest, r == "" ? c.input : tail(c.input)>;
      if (size(next.stack) <= maxStack && next notin seen) {
        seen += {next};
        pending += [next];
      }
    }
  }
  return false;
}
// <<run.end>>

// ---------------------------------------------------------------------------
// a^n b^n
// ---------------------------------------------------------------------------

// <<anbn>>
PDA anbn = pda("A", {"B"}, {
  <"A", "a", "",  ["a"], "A">,    // a, push(a)
  <"A", "",  "",  [],    "B">,    // lambda, ignore
  <"B", "b", "a", [],    "B">     // b, pop(a)
});
// <<anbn.end>>

bool isAnBn(str x) = size(x) % 2 == 0 && x == ("" | it + "a" | _ <- [0 .. size(x) / 2]) + ("" | it + "b" | _ <- [0 .. size(x) / 2]);

test bool anbnAll() = all(x <- wordsUpTo({"a", "b"}, 8), recognizes(anbn, x) == isAnBn(intercalate("", x)));

// ---------------------------------------------------------------------------
// The PDA of a context-free grammar
// ---------------------------------------------------------------------------

alias Grammar = rel[str lhs, list[str] rhs];

// <<fromgrammar>>
// One working state q. The stack holds the part of the sentential form that
// still has to be matched. A nonterminal on top is replaced by the right side
// of one of its rules; a terminal on top must match the next input symbol.
PDA fromGrammar(Grammar g, str s) {
  set[str] nonterminals = g.lhs;
  set[str] terminals = { x | <_, rhs> <- g, x <- rhs, x notin nonterminals };
  return pda("p", {"f"},
      { <"p", "", "", [s, "$"], "q"> }
    + { <"q", "", a, rhs, "q"> | <a, rhs> <- g }
    + { <"q", t, t, [], "q"> | t <- terminals }
    + { <"q", "", "$", [], "f"> });
}
// <<fromgrammar.end>>

Grammar aSb = { <"S", ["a", "S", "b"]>, <"S", ["a", "b"]> };

test bool aSbAll() = all(x <- wordsUpTo({"a", "b"}, 8),
  recognizes(fromGrammar(aSb, "S"), x) == (isAnBn(intercalate("", x)) && x != []));

// The "working automaton" of the slide, reading its strings with the top on
// the right: changeTop("$", "bSa") replaces $ by a,S,b (a on top). The $ is
// gone, so the final pop("$") never happens and no word is recognized.
PDA slideWorking = pda("A", {"C"}, {
  <"A", "",  "",  ["$"], "B">,
  <"B", "a", "a", [], "B">, <"B", "b", "b", [], "B">,
  <"B", "",  "S", ["a", "b"], "B">,
  <"B", "",  "$", ["a", "S", "b"], "B">,
  <"B", "",  "S", ["a", "S", "b"], "B">,
  <"B", "",  "$", [], "C">
});
test bool slideWorkingRejects() = !recognizes(slideWorking, w("ab")) && !recognizes(slideWorking, w("aabb"));

// The grammar of the slide "PDA for context-free languages":
// I ::= 1 | 2 | I1 | I2,  E ::= E + E | E * E | (E) | I
Grammar ie = {
  <"I", ["1"]>, <"I", ["2"]>, <"I", ["I", "1"]>, <"I", ["I", "2"]>,
  <"E", ["E", "+", "E"]>, <"E", ["E", "*", "E"]>, <"E", ["(", "E", ")"]>, <"E", ["I"]>
};
test bool ieWords() = recognizes(fromGrammar(ie, "E"), w("(12+2)*1"))
  && recognizes(fromGrammar(ie, "E"), w("21"))
  && !recognizes(fromGrammar(ie, "E"), w("1+"))
  && !recognizes(fromGrammar(ie, "E"), w("(1"));

// ---------------------------------------------------------------------------
// Well-formed formulas. Symbols as in the lecture's Gold code: p..s are
// letters, N is negation, A, O and I are and, or and implies.
// ---------------------------------------------------------------------------

// <<wff>>
// E: a formula is expected.  F: a complete formula was just read.
// The stack counts the open parentheses.
PDA wff = pda("E", {"F"}, {
  *{ <"E", l, "", [], "F"> | l <- ["p", "q", "r", "s"] },
  <"E", "N", "", [], "E">,
  <"E", "(", "", ["P"], "E">,
  *{ <"F", op, "", [], "E"> | op <- ["A", "O", "I"] },
  <"F", ")", "P", [], "F">
});
// <<wff.end>>

// The PDA of the slide. D is final and is reached after an operator, so it
// accepts words such as "A" and "pA" that are not formulas.
PDA wffSlide = pda("A", {"A", "C", "D"}, {
  <"A", "(", "", ["P"], "B">, <"B", "(", "", ["P"], "B">,
  <"A", "p", "", [], "C">,    <"C", "A", "", [], "D">,
  <"A", "A", "", [], "D">,    <"B", "p", "", [], "C">,
  <"C", ")", "P", [], "A">,   <"D", "", "", [], "A">,
  <"D", ")", "P", [], "A">,   <"A", ")", "P", [], "A">
});
test bool wffSlideAcceptsOperator() = recognizes(wffSlide, ["A"]) && recognizes(wffSlide, ["p", "A"]);

// Reference: a recursive recognizer for the WFF grammar.
//   WFF ::= Prop | N WFF | WFF Op WFF | ( WFF )
bool isWff(list[str] x) {
  if ([l] := x, l in ["p", "q", "r", "s"]) return true;
  if (["N", *rest] := x, isWff(rest)) return true;
  if (["(", *inner, ")"] := x, isWff(inner)) return true;
  if (size(x) < 3) return false;
  for (i <- [1 .. size(x) - 1], x[i] in ["A", "O", "I"]) {
    if (isWff(x[..i]) && isWff(x[i + 1..])) return true;
  }
  return false;
}

test bool wffAll() = all(x <- wordsUpTo({"p", "N", "A", "(", ")"}, 5), recognizes(wff, x) == isWff(x));
test bool wffNotSlide() = !recognizes(wff, ["A"]) && !recognizes(wff, ["p", "A"]);

// ---------------------------------------------------------------------------
// Exercise 5: expressions
// ---------------------------------------------------------------------------

// <<expgrammar>>
Grammar exp = {
  <"Exp",  ["Exp", "+", "Term"]>,  <"Exp",  ["Term"]>,
  <"Term", ["Term", "*", "Fact"]>, <"Term", ["Fact"]>,
  <"Fact", ["(", "Exp", ")"]>,     <"Fact", ["1"]>
};
// <<expgrammar.end>>

bool isExp(list[str] x) {
  // Exp is a sum of terms; split at the + signs that are not inside parentheses.
  return splitAt(x, "+", isTerm);
}
bool isTerm(list[str] x) = splitAt(x, "*", isFact);
bool isFact(list[str] x) = x == ["1"] || (["(", *inner, ")"] := x && isExp(inner));

bool splitAt(list[str] x, str op, bool(list[str]) part) {
  list[list[str]] parts = [[]];
  int depth = 0;
  for (s <- x) {
    if (s == "(") depth += 1;
    if (s == ")") depth -= 1;
    if (s == op && depth == 0) parts += [[]];
    else parts = parts[..-1] + [last(parts) + [s]];
  }
  return all(p <- parts, part(p));
}

test bool expAll() = all(x <- wordsUpTo({"1", "+", "*", "(", ")"}, 5),
  recognizes(fromGrammar(exp, "Exp"), x) == isExp(x));
