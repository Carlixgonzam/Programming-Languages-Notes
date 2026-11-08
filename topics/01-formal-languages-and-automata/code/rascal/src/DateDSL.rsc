module DateDSL

import ParseTree;

start syntax Date = Slash | Dash | Dot;

lexical Slash = MonthPart "/" DayPart "/" Year4;
lexical Dash  = DayPart "-" MonthPart "-" Year2;
lexical Dot   = Year4 "." MonthPart "." DayPart;

lexical DayPart   = Day | Day1;
lexical MonthPart = Month | Month1;

lexical Day    = [0-2] [0-9];
lexical Day1   = "3" [0-1];
lexical Month  = "0" [1-9];
lexical Month1 = "1" [0-2];
lexical Year4  = [0-2] [0-9] [0-9] [0-9];
lexical Year2  = [0-9] [0-9];

layout Spaces = [\ ]* !>> [\ ];
lexical Digit = [0-9];
lexical UptoTwo = [0-2];
syntax SlashSlide = "0" Digit | "1" UptoTwo "/" UptoTwo Digit
                  | "3" ("0" | "1") "/" UptoTwo Digit Digit Digit;

bool isDate(str x) {
  try { parse(#Date, x); return true; }
  catch ParseError(_): return false;
}

test bool generated()  = isDate("03/08/1978");
test bool dotDate()    = isDate("1979.10.01");
test bool dashLong()   = !isDate("12-11-2025");
test bool dashShort()  = isDate("12-11-25");

test bool month13()    = !isDate("13/01/2000");
test bool day32()      = !isDate("01/32/2000");
test bool day00()      = isDate("01/00/2000");
test bool feb31()      = isDate("02/31/2000");

test bool slideAcceptsMonthAlone() {
  try { parse(#SlashSlide, "05"); return true; }
  catch ParseError(_): return false;
}
test bool slideRejectsFullDate() {
  try { parse(#SlashSlide, "03/08/1978"); return false; }
  catch ParseError(_): return true;
}
