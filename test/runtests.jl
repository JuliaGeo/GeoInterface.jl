using GeoInterface
using Documenter
using Test

include("test_primitives.jl")
include("wrappers.jl")
doctest(GeoInterface)
