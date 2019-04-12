(in-package :dev-tools)

(defmacro average ((&optional(n 1))&body body)
  `(LOOP :REPEAT ,(+ n 2)
	 :COLLECT (TIMES(WITH-OUTPUT-TO-STRING(*TRACE-OUTPUT*)
			  (TIME (PROGN ,@body))))
	 :INTO ACC
	 :FINALLY (RETURN(%AVERAGE ACC ,n))))

(defun %average(list n)
  (let*((sorted(sort list #'<))
	(min(car sorted)))
    (labels((rec(list count acc mid)
	      (if(endp(cdr list))
		`(:MIN ,min :MAX ,(car list) :MID ,mid :AVERAGE ,(float(/ acc n)))
		(rec (cdr list)
		     (1- count)
		     (+(car list)acc)
		     (if(zerop count)
		       (car list)
		       mid)))))
      (rec(cdr sorted)(truncate n 2)0(cadr sorted)))))

(defun times (time-string)
  #.(or ; in order to avoid #-.
      #+(or clisp sbcl ecl)
      `(read-from-string time-string nil nil :start (1+(position #\: time-string)))
      #+ccl
      `(let((position(nth-value 1(read-from-string time-string))))
	(read-from-string time-string nil nil :start (1+(position #\( time-string :start position))))
      ;; as default.
      (progn ; do when read.
	#0=(warn "~S does not support ~S"'average uiop:*implementation-type*)
	;; embeded code.
	(cons 'error (cdr #0#)))))

(defun |#V-reader| (stream c time)
  (declare(ignore c))
  `(AVERAGE(,(or time 1))
     ,(read stream t t t)))
