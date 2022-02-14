(local a (require :miniseed))
(require-macros :fnl/aniseed/macros)

(macro require-from [mod s]
  (let [syms (if (sequence? s) s [s])
        bindings {}]
    (each [k v (ipairs syms)]
      (tset bindings (tostring v) v))
    `(local ,bindings (require ,mod))))

(macrodebug
  (require-from :miniseed [map concat]))
(macrodebug
  (module aniseed.scratch
    {require {: fennel
              a miniseed}}))
(macrodebug
  (def- x {:test false}))
(macrodebug
  (def y {:test true}))
(macrodebug
  (defn- do-thing [args] (print args)))
(macrodebug
  (defn do-other-thing [args] (print args)))

; (?. _G :package :loaded :fennel)

; (:require
;    [aniseed :as a :refer [map concat table?] :rename {table? tbl?}])
; -->
; (local (a map concat tbl?)
;   (let [a (require :aniseed-lite)
;         {:map map :concat concat :table? tbl?} a]
;     (values a map concat tbl?)))
