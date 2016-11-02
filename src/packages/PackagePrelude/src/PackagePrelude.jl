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
const packages_dir = joinpath(base_dir,"src", "packages")



# helpers
⇶(xs,f) = [f(x...) for x=xs]

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


## startup
mkpath(joinpath(dot_julia,version_dir))
mkpath(conda_dir)

#core forks, used everwhere, and needs globally consistent versions
[   (:JSON,      "master"),
    (:Compat,    "master")] ⇶ ensure_fork



end
