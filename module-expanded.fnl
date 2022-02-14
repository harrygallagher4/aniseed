; (local
;   (*module-name* *module* *module-locals* a fennel)
;   (do
;     (local *module-name* "aniseed.macros-scratch")
;     (local *module* (do (tset package.loaded *module-name* {})
;                         (. package.loaded *module-name*)))
;     (local *module-locals* (do (tset *module* "aniseed/locals" {})
;                                (. *module* "aniseed/locals")))
;     (local a (require "aniseed.core"))
;     (local fennel (require "fennel"))
;     (require-macros "m-dummy")
;     (tset *module-locals* "*module-name*" *module-name*)
;     (tset *module-locals* "*module*" *module*)
;     (tset *module-locals* "*module-locals*" *module-locals*)
;     (tset *module-locals* "a" a)
;     (tset *module-locals* "fennel" fennel)
;     (values *module-name* *module* *module-locals* a fennel)))

; (macrodebug (module aniseed.macros-scratch {require {a aniseed.core : fennel {: str} aniseed.compile} autoload {fs aniseed.fs} require-macros [m-dummy]}))

(local (*module-name* *module* *module-locals* autoload fs a fennel)
       (do
         (local *module-name* :aniseed.macros-scratch)
         (local *module*
                (do
                  (tset package.loaded *module-name* {})
                  (. package.loaded *module-name*)))
         (local *module-locals*
                (do
                  (tset *module* :aniseed/locals {})
                  (. *module* :aniseed/locals)))
         (local autoload (. (require :aniseed.autoload) :autoload))
         (local fs (autoload :aniseed.fs))
         (local a (require :aniseed.core))
         (local fennel (require :fennel))
         (require-macros :m-dummy)
         (tset *module-locals* :*module-name* *module-name*)
         (tset *module-locals* :*module* *module*)
         (tset *module-locals* :*module-locals* *module-locals*)
         (tset *module-locals* :autoload autoload)
         (tset *module-locals* :fs fs)
         (tset *module-locals* :a a)
         (tset *module-locals* :fennel fennel)
         (values *module-name* *module* *module-locals* autoload fs a fennel)))

;; current macro expands to:
;; -------------------------

["ANISEED_DELETE_ME"
 (local *module-name* "aniseed.macros-scratch")
 (local *module* (do
                   (tset package.loaded *module-name* {})
                   (. package.loaded *module-name*)))
 (local *module-locals* (do
                          (tset *module* "aniseed/locals" {})
                          (. *module* "aniseed/locals")))
 (local autoload (. (require "aniseed.autoload") "autoload"))
 (local (fs a fennel _)
   (values (autoload "aniseed.fs")
           (require "aniseed.core")
           (require "fennel")
           (require-macros "m-dummy")))
 (tset *module-locals* "fs" fs)
 (tset *module-locals* "a" a)
 (tset *module-locals* "fennel" fennel)
 (tset *module-locals* "_" _)]

