__precompile__()
module LilNotebook

  import LilConda: ensure_conda
  using PackagePrelude: ensure_fork, ⇶

  #forks
  [  (:IJulia,    "master"),
     (:NBInclude, "master"),
     (:ZMQ,       "master"),
     (:SHA,       "master")] ⇶ ensure_fork

  ensure_conda("jupyter", v"1.0.0")
  ## add nb extensions
end
