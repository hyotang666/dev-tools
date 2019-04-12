(in-package :dev-tools)

(defmacro with-debug((number)&body body)
  `(LOCALLY(DECLARE(OPTIMIZE(DEBUG,(the (integer 1 3)number))))
     ,@body))
  

(defun |#L-reader|(stream character &optional number)
  (declare(ignore character))
  `(WITH-DEBUG(,(or number 3)),(read stream t t t)))
