(in-package :dev-tools)

(defun |#E-reader| (stream &rest args)
  (declare (ignore args))
  `(print ,(read stream t t t)))