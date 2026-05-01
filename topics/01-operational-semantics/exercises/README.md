# Ejercicios — Operational Semantics
Documentos LaTeX **autocontenidos** (cada uno con su propio `\documentclass` y `\begin{document}`) con ejercicios sueltos.
A diferencia de los archivos en `../sections/`, estos NO se incluyen vía `\input` desde `main.tex`: se compilan independientemente.
## Convención de nombres
- `preexam-solution.tex` 
- `homework-NN.tex` 
- `practice-tema.tex` 
## Compilar uno
```bash
cd topics/01-operational-semantics/exercises
latexmk -pdf preexam-solution.tex
```
