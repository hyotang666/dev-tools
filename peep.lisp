(in-package :dev-tools)

(defun peep(object)
  (report(%peep object)))

(defun %peep(object)
  (list* (class-name(class-of object))
	 (property<=obj object)))

(defun property<=obj (object)
  (loop :for slot :in (slots<=obj object)
	:collect slot
	:collect (if(slot-boundp object slot)
		   (slot-value object slot)
		   :unbound)))

(defun slots<=obj(object)
  (mapcar #'closer-mop:slot-definition-name
	  (closer-mop:class-slots(class-of object))))

(defun report(list)
  (format t "~&;; ~A"(car list))
  (let((length(loop :for elt :in (cdr list) :by #'cddr
		    :maximize (length(symbol-name elt)))))
    (loop :for (slot value . nil) :on (cdr list) :by #'cddr
	  :do (format t "~&~VA = ~S"length slot value))))
