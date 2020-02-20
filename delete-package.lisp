(in-package :dev-tools)

(defun delete-package (package)
  (setf package (find-package package))
  (let ((dependencies (package-used-by-list package)))
    (when dependencies
      (mapc #'delete-package dependencies))
    (when (eq package *package*)
      (warn "To delete current package, into cl-user package.")
      (in-package :cl-user))
    (cl:delete-package (print package))))

(defun package-used-by-list (package)
  (setf package (find-package package))
  (when (package-name package)
    (loop :for p :in (remove package (cl:list-all-packages) :test #'eq)
          :when (loop :for symbol :being :each :symbol :in p
                      :thereis (eq package (symbol-package symbol)))
            :collect p :into p*
          :finally (return (union p* (cl:package-used-by-list package))))))