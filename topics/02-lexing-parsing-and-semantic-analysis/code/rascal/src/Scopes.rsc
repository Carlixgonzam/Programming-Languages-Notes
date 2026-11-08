module Scopes

import List;
import ParseTree;

layout Spaces = [\ \t\n]* !>> [\ \t\n];
keyword Reserved = "int";
lexical Id  = ([a-z][a-z0-9]* !>> [a-z0-9]) \ Reserved;
lexical Num = [0-9]+ !>> [0-9];

start syntax Block = Item*;
syntax Item = Type Id ";" | Id "=" E ";" | "{" Block "}";
syntax Type = "int";
syntax E    = Id | Num;

alias Table = list[map[str, int]];

Table createTable()                          = [()];
Table enterBlock(Table t)                    = [()] + t;
Table exitBlock(Table t)                     = tail(t);
Table enterId(Table t, str id, int ref)      = [head(t) + (id: ref)] + tail(t);

int searchId(Table t, str id) {
  for (block <- t, id in block) return block[id];
  return -1;
}
int searchBlockId(Table t, str id) = id in head(t) ? head(t)[id] : -1;

list[Item] items(Block b) = [ i | (Block) `<Item* is>` := b, Item i <- is ];

tuple[list[str] errors, list[tuple[str, int]] uses] process(str program, bool slideVersion = false) {
  Table table = createTable();
  list[str] errors = [];
  list[tuple[str, int]] uses = [];
  int declarations = 0;

  void use(str x) {
    int ref = slideVersion ? searchBlockId(table, x) : searchId(table, x);
    if (ref == -1) errors += ["<x> is not declared"];
    else uses += [<x, ref>];
  }

  void item(Item i) {
    switch (i) {
      case (Item) `<Type _> <Id x>;`: {
        if (searchBlockId(table, "<x>") != -1) {
          errors += ["<x> is declared twice in the same block"];
        } else {
          declarations += 1;
          table = enterId(table, "<x>", declarations);
        }
      }
      case (Item) `<Id x> = <E e>;`: {
        use("<x>");
        if ((E) `<Id y>` := e) use("<y>");
      }
      case (Item) `{ <Block b> }`: {
        table = enterBlock(table);
        for (j <- items(b)) item(j);
        table = exitBlock(table);
      }
    }
  }

  for (i <- items(parse(#start[Block], program).top)) item(i);
  return <errors, uses>;
}

test bool lecture() = process("int a; { a = 4; int bar; }") == <[], [<"a", 1>]>;

test bool slideError() = process("int a; { a = 4; int bar; }", slideVersion = true).errors == ["a is not declared"];

test bool redeclared() = process("int a; int a;").errors == ["a is declared twice in the same block"];
test bool shadowing() = process("int a; { int a; a = 1; } a = 2;").uses == [<"a", 2>, <"a", 1>];
test bool undeclared() = process("int a; a = b;").errors == ["b is not declared"];
test bool outOfScope() = process("{ int c; } c = 1;").errors == ["c is not declared"];
