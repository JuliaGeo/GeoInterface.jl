module GeoInterfaceRecipes

using GeoInterface, RecipesBase
import GeoInterface: @enable, @enable_geo_plots

# This is now an empty package, but loading both GeoInterface and RecipesBase
# will trigger the extension which loads the recipes
export @enable
export @enable_geo_plots

end
