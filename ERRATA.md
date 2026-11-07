# Errata

Errores encontrados en las diapositivas del curso y en versiones anteriores de este repo. Las notas ya tienen la versión corregida.

La numeración de diapositivas es la que aparece impresa en cada diapositiva, que no coincide con la página del PDF; por eso va también la página.

## Diapositivas

| Diapositiva | Dice | Debería decir |
|---|---|---|
| 9-semantic_analysis, diap. 8 (pág. 19) | Regla de la resta: `Exp1.val := make_bin_op("-", Exp2.ptr, Term.ptr)` | `Exp1.ptr := make_bin_op("-", Exp2.ptr, Term.ptr)`. La regla construye un nodo del AST, no calcula un valor. |
| 9-semantic_analysis, diap. 8 (pág. 19) | `Factor1 ::= - Factor2` con `Factor1.ptr := make_un_op("+/-", Fact2.ptr)` | Los nombres no coinciden con el resto de la gramática (`Fact`). Debe ser `Fact1 ::= - Fact2`, `Fact1.ptr := make_un_op("-", Fact2.ptr)`. |
| 9-semantic_analysis, diap. 37 (pág. 52) | Caso `id=E;` de `process()`: `ref := table.search_block_id(succs[0].id)` | `ref := table.search_id(succs[0].id)`. `search_block_id` solo mira el bloque actual y sirve para detectar redeclaraciones; un uso tiene que buscar en todos los bloques que lo encierran. Con `int a; { a = 4; }` la versión de la diapositiva reporta un error que no existe. |

## Repo

| Archivo | Decía | Corrección |
|---|---|---|
| `topics/04-semantics/exercises/preexam-solution.tex` | Caso base de `repeat` con $k = 0$ | $n \le 0$. Con un número negativo ninguna regla aplica y la configuración queda bloqueada. |
| `topics/04-semantics/exercises/README.md` | Ruta `topics/01-operational-semantics/exercises` | `topics/04-semantics/exercises` |
| `topics/01-.../references.bib`, `topics/05-.../references.bib` | *Foundations of Programming Languages* de John A. N. Lee (1989) | El libro que citan las diapositivas es de Kent D. Lee (Springer). |
| `topics/03-type-systems/references.bib` | Entrada "Lee, Peter, Programming Languages course notes, syllabus §5.22" | No corresponde a ninguna referencia de las diapositivas; se quitó. |
| `topics/02-.../references.bib` | Wilhelm y "Seidel" (2010) | Wilhelm, Seidl y Hack (2013). |
