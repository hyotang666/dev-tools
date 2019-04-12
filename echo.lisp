(in-package :dev-tools)

(defun |#E-reader|(stream &rest args)
  (declare(ignore args))
  `(PRINT,(read stream t t t)))
