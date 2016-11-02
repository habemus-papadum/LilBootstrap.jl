##todo -- create subprocess
##todo -- test forks

using Base.Test

using LilBootstrap
using PackagePrelude

embedded = PackagePrelude.list_packages(forks=false)
println("Testing loading")
for e in embedded
  eval(:(import $e))
end

for e in embedded
  test = joinpath(PackagePrelude.locate_package(e),"test", "runtests.jl")
  isfile(test) && include(test)
end
