module GeoInterfaceMakie

using GeoInterface
import MakieCore as MC
import GeometryBasics as GB
import GeoInterface as GI


function _plottype(geom)
    plottype_from_geomtrait(GI.geomtrait(geom))
end
function plottype_from_geomtrait(::Union{GI.LineStringTrait, GI.MultiLineStringTrait})
    MC.Lines
end
function plottype_from_geomtrait(::Union{GI.PointTrait, GI.MultiPointTrait})
    MC.Scatter
end
function plottype_from_geomtrait(::Union{GI.PolygonTrait,GI.MultiPolygonTrait, GI.LinearRingTrait})
    MC.Poly
end

function _convert_arguments(t, geom)::Tuple
    geob = GI.convert(GB, geom)
    MC.convert_arguments(t, geob)
end
function _convert_array_arguments(t, geoms::AbstractArray{T})::Tuple where T
    if Missing <: T
        geob = map(geom -> GI.convert(GB, geom), skipmissing(geoms))
    else
        geob = map(geom -> GI.convert(GB, geom), geoms)
    end
    MC.convert_arguments(t, geob)
end

function expr_enable(Geom)
    quote
        function $MC.plottype(geom::$Geom)
            $_plottype(geom)
        end
        # TODO: this method doesn't seem to do anything
        function $MC.plottype(geom::AbstractArray{<:Union{Missing,<:$Geom}})
            $_plottype(first(geom))
        end
        function $MC.convert_arguments(p::Type{<:$MC.Poly}, geom::$Geom)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Poly}, geoms::AbstractArray{<:Union{Missing,<:$Geom}})
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geom::$Geom)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geoms::AbstractArray{<:Union{Missing,<:$Geom}})
            $_convert_array_arguments(p, geoms)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Lines}, geom::$Geom)
            $_convert_arguments(p, geom)
        end
        function $MC.convert_arguments(p::Type{<:$MC.Lines}, geoms::AbstractArray{<:Union{Missing,<:$Geom}})
            $_convert_array_arguments(p, geoms)
        end
    end
end

"""

    GeoInterfaceMakie.@enable(GeometryType)

Enable Makie based plotting for a type `Geom` that implements the geometry interface 
defined in `GeoInterface`.

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
macro enable(Geom)
    esc(expr_enable(Geom))
end

# Enable Makie.jl for GeoInterface wrappers
@enable GeoInterface.Wrappers.WrapperGeometry

# TODO 
# Features and Feature collections
# https://github.com/JuliaGeo/GeoInterface.jl/pull/72#issue-1406325596

end
