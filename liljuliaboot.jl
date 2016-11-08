## Liljulia staruup script
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"src"))
using LilBootstrap

user_boot = joinpath(homedir(),".liljuliarc.jl")
isfile(user_boot) && include(user_boot)
