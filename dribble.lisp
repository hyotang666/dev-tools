(in-package :dev-tools)

(defmacro with-dribble(filespec &body body)
  `(UNWIND-PROTECT(PROGN (DRIBBLE ,filespec)
			 ,@body)
     (DRIBBLE)))

(defun |#D-reader|(stream &rest args)
  (declare(ignore args))
  (let((form(read stream t t t)))
    `(WITH-DRIBBLE,(dribble-file-name),form)))

(defun dribble-file-name()
  (format nil "~(~A~)-~A"
	  uiop:*implementation-type*
	  (gensym "dribble")))

