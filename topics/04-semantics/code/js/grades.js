const assert = require("assert");

// <<grades>>
function grade(studentScore) {
  let studentGrade;
  if (studentScore >= 90) {
    studentGrade = "A";
  } else if (studentScore >= 80) {
    studentGrade = "B";
  } else if (studentScore >= 70) {
    studentGrade = "C";
  } else if (studentScore >= 60) {
    studentGrade = "D";
  } else {
    studentGrade = "F";
  }
  return studentGrade;
}
// <<grades.end>>

assert.strictEqual(grade(78), "C");
assert.strictEqual(grade(95), "A");
assert.strictEqual(grade(10), "F");
