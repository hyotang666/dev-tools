(in-package :dev-tools)

(let (count)
  (defun die-after (num)
    (if (not count) ; it's first time to be called.
        (setf count num)
        (when (zerop (decf count))
          (setf count nil) ; reinitialize.
          (error "~S time passing." num)))))

(defvar *enbroken* (make-hash-table))

(defun enbreak (symbol)
  (when (and (fboundp symbol)
             (not (macro-function symbol))
             (not (special-operator-p symbol)))
    (if (gethash symbol *enbroken*)
        (warn "~S is already enbroken." symbol)
        (cl-package-locks:without-package-locks
          (let ((original (symbol-function symbol)))
            (setf (gethash symbol *enbroken*) original)
            (flet ((enbreak (&rest args)
                     (break "Broken ~S" symbol)
                     (apply original args)))
              (setf (symbol-function symbol) #'enbreak)))))))

(defun debreak (&rest args)
  (flet ((debreak (symbol function)
           (cl-package-locks:without-package-locks
             (setf (symbol-function symbol) function))
           (remhash symbol *enbroken*)))
    (if (null args)
        (maphash #'debreak *enbroken*)
        (dolist (symbol args)
          (let ((original (gethash symbol *enbroken*)))
            (if original
                (debreak symbol original)
                (warn "~S is not enbroken" symbol)))))))