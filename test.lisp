(in-package :dev-tools)

(defun retest () (update) (test))

(defun test () (asdf:test-system (make-symbol (package-name *package*))))

(defun local-projects ()
  (flet ((enkey (string)
           (intern (string-upcase string) :keyword)))
    (mapcar #'enkey (ql:list-local-systems))))

(defvar *ros-installed* '("clisp" "sbcl" "ccl-bin" "ecl"))

(defun check (system)
  ;; Validation.
  (restart-case (asdf:find-system system)
    (use-value (new)
        :report "Specify correct system."
        :interactive (lambda () (list (prompt-for #'asdf:find-system "~&>> ")))
      (setf system new)))
  ;; Body
  (dolist (impl *ros-installed*)
    (format *trace-output* "~&Start to run test ~S on ~A~%" system impl)
    (force-output *trace-output*)
    (multiple-value-bind (out error-out status)
        (uiop:run-program
          (format nil "ros -e '~S' -L ~A"
                  `(progn
                    (if (find-package :uiop)
                        (let (*compile-print* *compile-verbose*)
                          (asdf:test-system ,system)
                          (format *trace-output* "~&Finish test in ~A~A~2%"
                                  (lisp-implementation-type)
                                  (lisp-implementation-version)))
                        (write-line
                          ,(format nil
                                   "~A Give up to test ~S because UIOP missing."
                                   impl system))))
                  impl)
          :output t
          :error-output *standard-output*
          :ignore-error-status t)
      (declare (ignore out error-out))
      (unless (zerop status)
        (format t "~%~A Give up to test ~S: ~S" impl system status)))))

(defun rec-test (system)
  (dolist (system (all-dependencies system))
    (asdf:test-system (print system))
    (force-output)
    (ql::press-enter-to-continue)))