(in-package :dev-tools)

(eval-when(:compile-toplevel :load-toplevel :execute)
  (defmacro with-verbose-setting((verbose supplied-p)&body body)
    (let((c(gensym"CONDITION")))
      `(LET((*LOAD-VERBOSE*(VERBOSE-SETTING :LOAD-VERBOSE ,verbose ,supplied-p))
	    (*COMPILE-VERBOSE*(VERBOSE-SETTING :COMPILE-VERBOSE ,verbose ,supplied-p))
	    (*LOAD-PRINT*(VERBOSE-SETTING :LOAD-PRINT ,verbose ,supplied-p))
	    (*COMPILE-PRINT*(VERBOSE-SETTING :COMPILE-PRINT ,verbose ,supplied-p)))
	 (HANDLER-BIND((WARNING(LAMBDA(,c)
				 (UNLESS(VERBOSE-SETTING :WARNING ,verbose ,supplied-p)
				   (MUFFLE-WARNING ,c)))))
	   ,@body)))))

(defun verbose-setting(type verbose supplied-p)
  (if(not supplied-p) ; verbose is nil as initial value, so...
    (ecase type ; use implementation dependent default value.
      (:load-verbose *load-verbose*)
      (:compile-verbose *compile-verbose*)
      (:load-print *load-print*)
      (:compile-print *compile-print*)
      (:warning T))
    (etypecase verbose
      (boolean verbose)
      (list (find type verbose :test #'eq)))))

(defun update(&optional(name(find-symbol(package-name *package*)))
	       (verbose nil supplied-p)
	       &aux(name(or name (string-downcase(package-name *package*)))))
  (declare(ignorable supplied-p))
  #.(or ; in order to avoid #-.
      ;#+(and :remora :thread-support)
      ;'(remora::load-system* name :verbose verbose)
      ;#+remora '(remora:load-system name :verbose verbose)
      ;; as default below.
      `(with-verbose-setting(verbose supplied-p)
         #+sbcl
         (trivial-formatter:fmt name :supersede)
	 (asdf:load-system name))))

