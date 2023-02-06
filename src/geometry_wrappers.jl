"""
    Wrappers

Geometry, Feature, and FeatureCollection wrappers for constructing ad-hoc
geometry objects from any GeoInterface.jl compatible geometries, or
vectors of them.

These are not exported by default, due to the names being so common.
To bring them into your local scope, do:

```juila
using GeoInterface.Wrappers
```

Otherwise they can be accessed as:

```julia
GeoInterface.Polygon
```
"""
module Wrappers

import Extents

import ..GeoInterface: AbstractGeometryTrait, PointTrait, LineTrait, LineStringTrait, LinearRingTrait, TriangleTrait,
       QuadTrait, PentagonTrait, HexagonTrait, RectangleTrait, MultiPointTrait, PolygonTrait, MultiLineStringTrait, 
       MultiCurveTrait, MultiPolygonTrait, TINTrait, GeometryCollectionTrait, PolyhedralSurfaceTrait, 
       FeatureTrait, FeatureCollectionTrait, PointTuple3

import ..GeoInterface: isgeometry, isfeature, isfeaturecollection, trait, geomtrait, is3d, ismeasured, getgeom,
       getpoint, gethole, getring, ngeom, npoint, nhole, convert, x, y, z, m, getfeature, nfeature, properties, extent, crs

export Point, EmptyPoint, LineString, Polygon, Triangle, MultiPoint, MultiCurve, MultiPolygon, MultiLineString, TIN, Collection, Feature, FeatureCollection

# Implement interface

"""
    WrapperGeometry{Z,M,T}

Provides geometry wrappers that wrap any GeoInterface compatible
objects, or vectors or their child object.

These can be usefull for building custom geometries, in tests,
and in packages with no direct dependencies on specific geometry
types.

Parameters `Z` and `M` hold `Bool` values `true` or `false`
to indicate if a z dimension or measures are present. They are
usually detected from the wrapped object, but can be added manually
e.g. for `Tuple` or `Vector` points to have the third value used as
measures.

# Example


"""
abstract type WrapperGeometry{Z,M,T} end

isgeometry(::Type{<:WrapperGeometry}) = true
is3d(::WrapperGeometry{Z}) where Z = Z
ismeasured(::WrapperGeometry{<:Any,M})  where M = M

Base.parent(geom::WrapperGeometry) = geom.geom

function Base.:(==)(g1::WrapperGeometry, g2::WrapperGeometry)
    all(((a, b),) -> a == b, zip(GeoInterface.getgeom(g1), GeoInterface.getgeom(g2)))
end
function Base.:(!=)(g1::WrapperGeometry, g2::WrapperGeometry)
    any(!=, zip(GeoInterface.getgeom(g1), GeoInterface.getgeom(g2)))
end

geointerface_geomtype(trait) = geomtype(typeof(trait))
geointerface_geomtype(trait::Type) = throw(ArgumentError("trait $trait not handled in wrappers"))
const geomtype = geointerface_geomtype

# Interface methods
# With indexing
function getgeom(trait::AbstractGeometryTrait, geom::WrapperGeometry{<:Any,<:Any,T}, i) where T
    isgeometry(T) ? getgeom(trait, parent(geom), i) : parent(geom)[i]
end
getpoint(trait::AbstractGeometryTrait, geom::WrapperGeometry, i) = getpoint(trait, parent(geom), i)
gethole(trait::AbstractGeometryTrait, geom::WrapperGeometry, i) = gethole(trait, parent(geom), i)

for (geomtype, trait, childtype, child_trait, length_check, nesting) in (
        (:Line, :LineTrait, :Point, :PointTrait, ==(2), 1),
        (:LineString, :LineStringTrait, :Point, :PointTrait, >=(2), 1),
        (:LinearRing, :LinearRingTrait, :Point, :PointTrait, >=(3), 1),
        (:Triangle, :TriangleTrait, :Point, :PointTrait, ==(3), 1),
        (:Quad, :QuadTrait, :Point, :PointTrait, ==(4), 1),
        (:Pentagon, :PentagonTrait, :Point, :PointTrait, ==(4), 1),
        (:Hexagon, :HexagonTrait, :Point, :PointTrait, ==(6), 1),
        (:Rectangle, :RectangleTrait, :Point, :PointTrait, nothing, 1),
        (:MultiPoint, :MultiPointTrait, :Point, :PointTrait, nothing, 1),
        (:Polygon, :PolygonTrait, :LinearRing, :LineStringTrait, nothing, 2),
        (:MultiLineString, :MultiLineStringTrait, :LineString, :LineStringTrait, nothing, 2),
        (:MultiCurve, :MultiCurveTrait, :LineString, :AbstractCurveTrait, nothing, 2),
        (:MultiPolygon, :MultiPolygonTrait, :Polygon, :PolygonTrait, nothing, 3),
        (:TIN, :TINTrait, :Triangle, :TriangleTrait, nothing, 2),
        (:GeometryCollection, :GeometryCollectionTrait, :AbstractGeometry, :AbstractGeometryTrait, nothing, nothing),
        (:PolyhedralSurface, :PolyhedralSurfaceTrait, :Polygon, :PolygonTrait, nothing, 3),
    )

    # Prepare docstring example
    childname = lowercase(string(childtype))
    example_child_geoms = if geomtype == :Polygon
        "child_geoms = [interior, ring, ring]"
    else
        "child_geoms = [$(childname)1, $(childname)2, $(childname)3))]"
    end
    docstring = """
        $geomtype

        $geomtype(geom, [extent])
        $geomtype{Z,M}(geom, [extent])

    ## Arguments

    - `geom`: any object returning $trait from `GeoInterface.trait`, or a vector
        of objects returning $child_trait.
    - `extent`: an `Extents.Extent`, or `nothing`.

    ## Parameters (optional)

    - `Z`: `true` or `false` if there is a z dimension.
    - `M`: `true` or `false` if there are measures.

    # Example

    ```julia
    $geomtype(geometry)
    ```

    Or with child object of `$child_trait()`:

    ```julia
    $example_child_geoms
    $geomtype(child_geoms)
    ```
    """
    @eval begin
        @doc $docstring
        struct $geomtype{Z,M,T,E} <: WrapperGeometry{Z,M,T}
            geom::T
            extent::E
        end
        $geomtype(geom; extent=nothing) = $geomtype{nothing,nothing}(geom; extent=nothing)
        geomtrait(::$geomtype) = $trait()
        geointerface_geomtype(::Type{$trait}) = $geomtype
        # Here converting means wrapping
        convert(::Type{$geomtype}, ::$trait, geom) = $geomtype(geom)
        # But not if geom is already a WrapperGeometry
        convert(::Type{$geomtype}, ::$trait, geom::$geomtype) = geom
    end
    @eval function $geomtype{Z,M}(geom::T; extent::E=nothing) where {Z,M,T,E}
        Z isa Union{Bool,Nothing} || throw(ArgumentError("Z Parameter must be `true`, `false` or `nothing`"))
        M isa Union{Bool,Nothing} || throw(ArgumentError("M Parameter must be `true`, `false` or `nothing`"))

        # Wrap some geometry at the same level
        if isgeometry(geom)
            geomtrait(geom) isa $trait || _argument_error(T, $trait)
            Z1 = isnothing(Z) ? is3d(geom) : Z
            M1 = isnothing(M) ? ismeasured(geom) : M
            return $geomtype{Z1,M1,T,E}(geom, extent)

        # Otherwise wrap an array of child geometries
        elseif geom isa AbstractArray
            child = first(geom)
            chilren_match = all(child -> geomtrait(child) isa $child_trait, geom)

            # Where the next level down is the child geometry
            if chilren_match
                if $(!isnothing(length_check))
                    $length_check(Base.length(geom)) || _length_error($geomtype, $length_check, geom)
                end
                Z1 = isnothing(Z) ? is3d(first(geom)) : Z
                M1 = isnothing(M) ? ismeasured(first(geom)) : M
                return $geomtype{Z1,M1,T,E}(geom, extent)

            # Where we have nested points, as in `coordinates(geom)`
            else
                if child isa AbstractArray
                    if $nesting === 2
                        all(child2 -> geomtrait(child2) isa PointTrait, child) || _parent_type_error(geom)
                        Z1 = isnothing(Z) ? is3d(first(child)) : Z
                        M1 = isnothing(M) ? ismeasured(first(child)) : M
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{Z1,M1,typeof(newgeom),E}(newgeom, extent)
                    elseif $nesting === 3
                        all(child) do child2
                            child2 isa AbstractArray && all(child3 -> geomtrait(child3) isa PointTrait, child2)
                        end || _parent_type_error(geom)
                        Z1 = isnothing(Z) ? is3d(first(first(child))) : Z
                        M1 = isnothing(M) ? ismeasured(first(first(child))) : M
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{Z1,M1,typeof(newgeom),E}(newgeom, extent)
                    else
                        # Otherwise compain the nested child type is wrong
                        _wrong_child_error($geomtype, $child_trait, child)
                    end
                else
                    # Otherwise compain the nested child type is wrong
                    _wrong_child_error($geomtype, $child_trait, child)
                end
            end
        else
            # Or complain the parent type is wrong
            _parent_type_error(geom)
        end
    end
    @eval function ngeom(trait::$trait, wrapper::$geomtype)
        p = parent(wrapper)
        if isgeometry(p)
            return ngeom(p)
        elseif p isa AbstractArray
            return length(p)
        end
    end
    # Without indexing
    @eval function getgeom(trait::$trait, wrapper::$geomtype)
        p = parent(wrapper)
        if isgeometry(p)
            return getgeom(p)
        elseif p isa AbstractArray
            return p
        end
    end
    @eval extent(trait::$trait, wrapper::$geomtype) = wrapper.extent
end

@noinline _wrong_child_error(geomtype, C, child) = throw(ArgumentError("$geomtype must have child objects with trait $C, got $(typeof(child)) with trait $(geomtrait(child))"))
@noinline _argument_error(T, A) = throw(ArgumentError("$T is not a $A"))
@noinline _length_error(T, f, x) = throw(ArgumentError("Length of array must be $(f.f) $(f.x) for $T"))
@noinline _parent_type_error(geom) = throw(ArgumentError("Object $geom is not a geometry or array of child geometries"))

"""
    Point
    Point(geom)
    Point{Z,M}(geom)
    Point(; X, Y, [Z, M])

## Arguments

- `geom`: any object returning `PontTrait` from `GeoInterface.trait`.

## Parameters (optional)

These can be used to force points to be interpreted with
measures or z dimension.

- `Z`: `true` or `false` if there is a z dimension.
- `M`: `true` or `false` if there are measures.

# Example

```jldoctest
using GeoInterface
point = Point{false,true}([1, 2, 3])
@asssert GeoInterface.ismeasured(point) == true
@asssert GeoInterface.is3d(point) == false
```
"""
struct Point{Z,M,T} <: WrapperGeometry{Z,M,T}
    geom::T
end
function Point{Z,M}(geom::T) where {Z,M,T}
    expected_coords = 2 + Z + M
    ncoords(geom) == expected_coords || _coord_length_error(Z, M, ncoords(geom))
    Point{Z,M,T}(geom)
end
Point(x::Real, y::Real, args::Real...) = Point((x, y, args...))
Point{Z,M}(x::Real, y::Real, args::Real...) where {Z,M} = Point{Z,M}((x, y, args...))
function Point(; X::Real, Y::Real, Z::Union{Real,Nothing}=nothing, M::Union{Real,Nothing}=nothing)
    p = (; X, Y)
    if !isnothing(Z)
        p = merge(p, (; Z))
    end
    if !isnothing(M)
        p = merge(p, (; M))
    end
    return Point(p)
end
function Point(geom)
    geomtrait(geom) isa PointTrait || _parent_type_error(geom)
    if is3d(geom) && ismeasured(geom)
        return Point{true,true,typeof(geom)}(geom)
    elseif is3d(geom)
        return Point{true,false,typeof(geom)}(geom)
    elseif ismeasured(geom)
        return Point{false,true,typeof(geom)}(geom)
    else
        return Point{false,false,typeof(geom)}(geom)
    end
end

isgeometry(::Type{<:Point}) = true
geomtrait(geom::Point) = PointTrait()
ncoord(trit::PointTrait, geom::Point) = ncoord(trait, parent(geom))
getcoord(trait::PointTrait, geom::Point, i::Integer) = getcoord(trait, parent(geom), i)
convert(::Type{Point}, ::PointTrait, geom) = Point(geom)
convert(::Type{Point}, ::PointTrait, geom::Point) = geom

x(trait::PointTrait, geom::Point) = x(trait, parent(geom))
y(trait::PointTrait, geom::Point) = y(trait, parent(geom))
z(trait::PointTrait, geom::Point{true}) = z(trait, parent(geom))
z(trait::PointTrait, geom::Point{false}) = _no_z_error()
m(trait::PointTrait, geom::Point{<:Any,false}) = _no_m_error()
m(trait::PointTrait, geom::Point{<:Any,true}) = m(trait, parent(geom))
# Special-case vector and tuple points so we can force them to be measured while not 3d
m(trait::PointTrait, geom::Point{false,true,<:PointTuple3}) = parent(geom)[3]
m(trait::PointTrait, geom::Point{false,true,<:Vector{<:Real}}) = parent(geom)[3]

function Base.:(==)(g1::Point, g2::Point)
    x(g1) == x(g2) && y(g1) == y(g2) && is3d(g1) == is3d(g2) && ismeasured(g1) == ismeasured(g2) || return false
    if is3d(g1)
        z(g1) == z(g2) || return false
    end
    if ismeasured(g1)
        m(g1) == m(g2) || return false
    end
    return true
end
Base.:(!=)(g1::Point, g2::Point) = !(g1 == g2)

@noinline _coord_length_error(Z, M, l) =
    _throw(ArgumentError("Number of coordinates must be $(2 + Z + M) when `Z` is $Z and `M` is $M. Got $l"))
@noinline _no_z_error() = throw(ArgumentError("Point has no `Z` coordinate"))
@noinline _no_m_error() = throw(ArgumentError("Point has no `M` coordinate"))

"""
    Feature(geometry; [properties, crs, extent])

A Feature wrapper.

- `geometry`: any GeoInterface compatible geometry object, or `nothing`.

# Keywords

- `properties`: any object that defines `propertynames` and `getproperty`
- `crs`: Any GeoFormatTypes.jl crs type, or `nothing`
- `extent`: An Extents.jl `Extent` or `nothing`
"""
struct Feature{G,P,C,E<:Union{Extents.Extent,Nothing}}
    geometry::G
    properties::P
    crs::C
    extent::E
end
Feature(geometry=nothing; properties=nothing, crs=nothing, extent=nothing) =
    Feature(geometry, properties, crs, extent)

isfeature(::Type{<:Feature}) = true
trait(feature::Feature) = FeatureTrait()
geometry(f::Feature) = f.geometry
properties(f::Feature) = f.properties
extent(f::Feature) = f.extent
crs(f::Feature) = f.crs

"""
    FeatureCollection(features; [crs, extent])

A FeatureCollection wrapper.

- `features`: an `AbstractArray` of GeoInterface compatible features.
    Iterables are accepted but will be collected to an `Array`.

# Keywords

- `crs`: Any GeoFormatTypes.jl crs type, or `nothing`
- `extent`: An Extents.jl `Extent` or `nothing`

"""
struct FeatureCollection{P,C,E}
    parent::P
    crs::C
    extent::E
end
function FeatureCollection(parent; crs=nothing, extent=nothing)
    if GI.isfeaturecollection(parent)
        FeatureCollection(parent, crs, extent)
    else
        features = !(parent isa AbstractArray) ? collect(parent) : parent
        all(f -> isfeature(f) in features) || _child_feature_error()
        FeatureCollection(parent, crs, extent)
    end
end

_child_feature_error() = throw(ArgumentError("child objects must be features, but the return `GeoInterface.isfeature(obj) == false`"))

isfeaturecollection(fc::Type{<:FeatureCollection}) = true
trait(fc::FeatureCollection) = FeatureCollectionTrait()

function nfeature(::FeatureCollectionTrait, fc::FeatureCollection)
    isfeaturecollection(parent(fc)) ? nfeature(t, parent(fc)) : length(fc.geoms)
end
getfeature(::FeatureCollectionTrait, fc::FeatureCollection) = fc.features
function getfeature(t::FeatureCollectionTrait, fc::FeatureCollection, i::Integer)
    isfeaturecollection(parent(fc)) ? getfeature(t, parent(fc), i) : fc.features[i]
end
function extent(fc::FeatureCollection)
    if isfeaturecollection(parent(fc)) && isnothing(fc.extent)
        extent(parent(fc))
    else
        fc.extent
    end
end
function crs(fc::FeatureCollection)
    if isfeaturecollection(parent(fc)) && isnothing(fc.crs)
        crs(parent(fc))
    else
        fc.crs
    end
end

end # module
