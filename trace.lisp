(in-package :dev-tools)

(defvar *traces* nil)

(defmacro trace-package (&optional (package *package*))
  (let ((package (ensure-package package)))
    (if (and *traces* (eq package (symbol-package (car *traces*))))
        `(trace ,@*traces*)
        `(trace ,@(setf *traces* (function-designators package))))))

(defun ensure-package (arg)
  (etypecase arg (package arg) ((or symbol string) (find-package arg))))

(defmacro ignore-traces (&rest names)
  `(setf *traces* (nset-difference *traces* ',names)))

(defun function-designators
       (&optional (package *package*) &aux (package (ensure-package package)))
  (loop :for symbol :being :each :symbol :of package
        :when (and (eq package (symbol-package symbol))
                   (not (macro-function symbol))
                   (fboundp symbol))
          :collect symbol))

(defmacro with-trace ((&optional (package *package*)) &body body)
  `(unwind-protect (progn (trace-package ,package) ,@body) (untrace)))

(defun trace-file-name ()
  (format nil "~(~A~)-~A" uiop:*implementation-type* (gensym "trace-log")))

(defmacro with-trace-out ((&optional (package '*package*)) &body body)
  `(unwind-protect
       (progn
        (dribble (trace-file-name))
        (let ((*trace-output* (to-dribble-stream)))
          (with-trace (,package)
            ,@body)))
     (dribble)))

(defun |#T-reader| (stream &rest args)
  (declare (ignore args))
  `(unwind-protect
       (progn
        (dribble (trace-file-name))
        (let ((*trace-output* (to-dribble-stream)))
          (with-trace nil
            ,(read stream t nil t))))
     (dribble)))

(defun to-dribble-stream ()
  ;; when your lisp implementation does not output *trace-output* to dribble,
  ;; add dribble-stream like below.
  ;; (apropos "dribble") will help you to find dribble-stream.
  (make-broadcast-stream #+sbcl sb-impl::*dribble-stream* *trace-output*))

(defmacro tlabels ((&rest definition*) &body body)
  `(labels ,(loop :for (name lambda-list . body) :in definition*
                  :collect (multiple-value-bind (body declarations doc-string)
                               (alexandria:parse-body body)
                             `(,name ,lambda-list ,@doc-string ,@declarations
                               (format *trace-output*
                                       "~%;;; TRACING~%~:<~A~^ ~:I~@_~@{~S~^ ~_~}~:>~%"
                                       (list ',name
                                             ,@(lambda-fiddle:extract-all-lambda-vars
                                                 lambda-list)))
                               (force-output *trace-output*) ,@body)))
     ,@body))

(defmacro tcond (&rest clause*)
  `(cond
     ,@(loop :for (pred . body) :in clause*
             :collect `((progn
                         (format *trace-output* "~%;;; TRACING COND ~S" ',pred)
                         (print ,pred))
                        ,@body))))

(defvar *trace-indent* -1)

(defmacro tlet (bind* &body body)
  `(let ,(loop :for bind :in bind*
               :collect (if (symbolp bind)
                            `(,bind
                              (format *trace-output* "~%;;; TRACING ~A = NIL."
                                      ',bind))
                            (if (cdr bind)
                                `(,(car bind)
                                  (let ((#0=#:temp ,(cadr bind)))
                                    (format *trace-output*
                                            "~%;;; TRACING ~A is ~S"
                                            ',(car bind) #0#)
                                    #0#))
                                `(,(car bind)
                                  (format *trace-output*
                                          "~%;;; TRACING ~A = NIL."
                                          ',(car bind))))))
     ,@body))

(defmacro tlet* (bind* &body body)
  `(let* ((*trace-indent* (1+ *trace-indent*))
          ,@(loop :for bind :in bind*
                  :collect (if (symbolp bind)
                               `(,bind
                                 (format *trace-output*
                                         "~%~VT;;; TRACING ~S = NIL."
                                         (* 2 *trace-indent*) ',bind))
                               (if (cdr bind)
                                   `(,(car bind)
                                     (let ((#0=#:temp ,(cadr bind)))
                                       (format *trace-output*
                                               "~%~VT;;; TRACING ~S = ~S"
                                               (* 2 *trace-indent*)
                                               ',(car bind) #0#)
                                       #0#))
                                   `(,(car bind)
                                     (format *trace-output*
                                             "~%~VT;;; TRACING ~S = NIL."
                                             (* 2 *trace-indent*)
                                             ',(car bind)))))))
     ,@body))

(defmacro tand (&body clauses)
  `(and ,@(mapcar
            (lambda (clause)
              `(or ,clause
                   (format *trace-output*
                           "~%;;; TRACING, AND fails in cluase: ~S" ',clause)))
            clauses)))

(defmacro tdo (binds return &body body)
  `(do ,binds
       ,return
    ,@(mapcar
        (lambda (bind)
          (let ((var (alexandria:ensure-car bind)))
            `(format *trace-output* "~%;;; TRACING DO ~S = ~S" ',var ,var)))
        binds)
    ,@body))

(defmacro tdo* (binds return &body body)
  `(do* ,binds
        ,return
    ,@(mapcar
        (lambda (bind)
          (let ((var (alexandria:ensure-car bind)))
            `(format *trace-output* "~%;;; TRACING DO* ~S = ~S" ',var ,var)))
        binds)
    ,@body))