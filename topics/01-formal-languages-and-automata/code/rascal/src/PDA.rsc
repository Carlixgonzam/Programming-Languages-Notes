module PDA

import List;
import Set;
import String;
import Automata;

alias PTrans = rel[str from, str read, str top, list[str] push, str to];

data PDA = pda(str initial, set[str] finals, PTrans delta);

alias Config = tuple[str state, list[str] stack, list[str] input];

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

PDA anbn = pda("A", {"B"}, {
  <"A", "a", "",  ["a"], "A">,
  <"A", "",  "",  [],    "B">,
  <"B", "b", "a", [],    "B">
});

bool isAnBn(str x) = size(x) % 2 == 0 && x == ("" | it + "a" | _ <- [0 .. size(x) / 2]) + ("" | it + "b" | _ <- [0 .. size(x) / 2]);

test bool anbnAll() = all(x <- wordsUpTo({"a", "b"}, 8), recognizes(anbn, x) == isAnBn(intercalate("", x)));

alias Grammar = rel[str lhs, list[str] rhs];

PDA fromGrammar(Grammar g, str s) {
  set[str] nonterminals = g.lhs;
  set[str] terminals = { x | <_, rhs> <- g, x <- rhs, x notin nonterminals };
  return pda("p", {"f"},
      { <"p", "", "", [s, "$"], "q"> }
    + { <"q", "", a, rhs, "q"> | <a, rhs> <- g }
    + { <"q", t, t, [], "q"> | t <- terminals }
    + { <"q", "", "$", [], "f"> });
}

Grammar aSb = { <"S", ["a", "S", "b"]>, <"S", ["a", "b"]> };

test bool aSbAll() = all(x <- wordsUpTo({"a", "b"}, 8),
  recognizes(fromGrammar(aSb, "S"), x) == (isAnBn(intercalate("", x)) && x != []));

PDA slideWorking = pda("A", {"C"}, {
  <"A", "",  "",  ["$"], "B">,
  <"B", "a", "a", [], "B">, <"B", "b", "b", [], "B">,
  <"B", "",  "S", ["a", "b"], "B">,
  <"B", "",  "$", ["a", "S", "b"], "B">,
  <"B", "",  "S", ["a", "S", "b"], "B">,
  <"B", "",  "$", [], "C">
});
test bool slideWorkingRejects() = !recognizes(slideWorking, w("ab")) && !recognizes(slideWorking, w("aabb"));

Grammar ie = {
  <"I", ["1"]>, <"I", ["2"]>, <"I", ["I", "1"]>, <"I", ["I", "2"]>,
  <"E", ["E", "+", "E"]>, <"E", ["E", "*", "E"]>, <"E", ["(", "E", ")"]>, <"E", ["I"]>
};
test bool ieWords() = recognizes(fromGrammar(ie, "E"), w("(12+2)*1"))
  && recognizes(fromGrammar(ie, "E"), w("21"))
  && !recognizes(fromGrammar(ie, "E"), w("1+"))
  && !recognizes(fromGrammar(ie, "E"), w("(1"));

PDA wff = pda("E", {"F"}, {
  *{ <"E", l, "", [], "F"> | l <- ["p", "q", "r", "s"] },
  <"E", "N", "", [], "E">,
  <"E", "(", "", ["P"], "E">,
  *{ <"F", op, "", [], "E"> | op <- ["A", "O", "I"] },
  <"F", ")", "P", [], "F">
});

PDA wffSlide = pda("A", {"A", "C", "D"}, {
  <"A", "(", "", ["P"], "B">, <"B", "(", "", ["P"], "B">,
  <"A", "p", "", [], "C">,    <"C", "A", "", [], "D">,
  <"A", "A", "", [], "D">,    <"B", "p", "", [], "C">,
  <"C", ")", "P", [], "A">,   <"D", "", "", [], "A">,
  <"D", ")", "P", [], "A">,   <"A", ")", "P", [], "A">
});
test bool wffSlideAcceptsOperator() = recognizes(wffSlide, ["A"]) && recognizes(wffSlide, ["p", "A"]);

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

Grammar exp = {
  <"Exp",  ["Exp", "+", "Term"]>,  <"Exp",  ["Term"]>,
  <"Term", ["Term", "*", "Fact"]>, <"Term", ["Fact"]>,
  <"Fact", ["(", "Exp", ")"]>,     <"Fact", ["1"]>
};

bool isExp(list[str] x) {
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
