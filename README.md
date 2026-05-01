# Programming-Languages-Notes
Librería personal de notas en LaTeX sobre lenguajes de programación, semántica, sistemas de tipos y temas relacionados.
## Estructura
- `common/` — preamble, macros, entornos de teoremas y bibliografía compartida.
- `topics/NN-tema/` — un documento por tema, con sus propias secciones, figuras, diagramas y referencias.
- `assets/` — recursos globales (imágenes, plantillas).
## Temas
- **01 · Abstract Syntax Trees, Type Inference & Operational Semantics** — `topics/01-operational-semantics/main.tex` · _en progreso_
- **02 · Type Systems and Semantic Analysis** — `topics/02-type-systems/main.tex` · _en progreso_
## Compilación
Desde la raíz del repo:
```bash
cd topics/01-operational-semantics
latexmk -pdf main.tex
```
o usando `pdflatex main.tex` dos veces si no tienes `latexmk`.
## Convenciones
- Cada tema tiene su propio `main.tex` que hace `\input` de `common/` y de sus `sections/`.
- Las macros nuevas y reutilizables se añaden a `common/macros.tex`.
- Las macros muy específicas de un tema viven en su propio archivo dentro del tema.
