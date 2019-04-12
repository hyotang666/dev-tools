(in-package :dev-tools)

(defun listup(package)
  (do-external-symbols(s package)
    (format t "~&~%~A~@[ ~A~]"
	    (cl-ansi-text:yellow(princ-to-string s))
	    (cond
	      ((and (fboundp s)
		    (not(special-operator-p s)))
	       (format nil "~:S~%~@[~A~]"
		       (millet:lambda-list s)
		       (documentation s 'function)))
	      ((or (millet:special-symbol-p s)
		   (constantp s))
	       (format nil "~A~%~@[~A~]"
		       (if(boundp s)
			 (prin1-to-string(symbol-value s))
			 "; Unbound")
		       (documentation s 'variable)))
	      (t (let((class(find-class s nil)))
		   (when class
		     (format nil "; of type ~A~%~@[~A~]"
			     (class-name (class-of class))
			     (documentation s 'type))))))))
  (values))

(defun list-all-packages(symbol)
  (loop :for package :in (cl:list-all-packages)
	:when (eq symbol (find-symbol (symbol-name symbol)package))
	:collect package))
