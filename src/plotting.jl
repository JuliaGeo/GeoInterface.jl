function _makie_plottype end
function _makie_convert_arguments end
function _makie_convert_array_arguments end

"""

    GeoInterface.@enable_makie(Makie, GeometryType)

Enable Makie plotting for a type `Geom` that implements the 
geometry interface defined in `GeoInterface`.

# Usage

```julia
using GeoInterface, Makie

struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

# Enable Makie.jl plotting
GeoInterface.@enable_makie Makie GeometryType
```
"""
macro enable_makie(LocalMakie, Geom)
    esc(expr_enable_makie(LocalMakie, Geom))
end

# We need to use `LocalMakie` so that this macro can be called in a package 
# extension as `@enable_makie Makie Geom` otherwise Makie will not be available even 
# after it is loaded, because ot the world age of the @enable macro
function expr_enable_makie(LocalMakie, Geom)
    quote
        # plottype
        function $LocalMakie.plottype(geom::$Geom)
            $_makie_plottype(geom)
        end
        function $LocalMakie.plottype(geom::AbstractArray{<:$Geom})
            $_makie_plottype(first(geom))
        end
        function $LocalMakie.plottype(geom::AbstractArray{<:Union{Missing,<:$Geom}})
            $_makie_plottype(first(skipmissing(geom)))
        end
        # we need `AbstractVector` specifically for dispatch
        function $LocalMakie.plottype(geom::AbstractVector{<:$Geom})
            $_makie_plottype(first(geom))
        end
        function $LocalMakie.plottype(geom::AbstractVector{<:Union{Missing,<:$Geom}})
            $_makie_plottype(first(skipmissing(geom)))
        end

        # convert_arguments
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Poly}, geom::$Geom; kw...)
            $_makie_convert_arguments(p, geom)
        end
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Poly}, geoms::AbstractArray{<:$Geom}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Poly}, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
        function $LocalMakie.convert_arguments(p::$LocalMakie.PointBased, geom::$Geom; kw...)
            $_makie_convert_arguments(p, geom)
        end
        function $LocalMakie.convert_arguments(p::$LocalMakie.PointBased, geoms::AbstractArray{<:$Geom}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
        function $LocalMakie.convert_arguments(p::$LocalMakie.PointBased, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Lines}, geom::$Geom; kw...)
            $_makie_convert_arguments(p, geom)
        end
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Lines}, geoms::AbstractArray{<:$Geom}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
        function $LocalMakie.convert_arguments(p::Type{<:$LocalMakie.Lines}, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_makie_convert_array_arguments(p, geoms)
        end
    end
end

function _plots_apply_recipe end
function _plots_apply_recipe_array end

"""
     GeoInterface.@enable_plots(RecipesBase, GeometryType)

Macro to add RecipesBase.jl/Plots.jl recipes to a geometry type.

# Usage

```julia
using RecipesBase, GeoInterface

struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

# Enable Plots.jl plotting
GeoInterfaceRecipes.@enable_plots RecipesBase MyGeometry
```
"""
macro enable_plots(LocalRecipesBase, typ)
    esc(expr_enable_plots(LocalRecipesBase, typ))
end

# We need to use `LocalRecipesBase` so that this macro can be called in a package 
# extension as `@enable_plots RecipesBase Geom` otherwise RecipesBase will not be available even 
# after it is loaded, because ot the world age of the @enable_plots macro
function expr_enable_plots(LocalRecipesBase, typ)
    quote
        # We recreate the apply_recipe functions manually here
        # as nesting the @recipe macro doesn't work.
        function $LocalRecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol, Base.Any}, geom::$typ)
            $_plots_apply_recipe(plotattributes, geom)
        end
        function $LocalRecipesBase.apply_recipe(plotattributes::Base.AbstractDict{Base.Symbol, Base.Any}, geom::Base.AbstractVector{<:Base.Union{Base.Missing,<:$typ}})
            $_plots_apply_recipe_array(plotattributes, geom)
        end
    end
end
