;; Dynamic type checking: every value carries its type, and operations check
;; the tags while the program runs. This is the idea of the lecture's
;; list_length example, written in Scheme.

;; <<tagged>>
(define (tagged value type) (cons value type))
(define (value-of v) (car v))
(define (type-of v) (cdr v))

(define (check-type v expected)
  (if (not (eq? (type-of v) expected))
      (error "type error:" (type-of v) 'is-not expected)))

;; list-length checks that its argument is tagged as a list.
(define (list-length v)
  (check-type v 'list)
  (let loop ((l (value-of v)) (n 0))
    (if (null? l)
        (tagged n 'int)
        (loop (cdr l) (+ n 1)))))
;; <<tagged.end>>

;; <<env>>
;; The lecture's type environment example (in OCaml there):
;;   let someval = "hello";;
;;   let otherval = "world" in let someval = 3 in printf "%d %s" someval otherval
(define someval "hello")
(define (inner)
  (let ((otherval "world"))
    (let ((someval 3))                  ; a new someval hides the outer one
      (list someval otherval))))
;; <<env.end>>

;; Tests
(define (check name expected got)
  (display name) (display ": expected ") (write expected)
  (display ", got ") (write got)
  (if (not (equal? expected got)) (display "  FAIL"))
  (newline))

(define (error-message thunk)
  (guard (e ((error-object? e)
             (cons (error-object-message e) (error-object-irritants e))))
    (thunk)
    "no error"))

(check "length of a list" (tagged 4 'int) (list-length (tagged '(a b c d) 'list)))
(check "length of 9" '("type error:" int is-not list)
       (error-message (lambda () (list-length (tagged 9 'int)))))
(check "inner someval" '(3 "world") (inner))
(check "outer someval" "hello" someval)
