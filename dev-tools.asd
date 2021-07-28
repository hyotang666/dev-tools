; vim: ft=lisp et
(defsystem :dev-tools
  :version "5.0.1"
  :depends-on
  (
   "prompt-for"         ; type safe user input.
   "closer-mop"         ; wrapper for meta object protocols.
   "named-readtables"   ; manage readtables.
   "alexandria"         ; public domain utilities.
   "millet"             ; wrapper for implementation dependent utilities.
   "cl-ansi-text"       ; text colorizing.
   #+sbcl "trestrul"    ; utilities for tree structured list.
   "lambda-fiddle"      ; tiny utilities for lambda-list processing.
   "tsort"              ; Topological sorting.
   "quicklisp"          ; For press enter to continue.
   "trivial-formatter"  ; Code formatting.
   "expander"           ; Macroexpand-all for macrolet-expander.
   "uiop"               ; Utilities.
   "asdf"               ; System object.
   )
  :components ((:file "package") ; (use)
               (:file "use" :depends-on ("package")) ; (use)
               (:file "log" :depends-on ("package")) ; (use uiop)
               (:file "license" :depends-on ("package")) ; (use asdf uiop alexandria tsort)
               (:file "delete-package" :depends-on ("package")) ; (use)
               (:file "listup" :depends-on ("package")) ; (use uiop closer-mop cl-ansi-text millet)
               (:file "dribble" :depends-on ("package")) ; (use uiop)
               (:file "enable" :depends-on ("package")) ; (use millet)
               (:file "expand" :depends-on ("package")) ; (use expander)
               (:file "trace" :depends-on ("package")) ; (use alexandria lambda-fiddle)
               (:file "update" :depends-on ("package")) ; (use asdf trivial-formatter)
               (:file "peep" :depends-on ("package")) ; (use closer-mop)
               (:file "load" :depends-on ("package")) ; (use asdf)
               (:file "disassemble-count" :depends-on ("package")) ; (use uiop)
               #+sbcl
               (:file "profile" :depends-on ("package")) ; (use uiop trestrul asdf)
               (:file "test" :depends-on ("package" "load" "license" "update")) ; (use asdf quicklisp uiop)
               (:file "readtable" :depends-on ("dribble" "trace")) ; (use named-readtables)
               (:file "who-use" :depends-on ("package")) ; (use)
               ))
