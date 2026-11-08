
(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

(define (m-bool b env)
  (cond ((eq? b 'true) #t)
        ((eq? b 'false) #f)
        ((symbol? b) (cdr (assq b env)))
        ((eq? (car b) 'and) (and (m-bool (cadr b) env) (m-bool (caddr b) env)))
        ((eq? (car b) 'or)  (or  (m-bool (cadr b) env) (m-bool (caddr b) env)))
        ((eq? (car b) 'not) (not (m-bool (cadr b) env)))))

(check "(x && true) || (not y && false)" #t
       (m-bool '(or (and x true) (and (not y) false)) '((x . #t) (y . #f))))

(define (m-digit d) (- (char->integer d) (char->integer #\0)))

(define (m-num digits)
  (let loop ((ds (string->list digits)) (acc 0))
    (if (null? ds) acc (loop (cdr ds) (+ (* acc 10) (m-digit (car ds)))))))

(define (m-e e)
  (if (string? e)
      (m-num e)
      (+ (m-e (cadr e)) (m-e (caddr e)))))

(check "m[123]" 123 (m-num "123"))
(check "m[12 + 30]" 42 (m-e '(+ "12" "30")))

(define (m-infix e)
  (cond ((number? e) e)
        ((eq? (car e) 'paren) (m-infix (cadr e)))
        ((eq? (car e) '+) (+ (m-infix (cadr e)) (m-infix (caddr e))))
        ((eq? (car e) '*) (* (m-infix (cadr e)) (m-infix (caddr e))))))

(check "2 * (3 + 4)" 14 (m-infix '(* 2 (paren (+ 3 4)))))

(define (leaf-int n) (list 'int n))
(define (leaf-var c) (list 'var c))
(define (tree op t1 t2) (list op t1 t2))

(define (m-tree e)
  (cond ((number? e) (leaf-int e))
        ((symbol? e) (leaf-var e))
        (else (tree (car e) (m-tree (cadr e)) (m-tree (caddr e))))))

(define (eval-tree t x)
  (case (car t)
    ((int) (cadr t))
    ((var) x)
    ((+) (+ (eval-tree (cadr t) x) (eval-tree (caddr t) x)))
    ((*) (* (eval-tree (cadr t) x) (eval-tree (caddr t) x)))
    ((^) (expt (eval-tree (cadr t) x) (eval-tree (caddr t) x)))))

(check "tree of x + 2" '(+ (var x) (int 2)) (m-tree '(+ x 2)))

(define (d e)
  (cond ((number? e) (cons (leaf-int e) (leaf-int 0)))
        ((eq? e 'x)  (cons (leaf-var 'x) (leaf-int 1)))
        ((symbol? e) (cons (leaf-var e) (leaf-int 0)))
        ((eq? (car e) '+)
         (let ((a (d (cadr e))) (b (d (caddr e))))
           (cons (tree '+ (car a) (car b)) (tree '+ (cdr a) (cdr b)))))
        ((eq? (car e) '*)
         (let ((a (d (cadr e))) (b (d (caddr e))))
           (cons (tree '* (car a) (car b))
                 (tree '+ (tree '* (cdr a) (car b)) (tree '* (car a) (cdr b))))))
        ((eq? (car e) '^)
         (let ((a (d (cadr e))) (n (caddr e)))
           (cons (tree '^ (car a) (leaf-int n))
                 (tree '* (tree '* (leaf-int n) (tree '^ (car a) (leaf-int (- n 1))))
                       (cdr a)))))))

(define f '(+ (* x x) (* 3 x)))
(check "f(2)" 10 (eval-tree (car (d f)) 2))
(check "f'(2)" 7 (eval-tree (cdr (d f)) 2))
(check "(x^3)' at 2" 12 (eval-tree (cdr (d '(^ x 3))) 2))

(define (rect r i) (list 1 r i))
(define (polar a m) (list 0 a m))
(define (real z) (if (= (car z) 1) (cadr z) (* (caddr z) (cos (cadr z)))))
(define (img z)  (if (= (car z) 1) (caddr z) (* (caddr z) (sin (cadr z)))))
(define (ang z)  (if (= (car z) 0) (cadr z) (atan (caddr z) (cadr z))))
(define (mag z)  (if (= (car z) 0) (caddr z) (sqrt (+ (* (cadr z) (cadr z)) (* (caddr z) (caddr z))))))

(define (m-complex e)
  (cond ((eq? (car e) 'rect) (rect (cadr e) (caddr e)))
        ((eq? (car e) 'polar) (polar (cadr e) (caddr e)))
        ((eq? (car e) '+)
         (let ((z1 (m-complex (cadr e))) (z2 (m-complex (caddr e))))
           (rect (+ (real z1) (real z2)) (+ (img z1) (img z2)))))
        ((eq? (car e) '*)
         (let ((z1 (m-complex (cadr e))) (z2 (m-complex (caddr e))))
           (polar (+ (ang z1) (ang z2)) (* (mag z1) (mag z2)))))))

(check "(1,2) + (3,4)" '(1 4 6) (m-complex '(+ (rect 1 2) (rect 3 4))))
(check "<0,2> * <0,3>" '(0 0 6) (m-complex '(* (polar 0 2) (polar 0 3))))

(define (m-s s)
  (cond ((number? s) s)
        ((eq? (car s) '+) (apply + (m-l (cdr s))))
        ((eq? (car s) '*) (apply * (m-l (cdr s))))))

(define (m-l l)
  (if (null? l) '() (cons (m-s (car l)) (m-l (cdr l)))))

(check "(+ 1 (* 2 3) 4)" 11 (m-s '(+ 1 (* 2 3) 4)))

(define (new-tuple) (make-vector 10 #f))
(define (m-set nums)
  (let ((t (new-tuple)))
    (for-each (lambda (n) (vector-set! t n #t)) nums)
    t))
(define (set-union t1 t2) (vector-map (lambda (a b) (or a b)) t1 t2))
(define (set-inter t1 t2) (vector-map (lambda (a b) (and a b)) t1 t2))
(define (set-compl t) (vector-map not t))

(check "{1,3}" #(#f #t #f #t #f #f #f #f #f #f) (m-set '(1 3)))
(check "{1,3} union {3,4}" (m-set '(1 3 4)) (set-union (m-set '(1 3)) (m-set '(3 4))))
(check "{1,3} inter {3,4}" (m-set '(3)) (set-inter (m-set '(1 3)) (m-set '(3 4))))
(check "complement of {}" (m-set '(0 1 2 3 4 5 6 7 8 9)) (set-compl (m-set '())))

(define (lookup mem var) (let ((p (assq var mem))) (if p (cdr p) 0)))

(define (m-exp e mem)
  (cond ((number? e) e)
        ((symbol? e) (lookup mem e))
        ((eq? (car e) '+) (+ (m-exp (cadr e) mem) (m-exp (caddr e) mem)))
        ((eq? (car e) '*) (* (m-exp (cadr e) mem) (m-exp (caddr e) mem)))))

(define (assign as mem)
  (if (null? as)
      mem
      (let* ((a (car as)) (var (cadr a)) (e (caddr a)))
        (assign (cdr as) (cons (cons var (m-exp e mem)) mem)))))

(define (m-program p) (assign (cdr p) '()))

(define prog '(begin (:= x 3) (:= y (+ x 4)) (:= x (* x y))))
(check "x after the program" 21 (lookup (m-program prog) 'x))
(check "y after the program" 7 (lookup (m-program prog) 'y))

(define (emit code . instruction)
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

(check "code for x := 3" '((push 3) (asg x)) (m-code '(begin (:= x 3))))
(check "code for y := x + 4" '((get x) (push 4) (plus) (asg y)) (m-code '(begin (:= y (+ x 4)))))
(check "running the code gives the same x" 21 (lookup (run (m-code prog)) 'x))
