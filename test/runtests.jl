using GeoFormatTypes
using GeoInterface
using Documenter
using Test

include("test_primitives.jl")
include("test_wrappers.jl")
doctest(GeoInterface)
