module LilBootstrap

const base_dir = normpath(joinpath(dirname(@__FILE__),".."))
const ephemera = joinpath(base_dir,"deps/ephemera")

"""A json-like store of config

Semanticly this is to behave like compile-time config, as opposed to run-time,
though those concepts are not really well defined in this context.  Reading
the code will provide a better gist of what this might actually mean.
"""
config = Dict()


"Remove all traces of this instance of LilBootstrap"
function nuke()
  rm(base_dir;force=true, recursive=true)
end

"Remove all ephemera created by this instance"
function clean()
  rm(ephemera;force=true, recursive=true)
end

"""scaffolding: Inefficiently, redundantly, brute forces its ways to a working installation

TODO: Make this modular, and steps idempotent, and redundancy checks quick
"""
function bootboot()
  mkpath(ephemera)

  url(fork) = "https://github.com/lilinjn/$(fork[:repo])"
  local_path(fork) = joinpath(ephemera,"repos",fork[:repo])
  runf(fork, cmd) = run(Cmd(cmd,dir=local_path(fork)))

  #shell out to git; Boycott LibGit2.jl for hardcoding Github specific behavior
  retrieve(fork) = begin
    lp = local_path(fork)
    print_with_color(:yellow, "$(fork[:repo])...\n")
    ispath(lp) || run(`git clone -b $(fork[:treeish]) $(url(fork)) $(lp)`)
    runf(fork, `git pull`)
  end

  build_config()
  print_with_color(:yellow, "Creating/Updating forks...\n")
  for f = config[:forks]
    retrieve(f)
  end

end

function build_config()

  #technically, should be commit-ish, but that term is artless
  fork(repo, treeish="master") = Dict(:repo=>repo, :treeish=>treeish)

  config[:forks] = [fork("Conda.jl"), fork("IJulia.jl")]
  config
end

end
