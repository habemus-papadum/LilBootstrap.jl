__precompile__()
module LilNotebook

  using PackagePrelude: ensure_fork, ⇶

  #forks
  [  (:IJulia,    "master"),
     (:NBInclude, "master")] ⇶ ensure_fork

  ## add nb extensions
end
