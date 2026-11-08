
(define (factorial n)
  (if (< n 2)
      1
      (* n (factorial (- n 1)))))

(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

(check "0!" 1 (factorial 0))
(check "1!" 1 (factorial 1))
(check "5!" 120 (factorial 5))
(check "10!" 3628800 (factorial 10))
