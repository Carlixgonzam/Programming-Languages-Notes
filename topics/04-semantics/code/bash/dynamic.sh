x=10
f() { echo "$x"; }
g() { local x=20; f; }

[ "$(g)" = "20" ] || exit 1
[ "$(f)" = "10" ] || exit 1
