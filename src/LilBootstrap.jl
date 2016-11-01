__precompile__()

module LilBootstrap

const base_dir = normpath(joinpath(dirname(@__FILE__),".."))
const ephemera = joinpath(base_dir,"deps/ephemera")
const local_repos = joinpath(ephemera,"repos")
const version_dir = "v$(Base.VERSION.major).$(Base.VERSION.minor)"
const dot_julia = joinpath(ephemera,".julia")
const compile_cache = joinpath(dot_julia, "lib",version_dir)
const conda_dir = joinpath(ephemera,"conda")

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

#----------------------------------------------------

"Prelude"
⇶(xs,f) = [f(x...) for x=xs]


#----------------------------------------------------


"""
bootboot: Inefficiently, redundantly, brute forces its ways to a working installation
<scaffolding: Make this modular, and steps idempotent, and redundancy checks quick>
"""
function bootboot()

  #creates necessary directories
  mkpath(joinpath(dot_julia,version_dir))
  mkpath(conda_dir)

  # todo: smarter up to date check
  retrieve(fork, version) = begin
    repo_str(fork) = "$(fork).jl"
    url(fork) = "https://github.com/lilinjn/$(repo_str(fork))"
    local_path(fork) = joinpath(local_repos,string(fork))
    pkg_path(fork) = joinpath(dot_julia, version_dir,string(fork))

    #shell out to git; Boycott LibGit2.jl for hardcoding Github specific behavior
    runf(fork, cmd) = run(Cmd(cmd,dir=local_path(fork)))

    lp = local_path(fork)
    print_with_color(:yellow, "$(fork)...\n")
    ispath(lp) || run(`git clone -b $(version) $(url(fork)) $(lp)`)

    runf(fork, `git pull`)
    pp = pkg_path(fork)
    rm(pp, force=true)
    symlink(lp, pp)

    fork
  end

  print_with_color(:yellow, "Retrieving forks...\n")
  config[:forks]  ⇶ retrieve

  nothing
end

function build_config()

  # when things stabilize it will look like:  (:Conda,"243b09f")
  config[:forks] = [(:Conda,  "master"),
                    (:PyCall, "master"),
                    (:PyPlot, "master"),
                    (:IJulia, "master"),
                    (:JSON,   "master"),
                    (:ZMQ,    "master"),
                    (:Compat, "master")]

  #conda:zeromq                    4.1.3, 1.0.0
  # jupyter 1.0.0
  # pil pil:      1.1.7-py27_2
  # 1.5.3-np111py27_1
end



#-----------------Main Setup------------------
build_config()
bootboot() # relies on precompilation to smartly update when necessary


#-----------------------------------------------

function __init__()

  # all hell breaks loose now
  push!(LOAD_PATH, Pkg.dir()) #allow access to Pkgs from the host julia (I will regret this)
  ENV["JULIA_PKGDIR"]=dot_julia
  prepend!(Base.LOAD_CACHE_PATH,[compile_cache])
  #=
  Commentary on the current state of Julia:
  I am fine with LOAD_PATH and LOAD_CACHE_PATH; I very much dislike
  ENV["JULIA_PKGDIR"], and all things Pkg in general, to the point I even considered
  `push!(LOAD_PATH, local_repos);ENV["JULIA_PKGDIR"]=tempname()`  However, I chose to be a little
  less hardline, and the current version allows Pkg's from the host julia
  config to (possibly) still work, albeit requiring a potential re-pre-compilation

  After this module had loaded, Pkg.add, rm, etc could still work,
  but inefficiently -- re-pulling in Pkgs already
  available on the host julia.

  But the whole point is that we are trying not use Pkg at all.

  But there are times in which one finds themselves in a hacker fugue state, and just wants
  to pull in code the quick and dirty way, rather than recommended "fork and hack" approach endorsed
  by LilBootstrap.

  As a practical sanity check/speed bump, any initial Pkg command will fail due to the lack of a METADATA dir,
  asking the user to explicitly run Pkg.init() -- which is easy enough

  And I very much like the idea of letting myself shoot my own foot off -- Now that is a good design!
  =#

end

end

#=
Cleanup:
   * printing
   * pinning forks to specific versions
=#
