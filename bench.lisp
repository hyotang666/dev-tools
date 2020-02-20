(in-package :dev-tools)

(defmacro bench ((&optional (n 1)) &body body)
  `(time (dotimes (#:x ,n) ,@body)))

(defun |#B-reader| (stream c time)
  ;; Implementation dependent: Some implementation call dispatch macro function
  ;; with specific NIL for TIME, we can not use &optional(time 1).
  (declare (ignore c))
  `(bench (,(or time 1))
     ,(read stream t nil t)))