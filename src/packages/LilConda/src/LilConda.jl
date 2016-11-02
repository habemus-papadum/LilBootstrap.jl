__precompile__()

module LilConda
  using PackagePrelude: ensure_fork, ⇶
  [ (:Conda,     "master")] ⇶ ensure_fork

  using Conda
  function ensure_conda(package, version, channel=:anaconda)
    pstr = "$(package)=$(version)"
    Conda.is_installed(package,version) || Conda.add(pstr)
  end

  function python_dir()=Conda.PYTHONDIR

  ##bootstrap conda
  Conda.add("zlib=1.2.8")

end
