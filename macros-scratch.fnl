(local unpack (or _G.unpack table.unpack))

(fn nil? [x] (= :nil (type x)))
(fn seq? [x] (not (nil? (. x 1))))
(fn string? [x] (= (type x) :string))
(fn str [x] (if (= :string (type x)) x (tostring x)))
(fn sorted-each [f x] (let [acc []] (each [k v (pairs x)] (table.insert acc [k v])) (table.sort acc (fn [a b] (< (str (. a 1)) (str (. b 1))))) (each [_ [k v] (ipairs acc)] (f k v))))
(fn contains? [t target] (var seen? false) (each [k v (pairs t)] (when (= k target) (set seen? true))) seen?)

(local locals-key :aniseed/locals)
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

(fn init-module [syms vals]
  (let [result `(do)
        bound-syms (filter-side-effects syms)]
    (each [k v (ipairs syms)]
      (if (not= v init-side-effect!)
          (table.insert result `(local ,(. syms k) ,(. vals k)))
          (table.insert result (. vals k))))
    (table.insert result `(values ,(unpack bound-syms)))
    `(local ,(list (unpack bound-syms)) ,result)))

;;
;; old version wihch used a let block instead of a bunch of locals
(fn init-module-let [syms vals]
  (let [let-bindings []
        bound-syms (filter-side-effects syms)]
    (each [k v (ipairs syms)]
      (if (not= v init-side-effect!)
          (table.insert let-bindings (. syms k))
          (table.insert let-bindings (gensym "_")))
      (table.insert let-bindings (. vals k)))
    `(local ,(list (unpack bound-syms))
            (let ,let-bindings
              (values ,(unpack bound-syms))))))

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

    (init-module keys vals)))

{: multi-local : module}

