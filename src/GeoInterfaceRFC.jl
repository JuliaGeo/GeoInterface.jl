module GeoInterfaceRFC

include("types.jl")
include("interface.jl")
include("defaults.jl")
# include("primitives.jl")  # needs rethinking
include("utils.jl")

export test_interface_for_geom

export geomtype
export ncoord
export getcoord
export ngeom
export getgeom

end # module
