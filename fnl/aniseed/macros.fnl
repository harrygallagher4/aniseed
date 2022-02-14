;; All of Aniseed's macros in one place.
;; Can't be compiled to Lua directly.

;; Automatically loaded through require-macros for all Aniseed based evaluations.

(fn nil? [x]
  (= :nil (type x)))

(fn seq? [x]
  (not (nil? (. x 1))))

(fn string? [x] (= (type x) :string))

(fn str [x]
  (if (= :string (type x))
    x
    (tostring x)))

(fn sorted-each [f x]
  (let [acc []]
    (each [k v (pairs x)]
      (table.insert acc [k v]))
    (table.sort
      acc
      (fn [a b]
        (< (str (. a 1)) (str (. b 1)))))
    (each [_ [k v] (ipairs acc)]
      (f k v))))

(fn contains? [t target]
  (var seen? false)
  (each [k v (pairs t)]
    (when (= k target)
      (set seen? true)))
  seen?)

;; This marker can be used by a post-processor to delete a useless byproduct line.
(local delete-marker :ANISEED_DELETE_ME)

;; We store all locals under this for later splatting.
(local locals-key :aniseed/locals)

;; Various symbols we want to use multiple times.
;; Avoids the compiler complaining that we're introducing locals without gensym.
(local mod-name-sym (sym :*module-name*))
(local mod-sym (sym :*module*))
(local mod-locals-sym (sym :*module-locals*))
(local autoload-sym (sym :autoload))

(local init-side-effect! (gensym "_"))
(local internal-syms {locals-key true
                      mod-name-sym true
                      mod-sym true
                      mod-locals-sym true
                      init-side-effect! true})

(fn is-internal-sym? [sym]
  (contains? internal-syms sym))
(fn is-normal-sym? [sym]
  (not (is-internal-sym? sym)))

(fn multi-local [syms vals]
  (let [let-bindings []]
    (each [k v (ipairs syms)]
      (table.insert let-bindings (. syms k))
      (table.insert let-bindings (. vals k)))
    `(local ,(list (unpack syms))
            (let ,let-bindings
              (values ,(unpack syms))))))

(fn filter-side-effects [syms]
  (icollect [_ v (ipairs syms)]
    (when (not= v init-side-effect!) v)))
(fn filter-internal-syms [syms]
  (icollect [_ v (ipairs syms)]
    (when (is-normal-sym? v) v)))

;; run function for each module local
;; "local" as in something other than *module* *module-locals* etc.
(fn each-local! [keys f]
  (let [local-keys (filter-internal-syms keys)]
    (each [k v (pairs local-keys)]
      (f k v))))

(fn locals-with-side-effects [syms vals]
  (let [result `(do)
        bound-syms (filter-side-effects syms)]
    (each [k v (ipairs syms)]
      (if (not= v init-side-effect!)
          (table.insert result `(local ,(. syms k) ,(. vals k)))
          (table.insert result (. vals k))))
    (table.insert result `(values ,(unpack bound-syms)))
    `(local ,(list (unpack bound-syms)) ,result)))
;; Upserts the existence of the module for subsequent def forms and expands the
;; bound function calls into the current context.
;;
;; On subsequent interactive calls it will expand the existing module into your
;; current context. This should be used by Conjure as you enter a buffer.
;;
;; (module foo
;;   {require {nvim aniseed.nvim}}
;;   {:some-optional-base :table-of-things
;;    :to-base :the-module-off-of})
;;
;; (module foo) ;; expands foo into your current context

(fn module [mod-name mod-fns mod-base]
  (let [existing-mod (?. _G :package :loaded (tostring mod-name))
        interactive? (and (= :table (type existing-mod))
                          (not _G.ANISEED_STATIC_MODULES))

        keys [mod-name-sym mod-sym mod-locals-sym]
        vals [(tostring mod-name)
              (if interactive?
                  `(. package.loaded ,mod-name-sym)
                  `(do
                     (tset package.loaded ,mod-name-sym ,(or mod-base {}))
                     (. package.loaded ,mod-name-sym)))
              (if interactive?
                  `(. ,mod-sym ,locals-key)
                  `(do
                     (tset ,mod-sym ,locals-key {})
                     (. ,mod-sym ,locals-key)))]

        => (fn [k v]
             (table.insert keys (if (string? k) (sym k) k))
             (table.insert vals v))
        =!> (fn [v]
              (table.insert keys init-side-effect!)
              (table.insert vals v))]

    (when mod-fns
      (when (contains? mod-fns autoload-sym)
        (=> autoload-sym `(. (require :aniseed.autoload) :autoload)))
      (sorted-each
        (fn [mod-fn args]
          (if (seq? args)
              (each [_ arg (ipairs args)]
                (=!> `(,mod-fn ,(tostring arg))))
              (sorted-each (fn [bind arg]
                             (=> bind `(,mod-fn ,(tostring arg))))
                           args))) mod-fns))

    (when (seq? keys)
      (each-local!
        keys
        (fn [_ k]
          (=!> `(tset ,mod-locals-sym ,(tostring k) ,k)))))

    (when interactive?
      (sorted-each
        (fn [k v]
          (when (not= k locals-key)
            (=> (sym k) `(. ,mod-sym ,k))))
        existing-mod)
      (when (. existing-mod locals-key)
        (sorted-each 
          (fn [k v]
            (=> (sym k) `(. ,mod-locals-sym ,k)))
          (. existing-mod locals-key))))

    (locals-with-side-effects keys vals)))


(fn def- [name value]
  (locals-with-side-effects
    [name init-side-effect!]
    [value `(tset ,mod-locals-sym ,(tostring name) ,name)]))

(fn def [name value]
  (locals-with-side-effects
    [name init-side-effect!]
    [value `(tset ,mod-sym ,(tostring name) ,name)]))

(fn defn- [name ...]
  (locals-with-side-effects
    [name init-side-effect!]
    [`(fn ,name ,...) `(tset ,mod-locals-sym ,(tostring name) ,name)]))

(fn defn [name ...]
  (locals-with-side-effects
    [name init-side-effect!]
    [`(fn ,name ,...) `(tset ,mod-sym ,(tostring name) ,name)]))

(fn defonce- [name value]
  `(def- ,name (or ,name ,value)))

(fn defonce [name value]
  `(def ,name (or ,name ,value)))

(fn deftest [name ...]
  `(let [tests# (or (. ,mod-sym :aniseed/tests)
                    {})]
     (tset tests# ,(tostring name) (fn [,(sym :t)] ,...))
     (tset ,mod-sym :aniseed/tests tests#)))

(fn time [...]
  `(let [start# (vim.loop.hrtime)
         result# (do ,...)
         end# (vim.loop.hrtime)]
     (print (.. "Elapsed time: " (/ (- end# start#) 1000000) " msecs"))
     result#))

;; Checks surrounding scope for *module* and, if found, makes sure *module* is
;; inserted after `last-expr` (and therefore *module* is returned)
(fn wrap-last-expr [last-expr]
  (if (rawget (. (get-scope) :symmeta) :*module*)
      `(do ,last-expr ,(sym :*module*))
      last-expr))

;; Used by aniseed.compile to wrap the entire body of a file, replacing the
;; last expression with another wrapper; `wrap-last-expr` which handles the
;; module's return value.
;;
;; i.e.
;; (wrap-module-body
;; (module foo)
;; (def x 1)
;; (vim.cmd "...")) ; vim.cmd returns a string which becomes the returned value
;;                  ; for the entire file once compiled
;; --> expands to:
;; (do
;;   (module foo)
;;   (def x 1)
;;   (wrap-last-expr (vim.cmd "...")))
;; --> expands to:
;; (do
;;   (module foo)
;;   (def x 1)
;;   (do
;;     (vim.cmd "...")
;;     *module*))
(fn wrap-module-body [...]
  (let [body# [...]
        last-expr# (table.remove body#)]
    (table.insert body# `(wrap-last-expr ,last-expr#))
    `(do ,(unpack body#))))

{:module module
 :def- def- :def def
 :defn- defn- :defn defn
 :defonce- defonce- :defonce defonce
 :wrap-last-expr wrap-last-expr
 :wrap-module-body wrap-module-body
 :deftest deftest
 :time time}
