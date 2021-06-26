(in-package :dev-tools)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro with-verbose-setting ((verbose supplied-p) &body body)
    (let ((c (gensym "CONDITION")))
      `(let ((*load-verbose*
              (verbose-setting :load-verbose ,verbose ,supplied-p))
             (*compile-verbose*
              (verbose-setting :compile-verbose ,verbose ,supplied-p))
             (*load-print* (verbose-setting :load-print ,verbose ,supplied-p))
             (*compile-print*
              (verbose-setting :compile-print ,verbose ,supplied-p)))
         (handler-bind ((warning
                         (lambda (,c)
                           (unless (verbose-setting :warning ,verbose
                                                    ,supplied-p)
                             (muffle-warning ,c)))))
           ,@body)))))

(defun verbose-setting (type verbose supplied-p)
  (if (not supplied-p) ; verbose is nil as initial value, so...
      (ecase type ; use implementation dependent default value.
        (:load-verbose *load-verbose*)
        (:compile-verbose *compile-verbose*)
        (:load-print *load-print*)
        (:compile-print *compile-print*)
        (:warning t))
      (etypecase verbose
        (boolean verbose)
        (list (find type verbose :test #'eq)))))

(defun update
       (&optional (name (find-symbol (package-name *package*)))
        (verbose nil supplied-p)
        &aux (name (or name (string-downcase (package-name *package*)))))
  (declare (ignorable supplied-p))
  #.(or ; in order to avoid #-. #+(and :remora :thread-support)
        ; '(remora::load-system* name :verbose verbose) #+remora
        ; '(remora:load-system name :verbose verbose)
        ;; as default below.
        `(with-verbose-setting (verbose supplied-p)
           #+sbcl
           (trivial-formatter:fmt name :supersede)
           (asdf:load-system name))))