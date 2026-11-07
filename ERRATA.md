# Errata

Errores encontrados en las diapositivas del curso y en versiones anteriores de este repo. Las notas ya tienen la versión corregida.

La numeración de diapositivas es la que aparece impresa en cada diapositiva, que no coincide con la página del PDF; por eso va también la página.

## Diapositivas

| Diapositiva | Dice | Debería decir |
|---|---|---|
| 9-semantic_analysis, diap. 8 (pág. 19) | Regla de la resta: `Exp1.val := make_bin_op("-", Exp2.ptr, Term.ptr)` | `Exp1.ptr := make_bin_op("-", Exp2.ptr, Term.ptr)`. La regla construye un nodo del AST, no calcula un valor. |
| 9-semantic_analysis, diap. 8 (pág. 19) | `Factor1 ::= - Factor2` con `Factor1.ptr := make_un_op("+/-", Fact2.ptr)` | Los nombres no coinciden con el resto de la gramática (`Fact`). Debe ser `Fact1 ::= - Fact2`, `Fact1.ptr := make_un_op("-", Fact2.ptr)`. |
| 9-semantic_analysis, diap. 37 (pág. 52) | Caso `id=E;` de `process()`: `ref := table.search_block_id(succs[0].id)` | `ref := table.search_id(succs[0].id)`. `search_block_id` solo mira el bloque actual y sirve para detectar redeclaraciones; un uso tiene que buscar en todos los bloques que lo encierran. Con `int a; { a = 4; }` la versión de la diapositiva reporta un error que no existe. |
| 3-grammars, diap. 6 (pág. 8) | "λ/ε es la palabra vacía, es parte de todo lenguaje" | λ pertenece a Σ* para todo alfabeto, pero no a todo lenguaje: λ ∉ {a}. |
| 3-grammars, diap. 17 | `data Expr = = var(Id id) ...` y `mul (Expr lhs, Express rhs)` (igual en `div`, `add`, `sub`) | Un solo `=`, y el tipo es `Expr`. Además `var(Id id)` no tiene regla en la gramática de la misma diapositiva. |
| 3-grammars, diap. 22 | La regla `simple-formula ::= internal-formula operation internal-formula` usa `operation`, que no se define (N dice `operators`) | Falta `operation ::= "+" \| "-" \| "*" \| "/"`. |
| 3-grammars, diap. 19 y 22 | `=AVERAGE(AB$13, 9, 3.14, Z1480)` aparece como palabra del lenguaje | La gramática no la genera: `value ::= digit+` no tiene punto decimal y `ref` admite máximo dos dígitos. |
| 4-automata-2, diap. 24 y 25 | "does not contain the string cat or the string hat" | El enunciado es ambiguo. El NFA de la diapositiva reconoce "no contiene cat, o contiene hat" (acepta `hat` y `cathat`). Para "no contiene ninguna de las dos" hace falta otro autómata (ejercicio en las notas). |
| 4-automata-2, diap. 32 y 33 | NFA de "bb o bab exactamente una vez" | Le falta la transición D --a--> E. Sin ella rechaza `baabb`, que contiene `bb` una sola vez. |
| 4-automata-2, diap. 35 a 37 | NFA de (ab \| aab \| aba)* con un ciclo `a,b` en E y C como único final | Con ese ciclo acepta toda palabra que termine en `b` o `ba` (por ejemplo `b`, `bbb`) y rechaza λ. La versión correcta tiene E inicial y final, sin el ciclo. |
| 4-automata-2, diap. 73 | `A1* = ⟨Q1, Σ, I1, F2 ∪ I1, Δ⟩`, `Δ = Δ1 ∪ Δ2 ∪ ...` | No hay segundo autómata: es F1 y Δ1. Además, volver finales los estados iniciales no sirve en general: con Lb acepta `a`. Hay que agregar un estado inicial nuevo que sea final. |
| 5-regular_languages, diap. 7 (pág. 17) | "Empieza con 0 y longitud impar o empieza con 1 y longitud par": `(0((0\|1)(0\|1))*)\|(1(0\|1)*)` | La segunda parte acepta cualquier longitud. Debe ser `1(0\|1)((0\|1)(0\|1))*`. (La respuesta del ejercicio 5.7, diap. 52, sí es correcta.) |
| 5-regular_languages, diap. 53 | 5.8: `(0 \| 1)(0 \| 1)(0 \| 1)*` | Falta λ, que no es ni 0 ni 1. |
| 5-regular_languages, diap. 54 | 5.9: regex `0 \| 1 \| (0 \| 1)*(0 \| 1(0 \| 1))` y NFA con 0 --1--> 2 final | La regex no incluye λ. El NFA acepta `01` (0 --0--> 0 --1--> 2). |
| 5-regular_languages, diap. 58 | `Slash ::= Month\|Month1 / Day\|Day1 / ...` | Faltan paréntesis: `(Month \| Month1) "/" (Day \| Day1) ...`. Sin ellos `\|` parte toda la regla. |
| 5-regular_languages, diap. 59 | Regex de fechas | El mes aparece como `(0(1..9)\|1(0..2)0(1..9)\|1(0..2))`, el día está repetido dos veces seguidas y usa `(0..2)(1..9)`, que excluye 10 y 20. |
| 5-regular_languages, diap. 60 | Gramática de fechas en Rascal | `WhitespaceAndeComment` se declara y se usa `WhitespaceAndComment` (el módulo no carga). Las reglas `Slash`, `Dash` y `Dot` tienen `\|` sin agrupar, así que `05` es un `Slash` y `03/08/1978` no lo es. |
| 6-context_free_languages, diap. 14 | Gramática de Grace: `Ident ::= Exp \| Ident \| Num \| print(Exp)` | Debe ser `Exp ::= Ident \| Num \| print(Exp)`. Además falta `Stmt ::= Ident := Exp` para `x := x - 1`, y el `run` final no lo genera `S`. |
| 6-context_free_languages, diap. 25 | "LR parsers ... producing a leftmost word derivation" | Los parsers LR producen una derivación por la derecha, en orden inverso. Los LL producen la derivación por la izquierda. |
| 6-context_free_languages, diap. 49 | PDA de WFF en Gold | D es final y se llega a D después de un operador: acepta `A` y `pA`. Solo maneja la letra `p` y el operador `A`. |
| 6-context_free_languages, diap. 52 | `changeTop(I, I1)` y `changeTop(E, )E()` | Las dos usan convenciones distintas para el tope. Con el tope a la izquierda la segunda es `changeTop(E, (E))`. |
| 6-context_free_languages, diap. 55 | "Working automaton": `changeTop("$", "bSa")` | Con la definición de changeTop, eso quita el `$` del fondo y el `pop("$")` final nunca ocurre: el autómata no reconoce ninguna palabra. |
| 6-context_free_languages, diap. 64 | Gramática LDBL | No genera su propio ejemplo: `Name ::= (a..z)` y `Value ::= (0..9)` son de un solo carácter, la regla `Add` dice `image` donde el ejemplo dice `name`, y `Pairs` no tiene repetición. |
| 6-context_free_languages, diap. 69 | Prueba de que a^m b^m c^m no es libre de contexto | Empieza con "Suppose L is regular", repite el lema regular y dice que νβμ cae dentro de un solo bloque, lo que deja por fuera los casos 4 y 5 de su propia figura. |

## Repo

| Archivo | Decía | Corrección |
|---|---|---|
| `topics/04-semantics/exercises/preexam-solution.tex` | Caso base de `repeat` con $k = 0$ | $n \le 0$. Con un número negativo ninguna regla aplica y la configuración queda bloqueada. |
| `topics/04-semantics/exercises/README.md` | Ruta `topics/01-operational-semantics/exercises` | `topics/04-semantics/exercises` |
| `topics/01-.../references.bib`, `topics/05-.../references.bib` | *Foundations of Programming Languages* de John A. N. Lee (1989) | El libro que citan las diapositivas es de Kent D. Lee (Springer). |
| `topics/03-type-systems/references.bib` | Entrada "Lee, Peter, Programming Languages course notes, syllabus §5.22" | No corresponde a ninguna referencia de las diapositivas; se quitó. |
| `topics/02-.../references.bib` | Wilhelm y "Seidel" (2010) | Wilhelm, Seidl y Hack (2013). |
