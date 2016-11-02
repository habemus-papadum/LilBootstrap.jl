__precompile__()

#explcility duplicates some code from LilBootstrap to avoid
#precomplialtion difficulties

"Package Boilerplate"
module PackagePrelude

const base_dir = normpath(joinpath(dirname(@__FILE__),"..","..","..",".."))
const ephemera = joinpath(base_dir,"deps/ephemera")
const local_repos = joinpath(ephemera,"repos")
const version_dir = "v$(Base.VERSION.major).$(Base.VERSION.minor)"
const dot_julia = joinpath(ephemera,".julia")
const compile_cache = joinpath(dot_julia, "lib",version_dir)
const conda_dir = joinpath(ephemera,"conda")
const conda_lib_dir = joinpath(conda_dir, "lib")
const packages_dir = joinpath(base_dir,"src", "packages")



# helpers
⇶(xs,f) = [f(x...) for x=xs]

#break windows
function libfile(name; ensure = true)
  location = joinpath(conda_lib_dir, "lib$(name).$(Libdl.dlext)")
  ensure && Base.Libdl.dlopen_e(location) == C_NULL && error("Missing shared library: $(location)")
  location
end

"""
Inefficiently, redundantly, brute forces its ways to a working installation

TODO: Make this modular, and steps idempotent, and redundancy checks quick
"""
ensure_fork(fork, version) = begin
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


# lifted from https://github.com/JuliaLang/julia/blob/master/base/REPLCompletions.jl
"Helper to check if a path location is a module; returns a symbol if so, and nothing otherwise"
module_helper(dir, pname) = begin
  (pname[1] == '.' || pname == "METADATA" || pname == "REQUIRE") && return nothing
  mod_sym = Symbol(endswith(pname, ".jl") ?  pname[1:end - 3] : pname)
  # Valid file paths are
  #   <Mod>.jl
  endswith(pname, ".jl") && isfile(joinpath(dir, pname)) && return mod_sym
  #   <Mod>/src/<Mod>.jl
  #   <Mod>.jl/src/<Mod>.jl
  isfile(joinpath(dir, pname, "src", "$(mod_sym).jl")) &&  return mod_sym
  return nothing
end


"List packages managed via LilBootstrap"
list_packages(;embedded=true,forks=true) = begin
  pkgs = []

  process(dir) = begin
    ns = [module_helper(dir,e) for e in readdir(dir)]
    filter(n->n!=nothing, ns)
  end

  embedded && append!(pkgs, process(packages_dir))
  forks && append!(pkgs, process(local_repos))

  return pkgs |> unique |> sort
end

"""
Locate a package in the LilBootstrap enviroment.  returns `nothing` if package is not found

Emulates the behavior of `using` and may return items that are located out of tree
"""
function locate_package(pkg)
  pkg=string(pkg)
  for d in [Pkg.dir(); LOAD_PATH; pwd()]
    isdir(d) || continue
    (module_helper(d,pkg) != nothing) && return joinpath(d,pkg)
    (module_helper(d,"$pkg.jl") != nothing) && return joinpath(d,pkg)
  end
  nothing
end

## startup
mkpath(joinpath(dot_julia,version_dir))
mkpath(conda_dir)

#core forks, used everwhere, and needs globally consistent versions
[   (:JSON,      "master"),
    (:Compat,    "master")] ⇶ ensure_fork



end
