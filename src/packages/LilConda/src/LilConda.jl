__precompile__()

module LilConda
  using PackagePrelude: ensure_fork, ⇶
  [ (:Conda,     "master")] ⇶ ensure_fork

  using Conda
  function ensure_conda(package, version, channel=:anaconda)
    Conda.add("$(package)=$(version)")
  end
end
