(in-package :dev-tools)

(defun disassemble-lines (function) ; separated for easy developping.
  (with-output-to-string (*standard-output*) (disassemble function)))

(defun disassemble-count (function)
  (let ((string (disassemble-lines function)))
    #+(or sbcl clisp)
    (with-input-from-string (s string)
      (loop :for line = (read-line s nil)
            :while line
            :count line :into count
            :finally (return (- count #.(or #+sbcl 2 #+clisp 9)))))
    #+ccl
    (with-input-from-string (s string)
      (loop :for line = (read-line s nil)
            :while line
            :unless (or (string= "" line)
                        (uiop:string-prefix-p ";" line)
                        (not (uiop:string-prefix-p " " line)))
              :count line))))

(defun disassemble< (function1 function2)
  (let ((a (disassemble-count function1)) (b (disassemble-count function2)))
    (values (< a b) (abs (- a b)))))
