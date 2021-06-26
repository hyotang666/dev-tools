(in-package :dev-tools)

(defun who-use (symbol)
  (loop :for package :in (cl:list-all-packages)
        :when (eq symbol (find-symbol (symbol-name symbol) package))
          :collect package))