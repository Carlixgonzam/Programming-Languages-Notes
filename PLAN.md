# Plan de actualización de las notas

Rama: `actualizacion-notas`. Nada se edita en masa hasta que apruebes este plan.

## Parámetros

| Parámetro | Valor |
|---|---|
| Diapositivas | `~/Downloads/2-pls.pdf` a `~/Downloads/16-runtime_representation.pdf` (15 archivos, uso `4-automata-2.pdf` y `3-grammars.pdf`) |
| Rascal | `~/Downloads/rascal-shell-stable.jar` (versión 0.40.17) |
| Scheme | MIT/GNU Scheme 12.1 (`/opt/homebrew/bin/scheme`), código en R7RS small |
| Common Lisp | SBCL (`/opt/homebrew/bin/sbcl`), solo donde Common Lisp muestra algo que Scheme no |
| Idioma de las notas | inglés. README, `PLAN.md`, `ERRATA.md` y comentarios de convención en español. `preexam-solution.tex` sigue en español |
| Referencia de estilo | `~/Downloads/repaso-parcial2-enunciados.tex` y `repaso-parcial2-soluciones.tex` (no están en el repo) |

## Decisiones globales

**Preámbulo.** `common/preamble.tex` queda con `lmodern`, `microtype`, `geometry` (margen 1in), `amsmath/amssymb/amsthm`, `mathpartir`, `booktabs`, `array`, `forest`, `tikz` con `automata, positioning, arrows.meta, calc, shapes.multipart, fit`, `caption`, `listings` y `hyperref` con `hidelinks`. Sale `xcolor` como paquete explícito (TikZ lo carga por dentro). Los estilos de TikZ comunes (`caja`, `flecha`, `nodoarbol`, estados de autómata) se definen una sola vez ahí, copiados del repaso.

**Listings.** Defino `Rascal`, `Scheme` y `CommonLisp` en blanco y negro con palabras clave en negrita, sin marco de color. `\lstinputlisting` lee de `topics/NN-tema/code/<lenguaje>/`.

**Teoremas.** `common/theorems.tex` hoy dice "Definición", "Ejemplo", "Teorema". Como las notas van en inglés, pasan a "Definition", "Example", "Theorem", "Lemma", "Proposition", "Remark".

**Bibliografía.** `common/bibliography.bib` con los libros que citan las diapositivas en su página final: Hopcroft, Motwani y Ullman; Aho, Lam, Sethi y Ullman; Scott y Aldrich; Wilhelm, Seidl y Hack; Lee; Nystrom; Watt; Friedman y Wand (LETREC viene de ahí); Fernández (semántica operacional); Tennent; Pratt y Zelkowitz; MacLennan; Kaplan. Se activa `\bibliography` en cada `main.tex`. Pierce y Winskel ya estaban y se quedan.

**Código fuera de Rascal y Scheme.** El repo tiene listados en Python, Haskell, C, C++, Java, Scala, Go, SQL y bash. Hay intérprete o compilador para todos menos Scala y Go. Los que se quedan pasan a `code/` y se prueban (`python3`, `runghc`, `clang`, `javac`, `sqlite3`, `bash`). Los de Scala y Go se reescriben en Java o Haskell, que muestran lo mismo (genéricos con varianza, subtipado estructural). Fragmentos de una línea dentro de la prosa (`x = x + 1`) siguen como `\lstinline`.

**Prueba del código.** Cada carpeta `code/rascal/` es un proyecto con `META-INF/RASCAL.MF` (`Source: src`). Un script en la raíz, `test-code.sh`, corre:

- Rascal: `printf 'import M;\n:test\n:quit\n' | TERM=dumb java -jar ~/Downloads/rascal-shell-stable.jar` en cada proyecto y filtra el reporte. Ya probé que funciona con un módulo de ensayo.
- Scheme: `scheme --quiet < archivo.scm`. Cada archivo termina con casos que imprimen esperado y obtenido, y el script falla si alguno no coincide.
- SBCL: `sbcl --script archivo.lisp`, con el mismo formato.
- El resto según su herramienta.

La ruta del jar se toma de la variable `RASCAL_JAR` con `~/Downloads/rascal-shell-stable.jar` por defecto, para que funcione en otra máquina.

**Chequeos antes de cada commit.** Los cinco `grep` del prompt, más compilar con `latexmk -pdf` sin errores ni `Overfull \hbox` mayores a 5pt, más mirar en PNG (`pdftoppm -r 80`) cada página con figuras.

## Por tema

### 01 Formal languages and automata

**`01-programming-languages-overview`** (diapositivas 2-pls)
- Hoy: por qué estudiar teoría, definición formal, historia en tres generaciones, tensiones de diseño, paradigmas con Python/Haskell/SQL, "Why formal tools, not vibes".
- Falta: las definiciones de lenguaje y programa de la clase; los nueve lenguajes vistos (Ada, Prolog, Scratch, ASCII Dots, CLU, UML, Action!, Piet, SCuLPT); los ocho criterios de un buen lenguaje con un ejemplo concreto cada uno.
- Figuras: diagrama programa, traductor y máquina; tabla `booktabs` de los nueve lenguajes (año, paradigma, qué muestra).
- Código: la misma función en Scheme y en Rascal para comparar estilos; el ejemplo de paradigmas se queda, probado.
- Extra: historia, tensiones de diseño, taxonomía de paradigmas. El título "Why formal tools, not vibes" pasa a "Why formal definitions".

**`02-grammars-and-language-definitions`** (3-grammars)
- Hoy: alfabetos y operaciones, gramáticas, derivaciones, expresiones aritméticas, BNF/EBNF, jerarquía de Chomsky, ambigüedad (precedencia y dangling else).
- Falta: sintaxis concreta frente a abstracta, tipos de datos algebraicos, el ejemplo de listas de la clase, categorías de símbolos, generación de palabras.
- Figuras: árbol de derivación y AST de la misma lista, lado a lado; diagrama de la jerarquía de Chomsky.
- Código: Rascal `Lists.rsc` (sintaxis concreta `syntax`, AST `data`, `implode`, tests de palabras válidas e inválidas).
- Movimiento: precedencia y dangling else se quedan aquí corto y se desarrollan en la sección 05, que es donde las ponen las diapositivas.

**`03-finite-automata`** (4-automata-2)
- Hoy: DFA, ejemplo "termina en 01", NFA, construcción de subconjuntos, equivalencia, clausura.
- Falta: sistemas de transiciones etiquetadas; $\hat\delta$ y lenguaje de un DFA; NFA con transiciones $\lambda$, sobre palabras y con varios iniciales; eliminación de $\lambda$ ($\lambda$-clausura), de elecciones y de iniciales múltiples; unión, concatenación, estrella, intersección y diferencia por producto.
- Figuras (TikZ `automata`): el autómata de compras pay/ship/redeem/transfer, "contiene 01", pares de 0s y 1s, lenguaje de listas, "no contiene cat/hat", "bb o bab exactamente una vez", $(ab|aab|aba)^*$ y cada paso de cada eliminación y construcción.
- Código: Rascal `Automata.rsc` con DFA y NFA como datos, `accepts`, `lambdaClosure`, `determinize`, `product`; los tests corren los ejemplos de clase. Ningún uso de Gold.

**`04-regular-languages`** (5-regular_languages)
- Hoy: regex, Kleene, Thompson, regex prácticas en Python, lema del bombeo con $a^nb^n$, puente a lexers.
- Falta: gramáticas regulares por izquierda y por derecha, operadores, tabla regex a gramática, árboles de derivación de gramáticas regulares, propiedades de clausura y álgebra, el DSL de fechas (MM/DD/YYYY, DD-MM-YY, YYYY.MM.DD), los correos uniandes, los nueve ejercicios regex + autómata.
- Figuras: árboles por izquierda y por derecha de la misma palabra; los nueve autómatas; diagrama de la prueba del bombeo ($xyz$ sobre la palabra).
- Código: Rascal `DateDSL.rsc` (las tres formas, con tests de fechas válidas e inválidas), `Regex.rsc` con los nueve ejercicios probados contra palabras; Python de regex prácticas probado.
- Extra: Thompson y "where regex engines lie".

**`05-context-free-languages`** (6-context_free_languages)
- Hoy: CFG, árboles, dangling else, CNF, PDA, bombeo con $a^nb^nc^n$, clausura.
- Falta: derivaciones por izquierda y por derecha sobre el mismo ejemplo, precedencia y asociatividad metidas en la gramática, Open/Closed statements, eliminación de recursión por izquierda, operaciones y configuraciones del PDA, aceptación, PDA de $a^nb^n$, PDA desde la gramática, LDBL, Grace, WFF.
- Figuras: dos árboles para la expresión ambigua; árbol con la gramática estratificada; PDA de $a^nb^n$ con traza de pila; árbol de WFF.
- Código: Rascal `Expr.rsc` (precedencia con `>` y `left`, tests de que `1-2-3` asocia a la izquierda), `WFF.rsc`, `LDBL.rsc`, `PDA.rsc` (simulador con tests de $a^nb^n$ y de paréntesis).

### 02 Lexing, parsing and semantic analysis

**`01-lexical-analysis`** (7-lexers)
- Hoy: qué hace un lexer, DFA, maximal munch, palabras reservadas, espacios y comentarios, errores, lexer a mano en Python, generados frente a escritos a mano.
- Falta: componentes del análisis léxico, definición de tokens, tablas de símbolos y su implementación, estrategia de lookahead, patrones comunes, los ejercicios de tokenizar JavaScript, Python y Fortran, los cuatro "bootcamp".
- Figuras: pipeline fuente, lexer, tokens, parser con la tabla de símbolos al lado; DFA de identificadores y palabras reservadas; tabla de símbolos como hash con listas.
- Código: lexer en Rascal (`lexical`, `keyword`, `layout`) y el de Python actual, probados; tests con los tres programas de clase.

**`02-parsing`** (8-parsing)
- Hoy: descenso recursivo en Python, FIRST/FOLLOW, recursión por izquierda y factorización, Pratt, ascendente y recuperación en breve, ejemplo `3+4*2-1`.
- Falta: tipos de error; las cuatro recuperaciones; el ejemplo completo `Exp/Exp'/Term/Term'/Factor` con FIRST, FOLLOW y tabla LL(1); parser predictivo con pila; la traza de pánico con `)4*+2$`; shift-reduce con `3*2`; el conflicto del if-then-else; ítems LR(1), `closure`, `goto` y el autómata LR de la gramática de expresiones.
- Figuras: tablas FIRST/FOLLOW/LL(1) en `booktabs`; trazas de pila; autómata LR en TikZ.
- Código: Rascal o Scheme para el parser predictivo dirigido por tabla con la traza impresa; el Python actual probado.
- Extra: Pratt parsing.

**`03-abstract-syntax-trees`** (9-semantic_analysis, primera mitad)
- Hoy: muy corto, un ejemplo y ejercicios.
- Falta: AST frente a árbol de derivación, gramáticas de atributos, sintetizados ($7+3*4=19$), heredados ($9-4-3=2$), construcción de abajo hacia arriba (`make_leaf`, `make_bin_op`) y de arriba hacia abajo (`st` heredado) con `(1+2)*4`.
- Figuras: árboles decorados con `forest` para los tres ejemplos; el AST resultante.
- Código: Rascal `Attributes.rsc` que evalúa y construye el AST con los dos métodos y comprueba 19, 2 y la forma del árbol de `(1+2)*4`.
- Corrección: la regla de la resta usa `Exp1.ptr` (diapositiva 8).

**`04-semantic-analysis`** (9-semantic_analysis, segunda mitad)
- Hoy: por qué no basta la gramática, tablas de símbolos en Python, resolución de nombres, chequeo de tipos, ASTs decorados, flujo de datos, taxonomía de errores.
- Falta: análisis estático, reglas de validez y visibilidad con el `for` anidado de Java, tabla encadenada por bloques, las operaciones `create_table`, `enter_block`, `exit_block`, `enter_id`, `search_id`, `search_block_id`, el procedimiento `process()`, análisis dinámico (aserciones, invariantes, pre y poscondiciones).
- Figuras: tabla encadenada en cada punto del programa de ejemplo.
- Código: Rascal `Scopes.rsc` con la tabla de símbolos y `process()`; tests de redeclaración y de uso de una variable del bloque de afuera.
- Corrección: los usos buscan con `search_id` (diapositiva 37), con la explicación.
- Extra: flujo de datos.

### 03 Type systems

Propongo agregar una sección nueva `02-typing-rules-and-letrec.tex` y correr las demás un número.

**`01-introduction`** (10-type_systems)
- Hoy: por qué tipos, cuatro dimensiones, "well-typed programs cannot go wrong", hoja de ruta.
- Falta: tipos primitivos y compuestos; constructores función, suma, producto, igualdad e inductivos; estático frente a dinámico con pros y contras; el ejemplo de `list_length` en Prolog; duck typing; option, nullable y owned.
- Figuras: tabla de constructores con su notación y un ejemplo; diagrama de cuándo se detecta el error en estático y en dinámico.

**`02-typing-rules-and-letrec`** (nueva)
- LETREC y sus reglas en `mathpartir`, la regla para definir funciones, `type-of`, ambientes de tipos, chequeo frente a inferencia (el título pasa a "Type checking and type inference").
- Figuras: árbol de derivación de tipos de un programa LETREC.
- Código: Rascal `Letrec.rsc` con `typeOf` y tests de programas bien y mal tipados.

**`04-type-inference-and-checking`** (después `05-`)
- Hoy: Algoritmo W, tipos principales, $\lambda f. f\,f$, referencias, ejemplo, Scala, bidireccional.
- Falta: sustitución, unificación y occurs check como en las diapositivas, con `proc (f) zero?((f f))` y `proc (f) proc(x) -((f 3),(f x))`.
- Figuras: tabla de ecuaciones y sustituciones paso a paso; árbol con variables de tipo.
- Código: Rascal `Unify.rsc` (unificador con occurs check, tests con los dos ejemplos de clase); el ejemplo de Scala pasa a Java.

**Lambda calculus, STLC, polimorfismo, subtipado, tipos recursivos, seguridad.** Se quedan como extra, con estilo nuevo, una figura por sección (árbol de reducción, árbol de tipado, diagrama de varianza, desenrollado de $\mu$) y un párrafo que los conecte con LETREC y con `count`.

### 04 Semantics

**`01-operational-semantics`** (11-operational_semantics)
- Hoy: big step de listas (`concat`, `append`), small step y `for` en SIMP.
- Falta: el lenguaje SIMP; la máquina abstracta con pila de control, pila de resultados y memoria, con la traza del factorial con `while`; las reglas small step (opL, opR, :=, :=R, if, ifT, ifF, while, skip, seq), configuraciones finales y bloqueadas; big step con la derivación de `z:=!x; x:=!y; y:=!z`; bloques y variables locales.
- Se mueven aquí los "Worked Examples" que hoy están dentro del Ejercicio 5 del preexamen.
- Figuras: estados de la máquina abstracta como pilas dibujadas; árbol de derivación big step del intercambio.
- Código: Rascal `Simp.rsc` con evaluador small step (que imprime la traza) y big step, con tests de que ambos dan la misma memoria final.
- Extra: listas y `for`.

**`02-denotational-semantics`** (12-denotational_semantics)
- Hoy: funciones de interpretación, estado, expresiones, comandos, puntos fijos, equivalencia con operacional.
- Falta: los diez ejemplos de clase (booleanos, números, la gramática `E/T/F`, árboles con variables, derivadas con pares, complejos rectangulares y polares, S-expressions, conjuntos de dígitos, secuencias de asignaciones y su traducción).
- Código: Scheme `denotational.scm` con un intérprete por ejemplo (la función semántica escrita como función), probado.
- Figuras: árbol de una expresión con su denotación en cada nodo.
- Extra: puntos fijos y equivalencia.

**`03-axiomatic-semantics`**: extra, solo estilo y una figura (anotaciones de Hoare sobre el diagrama del ciclo).

**`04-control-flow`** (13-control)
- Hoy: secuencia y orden de evaluación, cortocircuito, excepciones, continuaciones, corrutinas, estructurado frente a no estructurado.
- Falta: precedencia y asociatividad, asignaciones, l-values y r-values, modelo de valor y de referencia, igualdad, boxing, break/continue, terminación temprana, retornos multinivel, selección (if, case, jump code, pattern matching), iteración (enumeración, cambio de índices, límites vacíos, acceso fuera del ciclo, ciclos con predicado), recursión, no determinismo.
- Figuras: diagramas de flujo de else-if, de break/continue y del ciclo; jump code de una condición con `&&`; modelo de valor frente a referencia como diagrama de memoria.
- Código: Scheme `call/cc` (salida temprana y retorno multinivel), Java para boxing e igualdad, C para orden de evaluación, todo probado.
- Extra: excepciones con Hoare, corrutinas.

**`05-environments-scoping-and-parameter-passing`** (14-environments_scoping)
- Hoy: ambiente frente a estado, estático y dinámico, closures, el gotcha del ciclo, paso de parámetros, regla small step de llamadas.
- Falta: holes and shadows, profundidad léxica, `extends`, ligadura de valores en dinámico, nombres calificados, modificadores de acceso, paso entre procesos, la traza "qué valores tienen las variables en cada paso" de la clase.
- Figuras: ambientes encadenados con su profundidad léxica; pila de activación con enlaces estáticos y dinámicos; tabla de las cinco formas de paso de parámetros sobre el mismo programa.
- Código: Scheme para closures y paso por nombre con thunks; Common Lisp para alcance dinámico con `defvar` (variables especiales), que es justo donde Lisp sirve más que Scheme; bash para el alcance dinámico de shell; C y C++ probados.

**`exercises/preexam-solution.tex`**: caso base $n \le 0$, sin `tcolorbox`, sin "Idea clave", Worked Examples fuera del Ejercicio 5. `exercises/README.md` con la ruta `topics/04-semantics/exercises`.

### 05 Runtime systems

**`01-lazy-evaluation`** (15-lazy_execution)
- Hoy: estricto frente a perezoso en Haskell, call-by-need con C, WHNF, fugas de espacio, análisis de estrictez.
- Falta: orden aplicativo y normal, `three infinity`, Church--Rosser, call-by-need, las dos formas de no estrictez, thunks con `delay`/`force`, listas perezosas (`from`, `firstPrime`), grafos y reducción de grafos (`square square 3`).
- Figuras: dos árboles de reducción de `three infinity`; grafo compartido de `square square 3` antes y después.
- Código: Scheme `lazy.scm` (`delay`/`force`, `from`, `firstPrime`, contador que muestra cuántas veces se evalúa un argumento por valor, por nombre y por necesidad); Haskell actual probado con `runghc`.

**`02-runtime-data-representation`** (16-runtime_representation)
- Hoy: boxing, registros, arreglos, variantes, closures, registros de activación, enlaces estáticos y displays.
- Falta: representación del código, tabla de saltos para `case`, almacenamiento estático, pila y heap, representación de sentencias, las dos preguntas de clase sobre listas, objetos y funciones, homoiconicidad.
- Figuras: mapa de memoria de un proceso; tabla de saltos; la lista antes y después de agregar `e0`; objeto con su tabla de métodos.
- Código: Scheme para objetos como closures (las dos instancias de la lista); Common Lisp `defmacro` para homoiconicidad (código que se manipula como lista y luego se evalúa); C para la tabla de saltos.

**`03` a `06`** (intérpretes, IR, máquinas virtuales, recolección de basura): extra. Estilo, una figura por sección (eval/apply, CFG en SSA, pila de la VM durante la traza, montículo marcado en tres colores), código actual probado y el intérprete metacircular pasado a Scheme probado.

### 06 DSL design

- Hoy: qué es un DSL con SQL, Make, regex y un DSL de entrenamiento; definición formal; externos frente a internos; procesamiento; decisiones de sintaxis, gramática, intérprete, tipos, semántica, ejecución, errores, capa de IA, evolución.
- Falta: conectar con los DSL del curso. El de fechas (desde 01), LDBL (desde 01), SCuLPT (desde 2-pls) y Objectilang según los enunciados de los proyectos 1 y 2: objetos, `extends`, genéricos con `+`/`-`, métodos con `method`, `override`, `if-then-else` y `for`.
- Objectilang aparece solo como contexto y en ejercicios que no son tareas del proyecto. No va ninguna gramática EBNF ni Rascal de Objectilang, ni AST, ni chequeador. Los conceptos (varianza, `override`, palabras reservadas frente a identificadores) se explican con los ejemplos de las diapositivas.
- Figuras: pipeline del DSL; jerarquía `Animal/Dog/Puppy` y `Food/DogFood` con la dirección de la varianza de `Transformer[-In, +Out]`.
- Extra: DSL de entrenamiento, capa de IA. Se quedan con estilo nuevo y sin los `fill=blue!10`.
- Se agrega `references.bib`, que este tema no tiene.

## Ejercicios

Al final de cada sección van los ejercicios que aparecen en las diapositivas correspondientes, con solución. Las soluciones largas (autómatas, trazas, derivaciones) van con figura.

## ERRATA.md

Arranca con esto y se va llenando tema por tema:

| Fuente | Dice | Debería decir |
|---|---|---|
| 9-semantic_analysis, diap. 8 | `Exp1.val := make_bin_op("-", ...)` | `Exp1.ptr := make_bin_op("-", ...)` |
| 9-semantic_analysis, diap. 8 | `Factor1 ::= - Factor2` con `make_un_op("+/-", Fact2.ptr)` | nombres consistentes: `Fact1 ::= - Fact2`, `Fact1.ptr := make_un_op("-", Fact2.ptr)` |
| 9-semantic_analysis, diap. 37 | uso `id=E;` busca con `search_block_id` | `search_id`; `search_block_id` es para redeclaraciones |
| `preexam-solution.tex` | caso base de `repeat` con $k = 0$ | $n \le 0$ |
| `exercises/README.md` | `topics/01-operational-semantics/exercises` | `topics/04-semantics/exercises` |

## Orden de trabajo y commits

1. Global: preámbulo, macros, teoremas, bibliografía, `test-code.sh`, README provisional. Commit `global: ...`.
2. Temas 01 a 06, uno por commit (`tema NN: ...`), cada uno con estilo, cobertura, figuras, ejemplos, ejercicios, código probado, compilación limpia y revisión visual.
3. README final y resumen.

No hago push.

## Decisiones tomadas (7 de noviembre)

- Plan aprobado.
- Todo el contenido nuevo sale de las diapositivas y de los enunciados del curso. Lo que ya estaba en el repo y no está en las diapositivas se queda como extra, pero no se le agrega material nuevo de fuera del curso.
- Código simple: Rascal, Scheme y Common Lisp (este último solo donde las diapositivas usan Lisp: `defvar` en alcance dinámico, homoiconicidad). Si una diapositiva trae su ejemplo en Java, C o Python, ese ejemplo va en ese lenguaje. Los listados que ya existían en otros lenguajes se prueban con su herramienta.
- Nada de soluciones a los proyectos, solo ejercicios.
- LETREC va en una sección nueva `02-typing-rules-and-letrec` del tema 03.
- `list_length` de Prolog: no hay `swipl` y no instalo nada. El punto (el error de tipos aparece al ejecutar) se muestra en Scheme y la consulta de Prolog de la diapositiva se cita en la prosa.
- Los archivos de repaso no se copian al repo.
- Tema 05: la homoiconicidad usa el ejemplo de la diapositiva (`setf` y `eval` sobre una lista) en lugar de `defmacro`, que no aparece en las diapositivas.
- Tema 06: la figura de varianza `Transformer[-In, +Out]` ya está en la sección de subtipos del tema 03; el tema 06 la referencia en vez de repetirla. El DSL de entrenamiento (extra) tiene gramática, chequeador y evaluador en Rascal probados, porque su ejemplo original no lo generaba su propia gramática.
