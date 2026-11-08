(defun check (name expected got)
  (format t "~a: expected ~s, got ~s~a~%" name expected got
          (if (equal expected got) "" "  FAIL")))

(defvar *x* 10)

(defun f () *x*)

(defun g ()
  (let ((*x* 20))
    (f)))

(check "f from g, dynamic" 20 (g))
(check "f alone" 10 (f))

(let ((y 10))
  (defun f-lex () y))

(defun g-lex ()
  (let ((y 20))
    (declare (ignorable y))
    (f-lex)))

(check "f-lex from g-lex, lexical" 10 (g-lex))

(defvar *lx* "foo")
(defun test2 () *lx*)
(defun test1 (*lx*) (test2))

(check "test2 alone" "foo" (test2))
(check "test2 from test1" "bar" (test1 "bar"))
