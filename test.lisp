(in-package :dev-tools)

(defun test(author)
  (dolist(name(local-projects))
    (let((system(asdf:find-component name nil)))
      (if(not system)
	(warn "~S is not found." name)
	(if (equal author (asdf:system-author system))
	  (handler-case(call-with-silent #'asdf:test-system name)
	    (error(c)(warn "Could not test ~S cause ~A"name c)))
	  #++(warn "~S's author is ~S not ~S."
		(asdf:coerce-name system)
		(asdf:system-author system)
		author))))))

(defun local-projects()
  (flet((enkey(string)
	  (intern (string-upcase string) :keyword)))
    (mapcar #'enkey (ql:list-local-systems))))

(defvar *ros-installed* '("clisp" "sbcl" "ccl-bin" "ecl"))
(defun check(system)
  (dolist(impl *ros-installed*)
    (format t "~&Run test ~S on ~A/" system impl)
    (uiop:run-program (concatenate 'string "ros -e '(progn (format t \"~A~%\"(lisp-implementation-version))"
				   (format nil "(if (find-package :uiop)(asdf:test-system ~(~S~))(write-line \"~A Give up to test because UIOP missing.\")))' -L ~:*~A"
					   system impl))
		      :output T
		      :error-output *standard-output*)))

(defun rec-test(system)
  (dolist(system(all-dependencies system))
    (asdf:test-system (print system))
    (ql::press-enter-to-continue)))
