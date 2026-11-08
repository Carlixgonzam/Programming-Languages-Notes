(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

;; <<three>>
(define (three x) 3)
(define (infinity) (+ (infinity) 1))      ; never returns

;; (three (infinity)) would loop: the argument is evaluated first.
(define (three-lazy x) 3)                 ; receives a promise and never forces it
(define r (three-lazy (delay (infinity))))
;; <<three.end>>
(check "three of a delayed infinity" 3 r)

;; <<modes>>
;; How many times is the argument computed? A counter records it.
(define computed 0)
(define (arg) (set! computed (+ computed 1)) 7)   ; stands for (3+4)

(define (square-value x) (* x x))                 ; call by value: x is a number
(define (square-name x) (* (x) (x)))              ; call by name: x is a thunk
(define (square-need x) (* (force x) (force x)))  ; call by need: x is a promise

(define (count thunk)
  (set! computed 0)
  (let ((v (thunk))) (list v computed)))
;; <<modes.end>>

(check "by value" '(49 1) (count (lambda () (square-value (arg)))))
(check "by name" '(49 2) (count (lambda () (square-name (lambda () (arg))))))
(check "by need" '(49 1) (count (lambda () (square-need (delay (arg))))))

;; <<streams>>
;; A lazy list is a pair whose rest is a promise.
(define-syntax lazy-cons
  (syntax-rules () ((_ a b) (cons a (delay b)))))
(define (lazy-car s) (car s))
(define (lazy-cdr s) (force (cdr s)))

(define (from n) (lazy-cons n (from (+ n 1))))   ; the infinite list n, n+1, ...

(define (take s k)
  (if (= k 0) '() (cons (lazy-car s) (take (lazy-cdr s) (- k 1)))))
;; <<streams.end>>

(check "take 5 (from 1)" '(1 2 3 4 5) (take (from 1) 5))

;; <<prime>>
(define (prime? n)
  (and (> n 1)
       (let loop ((d 2))
         (cond ((> (* d d) n) #t)
               ((= 0 (remainder n d)) #f)
               (else (loop (+ d 1)))))))

(define (first-prime s)
  (if (prime? (lazy-car s)) (lazy-car s) (first-prime (lazy-cdr s))))
;; <<prime.end>>

(check "first prime from 90" 97 (first-prime (from 90)))
(check "first prime from 2" 2 (first-prime (from 2)))
