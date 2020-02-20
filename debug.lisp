(in-package :dev-tools)

(defmacro with-debug ((number) &body body)
  `(locally (declare (optimize (debug ,(the (integer 1 3) number)))) ,@body))

(defun |#L-reader| (stream character &optional number)
  (declare (ignore character))
  `(with-debug (,(or number 3))
     ,(read stream t t t)))