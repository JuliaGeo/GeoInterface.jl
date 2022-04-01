module GeoInterface

include("types.jl")
include("interface.jl")
include("defaults.jl")
include("utils.jl")

export testgeometry
export isgeometry

export geomtype
export ncoord
export getcoord
export ngeom
export getgeom

end # module
