# Defaults for many of the interface functions are defined here as fallback.
# Methods here should take a type as first argument and should already be defined
# in the `interface.jl` first as a generic f(geom) method.

## Coords
# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M)

coordnames(::AbstractGeometryTrait, geom) = default_coord_names[1:ncoord(geom)]

# Maybe hardcode dimension order? At least for X and Y?
x(::AbstractPointTrait, geom) = getcoord(geom, findfirst(coordnames(geom), :X))
y(::AbstractPointTrait, geom) = getcoord(geom, findfirst(coordnames(geom), :Y))
z(::AbstractPointTrait, geom) = getcoord(geom, findfirst(coordnames(geom), :Z))
m(::AbstractPointTrait, geom) = getcoord(geom, findfirst(coordnames(geom), :M))

is3d(::AbstractPointTrait, geom) = :Z in coordnames(geom)
ismeasured(::AbstractPointTrait, geom) = :M in coordnames(geom)
isempty(T, geom) = false

## Points
ngeom(::AbstractPointTrait, geom)::Integer = 0
getgeom(::AbstractPointTrait, geom) = nothing
getgeom(::AbstractPointTrait, geom, i) = nothing

## LineStrings
npoint(c::AbstractCurveTrait, geom) = ngeom(c, geom)
getpoint(c::AbstractCurveTrait, geom) = getgeom(c, geom)
getpoint(c::AbstractCurveTrait, geom, i) = getgeom(c, geom, i)
startpoint(c::AbstractCurveTrait, geom) = getpoint(c, geom, 1)
endpoint(c::AbstractCurveTrait, geom) = getpoint(c, geom, length(geom))

## Polygons
nring(p::AbstractPolygonTrait, geom) = ngeom(p, geom)
getring(p::AbstractPolygonTrait, geom) = getgeom(p, geom)
getring(p::AbstractPolygonTrait, geom, i) = getgeom(p, geom, i)
getexterior(p::AbstractPolygonTrait, geom) = getring(p, geom, 1)
nhole(p::AbstractPolygonTrait, geom) = nring(p, geom) - 1
gethole(p::AbstractPolygonTrait, geom, i) = getring(p, geom, i + 1)
npoint(p::AbstractPolygonTrait, geom) = sum(npoint(p) for p in getring(p))
getpoint(g::AbstractPolygonTrait, geom) = (p for p in getpoint(r) for r in getring(geom))

## MultiLineString
nlinestring(p::AbstractMultiLineStringTrait, geom) = ngeom(p, geom)
getlinestring(p::AbstractMultiLineStringTrait, geom) = getgeom(p, geom)
getlinestring(p::AbstractMultiLineStringTrait, geom, i) = getgeom(p, geom, i)
npoint(g::AbstractMultiLineStringTrait, geom) = sum(npoint(l) for ls in getlinestring(geom))
getpoint(g::AbstractMultiLineStringTrait, geom) = (p for p in getpoint(ls) for l in getlinestring(geom))

## MultiPolygon
npolygon(p::AbstractMultiPolygonTrait, geom) = ngeom(p, geom)
getpolygon(p::AbstractMultiPolygonTrait, geom) = getgeom(p, geom)
getpolygon(p::AbstractMultiPolygonTrait, geom, i) = getgeom(p, geom, i)
nring(p::AbstractMultiPolygonTrait, geom) = sum(nring(p) for p in getpolygon(p))
getring(g::AbstractMultiPolygonTrait, geom) = (r for r in getring(p) for p in getpolygon(geom))
npoint(p::AbstractMultiPolygonTrait, geom) = sum(npoint(r) for r in getring(geom))
getpoint(g::AbstractMultiPolygonTrait, geom) = (p for p in getpoint(r) for r in getring(geom))

## Surface
npatch(p::AbstractPolyHedralSurfaceTrait, geom)::Integer = ngeom(p, geom)
getpatch(p::AbstractPolyHedralSurfaceTrait, geom) = getgeom(p, geom)
getpatch(p::AbstractPolyHedralSurfaceTrait, geom, i::Integer) = getgeom(p, geom, i)

## Default iterator
getgeom(p::AbstractGeometryTrait, geom) = (getgeom(p, geom, i) for i in 1:ngeom(p, geom))
getcoord(p::AbstractPointTrait, geom) = (getcoord(p, geom, i) for i in 1:ncoord(p, geom))

## Npoints
npoint(::LineTrait, _) = 2
npoint(::TriangleTrait, _) = 3
npoint(::RectangleTrait, _) = 4
npoint(::QuadTrait, _) = 4
npoint(::PentagonTrait, _) = 5
npoint(::HexagonTrait, _) = 6

issimple(::AbstractCurveTrait, geom) = allunique([getpoint(geom, i) for i in 1:npoint(geom)-1]) && allunique([getpoint(geom, i) for i in 2:npoint(geom)])
isclosed(::AbstractCurveTrait, geom) = getpoint(geom, 1) == getpoint(geom, npoint(geom))
isring(x::AbstractCurveTrait, geom) = issimple(x, geom) && isclosed(x, geom)

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(::AbstractMultiCurveTrait, geom) = all(i -> issimple(getgeom(geom, i)), 1:ngeom(geom))
isclosed(::AbstractMultiCurveTrait, geom) = all(i -> isclosed(getgeom(geom, i)), 1:ngeom(geom))

issimple(::MultiPointTrait, geom) = allunique((getgeom(geom, i) for i in 1:ngeom(geom)))

crs(::AbstractGeometryTrait, geom) = nothing
extent(::AbstractGeometryTrait, geom) = nothing

# Backwards compatibility
function coordinates(::AbstractPointTrait, geom)
    collect(getcoord(geom))
end
function coordinates(::AbstractGeometryTrait, geom)
    collect(coordinates.(getgeom(geom)))
end

# Subtraits

"""
    subtrait(t::AbstractGeometryTrait)

Gets the expected (sub)trait for subgeometries (retrieved with [`getgeom`](@ref)) of trait `t`.
This follows the [Type hierarchy](@ref) of Simple Features.

# Examples
```jldoctest; setup = :(using GeoInterface)
julia> GeoInterface.subtrait(GeoInterface.LineStringTrait())
GeoInterface.PointTrait
julia> GeoInterface.subtrait(GeoInterface.MultiPointTrait())
GeoInterface.PointTrait
```
```jldoctest; setup = :(using GeoInterface)
# `nothing` is returned when there's no subtrait or when it's not known beforehand
julia> isnothing(GeoInterface.subtrait(GeoInterface.PointTrait()))
true
julia> isnothing(GeoInterface.subtrait(GeoInterface.GeometryCollectionTrait()))
true
```
"""
subtrait(::PointTrait) = nothing
subtrait(::LineStringTrait) = PointTrait
subtrait(::PolygonTrait) = LineStringTrait
subtrait(::MultiPointTrait) = PointTrait
subtrait(::MultiLineStringTrait) = LineStringTrait
subtrait(::MultiPolygonTrait) = PolygonTrait
subtrait(::GeometryCollectionTrait) = nothing
