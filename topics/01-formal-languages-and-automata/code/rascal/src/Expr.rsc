module Expr

// <<adt>>
data Expr
  = integer(int intValue)
  | \true()
  | \false()
  | not(Expr arg)
  | mul(Expr lhs, Expr rhs)
  | div(Expr lhs, Expr rhs)
  | add(Expr lhs, Expr rhs)
  | sub(Expr lhs, Expr rhs)
  ;
// <<adt.end>>

// <<kind>>
// The kind of value an expression produces: "int", "bool" or "error".
str kind(integer(_)) = "int";
str kind(\true())    = "bool";
str kind(\false())   = "bool";
str kind(not(e))     = kind(e) == "bool" ? "bool" : "error";
default str kind(Expr e) = arith(e.lhs, e.rhs);

str arith(Expr l, Expr r) = kind(l) == "int" && kind(r) == "int" ? "int" : "error";
// <<kind.end>>

// The three examples from the lecture.
test bool threeTimesFour() = kind(mul(integer(3), integer(4))) == "int";
test bool notFalsePlusTrue() = kind(add(not(\false()), \true())) == "error";
test bool onePlusOnePlusOne() = kind(add(add(integer(1), integer(1)), integer(1))) == "int";
