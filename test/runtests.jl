using GeoFormatTypes
using GeoInterface
using Documenter
using Test

include("test_primitives.jl")
include("test_wrappers.jl")
include("test_makie.jl")
include("test_plots.jl")
include("test_dataapi.jl")
doctest(GeoInterface)
