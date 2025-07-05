module GeoInterfaceMakieExt

import Makie
import GeometryBasics as GB
import GeoInterface as GI


GI._plottype(geom) = plottype_from_geomtrait(GI.geomtrait(geom))

function plottype_from_geomtrait(::Union{GI.LineStringTrait,GI.MultiLineStringTrait})
    Makie.Lines
end
function plottype_from_geomtrait(::Union{GI.PointTrait,GI.MultiPointTrait})
    Makie.Scatter
end
function plottype_from_geomtrait(::Union{GI.GeometryCollectionTrait,GI.PolygonTrait,GI.MultiPolygonTrait,GI.LinearRingTrait})
    Makie.Poly
end

GI._convert_arguments(t, geom) = GI._convert_arguments(t, GI.trait(geom), geom)
function GI._convert_arguments(t, ::GI.AbstractGeometryTrait, geom)::Tuple
    geob = GI.convert(GB, geom)
    return Makie.convert_arguments(t, geob)
end
function GI._convert_arguments(t, ::GI.MultiPointTrait, geom)::Tuple
    geob = to_multipoint(GB, geom)
    return Makie.convert_arguments(t, geob)
end

function operator_nangeom_if_missing_or_func(func, trait::GI.AbstractGeometryTrait, ndims, numtype = Float64)
    nan_geom = _nan_geom(trait, ndims, numtype)
    return x -> ismissing(x) ? nan_geom : func(x)
end

function GI._convert_array_arguments(plottrait, geoms::AbstractArray{T})::Tuple where T
    geoms_without_missings = Missing <: T ? skipmissing(geoms) : geoms
    # assess whether multification is needed!
    # Multification is the conversion of a vector of mixed single and multi-geometry types,
    # like [::PolygonTrait, ::MultiPolygonTrait, ::PolygonTrait, ...], to the higher multi-
    # type, in this case `MultiPolygon`.
    needs_multification, trait = _needs_multification_trait(geoms_without_missings)

    func_to_apply = if needs_multification
        if trait isa GI.MultiLineStringTrait
            to_multilinestring
        elseif trait isa GI.MultiPolygonTrait
            to_multipoly
        else
            error("GeoInterface: We don't support mixed single-and-multi geometries for this multi trait yet: $(trait)")
        end
    else
        # base case
        Base.Fix1(GI.convert, GB)
    end
    if Missing <: T
        return Makie.convert_arguments(
            plottrait, 
            map(
                operator_nangeom_if_missing_or_func(
                    func_to_apply, 
                    trait, 
                    GI.ncoord(first(geoms_without_missings))
                ), 
                geoms
            )
        )
    else # no missings, do this the regular way
        return Makie.convert_arguments(plottrait, map(func_to_apply, geoms))
    end
end


# Creating empty geometries from traits
function _geomtrait_for_array(arr)
    idx = findfirst(!ismissing, arr)
    geom = if isnothing(idx)
        error("We can't plot only missings!!")
    else
        arr[idx]
    end
end

# NaN geometry creators from traits
_nan_geom(::GI.PointTrait, ndims = 2, T = Float64) = GB.Point{ndims, T}(NaN)
_nan_geom(::GI.MultiPointTrait, ndims = 2, T = Float64) = GB.MultiPoint(_nan_geom(GI.PointTrait(), ndims, T))
_nan_geom(::GI.LineStringTrait, ndims = 2, T = Float64) = GB.LineString([_nan_geom(GI.PointTrait(), ndims, T)])
_nan_geom(::GI.MultiLineStringTrait, ndims = 2, T = Float64) = GB.MultiLineString([_nan_geom(GI.LineStringTrait(), ndims, T)])
_nan_geom(::GI.PolygonTrait, ndims = 2, T = Float64) = GB.Polygon([_nan_geom(GI.PointTrait(), ndims, T)])
_nan_geom(::GI.MultiPolygonTrait, ndims = 2, T = Float64) = GB.MultiPolygon([_nan_geom(GI.PolygonTrait(), ndims, T)])

# Munging utilities for mixed geometry arrays
# Taken from GeoMakie.jl


_multi_trait(::Union{GI.PolygonTrait, GI.MultiPolygonTrait}) = GI.MultiPolygonTrait()
_multi_trait(::Union{GI.LineStringTrait, GI.MultiLineStringTrait}) = GI.MultiLineStringTrait()
_multi_trait(::Union{GI.PointTrait, GI.MultiPointTrait}) = GI.MultiPointTrait()

"""
    _needs_multification_trait(geoms)::(needs_mulification::Bool, trait::GI.AbstractTrait)

`geoms` must be some iterable of geometries.
"""
function _needs_multification_trait(geoms)
    first_trait = GI.geomtrait(first(skipmissing(geoms)))
    # GeometryCollections are a special case, since they can contain
    # multiple geometries, which all need to be handled differently.
    if first_trait isa GI.GeometryCollectionTrait # if this happens, look at the second trait if it exists
        if length(geoms) ≤ 1 # there is only one geometrycollection
            # analyze the contents
            traits = unique(map(GI.geomtrait, GI.getgeom(first(geoms))))
            if GI.MultiPolygonTrait() ∈ traits || GI.PolygonTrait() ∈ traits
                return true, GI.MultiPolygonTrait()
            elseif GI.MultiLineStringTrait() ∈ traits || GI.LineStringTrait() ∈ traits
                return true, GI.MultiLineStringTrait()
            elseif GI.MultiPointTrait() ∈ traits || GI.PointTrait() ∈ traits
                return true, GI.MultiPointTrait()
            end
        else 
            # A robust solution is to:
            # - Traverse the array to find the first non-geometrycollection element
            # If that fails, then introspect the first element as was done earlier, to
            # get the multification trait.
            first_nongc_idx = findfirst(x -> GI.geomtrait(x) != GI.GeometryCollectionTrait, geoms)
            if isnothing(first_nongc_idx) # only geometry collections in the whole array
                return _needs_multification_trait((GI.getgeom(first(skipmissing(geoms))),)) # introspect the first element
            else
                # introspect the first non-geometrycollection element
                return _needs_multification_trait((first(Iterators.drop(geoms, first_nongc_idx-1)),))
            end
        end
    end
    # Now, we continue with the regular code.
    different_trait_idx = findfirst(x -> GI.geomtrait(x) != first_trait, geoms)
    if isnothing(different_trait_idx)
        return false, first_trait # all traits are the same, so we don't need to multify
    else
        return true, _multi_trait(first_trait) # traits are different, so we need to multify
    end
end

to_multipoly(poly::GB.Polygon) = GB.MultiPolygon([poly])
to_multipoly(poly::Vector{GB.Polygon}) = GB.MultiPolygon(poly)
to_multipoly(mp::GB.MultiPolygon) = mp
to_multipoly(geom) = to_multipoly(GI.trait(geom), geom)
to_multipoly(::Nothing, geom::AbstractVector) = to_multipoly.(GI.trait.(geom), geom)
to_multipoly(::GI.PolygonTrait, geom) = GB.MultiPolygon([GI.convert(GB, geom)])
to_multipoly(::GI.MultiPolygonTrait, geom) = GI.convert(GB, geom)

function to_multipoly(::GI.GeometryCollectionTrait, geom)
    ls_or_mls = filter(x -> GI.geomtrait(x) isa Union{GI.MultiPolygonTrait, GI.PolygonTrait}, GI.getgeom(geom))
    multipolys = to_multipoly(ls_or_mls)
    return GB.MultiPolygon(vcat(getproperty.(multipolys, :polygons)...))
end

to_multilinestring(poly::GB.LineString) = GB.MultiLineString([poly])
to_multilinestring(poly::Vector{GB.Polygon}) = GB.MultiLineString(poly)
to_multilinestring(mp::GB.MultiLineString) = mp
to_multilinestring(geom) = to_multilinestring(GI.trait(geom), geom)
to_multilinestring(geom::AbstractVector) = to_multilinestring.(GI.trait.(geom), geom)
to_multilinestring(::GI.LineStringTrait, geom) = GB.MultiLineString([GI.convert(GB, geom)])
to_multilinestring(::GI.MultiLineStringTrait, geom) = GI.convert(GB, geom)

function to_multilinestring(::GI.GeometryCollectionTrait, geom)
    ls_or_mls = filter(x -> GI.geomtrait(x) isa Union{GI.MultiLineStringTrait, GI.LineStringTrait}, GI.getgeom(geom))
    multilinestrings = to_multilinestring(ls_or_mls)
    return GeometryBasics.MultiLineString(vcat(getproperty.(multilinestrings, :linestrings)...))
end

# GB.MultiPoint does not plot anymore, needs to be a Vector{GB.Point}
to_multipoint(poly::GB.Point) = GB.MultiPoint([poly])
to_multipoint(poly::Vector{GB.Point}) = poly
to_multipoint(mp::GB.MultiPoint) = mp
to_multipoint(geom) = to_multipoint(GI.trait(geom), geom)
to_multipoint(geom::AbstractVector) = to_multipoint.(GI.trait.(geom), geom)
to_multipoint(::GI.PointTrait, geom) = [GI.convert(GB, geom)]
to_multipoint(::GI.MultiPointTrait, geom) = GI.convert.(GB, GI.getpoint(geom))

# TODO 
# Features and Feature collections
# https://github.com/JuliaGeo/GI.jl/pull/72#issue-1406325596

# Enable Makie.jl for GI wrappers
GI.@enable_makie Makie GI.WrapperGeometry

end
