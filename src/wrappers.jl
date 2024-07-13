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

import ..GeoInterface: AbstractGeometryTrait, PointTrait, LineTrait, LineStringTrait, LinearRingTrait,
       MultiPointTrait, PolygonTrait, MultiLineStringTrait, MultiCurveTrait, MultiPolygonTrait,
       AbstractCurveTrait, GeometryCollectionTrait, FeatureTrait, FeatureCollectionTrait, PointTuple3,
       PolyhedralSurfaceTrait, TriangleTrait, QuadTrait, PentagonTrait, HexagonTrait, RectangleTrait, TINTrait

import ..GeoInterface: isgeometry, isfeature, isfeaturecollection, is3d, ismeasured,
       trait, geomtrait, convert, x, y, z, m, extent, crs,
       getgeom, getpoint, getring, gethole, getcoord,
       ngeom, npoint, nring, nhole, ncoord,
       nfeature, getfeature, geometry, properties

export Point, Line, LineString, LinearRing, Polygon, MultiPoint, MultiPolygon, MultiLineString, MultiCurve,
    PolyhedralSurface, GeometryCollection, Feature, FeatureCollection

# TODO
# Triangle, Quad, Pentagon, Hexagon, TIN, Surface


# Implement interface

"""
    abstract type WrapperGeometry{Z,M,T}

Provides geometry wrappers that wrap any GeoInterface compatible
objects, or vectors or their child objects.

These can be useful for building custom geometries, in tests,
and in packages with no direct dependencies on specific geometry
types.

Parameters `Z` and `M` hold `Bool` values `true` or `false`
to indicate if a z dimension or measures are present. They are
usually detected from the wrapped object, but can be added manually
e.g. for `Tuple` or `Vector` points to have the third value used as
measures.
"""
abstract type WrapperGeometry{Z,M,T,C} end

isgeometry(::Type{<:WrapperGeometry}) = true
is3d(::WrapperGeometry{Z}) where Z = Z
ismeasured(::WrapperGeometry{<:Any,M})  where M = M
ncoord(::WrapperGeometry{Z, M}) where {Z, M} = 2 + Z + M

Base.parent(geom::WrapperGeometry) = geom.geom

function Base.:(==)(g1::WrapperGeometry, g2::WrapperGeometry)
    all(((a, b),) -> a == b, zip(getgeom(g1), getgeom(g2)))
end

# Interface methods
# With indexing
function getgeom(trait::AbstractGeometryTrait, geom::WrapperGeometry{<:Any,<:Any,T}, i) where T
    isgeometry(T) ? getgeom(trait, parent(geom), i) : parent(geom)[i]
end
function getgeom(trait::AbstractGeometryTrait, geom::WrapperGeometry{<:Any,<:Any,T}) where T
    isgeometry(T) ? getgeom(trait, parent(geom)) : parent(geom)
end

extent(::AbstractGeometryTrait, geom::WrapperGeometry) =
    isnothing(geom.extent) && isgeometry(parent(geom)) ? extent(parent(geom)) : geom.extent
crs(::AbstractGeometryTrait, geom::WrapperGeometry) =
    isnothing(geom.crs) && isgeometry(parent(geom)) ? crs(parent(geom)) : geom.crs
function ngeom(trait::AbstractGeometryTrait, geom::WrapperGeometry{<:Any,<:Any,T}) where T
    isgeometry(T) ? ngeom(parent(geom)) : length(parent(geom))
end

# We define all the types in a loop so we have standardised docs and behaviour
# without too much repetition of code.
# `child_trait` and `child_type` define the trait and type of child geometries
# a geometry can be constructed from.
# `length_check` limits some types to specific number of points, defined with a Fix2 or function
# `nesting` indicates how many layers of point vectors need to be used to construct the object.
for (geomtype, trait, childtype, child_trait, length_check, nesting) in (
        (:Line, :LineTrait, :Point, :PointTrait, ==(2), 1),
        (:LineString, :LineStringTrait, :Point, :PointTrait, >=(2), 1),
        (:LinearRing, :LinearRingTrait, :Point, :PointTrait, >=(3), 1),
        (:MultiPoint, :MultiPointTrait, :Point, :PointTrait, nothing, 1),
        (:Polygon, :PolygonTrait, :LinearRing, :AbstractCurveTrait, nothing, 2),
        (:MultiLineString, :MultiLineStringTrait, :LineString, :LineStringTrait, nothing, 2),
        (:MultiCurve, :MultiCurveTrait, :LineString, :AbstractCurveTrait, nothing, 2),
        (:MultiPolygon, :MultiPolygonTrait, :Polygon, :PolygonTrait, nothing, 3),
        (:GeometryCollection, :GeometryCollectionTrait, :AbstractGeometry, :AbstractGeometryTrait, nothing, nothing),
        (:PolyhedralSurface, :PolyhedralSurfaceTrait, :Polygon, :PolygonTrait, nothing, 3),
        # (:Triangle, :TriangleTrait, :LinearRingTrait, :LinearRing, ==(3), 2),
        # (:Quad, :QuadTrait, :LinearRingTrait, :LinearRing, ==(4), 2),
        # (:Pentagon, :PentagonTrait, :LinearRingTrait, :LinearRing, ==(5), 2),
        # (:Hexagon, :HexagonTrait, :LinearRingTrait, :LinearRing, ==(6), 2),
        # (:Rectangle, :RectangleTrait, :Point, :PointTrait, nothing, 1), ?
        # (:TIN, :TINTrait, :Triangle, :TriangleTrait, nothing, 3),
    )

    # Prepare docstring example
    childname = lowercase(string(childtype))
    example_child_geoms = if geomtype == :Polygon
        "interior, hole1, hole2"
    else
        join((string(childname, n) for n in 1:(isnothing(length_check) ? 3 : length_check.x)), ", ")
    end
    docstring = """
        $geomtype

        $geomtype(geom; [extent, crs])
        $geomtype{Z,M}(geom; [extent, crs])

    ## Arguments

    - `geom`: any object returning $trait from `GeoInterface.trait`, or a vector
        of objects returning $child_trait.

    ## Keywords
    
    - `extent`: an `Extents.Extent`, or `nothing`.
    - `crs`: a `GeoFormatTypes.GeoFormat`, or `nothing`.

    ## Type Parameters (optional)

    These are usually detected from the parent object properties.

    - `Z`: `true` or `false` if there is a z dimension.
    - `M`: `true` or `false` if there are measures.

    ## Examples

    ```julia
    geom = $geomtype(geometry)
    ```

    Or with child objects with [`$child_trait`](@ref):

    ```julia
    geom = $geomtype([$example_child_geoms])
    ```
    """
    @eval begin
        @doc $docstring
        struct $geomtype{Z,M,T,E<:Union{Nothing,Extents.Extent},C} <: WrapperGeometry{Z,M,T,C}
            geom::T
            extent::E
            crs::C
        end
        $geomtype(geom::$geomtype; kw...) =
            $geomtype(parent(geom); extent=geom.extent, crs=geom.crs, kw...)
        $geomtype(geom; kw...) = $geomtype{nothing,nothing}(geom; kw...)
        geomtrait(::$geomtype) = $trait()
        geointerface_geomtype(::$trait) = $geomtype
        # Here converting means wrapping
        convert(::Type{$geomtype}, ::$trait, geom) = $geomtype(geom)
        # But not if geom is already a WrapperGeometry
        convert(::Type{$geomtype}, ::$trait, geom::$geomtype) = geom
        
        function Base.show(io::IO, ::MIME"text/plain", geom::$geomtype{Z, M, T, E, C}; show_mz::Bool = true) where {Z, M, T, E <: Union{Nothing,Extents.Extent}, C}
            compact = get(io, :compact, false)
            print(io, $geomtype)
            if show_mz
                print(io, "{$Z, $M}")
            end
            print(io, "(")
            this_geom = getgeom(trait(geom), geom)
            if this_geom isa AbstractVector
                print(io, "[")
                for (i, g) ∈ enumerate(this_geom)
                    _nice_print_geom(io, g, false)
                    if i != length(this_geom)
                        print(io, ",$(compact ? "" : " ")")
                    end
                end
                print(io, "]")
            else
                show(io, g; show_mz = false)
            end
            if compact
                print(io, ")")
            else
                if !isnothing(geom.extent)
                    print(", extent = $(geom.extent)")
                end
                if !isnothing(geom.crs)
                    print(", crs = $(geom.crs)")
                end
                print(")")
            end
            return nothing
        end
    end
    @eval function $geomtype{Z,M}(geom::T; extent::E=nothing, crs::C=nothing) where {Z,M,T,E,C}
        Z isa Union{Bool,Nothing} || throw(ArgumentError("Z Parameter must be `true`, `false` or `nothing`"))
        M isa Union{Bool,Nothing} || throw(ArgumentError("M Parameter must be `true`, `false` or `nothing`"))

        # Wrap some geometry at the same level
        if isgeometry(geom)
            geomtrait(geom) isa $trait || _argument_error(T, $trait)
            Z1 = isnothing(Z) ? is3d(geom) : Z
            M1 = isnothing(M) ? ismeasured(geom) : M
            return $geomtype{Z1,M1,T,E,C}(geom, extent, crs)

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
                return $geomtype{Z1,M1,T,E,C}(geom, extent, crs)

            # Where we have nested points, as in `coordinates(geom)`
            else
                if child isa AbstractArray
                    if $nesting === 2
                        all(child2 -> geomtrait(child2) isa PointTrait, child) || _parent_type_error($geomtype, $child_trait, geom)
                        Z1 = isnothing(Z) ? is3d(first(child)) : Z
                        M1 = isnothing(M) ? ismeasured(first(child)) : M
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{Z1,M1,typeof(newgeom),E,C}(newgeom, extent, crs)
                    elseif $nesting === 3
                        all(child) do child2
                            child2 isa AbstractArray && all(child3 -> geomtrait(child3) isa PointTrait, child2)
                        end || _parent_type_error($geomtype, $child_trait, geom)
                        Z1 = isnothing(Z) ? is3d(first(first(child))) : Z
                        M1 = isnothing(M) ? ismeasured(first(first(child))) : M
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{Z1,M1,typeof(newgeom),E,C}(newgeom, extent, crs)
                    end
                end
                # Otherwise compain the nested child type is wrong
                _wrong_child_error($trait, $child_trait, child)
            end
        else
            # Or complain the parent type is wrong
            _parent_type_error($geomtype, $child_trait, geom)
        end
    end
end

_nice_print_geom(io::IO, geom, ::Bool) = show(io, MIME("text/plain"), geom)
_nice_print_geom(io::IO, geom::WrapperGeometry, show_mz::Bool) = Base.show(io, MIME("text/plain"), geom; show_mz = show_mz)

@noinline _wrong_child_error(geomtype, C, child) = throw(ArgumentError("$geomtype must have child objects with trait $C, got $(typeof(child)) with trait $(geomtrait(child))"))
@noinline _argument_error(T, A) = throw(ArgumentError("$T does not have $A"))
@noinline _length_error(T, f, x) = throw(ArgumentError("Length of array must be $(f.f) $(f.x) for $T"))
@noinline _parent_type_error(trait, child_trait, geom) = throw(ArgumentError("Object $geom is not a $trait geometry or array of $child_trait child geometries"))
@noinline _not_a_point_error(geom) = throw(ArgumentError("Object $geom is not a PointTrait geometry"))

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
using GeoInterface.Wrappers
point = Point{false,true}([1, 2, 3])
@assert GeoInterface.ismeasured(point) == true
@assert GeoInterface.is3d(point) == false
GeoInterface.m(point)
# output
3
```
"""
struct Point{Z,M,T,C} <: WrapperGeometry{Z,M,T,C}
    geom::T
    crs::C
end
function Point{Z,M}(geom::T; crs::C=nothing) where {Z,M,T,C}
    expected_coords = 2 + Z + M
    ncoord(geom) == expected_coords || _coord_length_error(Z, M, ncoord(geom))
    Point{Z,M,T,C}(geom, crs)
end
Point(x::Real, y::Real, args::Real...; crs=nothing) = Point((x, y, args...); crs)
Point{Z,M}(x::Real, y::Real, args::Real...; crs=nothing) where {Z,M} = Point{Z,M}((x, y, args...); crs)
function Point(; X::Real, Y::Real, Z::Union{Real,Nothing}=nothing, M::Union{Real,Nothing}=nothing, crs=nothing)
    p = (; X, Y)
    if !isnothing(Z)
        p = merge(p, (; Z))
    end
    if !isnothing(M)
        p = merge(p, (; M))
    end
    return Point(p; crs)
end
function Point(geom::T; crs::C=nothing) where {T,C}
    geomtrait(geom) isa PointTrait || _not_a_point_error(geom)
    if is3d(geom) && ismeasured(geom)
        return Point{true,true,T,C}(geom, crs)
    elseif is3d(geom)
        return Point{true,false,T,C}(geom, crs)
    elseif ismeasured(geom)
        return Point{false,true,T,C}(geom, crs)
    else
        return Point{false,false,T,C}(geom, crs)
    end
end
Point(point::Point{Z,M,T}; crs::C=crs(point)) where {Z,M,T,C} = 
    Point{Z,M,T,C}(parent(point), crs)

geointerface_geomtype(::PointTrait) = Point

isgeometry(::Type{<:Point}) = true
geomtrait(geom::Point) = PointTrait()
ncoord(trait::PointTrait, geom::Point) = ncoord(trait, parent(geom))
getcoord(trait::PointTrait, geom::Point, i::Integer) = getcoord(trait, parent(geom), i)
convert(::Type{Point}, ::PointTrait, geom) = Point(geom)
convert(::Type{Point}, ::PointTrait, geom::Point) = geom
extent(trait::PointTrait, geom::Point) = extent(trait, parent(geom)) 

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

function Base.show(io::IO, ::MIME"text/plain", point::Point{Z, M, T, C}; show_mz::Bool = true) where {Z,M,T,C}
    print(io, "Point")
    this_crs = crs(point)

    compact = get(io, :compact, false)
    spacing = compact ? "" : " "

    if !compact && show_mz
        print(io, "{$Z, $M}")
    end
    print(io, "(")
    trait = geomtrait(point)
    print(io, "($(x(trait, point)),$(spacing)$(y(trait, point))")
    if Z
        print(io, ",$(spacing)$(z(trait, point))")
    end
    print(io, ")")

    if !isnothing(this_crs)
        print(io, ",$(spacing)crs$(spacing)=$(spacing)$(this_crs)")
    end
    print(io, ")")

    return nothing
end

@noinline _coord_length_error(Z, M, l) =
    throw(ArgumentError("Number of coordinates must be $(2 + Z + M) when `Z` is $Z and `M` is $M. Got $l"))
@noinline _no_z_error() = throw(ArgumentError("Point has no `Z` coordinate"))
@noinline _no_m_error() = throw(ArgumentError("Point has no `M` coordinate"))

"""
    Feature(geometry; [properties, crs, extent])

A Feature wrapper.

## Arguments

- `geometry`: any GeoInterface compatible geometry object, or `nothing`.

## Keywords

- `properties`: any object that defines `propertynames` and `getproperty`
- `crs`: Any GeoFormatTypes.jl crs type, or `nothing`
- `extent`: An Extents.jl `Extent` or `nothing`

## Example

```julia
feature = Feature(geom; properties=(a=1, b="2"), crs=EPSG(4326))
```
"""
struct Feature{T,C,E<:Union{Extents.Extent,Nothing}}
    parent::T
    crs::C
    extent::E
end
function Feature(f::Feature; crs=crs(f), extent=f.extent, properties=nothing)
    isnothing(properties) || @info "`properties` keyword not used when wrapping a feature"
    Feature(parent(f), crs, extent)
end
function Feature(geometry=nothing; properties=nothing, crs=nothing, extent=nothing)
    if isnothing(geometry) || isgeometry(geometry)
        # Wrap a NamedTuple feature
        Feature((; geometry, properties...), crs, extent)
    else
        throw(ArgumentError("object must be a feature, geometry or `nothing`. Got $(typeof(geometry))"))
    end
end

function Base.show(io::IO, ::MIME"text/plain", f::Feature)
    compact = get(io, :compact, false)
    spacing = compact ? "" : " "
    print(io, "Feature(")
    show(io, MIME("text/plain"), f.parent.geometry)
    non_geom_props = filter(!=(:geometry), propertynames(f.parent))
    if !isempty(non_geom_props)
        print(io, ", properties$(spacing)=$(spacing)(")
        for (i, property) ∈ enumerate(non_geom_props)
            print(io, "$(property)$(spacing)=$(spacing)")
            Base.show(io, getproperty(f.parent, property))
            if i != length(non_geom_props)
                print(io, ",$(spacing)")
            end
        end
        print(io, ")")
    end
    if !isnothing(f.extent)
        print(io, ", extent$(spacing)=$(spacing)$(f.extent)")
    end
    if !isnothing(f.crs)
        print(io, ", crs$(spacing)=$(spacing)$(f.crs)")
    end
    print(io, ")")
end

Base.parent(f::Feature) = f.parent

isfeature(::Type{<:Feature}) = true
trait(::Feature) = FeatureTrait()
geometry(f::Feature) = geometry(parent(f))
properties(f::Feature) = properties(parent(f))
extent(f::Feature) =
    isfeature(parent(f)) && isnothing(f.extent) ? extent(parent(f)) : f.extent
crs(f::Feature) =
    isfeature(parent(f)) && isnothing(f.crs) ? crs(parent(f)) : f.crs

"""
    FeatureCollection(features; [crs, extent])

A FeatureCollection wrapper.

## Arguments

- `features`: an `AbstractArray` of GeoInterface compatible features.
    Iterables are accepted but will be collected to an `Array`.

## Keywords

- `crs`: Any GeoFormatTypes.jl crs type, or `nothing`
- `extent`: An Extents.jl `Extent` or `nothing`

## Examples

```julia
fc = FeatureCollection([feature1, feature2, feature3];
    crs=EPSG(4326), extent=Extent(X=(11.0, 34.0), Y=(45.7, 78.0))
)
```

Or wrap another `FeatureColection`, e.g. if it has no crs attached:

```julia
fc = FeatureCollection(featurecollection, crs=EPSG(4326))
```
"""
struct FeatureCollection{P,C,E}
    parent::P
    crs::C
    extent::E
end
function FeatureCollection(fc::FeatureCollection; crs=crs(fc), extent=extent(fc))
    FeatureCollection(parent(fc), crs, extent)
end
function FeatureCollection(parent; crs=nothing, extent=nothing)
    if isfeaturecollection(parent)
        FeatureCollection(parent, crs, extent)
    else
        features = (parent isa AbstractArray) ? parent : collect(parent) 
        all(f -> isfeature(f), features) || _child_feature_error()
        FeatureCollection(parent, crs, extent)
    end
end

function Base.show(io::IO, ::MIME"text/plain", fc::FeatureCollection)
    print(io, "FeatureCollection(")
    compact = get(io, :compact, false)
    spacing = compact ? "" : " "
    features = _parent_is_fc(fc) ? getfeature(trait(fc), parent(fc)) : parent(fc)
    print(io, "[")
    for (i, f) ∈ enumerate(features)
        show(io, MIME("text/plain"), f)
        if i != length(features)
            print(io, ",$(spacing)")
        end
    end
    print(io, "]")
    if !isnothing(fc.crs)
        print(io, ",$(spacing)crs=$(fc.crs)")
    end
    if !isnothing(fc.extent)
        print(io, ",$(spacing)extent=$(fc.extent)")
    end
    print(io, ")")
    return nothing
end

Base.parent(fc::FeatureCollection) = fc.parent

_child_feature_error() = throw(ArgumentError("child objects must be features"))

isfeaturecollection(fc::Type{<:FeatureCollection}) = true
trait(fc::FeatureCollection) = FeatureCollectionTrait()

nfeature(::FeatureCollectionTrait, fc::FeatureCollection) =
    _parent_is_fc(fc) ? nfeature(t, parent(fc)) : length(parent(fc))
getfeature(::FeatureCollectionTrait, fc::FeatureCollection) =
    _parent_is_fc(fc) ? getfeature(t, parent(fc)) : parent(fc)
getfeature(t::FeatureCollectionTrait, fc::FeatureCollection, i::Integer) =
    _parent_is_fc(fc) ? getfeature(t, parent(fc), i) : parent(fc)[i]
extent(fc::FeatureCollection) =
    (isnothing(fc.extent) && _parent_is_fc(fc)) ? extent(parent(fc)) : fc.extent
crs(fc::FeatureCollection) =
    (isnothing(fc.crs) && _parent_is_fc(fc)) ? crs(parent(fc)) : fc.crs

_parent_is_fc(x) = isfeaturecollection(parent(x))

end # module