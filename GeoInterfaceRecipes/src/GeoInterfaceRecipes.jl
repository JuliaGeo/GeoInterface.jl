module GeoInterfaceRecipes

using GeoInterface, RecipesBase
import GeoInterface: @enable_plots

# This is now an empty package, but loading both GeoInterface and RecipesBase
# will trigger the extension which loads the recipes

# Backwards compatible
var"@enable" = var"@enable_plots"
var"@enable_geo_plots" = var"@enable_plots"

export @enable_plots
export @enable
export @enable_geo_plots

end
