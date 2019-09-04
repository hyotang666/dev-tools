(in-package :dev-tools)

(defun check-license(system)
  (integrate-alist (collect-licenses(asdf:find-system system))
		   #'append
		   :test #'string-equal))

(defun collect-licenses(system)
  (labels((license(system)
	    (list (asdf:system-license system)
		  (asdf:coerce-name system))))
    (mapcar #'license (all-dependencies system))))

(defun all-dependencies(system)
  (labels((rec(systems &optional acc)
	    (if(endp systems)
	      acc ; order is not issue.
	      (body (asdf:find-system(car systems))(cdr systems)acc)))
	  (body(system rest acc)
	    (let((deps(asdf:system-depends-on system)))
	      (rec (if deps
		     (union rest deps :test #'string-equal)
		     rest)
		   (pushnew system acc)))))
    (rec (asdf:system-depends-on (asdf:find-system system)))))

(defun graph<=dependencies(dependencies) ; separated for easy debugging.
  (loop :for system :in dependencies
	:collect(cons (asdf:coerce-name system)
		      (asdf:system-depends-on system))))

(defun dag(&rest names)
  (nreverse(tsort:tsort (graph<=dependencies
			  (loop :for name :in names
				:append (all-dependencies name) :into result
				:finally (return (remove-duplicates
						   result
						   :key #'asdf:coerce-name
						   :test #'string=))))
			:test #'string=
			:group t)))

(defun integrate-alist(alist function &key(test #'eql))
  (labels((rec(alist &optional acc)
	    (if(endp alist)
	      acc ; oder is not issue
	      (body(car alist)(cdr alist)acc)))
	  (body(pair rest acc)
	    (let((target(find (car pair) acc :key #'car :test test)))
	      (rec rest
		   (if target
		     (progn (rplacd target (funcall function (cdr target)(cdr pair)))
			    acc)
		     (push (copy-list pair) acc)))))) ; <--- in order to save original alist.
    (rec alist)))

(defun print-license(alist)
  (dolist(pair alist)
    (format t "~2%~A~%~3T~{~<~%~3T~1,80:;~A~>~^, ~}"
	    (car pair) (cdr pair))))

(defvar *indent* 0)

(defun print-all-dependencies(system)
  (format t "~VT~A~%" *indent* (asdf:coerce-name system))
  (let((*indent* (+ 3 *indent*)))
    (map nil #'print-all-dependencies (asdf:system-depends-on(asdf:find-system system)))))

(defun find-dependency-route(d system)
  (let((seen))
    (labels((rec(d system &optional acc)
	      (if(eq d system)
		(list(revappend acc (list (asdf:coerce-name system))))
		(unless (find system seen)
		  (push system seen)
		  (mapcan (lambda(s)
			    (rec d
				 (asdf:find-system s)
				 (cons (asdf:coerce-name system)
				       acc)))
			  (asdf:system-depends-on system))))))
      (rec (asdf:find-system d)
	   (asdf:find-system system)))))
