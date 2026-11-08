(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

;; <<meval>>
;; Expressions: numbers, symbols, (if c t e), (lambda (x ...) body), (f a ...)
;; Environments: lists of (name . value) pairs.
(define (m-eval expr env)
  (cond ((number? expr) expr)
        ((symbol? expr) (cdr (assq expr env)))
        ((eq? (car expr) 'if)
         (if (m-eval (cadr expr) env)
             (m-eval (caddr expr) env)
             (m-eval (cadddr expr) env)))
        ((eq? (car expr) 'lambda)
         (list 'closure (cadr expr) (caddr expr) env))
        (else
         (m-apply (m-eval (car expr) env)
                  (map (lambda (a) (m-eval a env)) (cdr expr))))))

(define (m-apply f args)
  (if (procedure? f)
      (apply f args)                          ; primitive
      (let ((params (cadr f)) (body (caddr f)) (env (cadddr f)))
        (m-eval body (append (map cons params args) env)))))
;; <<meval.end>>

;; <<globals>>
(define global-env
  (list (cons '+ +) (cons '* *) (cons '- -) (cons '< <)))
;; <<globals.end>>

(check "number" 3 (m-eval 3 global-env))
(check "sum" 7 (m-eval '(+ 3 4) global-env))
(check "if" 1 (m-eval '(if (< 1 2) 1 2) global-env))
(check "lambda" 25 (m-eval '((lambda (x) (* x x)) 5) global-env))
(check "closure keeps its env" 8
       (m-eval '(((lambda (n) (lambda (x) (+ x n))) 5) 3) global-env))
(check "lexical scope" 10
       (m-eval '((lambda (x) ((lambda (f) ((lambda (x) (f 0)) 99))
                              (lambda (y) (+ x y)))) 10)
               global-env))
