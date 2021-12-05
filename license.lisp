(in-package :dev-tools)

(defun check-license (system)
  (integrate-alist (collect-licenses (asdf:find-system system)) #'append
                   :test #'string-equal))

(defun collect-licenses (system)
  (labels ((license (system)
             (list (ignore-errors (asdf:system-license system))
                   (asdf:coerce-name system))))
    (mapcar #'license (all-dependencies system))))

(defun ensure-system (spec)
  (etypecase spec
    (asdf:system spec)
    ((or symbol string) (asdf:find-system spec))
    ((cons (eql :feature))
     (when (uiop:featurep (cadr spec))
       (let ((spec (caddr spec)))
         (etypecase spec
           (string (asdf:find-system spec))
           ((cons (eql :require)) (asdf:find-system (cadr spec)))))))))

(defun all-dependencies (&rest systems)
  (labels ((rec (systems &optional acc)
             (if (endp systems)
                 ;; Order is not the issue.
                 (remove-duplicates acc
                                    :test #'equal
                                    :key #'asdf:primary-system-name)
                 (multiple-value-call #'body (find-system systems) acc)))
           (find-system (systems)
             (loop :for (name . rest) :on systems
                   :for system = (ensure-system name)
                   :when system
                     :return (values system rest)))
           (body (system rest acc)
             (let ((deps (asdf:system-depends-on system)))
               (rec
                 (if deps
                     (union rest deps :test #'equalp)
                     rest)
                 (pushnew system acc)))))
    (rec
      (alexandria:mappend
        (alexandria:compose #'asdf:system-depends-on #'asdf:find-system)
        systems))))

(defun graph<=dependencies (dependencies) ; separated for easy debugging.
  (loop :for system :in dependencies
        :collect (cons (asdf:coerce-name (ensure-system system))
                       (mapcan
			 (lambda (x)
			   (let ((s (ensure-system x)))
			     (when s
			       (list (asdf:coerce-name s)))))
                         (asdf:system-depends-on system)))))

(defun dag (&rest names)
  (nreverse
    (tsort:tsort
      (graph<=dependencies
        (loop :for name :in names
              :append (all-dependencies name) :into result
              :finally (return
                        (remove-duplicates result
                                           :key #'asdf:coerce-name
                                           :test #'string=))))
      :test #'string=
      :group t)))

(defun integrate-alist (alist function &key (test #'eql))
  (labels ((rec (alist &optional acc)
             (if (endp alist)
                 acc ; oder is not issue
                 (body (car alist) (cdr alist) acc)))
           (body (pair rest acc)
             (let ((target (find (car pair) acc :key #'car :test test)))
               (rec rest
                    (if target
                        (progn
                         (rplacd target
                                 (funcall function (cdr target) (cdr pair)))
                         acc)
                        (push (copy-list pair) acc)))))) ; <--- in order to
                                                         ; save original alist.
    (rec alist)))

(defun print-license (alist)
  (dolist (pair alist)
    (format t "~2%~A~%~3T~{~<~%~3T~1,80:;~A~>~^, ~}" (car pair) (cdr pair))))

(defvar *indent* 0)

(defun print-all-dependencies (system)
  (format t "~VT~A~%" *indent* (asdf:coerce-name (ensure-system system)))
  (let ((*indent* (+ 3 *indent*)))
    (map nil #'print-all-dependencies
         (asdf:system-depends-on (ensure-system system)))))

(defun find-dependency-route (d system)
  (let ((seen))
    (labels ((rec (d system &optional acc)
               (if (eq d system)
                   (list (revappend acc (list (asdf:coerce-name system))))
                   (unless (find system seen)
                     (push system seen)
                     (mapcan
                       (lambda (s)
                         (rec d (ensure-system s)
                              (cons (asdf:coerce-name system) acc)))
                       (asdf:system-depends-on system))))))
      (rec (ensure-system d) (ensure-system system)))))
