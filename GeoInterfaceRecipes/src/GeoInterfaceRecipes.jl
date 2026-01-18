module GeoInterfaceRecipes
using RecipesBase
using GeoInterface

export @enable_geo_plots

# This package is deprecated. Plotting recipes are now built into GeoInterface.jl
# as package extensions. See:
# - GeoInterfaceRecipesBaseExt for Plots.jl support
# - GeoInterfaceMakieExt for Makie.jl support

# This stub package exists only to allow smooth upgrades for users who had
# GeoInterfaceRecipes.jl installed. No action is needed - simply load
# GeoInterface with Plots or Makie and the recipes will work automatically.

macro enable(typ)
    :(GeoInterface.@enable_plots RecipesBase $(esc(typ)))
end

# Compat
macro enable_geo_plots(typ)
    :(GeoInterface.@enable_plots RecipesBase $(esc(typ)))
end

end
