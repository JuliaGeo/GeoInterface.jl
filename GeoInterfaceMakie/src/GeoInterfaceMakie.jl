module GeoInterfaceMakie

using GeoInterface
import MakieCore as MC
import GeometryBasics as GB
import GeoInterface as GI
import Makie


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
    Makie.Poly
end
function pttype(geom)
    if GI.is3d(geom)
        GB.Point3f
    else
        GB.Point2f
    end
end
@noinline function _points!(out, geom)
    _points!(out, GI.geomtrait(geom), geom)
end
function _points!(out, t::GI.PointTrait, geom)
    pt = eltype(out)(GI.getcoord(geom)...)
    push!(out, pt)
    return out
end
function _points!(out, ::Any, geom)
    for subgeom in GI.getgeom(geom)
        _points!(out, GI.geomtrait(subgeom), subgeom)
    end
    out
end
function points(geom)::Union{Vector{GB.Point2f}, Vector{GB.Point3f}}
    Pt = pttype(geom)
    _points!(Pt[], geom)
end
function basicsgeom(geom)
    t = GI.geomtrait(geom)
    T = basicsgeomtype(t)
    GI.convert(T, t, geom)
end

basicsgeomtype(::GI.PointTrait)           = GB.Point
basicsgeomtype(::GI.MultiPointTrait)      = GB.MultiPoint
basicsgeomtype(::GI.PolygonTrait)         = GB.Polygon
basicsgeomtype(::GI.MultiPolygonTrait)    = GB.MultiPolygon
basicsgeomtype(::GI.LineStringTrait)      = GB.LineString
basicsgeomtype(::GI.MultiLineStringTrait) = GB.MultiLineString

function _convert_arguments(::Type{<:Makie.Poly}, geom)::Tuple
    geob = basicsgeom(geom)::Union{GB.Polygon, GB.MultiPolygon}
    (geob,)
end
function _convert_arguments(::MC.PointBased, geom)::Tuple
    pts = points(geom)
    (pts,)
end

function expr_enable(Geom)
    quote
        # import GeoInterfaceMakie.MakieCore
        # import GeoInterfaceMakie.Makie
        function $Makie.plottype(geom::$Geom)
            $_plottype(geom)
        end
        function $MC.convert_arguments(p::Type{<:$Makie.Poly}, geom::$Geom)
            $_convert_arguments(p,geom)
        end
        function $MC.convert_arguments(p::$MC.PointBased, geom::$Geom)
            $_convert_arguments(p,geom)
        end
    end
end
"""

    enable(Geom)

Enable Makie based plotting for a type `Geom` that implements the geometry interface 
defined in `GeoInterface`.

# Usage
```julia
struct MyGeometry 
...
end
# overload GeoInterface for MyGeometry
...

@enable MyGeometry
```
"""
macro enable(Geom)
    esc(expr_enable(Geom))
end

# TODO 
# Features and Feature collections
# https://github.com/JuliaGeo/GeoInterface.jl/pull/72#issue-1406325596

end
