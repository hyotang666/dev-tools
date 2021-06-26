(in-package :dev-tools)

(named-readtables:defreadtable syntax
  (:merge :standard)
  (:dispatch-macro-char #\# #\T #'|#T-reader|)
  (:dispatch-macro-char #\# #\M #'|#M-reader|))
