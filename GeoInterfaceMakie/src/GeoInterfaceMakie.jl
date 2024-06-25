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
    if !(eltype(geob) <: GB.AbstractGeometry) || eltype(geob) isa Union # Unions are bad
        if isempty(geob)
            geob = geob
        end
        first_trait = GI.geomtrait(first(geob))
        last_trait = GI.geomtrait(last(geob))
        if first_trait isa GI.PolygonTrait || first_trait isa GI.MultiPolygonTrait
            if last_trait isa GI.PolygonTrait || last_trait isa GI.MultiPolygonTrait
                geob = to_multipoly(geob)
            end
        elseif first_trait isa GI.LineStringTrait || first_trait isa GI.MultiLineStringTrait
            if last_trait isa GI.LineStringTrait || last_trait isa GI.MultiLineStringTrait
                geob = to_multilinestring(geob)
            end
        end
    end
    return MC.convert_arguments(t, geob)
end

function expr_enable(Geom)
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


# Munging utilities for mixed geometry arrays
# Taken from GeoMakie.jl

# TODO: this takes double the amount of time in convert args
# than it does using the functions straight, so something is wrong here.
# Maybe its actually a good idea, to call these functions directly, or move
# the detection code before the actual conversion...

to_multipoly(poly::GB.Polygon) = GB.MultiPolygon([poly])
to_multipoly(poly::Vector{GB.Polygon}) = GB.MultiPolygon(poly)
to_multipoly(mp::GB.MultiPolygon) = mp
to_multipoly(geom) = to_multipoly(GeoInterface.trait(geom), geom)
to_multipoly(::Nothing, geom::AbstractVector) = to_multipoly.(GeoInterface.trait.(geom), geom)
to_multipoly(::GeoInterface.PolygonTrait, geom) = GB.MultiPolygon([GeoInterface.convert(GB, geom)])
to_multipoly(::GeoInterface.MultiPolygonTrait, geom) = GeoInterface.convert(GB, geom)

to_multilinestring(poly::GB.LineString) = GB.MultiLineString([poly])
to_multilinestring(poly::Vector{GB.Polygon}) = GB.MultiLineString(poly)
to_multilinestring(mp::GB.MultiLineString) = mp
to_multilinestring(geom) = to_multilinestring(GeoInterface.trait(geom), geom)
to_multilinestring(geom::AbstractVector) = to_multilinestring.(GeoInterface.trait.(geom), geom)
to_multilinestring(::GeoInterface.LineStringTrait, geom) = GB.MultiLineString([GeoInterface.convert(GB, geom)])
to_multilinestring(::GeoInterface.MultiLineStringTrait, geom) = GeoInterface.convert(GB, geom)

to_multipoint(poly::GB.Point) = GB.MultiPoint([poly])
to_multipoint(poly::Vector{GB.Point}) = GB.MultiPoint(poly)
to_multipoint(mp::GB.MultiPoint) = mp
to_multipoint(geom) = to_multipoint(GeoInterface.trait(geom), geom)
to_multipoint(geom::AbstractVector) = to_multipoint.(GeoInterface.trait.(geom), geom)
to_multipoint(::GeoInterface.PointTrait, geom) = GB.MultiPoint([GeoInterface.convert(GB, geom)])
to_multipoint(::GeoInterface.MultiPointTrait, geom) = GeoInterface.convert(GB, geom)

# TODO 
# Features and Feature collections
# https://github.com/JuliaGeo/GeoInterface.jl/pull/72#issue-1406325596

end
