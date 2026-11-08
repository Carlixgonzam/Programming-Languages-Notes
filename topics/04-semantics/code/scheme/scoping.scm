(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

;; <<let>>
(define res
  (let ((x 3)
        (y 4))
    (+ (let ((x (+ y 5)))     ; inner x = 9, y = 4
         (* x y))             ; 36
       x)))                   ; outer x = 3
;; <<let.end>>
(check "nested let" 39 res)

;; <<lexical>>
(define x 10)
(define (f) x)                ; the x of f is the global x
(define (g)
  (let ((x 20))               ; a local x in g
    (f)))
;; <<lexical.end>>
(check "lexical f from g" 10 (g))

;; <<closure>>
(define (make-counter)
  (let ((count 0))            ; lives as long as the closure
    (lambda ()
      (set! count (+ count 1))
      count)))
;; <<closure.end>>
(define c1 (make-counter))
(define c2 (make-counter))
(c1) (c1)
(check "closure keeps its count" 3 (c1))
(check "another closure" 1 (c2))

;; <<byname>>
;; Call by name: each parameter is a pair of thunks that read and write the
;; argument expression in the caller's environment.
(define (swap-by-name get-x set-x! get-y set-y!)
  (let ((t (get-x)))
    (set-x! (get-y))
    (set-y! t)))

(define (main-by-name)
  (let ((x 1) (y (+ 2 8)))
    (swap-by-name (lambda () x) (lambda (v) (set! x v))      ; the name x
                  (lambda () y) (lambda (v) (set! y v)))     ; the name y
    (list x y)))
;; <<byname.end>>
(check "swap by name" '(10 1) (main-by-name))
