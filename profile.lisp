(in-package :dev-tools)

(defun targetp (symbol)
  (and (symbolp symbol)
       (fboundp symbol)
       (not (macro-function symbol))
       (not (special-operator-p symbol))
       (not
         (find-symbol (symbol-name symbol)
                      (load-time-value (find-package :cl))))))

(defun targets (source-code)
  (uiop:while-collecting (acc)
    (trestrul:dotree (l source-code)
      (when (targetp l)
        (acc l)))))

(defmacro profile (source-code) `(sb-profile:profile ,@(targets source-code)))

(defmacro profile-system (system)
  (setf system (asdf:find-system system))
  (let ((packages))
    (flet ((hook (macro-function form environment)
             (when (typep form '(cons (eql defpackage) t))
               (push (second form) packages))
             (funcall macro-function form environment)))
      (mapc #'asdf:load-system (asdf:system-depends-on system))
      (let ((*macroexpand-hook* #'hook))
        (asdf:load-system :system :force t)))
    `(progn
      ,@(mapcar
          (lambda (package)
            (loop :for symbol :being :each :symbol :of package
                  :when (targetp symbol)
                    :collect symbol :into result
                  :finally (return `(sb-profile:profile ,@result))))
          packages))))