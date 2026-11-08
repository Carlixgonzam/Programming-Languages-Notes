const assert = require("assert");
// <<loopvar>>
var funcsVar = [];
for (var i = 0; i < 3; i++) {
  funcsVar.push(() => i);            // var: one i for the whole function
}
var funcsLet = [];
for (let j = 0; j < 3; j++) {
  funcsLet.push(() => j);            // let: a new j in each iteration
}
// <<loopvar.end>>
assert.deepStrictEqual(funcsVar.map(f => f()), [3, 3, 3]);
assert.deepStrictEqual(funcsLet.map(f => f()), [0, 1, 2]);
