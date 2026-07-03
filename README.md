# Programming-Languages-Notes
Librería personal de notas en LaTeX sobre lenguajes de programación: lenguajes formales, autómatas, lexing, parsing, sistemas de tipos, semántica, sistemas en tiempo de ejecución y diseño de DSLs.

Notas del curso **ISIS-2111 · Elementos esenciales de lenguajes de programación (PLE)** — Universidad de los Andes.

## Estructura
- `common/` — preamble, macros, entornos de teoremas y bibliografía compartida.
- `topics/NN-tema/` — un bloque temático por carpeta, con su propio `main.tex`, `sections/`, `references.bib` y, si aplica, `exercises/`.
- `assets/` — recursos globales (imágenes, plantillas).

## Temas
Organizados por bloque temático (no semana a semana, ya que varios temas del syllabus se extienden sobre varias semanas):

- **01 · Formal Languages & Automata Theory** — `topics/01-formal-languages-and-automata/` · programming language overview, grammars, finite automata, regular languages, context-free languages.
- **02 · Lexing, Parsing & Semantic Analysis** — `topics/02-lexing-parsing-and-semantic-analysis/` · lexical analysis, parsing (LL/LR), ASTs, semantic analysis.
- **03 · Type Systems** — `topics/03-type-systems/` · lambda calculus, simply typed lambda calculus, type inference & checking, polymorphism, subtyping, recursive types, type safety.
- **04 · Semantics** — `topics/04-semantics/` · operational, denotational and axiomatic semantics, control flow, environments/scoping/parameter passing.
- **05 · Runtime Systems** — `topics/05-runtime-systems/` · lazy evaluation, runtime data representation, interpreters, native code & intermediate representations, virtual machines, garbage collection.
- **06 · DSL Design** — `topics/06-dsl-design/` · what is a DSL, design decisions.

## Compilación
Desde la raíz del repo:
```bash
cd topics/03-type-systems
latexmk -pdf main.tex
```
o usando `pdflatex main.tex` dos veces si no tienes `latexmk`.

## Convenciones
- Cada tema tiene su propio `main.tex` que hace `\input` de `common/` y de sus `sections/`.
- Las macros nuevas y reutilizables se añaden a `common/macros.tex`.
- Las macros muy específicas de un tema viven en su propio archivo dentro del tema.
- Cada sección termina, cuando aplica, con una subsección de `Exercises` para practicar el tema.
- El contenido de las notas está en inglés; este README y los comentarios de convención quedan en español.
