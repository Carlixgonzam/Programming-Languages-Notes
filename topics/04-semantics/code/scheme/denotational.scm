;; Denotational semantics as Scheme functions. Each semantic function maps
;; an abstract syntax tree, written as an S-expression, to its meaning.

(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

;; <<booleans>>
;; The language of booleans: (and B B), (or B B), (not B), true, false, x.
;; The meaning is a function from an environment to a Scheme boolean.
(define (m-bool b env)
  (cond ((eq? b 'true) #t)
        ((eq? b 'false) #f)
        ((symbol? b) (cdr (assq b env)))
        ((eq? (car b) 'and) (and (m-bool (cadr b) env) (m-bool (caddr b) env)))
        ((eq? (car b) 'or)  (or  (m-bool (cadr b) env) (m-bool (caddr b) env)))
        ((eq? (car b) 'not) (not (m-bool (cadr b) env)))))
;; <<booleans.end>>

(check "(x && true) || (not y && false)" #t
       (m-bool '(or (and x true) (and (not y) false)) '((x . #t) (y . #f))))

;; <<numbers>>
;; E ::= E + E | (0..9)+   with numbers written as strings of digits.
(define (m-digit d) (- (char->integer d) (char->integer #\0)))   ; m[0] = 0, ..., m[9] = 9

(define (m-num digits)                     ; m[N D] = m[N] * 10 + m[D]
  (let loop ((ds (string->list digits)) (acc 0))
    (if (null? ds) acc (loop (cdr ds) (+ (* acc 10) (m-digit (car ds)))))))

(define (m-e e)
  (if (string? e)
      (m-num e)
      (+ (m-e (cadr e)) (m-e (caddr e)))))   ; m[E1 + E2] = m[E1] + m[E2]
;; <<numbers.end>>

(check "m[123]" 123 (m-num "123"))
(check "m[12 + 30]" 42 (m-e '(+ "12" "30")))

;; <<infix>>
;; E ::= E + T | T,  T ::= T * F | F,  F ::= num | ( E )
(define (m-infix e)
  (cond ((number? e) e)                               ; m[num] = num.val
        ((eq? (car e) 'paren) (m-infix (cadr e)))     ; m[(E)] = m[E]
        ((eq? (car e) '+) (+ (m-infix (cadr e)) (m-infix (caddr e))))
        ((eq? (car e) '*) (* (m-infix (cadr e)) (m-infix (caddr e))))))
;; <<infix.end>>

(check "2 * (3 + 4)" 14 (m-infix '(* 2 (paren (+ 3 4)))))

;; <<trees>>
;; Expression trees with variables: the meaning of an expression is a tree.
(define (leaf-int n) (list 'int n))
(define (leaf-var c) (list 'var c))
(define (tree op t1 t2) (list op t1 t2))

(define (m-tree e)
  (cond ((number? e) (leaf-int e))
        ((symbol? e) (leaf-var e))
        (else (tree (car e) (m-tree (cadr e)) (m-tree (caddr e))))))

;; Evaluate a tree, to test the derivatives below.
(define (eval-tree t x)
  (case (car t)
    ((int) (cadr t))
    ((var) x)
    ((+) (+ (eval-tree (cadr t) x) (eval-tree (caddr t) x)))
    ((*) (* (eval-tree (cadr t) x) (eval-tree (caddr t) x)))
    ((^) (expt (eval-tree (cadr t) x) (eval-tree (caddr t) x)))))
;; <<trees.end>>

(check "tree of x + 2" '(+ (var x) (int 2)) (m-tree '(+ x 2)))

;; <<derivative>>
;; The meaning of an expression is the pair <tree, derivative tree> with
;; respect to x.
(define (d e)
  (cond ((number? e) (cons (leaf-int e) (leaf-int 0)))
        ((eq? e 'x)  (cons (leaf-var 'x) (leaf-int 1)))
        ((symbol? e) (cons (leaf-var e) (leaf-int 0)))
        ((eq? (car e) '+)                       ; sum rule
         (let ((a (d (cadr e))) (b (d (caddr e))))
           (cons (tree '+ (car a) (car b)) (tree '+ (cdr a) (cdr b)))))
        ((eq? (car e) '*)                       ; product rule
         (let ((a (d (cadr e))) (b (d (caddr e))))
           (cons (tree '* (car a) (car b))
                 (tree '+ (tree '* (cdr a) (car b)) (tree '* (car a) (cdr b))))))
        ((eq? (car e) '^)                       ; power rule, n a number
         (let ((a (d (cadr e))) (n (caddr e)))
           (cons (tree '^ (car a) (leaf-int n))
                 (tree '* (tree '* (leaf-int n) (tree '^ (car a) (leaf-int (- n 1))))
                       (cdr a)))))))
;; <<derivative.end>>

;; f(x) = x * x + 3x, f'(x) = 2x + 3, at x = 2: f = 10, f' = 7
(define f '(+ (* x x) (* 3 x)))
(check "f(2)" 10 (eval-tree (car (d f)) 2))
(check "f'(2)" 7 (eval-tree (cdr (d f)) 2))
(check "(x^3)' at 2" 12 (eval-tree (cdr (d '(^ x 3))) 2))

;; <<complex>>
;; Complex numbers as triples (T V1 V2): T = 1 rectangular (real, img),
;; T = 0 polar (angle, magnitude).
(define (rect r i) (list 1 r i))
(define (polar a m) (list 0 a m))
(define (real z) (if (= (car z) 1) (cadr z) (* (caddr z) (cos (cadr z)))))
(define (img z)  (if (= (car z) 1) (caddr z) (* (caddr z) (sin (cadr z)))))
(define (ang z)  (if (= (car z) 0) (cadr z) (atan (caddr z) (cadr z))))
(define (mag z)  (if (= (car z) 0) (caddr z) (sqrt (+ (* (cadr z) (cadr z)) (* (caddr z) (caddr z))))))

(define (m-complex e)
  (cond ((eq? (car e) 'rect) (rect (cadr e) (caddr e)))
        ((eq? (car e) 'polar) (polar (cadr e) (caddr e)))
        ((eq? (car e) '+)                       ; add parts, in rectangular form
         (let ((z1 (m-complex (cadr e))) (z2 (m-complex (caddr e))))
           (rect (+ (real z1) (real z2)) (+ (img z1) (img z2)))))
        ((eq? (car e) '*)                       ; add angles, multiply magnitudes
         (let ((z1 (m-complex (cadr e))) (z2 (m-complex (caddr e))))
           (polar (+ (ang z1) (ang z2)) (* (mag z1) (mag z2)))))))
;; <<complex.end>>

(check "(1,2) + (3,4)" '(1 4 6) (m-complex '(+ (rect 1 2) (rect 3 4))))
(check "<0,2> * <0,3>" '(0 0 6) (m-complex '(* (polar 0 2) (polar 0 3))))

;; <<sexp>>
;; S ::= (+ L) | (* L) | num,  L ::= S | L S
(define (m-s s)
  (cond ((number? s) s)                               ; m[num] = num.val
        ((eq? (car s) '+) (apply + (m-l (cdr s))))    ; apply(+, m[L])
        ((eq? (car s) '*) (apply * (m-l (cdr s))))))  ; apply(*, m[L])

(define (m-l l)                                       ; the list of meanings
  (if (null? l) '() (cons (m-s (car l)) (m-l (cdr l)))))
;; <<sexp.end>>

(check "(+ 1 (* 2 3) 4)" 11 (m-s '(+ 1 (* 2 3) 4)))

;; <<sets>>
;; Sets of digits as 10-tuples of booleans.
(define (new-tuple) (make-vector 10 #f))
(define (m-set nums)                       ; m[{n1, ..., nk}]
  (let ((t (new-tuple)))
    (for-each (lambda (n) (vector-set! t n #t)) nums)
    t))
(define (set-union t1 t2) (vector-map (lambda (a b) (or a b)) t1 t2))
(define (set-inter t1 t2) (vector-map (lambda (a b) (and a b)) t1 t2))
(define (set-compl t) (vector-map not t))
;; <<sets.end>>

(check "{1,3}" #(#f #t #f #t #f #f #f #f #f #f) (m-set '(1 3)))
(check "{1,3} union {3,4}" (m-set '(1 3 4)) (set-union (m-set '(1 3)) (m-set '(3 4))))
(check "{1,3} inter {3,4}" (m-set '(3)) (set-inter (m-set '(1 3)) (m-set '(3 4))))
(check "complement of {}" (m-set '(0 1 2 3 4 5 6 7 8 9)) (set-compl (m-set '())))

;; <<assign>>
;; P ::= begin As end,  As ::= As ; A | A,  A ::= var := E
;; E ::= E + T | T,  T ::= T * F | F,  F ::= num | var
;; The meaning of a program is the memory after the assignments, as an
;; association list; an undefined variable is 0.
(define (lookup mem var) (let ((p (assq var mem))) (if p (cdr p) 0)))

(define (m-exp e mem)
  (cond ((number? e) e)
        ((symbol? e) (lookup mem e))
        ((eq? (car e) '+) (+ (m-exp (cadr e) mem) (m-exp (caddr e) mem)))
        ((eq? (car e) '*) (* (m-exp (cadr e) mem) (m-exp (caddr e) mem)))))

(define (assign as mem)                   ; assign[As ; A] MEM
  (if (null? as)
      mem
      (let* ((a (car as)) (var (cadr a)) (e (caddr a)))
        (assign (cdr as) (cons (cons var (m-exp e mem)) mem)))))

(define (m-program p) (assign (cdr p) '()))   ; m[begin As end] = assign[As] []
;; <<assign.end>>

(define prog '(begin (:= x 3) (:= y (+ x 4)) (:= x (* x y))))
(check "x after the program" 21 (lookup (m-program prog) 'x))
(check "y after the program" 7 (lookup (m-program prog) 'y))

;; <<compile>>
;; The same programs translated to code for a stack machine.
(define (emit code . instruction)          ; code.add(instruction)
  (append code (list instruction)))

(define (m-code-exp e code)
  (cond ((number? e) (emit code 'push e))
        ((symbol? e) (emit code 'get e))
        ((eq? (car e) '+)
         (emit (m-code-exp (caddr e) (m-code-exp (cadr e) code)) 'plus))
        ((eq? (car e) '*)
         (emit (m-code-exp (caddr e) (m-code-exp (cadr e) code)) 'times))))

(define (m-code p)
  (let loop ((as (cdr p)) (code '()))
    (if (null? as)
        code
        (let ((a (car as)))
          (loop (cdr as)
                (emit (m-code-exp (caddr a) code) 'asg (cadr a)))))))

;; The machine: a stack and a memory.
(define (run code)
  (let loop ((code code) (stack '()) (mem '()))
    (if (null? code)
        mem
        (let* ((i (car code)) (rest (cdr code)))
          (case (car i)
            ((push) (loop rest (cons (cadr i) stack) mem))
            ((get) (loop rest (cons (lookup mem (cadr i)) stack) mem))
            ((plus) (loop rest (cons (+ (car stack) (cadr stack)) (cddr stack)) mem))
            ((times) (loop rest (cons (* (car stack) (cadr stack)) (cddr stack)) mem))
            ((asg) (loop rest (cdr stack)
                         (cons (cons (cadr i) (car stack)) mem))))))))
;; <<compile.end>>

(check "code for x := 3" '((push 3) (asg x)) (m-code '(begin (:= x 3))))
(check "code for y := x + 4" '((get x) (push 4) (plus) (asg y)) (m-code '(begin (:= y (+ x 4)))))
(check "running the code gives the same x" 21 (lookup (run (m-code prog)) 'x))
