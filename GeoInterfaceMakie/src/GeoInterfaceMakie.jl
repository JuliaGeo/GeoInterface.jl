module GeoInterfaceMakie

using GeoInterface
import GeoInterface as GI

function _convert_arguments end
function _convert_array_arguments end
function _plottype end

"""

    GeoInterfaceMakie.@enable(M::Module, GeometryType)

Enable Makie based plotting for a type module `M` and a type `Geom`
that implements the geometry interface defined in `GeoInterface`.

`M` can be either `Makie` or `MakieCore`. Passing it in directly
avoids directe dependency on MakieCore here.

# Usage
```julia
struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

# Enable Makie.jl plotting
GeoInterfaceMakie.@enable MyGeometry
```
"""
macro enable(MC, Geom) 
    expr_enable(MC, Geom)
end
macro enable(Geom) 
    throw(ArgumentError("Use the two-argument syntax of enable: `@enable MakieCore MyGeometry`. Specify Makie or MakieCore Module as the first argument, and your geometry type as the second"))
end

# TODO 
# Features and Feature collections
# https://github.com/JuliaGeo/GeoInterface.jl/pull/72#issue-1406325596

function expr_enable(MC, Geom::Union{Symbol,Expr})
    MC = esc(MC)
    Geom = esc(Geom)
    quote
        # plottype
        function $MC.plottype(geom::$Geom)
            $_plottype(geom)
        end
        function $MC.plottype(geom::AbstractArray{<:$Geom})
            $_plottype(first(geom))
        end
        function $MC.plottype(geom::AbstractArray{<:Union{Missing,<:$Geom}})
            $_plottype(first(skipmissing(geom)))
        end
        # we need `AbstractVector` specifically for dispatch
        function $MC.plottype(geom::AbstractVector{<:$Geom})
            $_plottype(first(geom))
        end
        function $MC.plottype(geom::AbstractVector{<:Union{Missing,<:$Geom}})
            $_plottype(first(skipmissing(geom)))
        end

        # convert_arguments
        function $MC.convert_arguments(p::Type{<:$MC.Poly}, geom::$Geom; kw...)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Poly}, geoms::AbstractArray{<:$Geom}; kw...)
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Poly}, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geom::$Geom; kw...)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geoms::AbstractArray{<:$Geom}; kw...)
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Lines}, geom::$Geom; kw...)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Lines}, geoms::AbstractArray{<:$Geom}; kw...)
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Lines}, geoms::AbstractArray{<:Union{Missing,<:$Geom}}; kw...)
            $_convert_array_arguments(p, geoms)
        end
    end
end

end