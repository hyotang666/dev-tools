(in-package :dev-tools)

(defun listup(package &optional target)
  (do-external-symbols(s package)
    (let((roll(symbol-roll s)))
      (when(or (null target)
	       (eq roll target))
	(format t "~&~%~A~@[ ~A~]"
		(cl-ansi-text:yellow(princ-to-string s))
		(case roll
		  (function
		   (format nil "~:S~%~@[~A~]"
			   (millet:lambda-list s)
			   (documentation s 'function)))
		  (variable
		   (format nil "; = ~A~%~@[~A~]"
			   (if(boundp s)
			     (prin1-to-string(symbol-value s))
			     "; Unbound")
			   (documentation s 'variable)))
		  (type
		    (format nil "; of type ~A~%~@[~A~]"
			    (class-name (class-of (find-class s)))
			    (documentation s 'type)))
		  ((nil) nil))))))
  (values))

(defun symbol-roll(s)
  (cond
    ((and (fboundp s)
	  (not(special-operator-p s)))
     'function)
    ((or (millet:special-symbol-p s)
		       (constantp s))
     'variable)
    ((find-class s nil)
     'type)
    (t nil)))

(defun list-all-packages(symbol)
  (loop :for package :in (cl:list-all-packages)
	:when (eq symbol (find-symbol (symbol-name symbol)package))
	:collect package))
