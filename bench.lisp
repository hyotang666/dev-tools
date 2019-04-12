(in-package :dev-tools)

(defmacro bench((&optional(n 1))&body body)
  `(TIME(DOTIMES(#:X ,n),@body)))

(defun |#B-reader|(stream c time)
  ;; Implementation dependent: Some implementation call dispatch macro function
  ;; with specific NIL for TIME, we can not use &optional(time 1).
  (declare(ignore c))
  `(BENCH(,(or time 1)),(read stream t nil t)))

