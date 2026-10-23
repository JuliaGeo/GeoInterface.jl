# GeoInterfaceRecipes.jl

**This package is deprecated.**

Plotting recipes for GeoInterface geometries are now built directly into [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) as package extensions:

- **Plots.jl support**: Load `GeoInterface` with `Plots` and recipes work automatically
- **Makie.jl support**: Load `GeoInterface` with `Makie` and `GeometryBasics` for Makie plotting

## Migration

No action is needed. Simply remove `GeoInterfaceRecipes` from your dependencies and use `GeoInterface` directly with your preferred plotting package.

```julia
using GeoInterface
using Plots  # or using Makie

# Plotting just works
plot(my_geometry)
```

This empty package exists only to provide a smooth upgrade path for users who had GeoInterfaceRecipes.jl in their dependencies.
