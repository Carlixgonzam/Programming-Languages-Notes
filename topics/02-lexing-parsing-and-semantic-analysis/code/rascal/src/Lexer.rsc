module Lexer

import List;
import Map;
import String;

data Token = token(str name, str lexeme, int line, int col);

tuple[str, int] relop(str s) {
  str next = size(s) > 1 ? s[1] : "";
  switch (s[0]) {
    case "\<": {
      if (next == "=") return <"LE", 2>;
      if (next == "\>") return <"NE", 2>;
      return <"LT", 1>;
    }
    case "=": return <"EQ", 1>;
    case "\>": {
      if (next == "=") return <"GE", 2>;
      return <"GT", 1>;
    }
  }
  return <"FAIL", 0>;
}

set[str] reserved = {"if", "then", "else"};

list[Token] scan(str src) {
  list[Token] tokens = [];
  int line = 1;
  int col = 1;
  while (src != "") {
    str lexeme = "";
    str name = "";
    if (/^<ws:[ \t]+>/ := src) {
      lexeme = ws;
    } else if (/^\n/ := src) {
      src = src[1..]; line += 1; col = 1; continue;
    } else if (/^<c:\/\/[^\n]*>/ := src) {
      lexeme = c;
    } else if (/^<w:[a-zA-Z][a-zA-Z0-9]*>/ := src) {
      lexeme = w;
      name = w in reserved ? toUpperCase(w) : "ID";
    } else if (/^<n:[0-9]+(\.[0-9]+)?>/ := src) {
      lexeme = n; name = "NUM";
    } else if (/^[\<\>=]/ := src) {
      <name, len> = relop(src);
      lexeme = src[..len];
      name = "OP_" + name;
    } else if (/^<p:\*\*|[*+\-\/;,(){}]>/ := src) {
      lexeme = p; name = "PUNCT";
    } else {
      lexeme = src[0]; name = "ERROR";
    }
    if (name != "") tokens += [token(name, lexeme, line, col)];
    src = src[size(lexeme)..];
    col += size(lexeme);
  }
  return tokens;
}

list[str] names(list[Token] ts) = [ t.name | t <- ts ];

test bool iffy() = names(scan("if iffyNum \<\> elsewhereNum then\n  iffyNum\nelse\n  elsewhereNum"))
  == ["IF", "ID", "OP_NE", "ID", "THEN", "ID", "ELSE", "ID"];

test bool relops() = [ relop(x)[0] | x <- ["\<=", "\<\>", "\<a", "=", "\>=", "\>1"] ]
  == ["LE", "NE", "LT", "EQ", "GE", "GT"];

test bool area() = [ <t.lexeme, t.line, t.col> | t <- scan("Area = pi * r ** 2"), t.name == "ID" ]
  == [<"Area", 1, 1>, <"pi", 1, 8>, <"r", 1, 13>];
test bool doubleStar() = [ t.lexeme | t <- scan("r ** 2"), t.name == "PUNCT" ] == ["**"];

test bool comments() = names(scan("x = 1 // comment\ny")) == ["ID", "OP_EQ", "NUM", "ID"];
test bool lines() = [ <t.line, t.col> | t <- scan("a\n  b") ] == [<1, 1>, <2, 3>];
test bool error() = "ERROR" in names(scan("a = b$"));

list[tuple[str, int, int]] wffOps(str src) {
  list[tuple[str, int, int]] ops = [];
  for (i <- [0 .. size(src)], src[i] in {"∨", "∧", "⇒"}) {
    ops += [<src[i], 1, i + 1>];
  }
  return ops;
}

test bool wffPositions() = wffOps("(p∨q)⇒(p∧q)⇒(¬q∧¬p)")
  == [<"∨", 1, 3>, <"⇒", 1, 6>, <"∧", 1, 9>, <"⇒", 1, 12>, <"∧", 1, 16>];

tuple[list[str], map[str, int]] screen(list[Token] tokens) {
  map[str, int] table = ();
  list[str] out = [];
  for (t <- tokens) {
    if (t.name == "ID") {
      if (t.lexeme notin table) table[t.lexeme] = size(table) + 1;
      out += ["Id(<table[t.lexeme]>)"];
    } else if (t.name == "NUM") {
      out += ["Intconst(<t.lexeme>)"];
    } else {
      out += [t.lexeme];
    }
  }
  return <out, table>;
}

test bool screening() {
  <out, table> = screen(scan("a = 42;\nb = a * a - 7;"));
  return out == ["Id(1)", "=", "Intconst(42)", ";", "Id(2)", "=", "Id(1)", "*", "Id(1)", "-", "Intconst(7)", ";"]
      && table == ("a": 1, "b": 2);
}

list[str] fortran(str stmt) {
  str s = replaceAll(stmt, " ", "");
  if (/^DO<label:[0-9]+><var:[A-Z][A-Z0-9]*>=<from:[0-9]+>,<to:[0-9]+>$/ := s) {
    return ["Do", "Int", "Identifier", "Equal", "Int", "Comma", "Int"];
  }
  if (/^<id:[A-Z][A-Z0-9]*>=[0-9]+\.[0-9]+$/ := s) {
    return ["Identifier", "Equal", "Float"];
  }
  return ["Error"];
}

test bool fortranAssign() = fortran("DO 5 I = 1.25") == ["Identifier", "Equal", "Float"];
test bool fortranLoop() = fortran("DO 5 I = 1,25") == ["Do", "Int", "Identifier", "Equal", "Int", "Comma", "Int"];
