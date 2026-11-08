(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

(define (three x) 3)
(define (infinity) (+ (infinity) 1))

(define (three-lazy x) 3)
(define r (three-lazy (delay (infinity))))
(check "three of a delayed infinity" 3 r)

(define computed 0)
(define (arg) (set! computed (+ computed 1)) 7)

(define (square-value x) (* x x))
(define (square-name x) (* (x) (x)))
(define (square-need x) (* (force x) (force x)))

(define (count thunk)
  (set! computed 0)
  (let ((v (thunk))) (list v computed)))

(check "by value" '(49 1) (count (lambda () (square-value (arg)))))
(check "by name" '(49 2) (count (lambda () (square-name (lambda () (arg))))))
(check "by need" '(49 1) (count (lambda () (square-need (delay (arg))))))

(define-syntax lazy-cons
  (syntax-rules () ((_ a b) (cons a (delay b)))))
(define (lazy-car s) (car s))
(define (lazy-cdr s) (force (cdr s)))

(define (from n) (lazy-cons n (from (+ n 1))))

(define (take s k)
  (if (= k 0) '() (cons (lazy-car s) (take (lazy-cdr s) (- k 1)))))

(check "take 5 (from 1)" '(1 2 3 4 5) (take (from 1) 5))

(define (prime? n)
  (and (> n 1)
       (let loop ((d 2))
         (cond ((> (* d d) n) #t)
               ((= 0 (remainder n d)) #f)
               (else (loop (+ d 1)))))))

(define (first-prime s)
  (if (prime? (lazy-car s)) (lazy-car s) (first-prime (lazy-cdr s))))

(check "first prime from 90" 97 (first-prime (from 90)))
(check "first prime from 2" 2 (first-prime (from 2)))
