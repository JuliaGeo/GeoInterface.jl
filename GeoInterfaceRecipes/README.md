[![Build Status](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGeo/GeoInterface.jl/actions/workflows/CI.yml?query=branch%3Amain)

# GeoInterfaceRecipes

Plot recipes for GeoInterface objects, using RecipesBase.jl (and Plots.jl)

# Usage
Add RecipesBase.jl support to a type that implements GeoInterface:
```julia
struct MyGeometry
...
end
# overload GeoInterface methods
...
import GeoInterfaceRcipes
GeoInterfaceMakie.@enable_geo_plots MyGeometry
```
