module Automata

import List;
import Set;
import String;

// <<types>>
// A transition <from, symbol, to>. The empty symbol "" is a lambda transition.
alias Trans = rel[str from, str sym, str to];

// An automaton with a set of initial states. A DFA is the special case with
// one initial state, no lambda transitions and at most one target per symbol.
data Automaton = automaton(set[str] initials, set[str] finals, Trans delta);
// <<types.end>>

// <<run>>
// Lambda-closure: every state reachable from qs using only lambda transitions.
set[str] closure(Trans delta, set[str] qs) {
  solve (qs) {
    qs += { t | <q, "", t> <- delta, q in qs };
  }
  return qs;
}

// All states reachable from qs reading the symbol s.
set[str] step(Trans delta, set[str] qs, str s)
  = closure(delta, { t | <q, s, t> <- delta, q in qs });

// A word is accepted if some path from an initial state ends in a final state.
bool accepts(Automaton a, list[str] word) {
  set[str] current = closure(a.delta, a.initials);
  for (s <- word) {
    current = step(a.delta, current, s);
  }
  return current & a.finals != {};
}
// <<run.end>>

// Words over single characters: "0101" becomes ["0","1","0","1"].
list[str] w(str text) = [ text[i] | i <- [0 .. size(text)] ];

set[str] alphabet(Automaton a) = { s | <_, s, _> <- a.delta, s != "" };

// All words over sigma of length at most n.
list[list[str]] wordsUpTo(set[str] sigma, int n) {
  list[list[str]] level = [[]];
  list[list[str]] result = [[]];
  for (_ <- [0 .. n]) {
    level = [ x + [s] | x <- level, s <- sort(toList(sigma)) ];
    result += level;
  }
  return result;
}

// True if the automaton accepts exactly the words of length <= n that satisfy p.
bool agrees(Automaton a, set[str] sigma, int n, bool(str) p)
  = all(x <- wordsUpTo(sigma, n), accepts(a, x) == p(intercalate("", x)));

// ---------------------------------------------------------------------------
// Examples from the lecture
// ---------------------------------------------------------------------------

// <<shopping>>
Automaton shopping = automaton({"A"}, {"G"}, {
  <"A", "pay", "B">,
  <"B", "redeem", "D">, <"D", "transfer", "F">,
  <"B", "ship", "C">,   <"D", "ship", "E">,     <"F", "ship", "G">,
  <"C", "redeem", "E">, <"E", "transfer", "G">
});
// <<shopping.end>>

test bool shopping1() = accepts(shopping, ["pay", "ship", "redeem", "transfer"]);
test bool shopping2() = accepts(shopping, ["pay", "redeem", "transfer", "ship"]);
test bool shopping3() = !accepts(shopping, ["pay", "ship", "ship"]);
test bool shopping4() = !accepts(shopping, ["ship", "pay"]);

// <<contains01>>
Automaton contains01 = automaton({"Just1"}, {"Read01"}, {
  <"Just1", "1", "Just1">,  <"Just1", "0", "Read0">,
  <"Read0", "0", "Read0">,  <"Read0", "1", "Read01">,
  <"Read01", "0", "Read01">, <"Read01", "1", "Read01">
});
// <<contains01.end>>

test bool c01a() = accepts(contains01, w("01"));
test bool c01b() = accepts(contains01, w("1010"));
test bool c01c() = accepts(contains01, w("100011"));
test bool c01d() = !accepts(contains01, w("0"));
test bool c01e() = !accepts(contains01, w("111000"));
test bool c01all() = agrees(contains01, {"0", "1"}, 8, bool(str x) { return contains(x, "01"); });

// Exercise 1: even number of 0s and even number of 1s.
// <<eveneven>>
Automaton evenEven = automaton({"EE"}, {"EE"}, {
  <"EE", "0", "OE">, <"OE", "0", "EE">, <"EO", "0", "OO">, <"OO", "0", "EO">,
  <"EE", "1", "EO">, <"EO", "1", "EE">, <"OE", "1", "OO">, <"OO", "1", "OE">
});
// <<eveneven.end>>

int count(str x, str c) = size([ i | i <- [0 .. size(x)], x[i] == c ]);

test bool evenEvenAll() = agrees(evenEven, {"0", "1"}, 8,
  bool(str x) { return count(x, "0") % 2 == 0 && count(x, "1") % 2 == 0; });

// Exercise 2: the language of lists, LIST ::= "[" "]" | NUMBER "|" LIST.
// <<lists>>
set[str] digits = { "<i>" | i <- [0 .. 10] };

Automaton lists = automaton({"q0"}, {"q2"}, {
  <"q0", "[", "q1">, <"q1", "]", "q2">,
  *{ <"q0", d, "q3"> | d <- digits },
  *{ <"q3", d, "q3"> | d <- digits },
  <"q3", "|", "q4">,
  *{ <"q4", d, "q3"> | d <- digits },
  <"q4", "[", "q1">
});
// <<lists.end>>

test bool lists1() = accepts(lists, w("[]"));
test bool lists2() = accepts(lists, w("1|[]"));
test bool lists3() = accepts(lists, w("1|2|3|[]"));
test bool lists4() = !accepts(lists, w("[1,2,3]"));
test bool lists5() = !accepts(lists, w("1|[]|2|[]"));

// NFA from the lecture: words over {c,a,t,h}. The branch through B accepts the
// words that contain "hat"; the branch through F accepts the words that do not
// contain "cat".
// <<cathat>>
Automaton catHat = automaton({"A"}, {"E", "F", "G", "H"}, {
  <"A", "", "B">,
  <"B", "c", "B">, <"B", "a", "B">, <"B", "t", "B">, <"B", "h", "B">,
  <"B", "h", "C">, <"C", "a", "D">, <"D", "t", "E">,
  <"E", "c", "E">, <"E", "a", "E">, <"E", "t", "E">, <"E", "h", "E">,
  <"A", "", "F">,
  <"F", "a", "F">, <"F", "t", "F">, <"F", "h", "F">, <"F", "c", "G">,
  <"G", "t", "F">, <"G", "h", "F">, <"G", "c", "G">, <"G", "a", "H">,
  <"H", "a", "F">, <"H", "h", "F">, <"H", "c", "G">, <"H", "t", "I">,
  <"I", "c", "I">, <"I", "a", "I">, <"I", "t", "I">, <"I", "h", "I">
});
// <<cathat.end>>

set[str] cath = {"c", "a", "t", "h"};

test bool catHatLanguage() = agrees(catHat, cath, 6,
  bool(str x) { return !contains(x, "cat") || contains(x, "hat"); });
test bool catHatAcceptsHat() = accepts(catHat, w("cathat"));

// Last symbol is 0, or the word is exactly 1.
// <<last0>>
Automaton last0 = automaton({"A"}, {"D"}, {
  <"A", "", "B">, <"B", "1", "D">,
  <"A", "", "C">, <"C", "0", "C">, <"C", "1", "C">, <"C", "0", "D">
});
// <<last0.end>>

test bool last0All() = agrees(last0, {"0", "1"}, 8,
  bool(str x) { return endsWith(x, "0") || x == "1"; });

// Exercise 3: words over {a,b} with exactly one occurrence of bb or bab,
// counting occurrences from left to right without overlapping.
int patterns(str x) {
  int n = 0; int i = 0;
  while (i < size(x)) {
    if (startsWith(x[i..], "bb"))       { n += 1; i += 2; }
    else if (startsWith(x[i..], "bab")) { n += 1; i += 3; }
    else i += 1;
  }
  return n;
}

// <<bbbab>>
Trans bbBabSlide = {
  <"E", "a", "E">, <"E", "b", "A">,
  <"A", "b", "B">, <"A", "a", "D">,
  <"B", "", "C">,  <"D", "b", "C">,
  <"C", "a", "C">, <"C", "b", "F">,
  <"F", "b", "H">, <"F", "a", "G">,
  <"G", "b", "H">, <"G", "a", "C">
};
Automaton bbBab      = automaton({"E"}, {"C", "F", "G"}, bbBabSlide);
Automaton bbBabFixed = automaton({"E"}, {"C", "F", "G"}, bbBabSlide + {<"D", "a", "E">});
// <<bbbab.end>>

bool exactlyOne(str x) = patterns(x) == 1;
test bool bbBabMissesBaabb() = !accepts(bbBab, w("baabb")) && exactlyOne("baabb");
test bool bbBabFixedAll() = agrees(bbBabFixed, {"a", "b"}, 10, exactlyOne);

// Exercise 4: (ab | aab | aba)*.
bool inAbStar(str x) = x == "" || any(p <- ["ab", "aab", "aba"], startsWith(x, p) && inAbStar(x[size(p)..]));

// The automaton of the slide: E has a self-loop on a and b, so it accepts
// every word that ends in b or in ba, and it rejects the empty word.
Automaton abSlide = automaton({"E"}, {"C"}, {
  <"A", "", "C">, <"A", "a", "D">, <"D", "", "C">, <"C", "", "E">,
  <"E", "a", "E">, <"E", "b", "E">, <"E", "b", "A">
});
test bool abSlideAcceptsB() = accepts(abSlide, w("b")) && !inAbStar("b");
test bool abSlideRejectsEmpty() = !accepts(abSlide, []) && inAbStar("");

// <<abstar>>
Automaton abStar = automaton({"E"}, {"E"}, {
  <"E", "a", "X">, <"X", "b", "E">,       // ab
  <"X", "a", "Z">, <"Z", "b", "E">,       // aab
  <"X", "b", "Y">, <"Y", "a", "E">        // aba
});
// <<abstar.end>>
test bool abStarAll() = agrees(abStar, {"a", "b"}, 10, inAbStar);

// ---------------------------------------------------------------------------
// Removing nondeterminism: the set construction
// ---------------------------------------------------------------------------

// <<determinize>>
str name(set[str] qs) = "{" + intercalate(",", sort(toList(qs))) + "}";

Automaton determinize(Automaton a, set[str] sigma) {
  set[str] first = closure(a.delta, a.initials);
  list[set[str]] pending = [first];
  set[set[str]] seen = {first};
  Trans delta = {};
  while (pending != []) {
    set[str] current = head(pending);
    pending = tail(pending);
    for (s <- sigma) {
      set[str] next = step(a.delta, current, s);
      delta += <name(current), s, name(next)>;
      if (next notin seen) {
        seen += {next};
        pending += [next];
      }
    }
  }
  set[str] finals = { name(qs) | qs <- seen, qs & a.finals != {} };
  return automaton({name(first)}, finals, delta);
}
// <<determinize.end>>

bool isDeterministic(Automaton a)
  = size(a.initials) == 1
  && all(<_, s, _> <- a.delta, s != "")
  && all(<q, s> <- a.delta<from, sym>, size(a.delta[q][s]) == 1);

// Exercise 5: lambda-closures.
Automaton closureEx = automaton({"A"}, {"B", "E"}, {
  <"A", "", "B">, <"A", "", "C">, <"B", "a", "B">,
  <"C", "a", "D">, <"D", "b", "E">, <"E", "", "C">
});
test bool closureA() = closure(closureEx.delta, {"A"}) == {"A", "B", "C"};
test bool closureE() = closure(closureEx.delta, {"E"}) == {"E", "C"};
test bool closureD() = closure(closureEx.delta, {"D"}) == {"D"};

// Exercise 6: convert to a DFA.
// <<ex6>>
Automaton ex6 = automaton({"S"}, {"C"}, {
  <"S", "a", "S">, <"S", "a", "A">, <"S", "b", "C">, <"S", "b", "B">,
  <"A", "a", "C">, <"B", "a", "C">, <"C", "a", "C">
});
// <<ex6.end>>
Automaton ex6Dfa = determinize(ex6, {"a", "b"});

test bool ex6States() = { q | <q, _, _> <- ex6Dfa.delta }
  == {"{S}", "{A,S}", "{B,C}", "{A,C,S}", "{C}", "{}"};
test bool ex6Deterministic() = isDeterministic(ex6Dfa);
test bool ex6Same() = all(x <- wordsUpTo({"a", "b"}, 8), accepts(ex6, x) == accepts(ex6Dfa, x));
test bool catHatDfa() = all(x <- wordsUpTo(cath, 5),
  accepts(catHat, x) == accepts(determinize(catHat, cath), x));

// ---------------------------------------------------------------------------
// Combining automata
// ---------------------------------------------------------------------------

// <<lbl2a>>
// Lb: words that contain b.  L2a: words that end in aa.
Automaton lb  = automaton({"W"}, {"Z"}, {
  <"W", "a", "W">, <"W", "b", "W">, <"W", "b", "Z">, <"Z", "a", "Z">, <"Z", "b", "Z">
});
Automaton l2a = automaton({"A"}, {"C"}, {
  <"A", "a", "A">, <"A", "b", "A">, <"A", "a", "B">, <"B", "b", "A">,
  <"B", "a", "C">, <"C", "", "A">
});
// <<lbl2a.end>>

Automaton rename(Automaton a, str p)
  = automaton({ p + q | q <- a.initials }, { p + q | q <- a.finals },
              { <p + q, s, p + t> | <q, s, t> <- a.delta });

// <<combine>>
Automaton union(Automaton a1, Automaton a2) {
  a1 = rename(a1, "1"); a2 = rename(a2, "2");
  return automaton({"q"}, a1.finals + a2.finals,
    a1.delta + a2.delta + { <"q", "", i> | i <- a1.initials + a2.initials });
}

Automaton concat(Automaton a1, Automaton a2) {
  a1 = rename(a1, "1"); a2 = rename(a2, "2");
  return automaton(a1.initials, a2.finals,
    a1.delta + a2.delta + { <f, "", i> | f <- a1.finals, i <- a2.initials });
}

// A new initial state q that is also final, so the empty word is accepted
// without making the old initial states final.
Automaton star(Automaton a) {
  a = rename(a, "1");
  return automaton({"q"}, a.finals + {"q"},
    a.delta + { <"q", "", i> | i <- a.initials } + { <f, "", "q"> | f <- a.finals });
}
// <<combine.end>>

// The construction on the slide: the initial states become final.
Automaton starSlide(Automaton a)
  = automaton(a.initials, a.finals + a.initials,
              a.delta + { <f, "", i> | f <- a.finals, i <- a.initials });

// <<product>>
// Product of two DFAs. keep decides which pairs of states are final.
Automaton product(Automaton d1, Automaton d2, set[str] sigma, bool(bool, bool) keep) {
  map[tuple[str, str], str] t1 = ( <q, s> : t | <q, s, t> <- d1.delta );
  map[tuple[str, str], str] t2 = ( <q, s> : t | <q, s, t> <- d2.delta );
  str pair(str p, str q) = "(<p>,<q>)";
  tuple[str, str] first = <getOneFrom(d1.initials), getOneFrom(d2.initials)>;
  list[tuple[str, str]] pending = [first];
  set[tuple[str, str]] seen = {first};
  Trans delta = {};
  while (pending != []) {
    <p, q> = head(pending);
    pending = tail(pending);
    for (s <- sigma) {
      tuple[str, str] next = <t1[<p, s>], t2[<q, s>]>;
      delta += <pair(p, q), s, pair(next[0], next[1])>;
      if (next notin seen) { seen += {next}; pending += [next]; }
    }
  }
  set[str] finals = { pair(p, q) | <p, q> <- seen, keep(p in d1.finals, q in d2.finals) };
  return automaton({pair(first[0], first[1])}, finals, delta);
}

Automaton intersection(Automaton a1, Automaton a2, set[str] sigma)
  = product(determinize(a1, sigma), determinize(a2, sigma), sigma,
            bool(bool x, bool y) { return x && y; });

Automaton difference(Automaton a1, Automaton a2, set[str] sigma)
  = product(determinize(a1, sigma), determinize(a2, sigma), sigma,
            bool(bool x, bool y) { return x && !y; });
// <<product.end>>

set[str] ab = {"a", "b"};
bool hasB(str x)  = contains(x, "b");
bool endsAA(str x) = endsWith(x, "aa");

test bool lbAll()  = agrees(lb, ab, 8, hasB);
test bool l2aAll() = agrees(l2a, ab, 8, endsAA);
test bool unionAll() = agrees(union(lb, l2a), ab, 8,
  bool(str x) { return hasB(x) || endsAA(x); });
test bool concatAll() = agrees(concat(lb, l2a), ab, 8,
  bool(str x) { return any(i <- [0 .. size(x) + 1], hasB(x[..i]) && endsAA(x[i..])); });
test bool starAll() = agrees(star(lb), ab, 8,
  bool(str x) { return x == "" || hasB(x); });
test bool starSlideAcceptsA() = accepts(starSlide(lb), ["a"]) && !accepts(star(lb), ["a"]);
test bool intersectionAll() = agrees(intersection(lb, l2a, ab), ab, 8,
  bool(str x) { return hasB(x) && endsAA(x); });
test bool differenceAll() = agrees(difference(l2a, lb, ab), ab, 8,
  bool(str x) { return endsAA(x) && !hasB(x); });
test bool unionProduct() = agrees(
  product(determinize(lb, ab), determinize(l2a, ab), ab, bool(bool x, bool y) { return x || y; }),
  ab, 8, bool(str x) { return hasB(x) || endsAA(x); });

// Exercise: words that contain neither "cat" nor "hat".
Automaton neither = automaton({"0"}, {"0", "1", "2"}, {
  <"0", "c", "1">, <"0", "h", "1">, <"0", "a", "0">, <"0", "t", "0">,
  <"1", "c", "1">, <"1", "h", "1">, <"1", "a", "2">, <"1", "t", "0">,
  <"2", "c", "1">, <"2", "h", "1">, <"2", "a", "0">, <"2", "t", "trap">,
  *{ <"trap", s, "trap"> | s <- cath }
});
test bool neitherAll() = agrees(neither, cath, 6,
  bool(str x) { return !contains(x, "cat") && !contains(x, "hat"); });
