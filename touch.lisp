(in-package :dev-tools)

(defun touch (name &optional data)
  (with-open-file (s name :direction :output
                   :if-exists :append
                   :if-does-not-exist :create)
    (if data
        (print data s)
        (truename s))))