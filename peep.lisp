(in-package :dev-tools)

(defgeneric peep (object))

(defmethod peep (o)
  (format t "~&;; ~A"(type-of o))
  (print o))

(defmethod peep ((o standard-object))
  (format t "~&;; ~A"(type-of o))
  (let*((properties(property<=obj o))
	(length(loop :for elt :in properties :by #'cddr
		     :maximize (length(symbol-name elt)))))
    (loop :for (slot value . nil) :on properties :by #'cddr
	  :do (format t "~&~VA = ~S"length slot value))))

(defun property<=obj (object)
  (loop :for slot :in (slots<=obj object)
	:collect slot
	:collect (if(slot-boundp object slot)
		   (slot-value object slot)
		   :unbound)))

(defun slots<=obj(object)
  (mapcar #'closer-mop:slot-definition-name
	  (closer-mop:class-slots(class-of object))))

(defmethod peep ((o hash-table))
  (format t "~&;; ~A"(type-of o))
  (let(ks vs)
    (maphash (lambda(k v)
	       (push (prin1-to-string k) ks)
	       (push v vs))
	     o)
    (let((length(or (loop :for k :in ks
			  :maximize (length k))
		    0)))
      (loop :for k :in ks
	    :for v :in vs
	    :do (format t "~&~VA = ~S"length k v)))))
