(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

(define (f return)
  (return 2)
  3)

(define a (call-with-current-continuation f))
(define b (f (lambda (x) x)))

(check "call/cc" 2 a)
(check "identity" 3 b)

(define (search key files)
  (call-with-current-continuation
    (lambda (found)
      (for-each (lambda (file)
                  (for-each (lambda (line)
                              (if (equal? line key) (found line)))
                            file))
                files)
      "not found")))

(check "found" "b" (search "b" '(("a" "x") ("y" "b" "c"))))
(check "not found" "not found" (search "z" '(("a") ("b"))))

(define (fact n)
  (if (= n 0) 1 (* n (fact (- n 1)))))

(define (fact-cps n k)
  (if (= n 0)
      (k 1)
      (fact-cps (- n 1) (lambda (v) (k (* n v))))))

(check "fact 5" 120 (fact 5))
(check "fact-cps 5" 120 (fact-cps 5 (lambda (v) v)))

(define (gcd a b)
  (cond ((= a b) a)
        ((> a b) (gcd (- a b) b))
        (else (gcd a (- b a)))))

(check "gcd 12 18" 6 (gcd 12 18))
(check "gcd in a long loop" 1 (gcd 1000000 1))
