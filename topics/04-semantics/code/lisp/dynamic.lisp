(defun check (name expected got)
  (format t "~a: expected ~s, got ~s~a~%" name expected got
          (if (equal expected got) "" "  FAIL")))

;; <<dynamic>>
(defvar *x* 10)               ; defvar makes *x* special: dynamically scoped

(defun f () *x*)

(defun g ()
  (let ((*x* 20))             ; binds *x* for g and everything g calls
    (f)))
;; <<dynamic.end>>

(check "f from g, dynamic" 20 (g))
(check "f alone" 10 (f))

;; <<lexical>>
(let ((y 10))                 ; y is lexical: a closure over this binding
  (defun f-lex () y))

(defun g-lex ()
  (let ((y 20))
    (declare (ignorable y))
    (f-lex)))
;; <<lexical.end>>

(check "f-lex from g-lex, lexical" 10 (g-lex))

;; <<logo>>
;; The Logo example: make "x "foo  /  to test1 :x  test2 end  /  to test2 print :x end
(defvar *lx* "foo")
(defun test2 () *lx*)
(defun test1 (*lx*) (test2))  ; the parameter binds the special variable
;; <<logo.end>>

(check "test2 alone" "foo" (test2))
(check "test2 from test1" "bar" (test1 "bar"))
