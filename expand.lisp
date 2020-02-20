(in-package :dev-tools)

(defun step-expand (form &optional rest)
  (multiple-value-bind (form expandedp)
      (macroexpand-1 form)
    (prog ()
      (progn (print form) (force-output))
     :rec
      (when rest
        (format *query-io* "~&Rest : ")
        (write rest
               :length 2
               :lines 1
               :level 2
               :pretty t
               :circle t
               :escape t
               :stream *query-io*)
        (force-output))
     :invalid
      (case
          (prompt-for t
                      "~&~:[~;[E]xpand, ~]~:[~;[D]iscard, ~]~:[~;[S]tep, ~][Q]uit,>> "
                      expandedp rest (consp form)
                      :by #'read-char)
        ((#\q #\Q) (return form)) ; Quit.
        ((#\d #\D) ; Discard current FORM.
         (if rest
             (progn
              (psetf form (print (car rest) *query-io*)
                     rest (cdr rest)
                     expandedp t)
              (force-output)
              (go :rec))
             nil)) ; end.
        ((#\s #\S) ; Step into current form's 2nd elememt.
         (psetf form (print (second form) *query-io*)
                rest
                  (if rest
                      (append (cddr form) rest)
                      (cddr form))
                expandedp t)
         (force-output)
         (go :rec))
        ((#\e #\E) ; Expand-1 current form.
         (return (step-expand form rest)))
        (otherwise (go :invalid))))))

(defun |#M-reader| (stream character number)
  (declare (ignore number))
  (let ((form (read stream t t t)))
    (if (upper-case-p character)
        `(macroexpand ',form)
        `(macroexpand-1 ',form))))

(defun put-expand (form &optional (name "~/expanded.lisp"))
  (with-open-file (*standard-output* name :direction :output
                   :if-does-not-exist :create
                   :if-exists :supersede)
    (print (macroexpand-1 form))))