__precompile__()

module LilConda
  using PackagePrelude: ensure_fork, ⇶
  [ (:Conda,     "master")] ⇶ ensure_fork

  using Conda
  function ensure_conda(package, version, channel=:anaconda)
    pstr = "$(package)=$(version)"
    Conda.exists(pstr) || Conda.add(pstr)
  end

  ##bootstrap conda
  Conda.add("zlib=1.2.8")
end
