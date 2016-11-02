__precompile__()

module LilBootstrap

const base_dir = normpath(joinpath(dirname(@__FILE__),".."))
const ephemera = joinpath(base_dir,"deps/ephemera")
const local_repos = joinpath(ephemera,"repos")
const version_dir = "v$(Base.VERSION.major).$(Base.VERSION.minor)"
const dot_julia = joinpath(ephemera,".julia")
const compile_cache = joinpath(dot_julia, "lib",version_dir)
const conda_dir = joinpath(ephemera,"conda")
const packages_dir = joinpath(base_dir,"src", "packages")


function launch()
  global dot_julia
  global packages_dir
  # all hell breaks loose now
  push!(LOAD_PATH, packages_dir)
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


#-----------------------------------------------

function __init__()
  launch()
end

end
