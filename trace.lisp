(in-package :dev-tools)

(defvar *traces* nil)

(defmacro trace-package(&optional(package *package*))
  (let((package(ensure-package package)))
    (if(and *traces*(eq package (symbol-package(car *traces*))))
      `(TRACE ,@*traces*)
      `(TRACE ,@(setf *traces* (function-designators package))))))

(defun ensure-package(arg)
  (etypecase arg
    (package arg)
    ((or symbol string)(find-package arg))))

(defmacro ignore-traces(&rest names)
  `(SETF *TRACES*(NSET-DIFFERENCE *TRACES* ',names)))

(defun function-designators(&optional(package *package*)
			     &aux(package(ensure-package package)))
  (loop :for symbol :being :each :symbol :of package
	:when(and (eq package (symbol-package symbol))
		  (not(macro-function symbol))
		  (fboundp symbol))
	:collect symbol))

(defmacro with-trace((&optional(package *package*))&body body)
  `(UNWIND-PROTECT
     (PROGN (TRACE-PACKAGE ,package)
	    ,@body)
     (UNTRACE)))

(defun trace-file-name()
  (format nil "~(~A~)-~A"
	  uiop:*implementation-type*
	  (gensym "trace-log")))

(defmacro with-trace-out((&optional(package '*package*))&body body)
  `(UNWIND-PROTECT
     (PROGN (DRIBBLE(TRACE-FILE-NAME))
	    (LET((*TRACE-OUTPUT*(TO-DRIBBLE-STREAM)))
	      (WITH-TRACE(,package)
		,@body)))
     (DRIBBLE)))

(defun |#T-reader|(stream &rest args)
  (declare(ignore args))
  `(UNWIND-PROTECT
     (PROGN (DRIBBLE(TRACE-FILE-NAME))
	    (LET((*TRACE-OUTPUT*(TO-DRIBBLE-STREAM)))
	      (WITH-TRACE()
		,(read stream t nil t))))
     (DRIBBLE)))

(defun to-dribble-stream()
  ;; when your lisp implementation does not output *trace-output* to dribble,
  ;; add dribble-stream like below.
  ;; (apropos "dribble") will help you to find dribble-stream.
  (make-broadcast-stream
    #+sbcl sb-impl::*dribble-stream*
    *trace-output*))

(defmacro tlabels((&rest definition*)&body body)
  `(labels
     ,(loop :for (name lambda-list . body) :in definition*
	    :collect (multiple-value-bind(body declarations doc-string)(alexandria:parse-body body)
		       `(,name,lambda-list
			  ,@doc-string
			  ,@declarations
			  (format *trace-output* "~%;;; TRACING(~A ~{~S~^ ~})"
				  ',name (list ,@(lambda-fiddle:extract-all-lambda-vars lambda-list)))
			  ,@body)))
     ,@body))

(defmacro tcond(&rest clause*)
  `(COND
     ,@(loop :for (pred) :in clause*
	     :collect `(,pred ',pred))))

(defvar *trace-indent* -1)

(defmacro tlet(bind* &body body)
  `(LET,(loop :for bind :in bind*
	      :collect (if(symbolp bind)
			 `(,bind(FORMAT *TRACE-OUTPUT* "~%;;; TRACING ~A = NIL." ',bind))
			 (if(cdr bind)
			   `(,(car bind)(LET((#0=#:TEMP,(cadr bind)))
					  (FORMAT *TRACE-OUTPUT* "~%;;; TRACING ~A is ~S" ',(car bind) #0#)
					  #0#))
			   `(,(car bind)(FORMAT *TRACE-OUTPUT* "~%;;; TRACING ~A = NIL." ',(car bind))))))
     ,@body))

(defmacro tlet*(bind* &body body)
  `(LET*((*TRACE-INDENT*(1+ *TRACE-INDENT*))
	 ,@(loop :for bind :in bind*
		 :collect (if(symbolp bind)
			    `(,bind(FORMAT *TRACE-OUTPUT* "~%~VT;;; TRACING ~S = NIL."
					   (* 2 *TRACE-INDENT*)',bind))
			    (if(cdr bind)
			      `(,(car bind)(LET((#0=#:temp,(cadr bind)))
					     (FORMAT *TRACE-OUTPUT* "~%~VT;;; TRACING ~S = ~S"
						     (* 2 *TRACE-INDENT*) ',(car bind) #0#)
					     #0#))
			      `(,(car bind)(format *trace-output* "~%~VT;;; TRACING ~S = NIL."
						   (* 2 *TRACE-INDENT*)',(car bind)))))))
       ,@body))

(defmacro tand(&body clauses)
  `(AND ,@(mapcar (lambda(clause)
		    `(or ,clause
			 (FORMAT *TRACE-OUTPUT* "~%;;; TRACING, AND fails in cluase: ~S"
				 ',clause)))
		  clauses)))
