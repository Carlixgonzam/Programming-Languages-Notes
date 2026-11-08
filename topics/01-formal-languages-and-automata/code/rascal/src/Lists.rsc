module Lists

import ParseTree;
import Node;

lexical NUMBER = [0-9]+ !>> [0-9];
layout Spaces = [\ ]* !>> [\ ];

start syntax LIST
  = empty: "[" "]"
  | cons: NUMBER "|" LIST
  ;

data List
  = empty()
  | cons(int head, List tail)
  ;

List toAst(str text) = unsetRec(implode(#List, parse(#start[LIST], text).top));

bool isList(str text) {
  try { parse(#start[LIST], text); return true; }
  catch ParseError(_): return false;
}

test bool ex1() = isList("3 | 14 | []");
test bool ex2() = isList("[]");
test bool ex3() = !isList("[-7, 3, 14]");
test bool ex4() = !isList("[1 | \"hello\" | 3.14 | True]");
test bool ex5() = !isList("1 | [] | 7 | 9 | 3 | []");
test bool ex6() = !isList("1 | [] | [7 | 9 | 3 ]");

test bool ast() = toAst("3 | 14 | []") == cons(3, cons(14, empty()));
