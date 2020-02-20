(in-package :dev-tools)

(defmacro with-dribble (filespec &body body)
  `(unwind-protect (progn (dribble ,filespec) ,@body) (dribble)))

(defun |#D-reader| (stream &rest args)
  (declare (ignore args))
  (let ((form (read stream t t t)))
    `(with-dribble ,(dribble-file-name)
       ,form)))

(defun dribble-file-name ()
  (format nil "~(~A~)-~A" uiop:*implementation-type* (gensym "dribble")))