;; <<cond>>
(defun quadrant (ang)
  (cond ((< ang 90)  "cond1")
        ((< ang 180) "cond2")
        ((< ang 270) "cond3")
        ((< ang 360) "cond4")))
;; <<cond.end>>

(defun check (name expected got)
  (format t "~a: expected ~s, got ~s~a~%" name expected got
          (if (equal expected got) "" "  FAIL")))

(check "354" "cond4" (quadrant 354))
(check "45" "cond1" (quadrant 45))
(check "360" nil (quadrant 360))
