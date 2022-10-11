# GeoInterfaceMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jw3126.github.io/GeoInterfaceMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jw3126.github.io/GeoInterfaceMakie.jl/dev/)
[![Build Status](https://github.com/jw3126/GeoInterfaceMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jw3126/GeoInterfaceMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)

Makie support for any geometry that implements [GeoInterface](https://github.com/JuliaGeo/GeoInterface.jl).

# Usage
Add Makie support to a type that implements GeoInterface:
```julia
struct MyGeometry
...
end
# overload GeoInterface methods
...
import GeoInterfaceMakie
GeoInterfaceMakie.@enable MyGeometry
```
