module GeoInterface

using Base.Iterators: flatten

export testgeometry, isgeometry, geomtype, ncoord, getcoord, ngeom, getgeom

include("types.jl")
include("interface.jl")
include("fallbacks.jl")
include("utils.jl")

end # module
