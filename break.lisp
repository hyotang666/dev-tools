(in-package :dev-tools)

(let(count)
  (defun die-after(num)
    (if(not count) ; it's first time to be called.
      (setf count num)
      (when(zerop(decf count))
	 (setf count nil) ; reinitialize.
	 (error "~S time passing."num)))))

