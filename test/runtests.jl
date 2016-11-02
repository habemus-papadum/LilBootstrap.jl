##todo -- create subprocess
##todo -- test forks
##todo -- fix travis.ci Coverage

using Base.Test

using LilBootstrap
using PackagePrelude

embedded = PackagePrelude.list_packages(forks=false)
print_with_color(:yellow, "Testing loading...\n")
for e in embedded
  print_with_color(:yellow, "$(e)...\n")
  eval(:(using $e))
end

print_with_color(:yellow, "Run tests...\n")
for e in embedded
  print_with_color(:yellow, "$(e)...\n")
  test = joinpath(PackagePrelude.locate_package(e),"test", "runtests.jl")
  isfile(test) && include(test)
end
