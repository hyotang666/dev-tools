(in-package :dev-tools)

(defun load (system &rest args)
  (apply #'call-with-silent #'asdf:load-system system args))

(defun call-with-silent (fun &rest args)
  (let ((*compile-print* nil)
        (*compile-verbose* t)
        (*load-verbose* nil)
        (*load-print* nil))
    (apply fun args)))