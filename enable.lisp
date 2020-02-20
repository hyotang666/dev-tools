(in-package :dev-tools)

(define-condition symbol-not-found (error)
  ((api :initarg :api :accessor condition-api)
   (format-control :initarg :format-control :accessor format-control)
   (format-arguments :initarg :format-arguments :accessor format-arguments))
  (:report
   (lambda (c *standard-output*)
     (format t "~S: ~?" (condition-api c) (format-control c)
             (format-arguments c)))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun bind-of-handler-bind (bind)
    (destructuring-bind
        (condition-name slots)
        bind
      (let ((arg (gensym "CONDITION")))
        `(,condition-name
          (lambda (,arg)
            (with-slots ,(mapcar #'car slots)
                ,arg
              (setf ,@(loop :for elt :in slots
                            :append elt))))))))
  (defmacro with-handler-slot-replace (binds &body body)
    "Making handler bindings which replace condition slots.
    syntax (WITH-HANDLER-SLOT-REPLACE(bind*)&BODY body)
    bind = (condition-name(slot-binding*))
    condition-name = (AND SYMBOL(NOT(OR NULL KEYWORD)))
    slot-binding = (slot-name slot-new-value)
    slot-name = (AND SYMBOL(NOT(OR NULL KEYWORD)))
    slot-new-value = LISP-OBJECT
    body = S-EXPRESSION*"
    `(handler-bind ,(mapcar #'bind-of-handler-bind binds)
       ,@body)))

(defun enable (char)
  (with-handler-slot-replace ((symbol-not-found
                               ((api 'enable)
                                (format-control
                                  "Function for dispatch macro character ~S is not found."))))
    (let ((reader-name (reader-name char))
          (reader (get-dispatch-macro-character #\# char)))
      (if reader ; somebody already set it, but...
          (if (eq reader-name (millet:function-name (coerce reader 'function))) ; it's
                                                                                ; me!
              #0=(set-dispatch-macro-character #\# char reader-name)
              (when (y-or-n-p
                      "DEV-TOOLS: #~A reader macro already used. : ~S~&Really do you want to replace it?"
                      char reader)
                #0#))
          #0#)))); nobody set it.

(defun reader-name (char)
  (or (find-symbol (format nil "#~A-reader" (char-upcase char)) :dev-tools)
      (error 'symbol-not-found
             :api 'reader-name
             :format-control "Symbol |#~:(~A~)-reader| is not found."
             :format-arguments (list char))))