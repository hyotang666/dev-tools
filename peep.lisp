(in-package :dev-tools)

(defgeneric peep (object &optional recp))

(defmethod peep (o &optional recp)
  (format t "~&;; ~A"(type-of o))
  (print o))

(defmethod peep ((o standard-object)&optional recp)
  (format t "~&;; ~A"(type-of o))
  (let*((properties(property<=obj o))
	(length(loop :for elt :in properties :by #'cddr
		     :maximize (length(symbol-name elt)))))
    (loop :for (slot value . nil) :on properties :by #'cddr
	  :do (format t "~&~VA = "length slot)
	  (if recp
	    (peep value)
	    (prin1 value)))))

(defun property<=obj (object)
  (loop :for slot :in (slots<=obj object)
	:collect slot
	:collect (if(slot-boundp object slot)
		   (slot-value object slot)
		   :unbound)))

(defun slots<=obj(object)
  (mapcar #'closer-mop:slot-definition-name
	  (closer-mop:class-slots(class-of object))))

(defmethod peep ((o hash-table)&optional recp)
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
	    :do (format t "~&~VA = "length k)
	    (if recp
	      (peep v)
	      (prin1 v))))))

(defmethod peep((list list)&optional recp)
  (format t "~&;; LIST")
  (if recp
    (progn (format t "~&(")
	   (mapc #'peep list)
	   (format t ")"))
    (print list)))


