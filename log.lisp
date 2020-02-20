(in-package :dev-tools)

(defmacro with-write-log ((path) &body body)
  `(with-open-file (*trace-output* ,path :direction :output
                    :if-does-not-exist :create
                    :if-exists :append)
     ,@body))

(defun log (format-dest format-control &rest args)
  (if (eq t format-dest)
      (uiop:format! *trace-output* "~%;; TRACING: ~?" format-control args)
      (with-write-log (format-dest)
        (uiop:format! *trace-output* "~%;; TRACING: ~?" format-control args))))