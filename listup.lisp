(in-package :dev-tools)

;;;; LISTUP

(declaim
 (ftype (function
         ((or symbol string package) &optional
          (member :command
                  :macro :function
                  :generic-function :variable
                  :class :type
                  :symbol-macro nil))
         (values &optional))
        listup))

(defun listup (package &optional target)
  (flet ((tune-indent (s list)
           (with-output-to-string (*standard-output*)
             (let* ((*package* (symbol-package s))
                    (lines
                     (split-sequence:split-sequence #\Newline
                                                    (format nil "~VT~:S"
                                                            (1+
                                                              (length
                                                                (symbol-name
                                                                  s)))
                                                            list))))
               (loop :initially (write-string
                                  (string-left-trim " " (car lines)))
                     :for line :in (cdr lines)
                     :do (format t "~%~A" line)
                     :finally (format t "~@[~%~A~]~@[~%~A~]"
                                      (when (ignore-errors
                                             (fdefinition `(setf ,s)))
                                        "SETFable.")
                                      (documentation s 'function))))))
         (class-format (s)
           (let ((class (find-class s)))
             (format nil "; of type ~A~%~@[~A~]~?"
                     (class-name (class-of class)) (documentation s 'type)
                     "~{~&~%~A ; Slot name.~@[~%~A~]~}"
                     `(,(loop :for slot :in (c2mop:class-direct-slots class)
                              :for name = (c2mop:slot-definition-name slot)
                              :when (eq
                                     :external (nth-value 1
                                                          (find-symbol
                                                            (symbol-name name)
                                                            package)))
                                :collect (cl-ansi-text:yellow
                                           (princ-to-string name))
                                :and :collect (handler-bind ((warning
                                                               #'muffle-warning))
                                                (documentation slot t))))))))
    (do-external-symbols (s package)
      (let ((roles (symbol-roles s)))
        (when (or (null target) (find target roles))
          (dolist (role roles)
            (unless (eq role :command)
              (format t "~&~%~A~@[ ~A~]"
                      (cl-ansi-text:yellow (princ-to-string s))
                      (case role
                        ((:function :macro :generic-function)
                         (tune-indent s (millet:lambda-list s)))
                        (:variable
                         (format nil "; = ~A~%~@[~A~]"
                                 (if (boundp s)
                                     (prin1-to-string (symbol-value s))
                                     "; Unbound")
                                 (documentation s 'variable)))
                        (:type
                         (format nil "; Type name.~%~@[~A~]"
                                 (documentation s 'type)))
                        (:class (class-format s))
                        (:symbol-macro
                         (format nil "; expanded to ~A"
                                 (tune-indent s (macroexpand-1 s))))))))))))
  (values))

(defun symbol-roles (s)
  `(,@(when (fboundp s)
        (unless (special-operator-p s)
          (if (macro-function s)
              '(:macro :command)
              (if (typep (symbol-function s) 'standard-generic-function)
                  '(:generic-function :command)
                  '(:function :command)))))
    ,@(when (or (millet:special-symbol-p s) (constantp s))
        '(:variable))
    ,@(if (find-class s nil)
          '(:class)
          (handler-case (typep '#:dummy s)
            (error ())
            (:no-error (return)
              (declare (ignore return)) '(:type))))
    ,@(when (nth-value 1 (macroexpand-1 s))
        '(:symbol-macro))))

(defun list-all-packages (symbol)
  (loop :for package :in (cl:list-all-packages)
        :when (eq symbol (find-symbol (symbol-name symbol) package))
          :collect package))