module Scopes

import List;
import ParseTree;

// <<grammar>>
// Block ::= Decl Block | Stat Block | λ
// Decl  ::= Type id ;          Type ::= int
// Stat  ::= id = E ; | { Block }
// E     ::= id | Num
layout Spaces = [\ \t\n]* !>> [\ \t\n];
keyword Reserved = "int";
lexical Id  = ([a-z][a-z0-9]* !>> [a-z0-9]) \ Reserved;
lexical Num = [0-9]+ !>> [0-9];

start syntax Block = Item*;
syntax Item = Type Id ";" | Id "=" E ";" | "{" Block "}";
syntax Type = "int";
syntax E    = Id | Num;
// <<grammar.end>>

// <<table>>
// A symbol table is a stack of blocks; each block maps a name to the
// reference of its declaration (here, the number of the declaration).
alias Table = list[map[str, int]];

Table createTable()                          = [()];
Table enterBlock(Table t)                    = [()] + t;
Table exitBlock(Table t)                     = tail(t);
Table enterId(Table t, str id, int ref)      = [head(t) + (id: ref)] + tail(t);

// -1 plays the role of null.
int searchId(Table t, str id) {
  for (block <- t, id in block) return block[id];   // innermost block first
  return -1;
}
int searchBlockId(Table t, str id) = id in head(t) ? head(t)[id] : -1;
// <<table.end>>

list[Item] items(Block b) = [ i | (Block) `<Item* is>` := b, Item i <- is ];

// <<process>>
// Links every applied occurrence of an identifier to its defining
// occurrence. Returns the errors and, for each use, the declaration found.
tuple[list[str] errors, list[tuple[str, int]] uses] process(str program, bool slideVersion = false) {
  Table table = createTable();
  list[str] errors = [];
  list[tuple[str, int]] uses = [];
  int declarations = 0;

  void use(str x) {
    // The slide uses search_block_id here; a use must search every block.
    int ref = slideVersion ? searchBlockId(table, x) : searchId(table, x);
    if (ref == -1) errors += ["<x> is not declared"];
    else uses += [<x, ref>];
  }

  void item(Item i) {
    switch (i) {
      case (Item) `<Type _> <Id x>;`: {                   // "Type id;"
        if (searchBlockId(table, "<x>") != -1) {
          errors += ["<x> is declared twice in the same block"];
        } else {
          declarations += 1;
          table = enterId(table, "<x>", declarations);
        }
      }
      case (Item) `<Id x> = <E e>;`: {                    // "id = E;"
        use("<x>");
        if ((E) `<Id y>` := e) use("<y>");
      }
      case (Item) `{ <Block b> }`: {                      // "{ Block }"
        table = enterBlock(table);
        for (j <- items(b)) item(j);
        table = exitBlock(table);
      }
    }
  }

  for (i <- items(parse(#start[Block], program).top)) item(i);
  return <errors, uses>;
}
// <<process.end>>

// The word of the lecture: int a; { a = 4; int bar; }
test bool lecture() = process("int a; { a = 4; int bar; }") == <[], [<"a", 1>]>;

// With search_block_id for uses, as on the slide, a is reported as undeclared.
test bool slideError() = process("int a; { a = 4; int bar; }", slideVersion = true).errors == ["a is not declared"];

test bool redeclared() = process("int a; int a;").errors == ["a is declared twice in the same block"];
test bool shadowing() = process("int a; { int a; a = 1; } a = 2;").uses == [<"a", 2>, <"a", 1>];
test bool undeclared() = process("int a; a = b;").errors == ["b is not declared"];
test bool outOfScope() = process("{ int c; } c = 1;").errors == ["c is not declared"];
