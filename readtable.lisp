(in-package :dev-tools)

(named-readtables:defreadtable syntax
  (:merge :standard)
  (:dispatch-macro-char #\# #\L #'|#L-reader|)
  (:dispatch-macro-char #\# #\B #'|#B-reader|)
  (:dispatch-macro-char #\# #\D #'|#D-reader|)
  (:dispatch-macro-char #\# #\T #'|#T-reader|)
  (:dispatch-macro-char #\# #\E #'|#E-reader|)
  (:dispatch-macro-char #\# #\M #'|#M-reader|)
  (:dispatch-macro-char #\# #\V #'|#V-reader|))