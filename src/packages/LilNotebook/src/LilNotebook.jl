__precompile__()
module LilNotebook
  export notebook,remote_headless

  using PackagePrelude: ensure_fork, ⇶, local_repos

  #forks
  [  (:IJulia,    "master"),
     (:NBInclude, "master")] ⇶ ensure_fork

  using LilConda
  using IJulia

  ## add nb extensions
  nb_ext="jupyter_contrib_nbextensions"
  ensure_fork(nb_ext,"master", julia=false)
  nb_ext_dir = joinpath(local_repos,nb_ext)

  ## install
  println("Install jupyter notebook extensions")
  pip = joinpath(LilConda.python_dir(),"pip")
  run(`$pip --quiet install -e $nb_ext_dir`)
  run(`$(IJulia.jupyter) contrib nbextension install --sys-prefix --symlink`)

  ##add extension_configurator
  configurator="jupyter_nbextensions_configurator"
  ensure_fork(configurator,"master", julia=false)
  configurator_dir = joinpath(local_repos,configurator)
  run(`$pip --quiet install -e $configurator_dir`)
  run(`$(IJulia.jupyter) nbextensions_configurator enable --sys-prefix`)

  function remote_headless(; dir=pwd(), )
    notebook(dir=dir, detached=detached, ifc="0.0.0.0", no_browser=true)
  end

  function notebook(; dir=pwd(), ifc="localhost", no_browser=false)
      IJulia.inited && error("IJulia is already running")
      env = copy(ENV)
      delete!(env, "JULIA_PKGDIR")
      cmd=`$(IJulia.jupyter) notebook -y --ip=$ifc $(no_browser ? "--no-browser" : "")`
      p = spawn(pipeline(Cmd(cmd, dir=dir, detach=true, env=env), stdout=STDOUT, stderr=STDERR))
#
      try
          wait(p)
      catch e
          if isa(e, InterruptException)
              kill(p, 2) # SIGINT
          else
              kill(p) # SIGTERM
              rethrow()
          end
      end
  end
end
