#!/usr/bin/env bash
# Corre todas las pruebas del código de las notas.
#
# Uso:   ./test-code.sh            (todos los temas)
#        ./test-code.sh 04         (solo el tema que empieza por 04)
#
# Rascal se corre con el jar de la terminal, nunca con la extensión de VS Code.
# La ruta del jar se puede cambiar con la variable RASCAL_JAR.
#
# Convenciones:
#   topics/NN-*/code/rascal/   proyecto Rascal (META-INF/RASCAL.MF, módulos en src/)
#                              con funciones "test bool"; se corren con :test.
#   topics/NN-*/code/scheme/   archivos .scm en R7RS small; cada caso imprime
#                              "nombre: expected X, got Y" y "FAIL" si no coinciden.
#   topics/NN-*/code/lisp/     archivos .lisp para SBCL, con la misma convención.
#   topics/NN-*/code/<otro>/   python, haskell, c, java, js, sql, swift, perl, bash: el programa
#                              termina con código distinto de 0 si algo falla.

set -u
RASCAL_JAR="${RASCAL_JAR:-$HOME/Downloads/rascal-shell-stable.jar}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
FILTER="${1:-}"
failures=0

strip() { sed -e 's/\x1b\[[0-9;?]*[a-zA-Z]//g' -e 's/[[:cntrl:]]//g'; }
fail() { echo "  FALLA: $1"; failures=$((failures + 1)); }

for topic in "$ROOT"/topics/"$FILTER"*/; do
  code="$topic/code"
  [ -d "$code" ] || continue
  echo "== $(basename "$topic")"

  # Rascal: un solo REPL por proyecto, importando todos los módulos.
  if [ -d "$code/rascal/src" ]; then
    mods=$(cd "$code/rascal/src" && find . -name '*.rsc' | sed -e 's|^\./||' -e 's|\.rsc$||' -e 's|/|::|g' | sort)
    input=""
    for m in $mods; do input="${input}import ${m};"$'\n'; done
    out=$(cd "$code/rascal" && printf '%s:test\n:quit\n' "$input" \
          | TERM=dumb java -jar "$RASCAL_JAR" 2>&1 | strip)
    echo "$out" | grep -E "Test report|tests succeeded|tests failed|failed|error" | sed 's/^/  /'
    if echo "$out" | grep -qiE "failed|error|could not|undeclared|parse error"; then
      fail "rascal en $(basename "$topic")"
    fi
  fi

  for f in "$code"/scheme/*.scm; do
    [ -e "$f" ] || continue
    out=$(scheme --quiet --load "$f" --eval '(exit 0)' < /dev/null 2>&1)
    n=$(echo "$out" | grep -c "expected")
    echo "  $(basename "$f"): $n casos"
    if echo "$out" | grep -qE "FAIL|error>|^;"; then echo "$out" | grep -E "FAIL|^;" | sed 's/^/    /'; fail "$f"; fi
  done

  for f in "$code"/lisp/*.lisp; do
    [ -e "$f" ] || continue
    out=$(sbcl --script "$f" 2>&1); st=$?
    n=$(echo "$out" | grep -c "expected")
    echo "  $(basename "$f"): $n casos"
    if [ $st -ne 0 ] || echo "$out" | grep -q "FAIL"; then echo "$out" | grep -E "FAIL|error" | sed 's/^/    /'; fail "$f"; fi
  done

  for f in "$code"/python/*.py; do
    [ -e "$f" ] || continue
    python3 -I "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/haskell/*.hs; do
    [ -e "$f" ] || continue
    runghc --ghc-arg=-package-env=- "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/c/*.c; do
    [ -e "$f" ] || continue
    tmp=$(mktemp); clang -std=c11 -Wall -o "$tmp" "$f" 2>/dev/null && "$tmp" > /dev/null 2>&1 \
      && echo "  $(basename "$f"): ok" || fail "$f"; rm -f "$tmp"
  done

  for f in "$code"/cpp/*.cpp; do
    [ -e "$f" ] || continue
    tmp=$(mktemp); clang++ -std=c++17 -Wall -o "$tmp" "$f" 2>/dev/null && "$tmp" > /dev/null 2>&1 \
      && echo "  $(basename "$f"): ok" || fail "$f"; rm -f "$tmp"
  done

  for f in "$code"/java/*.java; do
    [ -e "$f" ] || continue
    java -ea "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/sql/*.sql; do
    [ -e "$f" ] || continue
    out=$(sqlite3 :memory: < "$f" 2>&1)
    if [ $? -eq 0 ] && ! echo "$out" | grep -q FAIL; then echo "  $(basename "$f"): ok"; else fail "$f"; fi
  done

  for f in "$code"/js/*.js; do
    [ -e "$f" ] || continue
    node "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/swift/*.swift; do
    [ -e "$f" ] || continue
    swift "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/perl/*.pl; do
    [ -e "$f" ] || continue
    perl "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done

  for f in "$code"/bash/*.sh; do
    [ -e "$f" ] || continue
    bash "$f" > /dev/null 2>&1 && echo "  $(basename "$f"): ok" || fail "$f"
  done
done

if [ $failures -eq 0 ]; then echo "Todo pasó."; else echo "$failures archivo(s) con fallas."; exit 1; fi
