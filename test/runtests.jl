using GeoInterface
using Documenter
using Test

include("test_primitives.jl")
include("test_wrappers.jl")
include("test_extension.jl")
doctest(GeoInterface)
