
export Point, EmptyPoint, LineString, Polygon, Triangle, MultiPoint, MultiCurve, MultiPolygon, TIN, Collection, Feature, FeatureCollection

# Implement interface

"""
    WrapperGeometry

Provides geometry wrappers that accept any GeoInterface compatible
objects. These can be usefull for building custom geometries, or in tests.
"""
abstract type WrapperGeometry{T,Z,M} end

isgeometry(::Type{<:WrapperGeometry}) = true
is3d(::WrapperGeometry{<:Any,Z}) where Z = Z
ismeasured(::WrapperGeometry{<:Any,<:Any,M})  where M = M

Base.parent(geom::WrapperGeometry) = geom.geom
# Here converting means wrapping
Base.convert(::Type{T}, geom) where {T<:WrapperGeometry} = T(geom)
Base.convert(::Type{T}, geom::T) where {T<:WrapperGeometry} = geom
Base.convert(::Type{T}, geom::WrapperGeometry{T}) where T = parent(geom)

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
function getgeom(trait::AbstractGeometryTrait, geom::WrapperGeometry{T}, i) where T
    isgeometry(T) ? getgeom(trait, parent(geom), i) : parent(geom)[i]
end
getpoint(trait::AbstractGeometryTrait, geom::WrapperGeometry, i) = getpoint(trait, parent(geom), i)
gethole(trait::AbstractGeometryTrait, geom::WrapperGeometry, i) = gethole(trait, parent(geom), i)

for (geomtype, trait, childtype, child_trait, length_check, nesting) in (
        (:LineString, :LineStringTrait, :Point, :PointTrait, >=(2), 1),
        (:LinearRing, :LinearRingTrait, :Point, :PointTrait, >=(3), 1),
        (:Triangle, :TriangleTrait, :Point, :PointTrait, ==(3), 1),
        (:Quad, :QuadTrait, :Point, :PointTrait, ==(4), 1),
        (:Pentagon, :PentagonTrait, :Point, :PointTrait, ==(4), 1),
        (:Hexagon, :HexagonTrait, :Point, :PointTrait, ==(6), 1),
        (:Rectangle, :RectangleTrait, :Point, :PointTrait, nothing, 1),
        (:MultiPoint, :MultiPointTrait, :Point, :PointTrait, nothing, 1),
        (:Polygon, :PolygonTrait, :LinearRing, :AbstractLineStringTrait, nothing, 2),
        (:MultiCurve, :MultiCurveTrait, :LineString, :AbstractCurveTrait, nothing, 2),
        (:MultiPolygon, :MultiPolygonTrait, :Polygon, :PolygonTrait, nothing, 3),
        (:TIN, :TINTrait, :Triangle, :TriangleTrait, nothing, 2),
        (:GeometryCollection, :GeometryCollectionTrait, :AbstractGeometry, :AbstractGeometryTrait, nothing, nothing),
        (:PolyhedralSurface, :PolyhedralSurfaceTrait, :Polygon, :PolygonTrait, nothing, 3),
    )
    @eval begin
        struct $geomtype{T,Z,M,E} <: WrapperGeometry{T,Z,M}
            geom::T
            extent::E
        end
        geomtrait(::$geomtype) = $trait()
        geomtype(::Type{$trait}) = $geomtype
    end
    @eval function $geomtype(geom::T; extent::E=nothing) where {T,E}
        # Wrap some geometry at the same level
        if isgeometry(geom)
            geomtrait(geom) isa $trait || _argument_error(T, $trait)
            Z = is3d(geom)
            M = ismeasured(geom)
            return $geomtype{T,Z,M,E}(geom, extent)
        # Otherwise wrap an array of child geometries
        elseif geom isa AbstractArray
            child = first(geom)
            chilren_match = all(child -> geomtrait(child) isa $child_trait, geom) 
            # Where the next level down is the child geometry
            if chilren_match
                if $(!isnothing(length_check))
                    $length_check(Base.length(geom)) || _length_error($geomtype, $length_check, geom)
                end
                Z = is3d(first(geom))
                M = ismeasured(first(geom))
                return $geomtype{T,Z,M,E}(geom, extent)
            # Where we have nested points, as in `coordinates(geom)`
            else
                if child isa AbstractArray
                    if $nesting === 2
                        all(child2 -> geomtrait(child2) isa PointTrait, child) || _parent_type_error(geom)
                        Z = is3d(first(child))
                        M = ismeasured(first(child))
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{typeof(newgeom),Z,M,E}(newgeom, extent)
                    elseif $nesting === 3
                        all(child) do child2
                            child2 isa AbstractArray && all(child3 -> geomtrait(child3) isa PointTrait, child2) 
                        end || _parent_type_error(geom)
                        Z = is3d(first(first(child)))
                        M = ismeasured(first(first(child)))
                        childtype = $childtype
                        newgeom = childtype.(geom)
                        return $geomtype{typeof(newgeom),Z,M,E}(newgeom, extent)
                    else
                        _wrong_child_error($geomtype, $child_trait, child)
                    end
                else
                    _wrong_child_error($geomtype, $child_trait, child)
                end
            end
        else
            _parent_type_error(geom)
        end
    end
    @eval function ngeom(wrapper::$geomtype)
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
    @eval extent(wrapper::$geomtype) = wrapper.extent
end
# :nring, :getring, :getexterior, :nhole, :gethole

struct Point{T,Z,M} <: WrapperGeometry{T,Z,M}
    geom::T
end
function Point(x::Real, y::Real, args::Real...)
    Base.length(args) < 3 || _ncoord_error(Base.length(args) + 2)
    return Point((x, y, args...))
end
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
        g = (X=x(geom), Y=y(geom), Z=z(geom), M=m(geom))
        return Point{typeof(g),true,true}(g)
    elseif is3d(geom)
        g = (X=x(geom), Y=y(geom), Z=z(geom))
        return Point{typeof(g),true,false}(g)
    elseif ismeasured(geom)
        g = (X=x(geom), Y=y(geom), M=m(geom))
        return Point{typeof(g),false,true}(g)
    else
        g = (X=x(geom), Y=y(geom))
        return Point{typeof(g),false,false}(g)
    end
end

_ncoord_error(ncoords) = throw(ArgumentError("Point can have 2 to 4 coords, got $ncoords"))

isgeometry(::Type{<:Point}) = true
geomtrait(geom::Point) = PointTrait()
ncoord(trit::PointTrait, geom::Point) = ncoord(trait, parent(geom))
getcoord(trait::PointTrait, geom::Point, i::Integer) = getcoord(trait, parent(geom), i)

x(trait::PointTrait, geom::Point) = x(trait, parent(geom))
y(trait::PointTrait, geom::Point) = y(trait, parent(geom))
z(trait::PointTrait, geom::Point) = z(trait, parent(geom))
m(trait::PointTrait, geom::Point) = m(trait, parent(geom))

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

struct Feature{G,P,C,E}
    geometry::G
    properties::P
    crs::C
    extent::E
end
Feature(; geometry=nothing, properties=nothing, crs=nothing, extent=nothing) = 
    Feature(geometry, properties, crs, extent)

isfeature(::Type{<:Feature}) = true
trait(feature::Feature) = FeatureTrait()
geometry(f::Feature) = f.geometry
properties(f::Feature) = f.properties
extent(f::Feature) = f.extent
crs(f::Feature) = f.crs

struct FeatureCollection{F,C,E}
    features::F
    crs::C
    extent::E
end
function FeatureCollection(features; crs=nothing, extent=nothing)
    all(f -> GI.isfeature(f), features) || throw(ArgumentError("contents are not all features"))
    if features isa AbstractArray
        FeatureCollection(features, crs, extent)
    else
        FeatureCollection(collect(features), crs, extent)
    end
end

isfeaturecollection(fc::Type{<:FeatureCollection}) = true
trait(fc::FeatureCollection) = FeatureCollectionTrait()

nfeature(::FeatureCollectionTrait, fc::FeatureCollection) = length(fc.geoms)
getfeature(::FeatureCollectionTrait, fc::FeatureCollection) = fc.features
getfeature(::FeatureCollectionTrait, fc::FeatureCollection, i::Integer) = fc.features[i]
extent(fc::FeatureCollection) = fc.extent
crs(fc::FeatureCollection) = fc.crs

@noinline _wrong_child_error(geomtype, C, child) = throw(ArgumentError("$geomtype must have child objects with trait $C, got $(typeof(child)) with trait $(geomtrait(child))"))
@noinline _argument_error(T, A) = throw(ArgumentError("$T is not a $A"))
@noinline _length_error(T, f, x) = throw(ArgumentError("Length of array must be $(f.f) $(f.x) for $T"))
@noinline _parent_type_error(geom) = throw(ArgumentError("Object $geom is not a geometry or array of child geometries"))
