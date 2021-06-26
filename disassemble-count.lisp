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

(defun disassemble-test (function)
  (with-input-from-string (s (disassemble-lines function))
    (loop :for line = (read-line s nil)
          :while line
          :do (print line)
              (force-output)
              (read-line *query-io*))))

#+sbcl
(defun disassemble-analyze (function)
  (let ((ht (make-hash-table :test #'equal)))
    (with-input-from-string (s (disassemble-lines function))
      (with-fields:do-stream-fields ((op 3))
          s
        (if (gethash op ht)
            (incf (gethash op ht))
            (setf (gethash op ht) 1))))
    (sort (alexandria:hash-table-alist ht) #'> :key #'cdr)))

#+ccl
(defun disassemble-analyze (function)
  (let ((ht (make-hash-table :test #'eq)))
    (with-input-from-string (s (disassemble-lines function))
      (with-fields:dofields ((op 0 :key (lambda (s) (read-from-string s nil))))
          s
        (when (and op (listp op))
          (if (gethash (car op) ht)
              (incf (gethash (car op) ht))
              (setf (gethash (car op) ht) 1)))))
    (sort (alexandria:hash-table-alist ht) #'> :key #'cdr)))

#+clisp
(defun disassemble-analyze (function)
  (let ((ht (make-hash-table :test #'eq)))
    (with-input-from-string (s (disassemble-lines function))
      (with-fields:dofields ((op 1 :key (lambda (s) (read-from-string s nil))))
          s
        (when (and op (listp op))
          (if (gethash (car op) ht)
              (incf (gethash (car op) ht))
              (setf (gethash (car op) ht) 1)))))
    (sort (alexandria:hash-table-alist ht) #'> :key #'cdr)))