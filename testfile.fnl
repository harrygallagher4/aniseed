(require-macros :fnl/aniseed/macros)
(module testfile
  {require {a miniseed
            : fennel}})

(def- x-internal {:internal true})
(def y-public {:internal false})

(defn- do-internal-thing [...]
  (print ...))

(defn do-other-thing [...]
  "Just kidding, it does the same thing"
  (print ...))

(fennel.view *module*)

