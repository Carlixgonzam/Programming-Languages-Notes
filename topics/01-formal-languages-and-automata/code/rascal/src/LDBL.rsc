module LDBL

import ParseTree;

layout Layout = [\ \t\n\r]* !>> [\ \t\n\r];

keyword Reserved = "ADD" | "REMOVE" | "SEARCH" | "VIEW" | "ADDIMAGE" | "SUBTRACTIMAGE"
                 | "HALT" | "file" | "name" | "properties" | "if" | "then" | "else"
                 | "fi" | "loop" | "do" | "od" | "and" | "or";

lexical Name  = ([a-z] [a-z0-9]* !>> [a-z0-9]) \ Reserved;
lexical Value = [0-9]+ !>> [0-9];
lexical File  = Name "." Name;

start syntax Command = (Operation | Statement)*;

syntax Operation
  = add:      "ADD" "file" File "name" Name "properties" "[" {Pair ","}* "]"
  | remove:   "REMOVE" Name
  | search:   "SEARCH" Referent
  | view:     "VIEW" Name
  | assign:   Name ":=" Image
  | halt:     "HALT"
  ;

syntax Pair     = "[" Name "," Value "]";
syntax Referent = Condition | Referent "and" Condition | Referent "or" Condition;

syntax Image
  = Name
  | "ADDIMAGE" Image Image
  | "SUBTRACTIMAGE" Image Image
  ;

syntax Statement
  = \if:  "if" Condition "then" Command "else" Command "fi"
  | loop: "loop" Condition? "do" Command "od"
  ;

syntax Condition = Atom Comparison Atom;
syntax Atom = Name | Value;
lexical Comparison = "\>" | "\<" | "==";

bool isProgram(str x) {
  try { parse(#start[Command], x); return true; }
  catch ParseError(_): return false;
}

test bool slideExample() = isProgram("ADD file image1.img name image properties [[c1, 1], [c2,2]]");
test bool program() = isProgram(
  "ADD file cat.img name cat properties [[legs, 4]]
  'SEARCH legs == 4 and tail \> 0
  'both := ADDIMAGE cat dog
  'if n \< 3 then VIEW both else REMOVE cat fi
  'loop do HALT od");
test bool missingFi() = !isProgram("if n \< 3 then VIEW cat else VIEW dog");
test bool reservedName() = !isProgram("VIEW loop");
