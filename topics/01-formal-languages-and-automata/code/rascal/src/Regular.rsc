module Regular

import Automata;
import ParseTree;
import String;
import List;

// ---------------------------------------------------------------------------
// Regular grammars from the lecture
// ---------------------------------------------------------------------------

// <<right>>
// Right regular grammar: A ::= a | aB | bA | b,  B ::= bB | a
lexical A = "a" | "a" B | "b" A | "b";
lexical B = "b" B | "a";
// <<right.end>>

// <<left>>
// Left regular grammar: S ::= Abbb | Sb,  L ::= La | aa
// (the slide calls the second nonterminal A; it is renamed L here
// because A is already used above)
lexical S = L "bbb" | S "b";
lexical L = L "a" | "aa";
// <<left.end>>

bool generates(type[&T <: Tree] t, str word) {
  try { parse(t, word); return true; }
  catch ParseError(_): return false;
}

// The languages of both grammars written as regular expressions.
test bool rightGrammar() = all(x <- wordsUpTo({"a", "b"}, 8),
  generates(#A, intercalate("", x)) == /^b*(a|b|ab*a)$/ := intercalate("", x));
test bool rightWord() = generates(#A, "bbbabba");

test bool leftGrammar() = all(x <- wordsUpTo({"a", "b"}, 8),
  generates(#S, intercalate("", x)) == /^aaa*bbbb*$/ := intercalate("", x));
test bool leftShortest() = generates(#S, "aabbb") && !generates(#S, "abbb");

// ---------------------------------------------------------------------------
// Exercise 1: (A..G)+(flat|sharp)?
// ---------------------------------------------------------------------------

bool note(str x) = /^[A-G]+(♭|♯)?$/ := x;

test bool notes() = note("A♭") && note("C♯") && !note("ABK♭") && !note("A♭B") && note("GFE");

// ---------------------------------------------------------------------------
// Exercise 2
// ---------------------------------------------------------------------------

bool oneOf(str x, list[str] ws) = any(y <- ws, x == y);
list[str] all01(int n) = [ intercalate("", x) | x <- wordsUpTo({"0", "1"}, n) ];
list[str] allAB(int n) = [ intercalate("", x) | x <- wordsUpTo({"a", "b"}, n) ];

test bool sub00() = all(x <- all01(8), (/^(0|1)*00(0|1)*$/ := x) == contains(x, "00"));

test bool noAA() = all(x <- allAB(8), (/^(a(b|ba)*|(b|ba)*)$/ := x) == !contains(x, "aa"));

bool oddEven(str x) = (startsWith(x, "0") && size(x) % 2 == 1) || (startsWith(x, "1") && size(x) % 2 == 0);
// The answer on the slide accepts every word that starts with 1.
test bool oddEvenSlide() = /^(0((0|1)(0|1))*)|(1(0|1)*)$/ := "1" && !oddEven("1");
test bool oddEvenFixed() = all(x <- all01(8),
  (/^(0((0|1)(0|1))*|1(0|1)((0|1)(0|1))*)$/ := x) == oddEven(x));

// ---------------------------------------------------------------------------
// Exercises 3 and 4: e-mail addresses
// ---------------------------------------------------------------------------

// <<email>>
bool uniandes(str x) = /^[a-zA-Z0-9.\-]+@uniandes\.edu\.co$/ := x;
bool email(str x)    = /^[a-zA-Z0-9.\-]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)*\.(edu|com|co|net|org)$/ := x;
// <<email.end>>

test bool email1() = uniandes("ca.gonzalez@uniandes.edu.co");
test bool email2() = !uniandes("ca.gonzalez@gmail.com") && !uniandes("@uniandes.edu.co");
test bool email3() = email("ca.gonzalez@gmail.com") && email("someone@cs.uni-x.edu");
test bool email4() = !email("no-at-sign.com") && !email("a@b");

// ---------------------------------------------------------------------------
// Exercise 5: nine languages over {0,1}, each with a regex and an automaton
// ---------------------------------------------------------------------------

bool matches(str re, str x) = rexpMatch(x, "^(" + re + ")$");

bool agreeAll(str re, Automaton a, bool(str) p)
  = all(x <- wordsUpTo({"0", "1"}, 9),
        matches(re, intercalate("", x)) == p(intercalate("", x))
        && accepts(a, x) == p(intercalate("", x)));

int zeros(str x) = size([ c | c <- chars(x), c == 48 ]);

// <<ex51>>
Automaton div3 = automaton({"0"}, {"0"}, {
  <"0", "0", "1">, <"1", "0", "2">, <"2", "0", "0">,
  <"0", "1", "0">, <"1", "1", "1">, <"2", "1", "2">
});
// <<ex51.end>>
test bool ex51() = agreeAll("(1|01*01*0)*", div3, bool(str x) { return zeros(x) % 3 == 0; });

Automaton even0 = automaton({"0"}, {"0"}, {
  <"0", "0", "1">, <"1", "0", "0">, <"0", "1", "0">, <"1", "1", "1">
});
test bool ex52() = agreeAll("(1|01*0)*", even0, bool(str x) { return zeros(x) % 2 == 0; });

// <<ex53>>
Automaton fifth = automaton({"0"}, {"5"}, {
  <"0", "0", "0">, <"0", "1", "0">, <"0", "1", "1">,
  <"1", "0", "2">, <"1", "1", "2">, <"2", "0", "3">, <"2", "1", "3">,
  <"3", "0", "4">, <"3", "1", "4">, <"4", "0", "5">, <"4", "1", "5">
});
// <<ex53.end>>
test bool ex53() = agreeAll("(0|1)*1(0|1)(0|1)(0|1)(0|1)", fifth,
  bool(str x) { return size(x) >= 5 && x[size(x) - 5] == "1"; });

Automaton zeroThenOne = automaton({"1"}, {"1"}, {
  <"1", "0", "0">, <"1", "1", "1">, <"0", "1", "1">
});
bool eachZeroFollowedByOne(str x) {
  for (i <- [0 .. size(x)]) {
    if (x[i] == "0" && (i + 1 == size(x) || x[i + 1] != "1")) return false;
  }
  return true;
}
test bool ex54() = agreeAll("(0?1)*", zeroThenOne, eachZeroFollowedByOne);

Automaton zerosOnes = automaton({"0"}, {"3"}, {
  <"0", "0", "1">, <"1", "0", "2">, <"2", "0", "3">, <"2", "0", "2">,
  <"3", "1", "4">, <"4", "1", "3">
});
test bool ex55() = agreeAll("000*0(11)*", zerosOnes,
  bool(str x) { return /^(0+)(1*)$/ := x && zeros(x) >= 3 && (size(x) - zeros(x)) % 2 == 0; });

Automaton atMost2 = automaton({"0"}, {"0", "1", "2"}, {
  <"0", "1", "0">, <"1", "1", "1">, <"2", "1", "2">, <"0", "0", "1">, <"1", "0", "2">
});
test bool ex56() = agreeAll("1*0?1*0?1*", atMost2, bool(str x) { return zeros(x) <= 2; });

// <<ex57>>
Automaton oddEvenDfa = automaton({"0"}, {"2", "3"}, {
  <"0", "1", "1">, <"0", "0", "2">,
  <"1", "0", "3">, <"1", "1", "3">, <"3", "0", "1">, <"3", "1", "1">,
  <"2", "0", "4">, <"2", "1", "4">, <"4", "0", "2">, <"4", "1", "2">
});
// <<ex57.end>>
test bool ex57() = agreeAll("(0|1(0|1))((0|1)(0|1))*", oddEvenDfa, oddEven);

// Any word except 0 and 1. The slide's regex misses the empty word.
Automaton not01 = automaton({"0"}, {"0", "3"}, {
  <"0", "0", "1">, <"0", "1", "1">, <"1", "0", "3">, <"1", "1", "3">,
  <"3", "0", "3">, <"3", "1", "3">
});
test bool ex58Slide() = !matches("(0|1)(0|1)(0|1)*", "");
test bool ex58() = agreeAll("|(0|1)(0|1)(0|1)*", not01, bool(str x) { return x != "0" && x != "1"; });

// Do not end with 01. The slide's regex misses the empty word, and its
// automaton accepts 01, because state 0 goes to the final state 2 on a 1.
Automaton not01Slide = automaton({"0"}, {"1", "2", "3"}, {
  <"0", "1", "0">, <"0", "0", "0">, <"0", "0", "1">, <"0", "1", "2">, <"2", "1", "3">
});
test bool ex59Slide() = accepts(not01Slide, w("01")) && !matches("0|1|(0|1)*(0|1(0|1))", "");
// <<ex59>>
Automaton notEnd01 = automaton({"s"}, {"s", "z"}, {
  <"s", "0", "z">, <"s", "1", "s">,
  <"z", "0", "z">, <"z", "1", "zo">,
  <"zo", "0", "z">, <"zo", "1", "s">
});
// <<ex59.end>>
test bool ex59() = agreeAll("|0|1|(0|1)*(0|1(0|1))", notEnd01, bool(str x) { return !endsWith(x, "01"); });
