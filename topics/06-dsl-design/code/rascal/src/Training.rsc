module Training

import ParseTree;
import String;

// <<grammar>>
layout Layout = [\ \t\n\r]* !>> [\ \t\n\r];

lexical Number   = [0-9]+ !>> [0-9];
lexical Label    = [a-z]+ !>> [a-z];
lexical DayName  = "Monday" | "Tuesday" | "Wednesday" | "Thursday"
                 | "Friday" | "Saturday" | "Sunday";
lexical Exercise = "run" | "swim" | "cycle" | "strength" | "rest";
lexical Unit     = "km" !>> [a-z] | "m" !>> [a-z] | "min" !>> [a-z] | "h" !>> [a-z];

start syntax Plan = Day+ days;
syntax Day       = DayName name ":" Activity+ activities;
syntax Activity  = Exercise exercise ":" Quantity quantity Intensity? intensity;
syntax Quantity  = Number amount Unit unit;
syntax Intensity = "@" Label label;
// <<grammar.end>>

Plan parsePlan(str s) = parse(#Plan, s);

// <<check>>
set[str] distanceExercises = {"run", "swim", "cycle"};
set[str] distanceUnits = {"km", "m"};
set[str] durationUnits = {"min", "h"};

list[str] check(Plan p) {
  list[str] errors = [];
  for (/Activity a := p) {
    str ex = "<a.exercise>";
    str unit = "<a.quantity.unit>";
    set[str] expected = ex in distanceExercises ? distanceUnits : durationUnits;
    if (unit notin expected) {
      errors += "line <a.src.begin.line>: invalid unit \'<unit>\' for exercise \'<ex>\'";
    }
    if (toInt("<a.quantity.amount>") == 0) {
      errors += "line <a.src.begin.line>: the amount of \'<ex>\' must be positive";
    }
  }
  return errors;
}
// <<check.end>>

// <<eval>>
int meters(Quantity q) = "<q.unit>" == "km" ? toInt("<q.amount>") * 1000 : toInt("<q.amount>");

int totalMeters(Plan p) {
  int total = 0;
  for (/Activity a := p, "<a.exercise>" in distanceExercises) {
    total += meters(a.quantity);
  }
  return total;
}
// <<eval.end>>

str example = "Monday:
              '  run: 10km @threshold
              '  rest: 15min
              'Wednesday:
              '  swim: 2000m @steady
              '  strength: 30min";

test bool parsesExample() = /Day _ := parsePlan(example);
test bool exampleIsValid() = check(parsePlan(example)) == [];
test bool exampleDistance() = totalMeters(parsePlan(example)) == 12000;
test bool runInMinutes() =
  check(parsePlan("Monday:\n  run: 10min")) == ["line 2: invalid unit \'min\' for exercise \'run\'"];
test bool restInKm() =
  check(parsePlan("Monday:\n  rest: 5km")) == ["line 2: invalid unit \'km\' for exercise \'rest\'"];
test bool zeroDistance() =
  check(parsePlan("Monday:\n  run: 0km")) == ["line 2: the amount of \'run\' must be positive"];
test bool negativeIsSyntaxError() {
  try { parsePlan("Monday:\n  run: -5km"); return false; }
  catch ParseError(_): return true;
}
test bool missingColonIsSyntaxError() {
  try { parsePlan("Monday:\n  run 10km:"); return false; }
  catch ParseError(_): return true;
}
test bool cycleInHours() =
  check(parsePlan("Monday:\n  cycle: 2h")) == ["line 2: invalid unit \'h\' for exercise \'cycle\'"];
test bool uppercaseLabelIsSyntaxError() {
  try { parsePlan("Monday:\n  run: 10km @Threshold"); return false; }
  catch ParseError(_): return true;
}
test bool longRunPassesEveryCheck() = check(parsePlan("Monday:\n  run: 90km")) == [];
