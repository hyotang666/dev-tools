(in-package :cl-user)
(defpackage :dev-tools(:use :cl :prompt-for)
  (:nicknames :dev)
  (:shadow #:load #:delete-package #:log #:list-all-packages #:package-used-by-list)
  (:export
    ;;;; debug
    #:with-debug ; #L
    ;; for printf debug #E

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

    ;;;; break.
    #:die-after
    #:enbreak
    #:debreak

    ;;;; expand.
    ;; for macroexpand #M
    #:step-expand
    #:put-expand

    ;;;; average.
    #:average ; #V

    ;;;; inspect.
    #:peep

    ;;;; named-readtable
    #:syntax

    ;;;; asdf.
    #:load

    ;;;; disassemble-count
    #:disassemble-count
    #:disassemble<

    ;;;; generate project directories.
    #:generate

    ;;;; test local projects
    #:test ; all specified author's systems are tested on this lisp.
    #:check ; specified system is tested on all lisps.
    #:rec-test ; test all dependencies.

    ;;;; Easy to make file
    #:touch

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
    ))
(in-package :dev-tools)
