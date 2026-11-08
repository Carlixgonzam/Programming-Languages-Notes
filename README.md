# Programming-Languages-Notes

Notas en LaTeX del curso **ISIS-2111** (lenguajes de programación): lenguajes formales y autómatas, análisis léxico, parsing y análisis semántico, sistemas de tipos, semántica, sistemas en tiempo de ejecución y diseño de DSL. Las notas están en inglés; este README, `PLAN.md` y `ERRATA.md` están en español.

## Estructura

- `common/`: preámbulo, macros, entornos de teoremas y la bibliografía compartida (`bibliography.bib`, con los libros que citan las diapositivas).
- `topics/NN-tema/`: un tema por carpeta, con su `main.tex`, `sections/`, `references.bib` (solo las referencias propias del tema), `code/` y, en el tema 04, `exercises/`.
- `topics/NN-tema/code/`: todo el código que aparece en las notas. Las notas lo incluyen con `\lstinputlisting` (macros `\codefile` y `\coderange` del preámbulo); los fragmentos se marcan en el archivo con comentarios `<<nombre>>` y `<<nombre.end>>`.
- `test-code.sh`: corre las pruebas del código de uno o de todos los temas.
- `PLAN.md`: el plan de la actualización y las decisiones tomadas.
- `ERRATA.md`: errores encontrados en las diapositivas y en el repo, con la corrección.

## Temas y diapositivas

| Tema | Sección | Diapositivas |
|---|---|---|
| 01 Formal languages and automata | `01-programming-languages-overview` | 2-pls |
| | `02-grammars-and-language-definitions` | 3-grammars |
| | `03-finite-automata` | 4-automata |
| | `04-regular-languages` | 5-regular_languages |
| | `05-context-free-languages` | 6-context_free_languages |
| 02 Lexing, parsing and semantic analysis | `01-lexical-analysis` | 7-lexers |
| | `02-parsing` | 8-parsing |
| | `03-abstract-syntax-trees` | 9-semantic_analysis (primera parte) |
| | `04-semantic-analysis` | 9-semantic_analysis (segunda parte) |
| 03 Type systems | `01-introduction` | 10-type_systems |
| | `02-typing-rules-and-letrec` | 10-type_systems (LETREC) |
| | `05-type-inference` | 10-type_systems (unificación) |
| | `03`, `04`, `06` a `09` | extra |
| 04 Semantics | `01-operational-semantics` | 11-operational_semantics |
| | `02-denotational-semantics` | 12-denotational_semantics |
| | `03-axiomatic-semantics` | extra |
| | `04-control-flow` | 13-control |
| | `05-environments-scoping-and-parameter-passing` | 14-environments_scoping |
| 05 Runtime systems | `01-lazy-evaluation` | 15-lazy_execution |
| | `02-runtime-data-representation` | 16-runtime_representation |
| | `03` a `06` (intérpretes, IR, máquinas virtuales, recolección de basura) | extra |
| 06 DSL design | `01-what-is-a-dsl` | DSL de fechas y LDBL (5 y 6), SCuLPT (2-pls), enunciados del proyecto |
| | `02-design-decisions` | extra |

Lo marcado como extra ya estaba en el repo y no aparece en las diapositivas; se dejó con el estilo nuevo y lo dice al comienzo de la sección o subsección.

## Compilación

Desde la carpeta de cada tema:

```bash
cd topics/03-type-systems
latexmk -pdf main.tex
```

Sin `latexmk`: `pdflatex main.tex`, `bibtex main` y `pdflatex main.tex` dos veces más.

## Pruebas del código

```bash
./test-code.sh        # todos los temas
./test-code.sh 04     # solo el tema 04
```

El script usa estas herramientas, según lo que haya en cada tema:

- **Rascal**: solo desde la terminal, con el jar de la consola (`RASCAL_JAR`, por defecto `~/Downloads/rascal-shell-stable.jar`). Cada `code/rascal/` es un proyecto con `META-INF/RASCAL.MF` y fuentes en `src/`; el script importa todos los módulos y corre `:test`. A mano:
  ```bash
  cd topics/01-formal-languages-and-automata/code/rascal
  printf 'import Automata;\n:test\n:quit\n' | java -jar ~/Downloads/rascal-shell-stable.jar
  ```
- **Scheme** (R7RS small, MIT Scheme): cada archivo imprime `nombre: expected ..., got ...` y marca `FAIL` si no coinciden.
  ```bash
  scheme --quiet --load topics/05-runtime-systems/code/scheme/lazy.scm --eval '(exit 0)' < /dev/null
  ```
- **Common Lisp** (`sbcl --script`), **Python** (`python3`), **Haskell** (`runghc`), **C** (`clang -std=c11`), **C++** (`clang++ -std=c++17`), **Java** (`java -ea`), **JavaScript** (`node`), **Swift**, **SQL** (`sqlite3`), **Perl** y **Bash**: cada programa termina con error o imprime `FAIL` si una prueba falla.

## Convenciones

- Estilo de artículo limpio: sin cajas ni color, negrita solo en la primera definición de un término, figuras con `\caption` y `\ref`, al menos una figura por sección.
- Cada sección termina con ejercicios resueltos; los de las diapositivas van primero.
- Las citas van a `common/bibliography.bib` o al `references.bib` del tema.
- Las macros reutilizables van en `common/macros.tex`.
