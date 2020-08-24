; vim: ft=lisp et
(defsystem :dev-tools
  :version "3.0.2"
  :depends-on
  (
   "prompt-for"         ; type safe user input.
   "closer-mop"         ; wrapper for meta object protocols.
   "named-readtables"   ; manage readtables.
   "alexandria"         ; public domain utilities.
   "with-fields"        ; awk like feature.
   "millet"             ; wrapper for implementation dependent utilities.
   "cl-ansi-text"       ; text colorizing.
   #+sbcl "trestrul"    ; utilities for tree structured list.
   "lambda-fiddle"      ; tiny utilities for lambda-list processing.
   "tsort"              ; Topological sorting.
   "split-sequence"     ; Utiltity for split sequence.
   "cl-package-locks"   ; Wrapper for package locking.
   "quicklisp"          ; For press enter to continue.
   "trivial-formatter"  ; Code formatting.
   )
  :components ((:file "package")
               (:file "use" :depends-on ("package"))
               (:file "debug" :depends-on ("package"))
               (:file "log" :depends-on ("package"))
               (:file "license" :depends-on ("package"))
               (:file "delete-package" :depends-on ("package"))
               (:file "listup" :depends-on ("package"))
               (:file "bench" :depends-on ("package"))
               (:file "break" :depends-on ("package"))
               (:file "dribble" :depends-on ("package"))
               (:file "enable" :depends-on ("package"))
               (:file "expand" :depends-on ("package"))
               (:file "trace" :depends-on ("package"))
               (:file "update" :depends-on ("package"))
               (:file "echo" :depends-on ("package"))
               (:file "average" :depends-on ("package"))
               (:file "peep" :depends-on ("package"))
               (:file "load" :depends-on ("package"))
               (:file "disassemble-count" :depends-on ("package"))
               (:file "generate" :depends-on ("package"))
               (:file "touch" :depends-on ("package"))
               #+sbcl
               (:file "profile" :depends-on ("package"))
               (:file "test" :depends-on ("package" "load" "license" "update"))
               (:file "readtable" :depends-on ("bench" "dribble" "trace" "echo" "average" "debug"))
               (:file "who-use" :depends-on ("package"))
               ))
