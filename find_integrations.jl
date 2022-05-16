# Adapted from https://raw.githubusercontent.com/JuliaData/Tables.jl/main/find_integrations.jl
####
#### automatically generate a list of integrations
####

###
### Usage
###
### 1. ensure a development version of GeoInterface.jl (`pkg> add GeoInterface`)
### 2. make sure the General registry is up to date (`pkg> up`)
### 3. run this script, which uses the first depot from DEPOT_PATH

DEPOT = first(DEPOT_PATH)
REGISTRIES = joinpath(DEPOT, "registries")
@info DEPOT
# find each package w/ a direct dependency on GeoInterface.jl
general = joinpath(DEPOT, "General")
mkpath(general)
# run(`tar -xzf General.tar.gz -C $general`)
pkgs = cd(REGISTRIES) do
    dirname.(readlines(`grep -rl ^GeoInterface General/. --include=Deps.toml`))
end

pkgnames = sort([splitpath(x)[end] for x in pkgs])

function parseurl(file)
    repo = readlines(file)[end]
    return strip(split(repo, " = ")[end], '"')
end

urls = [parseurl(joinpath(REGISTRIES, "General", string(first(nm)), nm, "Package.toml"))
        for nm in pkgnames]

open(joinpath(dirname(@__DIR__), "GeoInterface.jl", "INTEGRATIONS.md"), "w+") do io
    println(io, "# Packages\nPackages currently integrating with GeoInterface.jl:")
    for (nm, url) in zip(pkgnames, urls)
        println(io, "* [$nm]($url)")
    end
end

