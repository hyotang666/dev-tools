(in-package :cl-user)

(defpackage :dev-tools
  (:use :cl :prompt-for)
  (:nicknames :dev)
  (:shadow #:load
           #:delete-package
           #:log
           #:list-all-packages
           #:package-used-by-list)
  (:export ;; for printf debug #E
           ;;;; qualified use package.
           #:use
           ;;;; trace.
           #:with-trace ; #T
           #:trace-package
           #:ignore-traces
           #:*traces*
           #:tlabels
           #:tcond
           #:tand
           #:tlet
           #:tlet*
           #:tdo
           #:tdo*
           ;;;; dribble.
           #:with-dribble ; #D
           ;;;; bench.
           #:bench ; #B
           ;;;; enable.
           #:enable
           ;;;; update.
           #:update
           ;;;; expand.
           ;; for macroexpand #M
           #:step-expand
           #:put-expand
           #:macrolet-expand
           ;;;; inspect.
           #:peep
           ;;;; named-readtable
           #:syntax
           ;;;; asdf.
           #:load
           ;;;; disassemble-count
           #:disassemble-count
           #:disassemble<
           ;;;; test local projects
           #:test ; Tests current package system.
           #:retest ; Update and test current package system.
           #:check ; specified system is tested on all lisps.
           #:rec-test ; test all dependencies.
           ;;;; Package summary
           #:listup
           #:list-all-packages
           ;;;; Profiling only works in SBCL.
           #:profile
           ;;;; Reccursively deleting package.
           #:delete-package
           ;;;; Recursively collect all dependencies license.
           #:check-license
           #:all-dependencies
           #:find-dependency-route
           ;;;; Log output. Use instead of `CL:PRINT`.
           #:log
           ;;;; Apropos.
           #:who-use))

(in-package :dev-tools)
