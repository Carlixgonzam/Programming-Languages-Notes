(list 1 2 (list 3 4))
(* 2 (+ 3 4))
'(* 2 (+ 3 4))

(defvar expression (list '* (list 'sin 1.1) (list 'cos 2.03)))
(third expression)
(setf (first (third expression)) 'sin)
(eval expression)
(prin1-to-string expression)

(defun check (name expected got)
  (format t "~a: expected ~s, got ~s~a~%" name expected got
          (if (equal expected got) "" "  FAIL")))

(check "data" '(1 2 (3 4)) (list 1 2 (list 3 4)))
(check "code" 14 (* 2 (+ 3 4)))
(check "quoted code" 3 (length '(* 2 (+ 3 4))))
(check "eval quoted" 14 (eval '(* 2 (+ 3 4))))
(check "third" '(sin 2.03) (third expression))
(check "changed" "(* (SIN 1.1) (SIN 2.03))" (prin1-to-string expression))
(check "eval" "0.79888" (format nil "~,5f" (eval expression)))

(defvar e (list '+ 1 (list '* 2 3)))
(check "before" 7 (eval e))
(setf (first (third e)) '+)
(check "after" 6 (eval e))
