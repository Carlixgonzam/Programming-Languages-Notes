# <<bash>>
x=10
f() { echo "$x"; }
g() { local x=20; f; }
# <<bash.end>>

[ "$(g)" = "20" ] || exit 1      # f sees the x of g, its caller
[ "$(f)" = "10" ] || exit 1
