(in-package :dev-tools)

(defun generate (name &optional parent)
  (setf name (asdf:coerce-name name))
  (let ((*default-pathname-defaults*
         (mkdir name
                (when parent
                  (asdf:coerce-name parent)))))
    (generate-asd name)
    (generate-lisp name)
    (generate-readme name)
    (ql:register-local-projects)))

(defparameter *local-projects-directory*
  (merge-pathnames ".roswell/local-projects/" (user-homedir-pathname)))

(defun mkdir (name parent)
  (ensure-directories-exist (mkpath name parent) :verbose t))

(defun mkpath (name parent)
  (merge-pathnames
    (concatenate 'string (or parent "")
                 (if parent
                     "/"
                     "")
                 name "/")
    *local-projects-directory*))

(defmacro with-generate ((pathname) &body body)
  `(with-open-file (*standard-output* ,pathname :direction :output
                    :if-exists :supersede
                    :if-does-not-exist :create)
     ,@body))

(defun generate-asd (name)
  (with-generate ((make-pathname
                   :name name
                   :type "asd"
                   :defaults *default-pathname-defaults*))
    (%generate-asd name)))

(defun %generate-asd (name)
  (let ((*package* (find-package :asdf)))
    (format t "; vim: ft=lisp et~%~(~S~)~%~(~:S~)" `(in-package :asdf)
            `(asdf:defsystem ,name
               :depends-on
               ("endaira")
               :components
               ((:file ,name))))))

(defun generate-lisp (name)
  (with-generate ((make-pathname
                   :name name
                   :type "lisp"
                   :defaults *default-pathname-defaults*))
    (%generate-lisp name)))

(defun %generate-lisp (name)
  (let ((name (make-symbol (string-upcase name))))
    (format t "~(~S~)~%~(~S~)"
            `(defpackage ,name
               (:use #:endaira)
               (:export))
            `(in-package ,name))))

(defun generate-readme
       (name
        &optional (*default-pathname-defaults* *default-pathname-defaults*))
  (with-generate ((make-pathname
                   :name "README"
                   :type "md"
                   :defaults *default-pathname-defaults*))
    (%generate-readme name)))

(defun %generate-readme (name)
  (format t "# ~A 0.0.0~%~
	  ## What is this?~2%~
	  ### Current lisp world~2%~
	  ### Issues~2%~
	  ### Proposal~2%~
	  ## Usage~2%~
	  ## From developer~2%~
	  ### Product's goal~2%~
	  ### License~2%~
	  ### Developed with~2%~
	  ### Tested with~2%~
	  ## Installation~2%"
          name))