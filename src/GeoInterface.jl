module GeoInterface

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeoInterface

include("types.jl")
include("interface.jl")
include("defaults.jl")
# include("primitives.jl")  # needs rethinking
include("utils.jl")

export testgeometry
export isgeometry

export geomtype
export ncoord
export getcoord
export ngeom
export getgeom

end # module
