# Defaults for many of the interface functions are defined here as fallback.
# Methods here should take a type as first argument and should already be defined
# in the `interface.jl` first as a generic f(geom) method.

## Coords
# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M)

coordnames(t::AbstractGeometryTrait, geom) = default_coord_names[1:ncoord(t, geom)]

# Maybe hardcode dimension order? At least for X and Y?
x(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:X), coordnames(geom)))
y(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:Y), coordnames(geom)))
z(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:Z), coordnames(geom)))
m(t::AbstractPointTrait, geom) = getcoord(t, geom, findfirst(isequal(:M), coordnames(geom)))

is3d(::AbstractPointTrait, geom) = :Z in coordnames(geom)
ismeasured(::AbstractPointTrait, geom) = :M in coordnames(geom)
isempty(T, geom) = false

## Points
ngeom(::AbstractPointTrait, geom)::Integer = 0
getgeom(::AbstractPointTrait, geom) = nothing
getgeom(::AbstractPointTrait, geom, i) = nothing

## LineStrings
npoint(t::AbstractCurveTrait, geom) = ngeom(t, geom)
getpoint(t::AbstractCurveTrait, geom) = getgeom(t, geom)
getpoint(t::AbstractCurveTrait, geom, i) = getgeom(t, geom, i)
startpoint(t::AbstractCurveTrait, geom) = getpoint(t, geom, 1)
endpoint(t::AbstractCurveTrait, geom) = getpoint(t, geom, length(geom))

## Polygons
nring(t::AbstractPolygonTrait, geom) = ngeom(t, geom)
getring(t::AbstractPolygonTrait, geom) = getgeom(t, geom)
getring(t::AbstractPolygonTrait, geom, i) = getgeom(t, geom, i)
getexterior(t::AbstractPolygonTrait, geom) = getring(t, geom, 1)
nhole(t::AbstractPolygonTrait, geom) = nring(t, geom) - 1
gethole(t::AbstractPolygonTrait, geom, i) = getring(t, geom, i + 1)
npoint(p::AbstractPolygonTrait, geom) = sum(npoint(p) for p in getring(t, geom))
getpoint(t::AbstractPolygonTrait, geom) = (p for p in getpoint(r) for r in getring(t, geom))

## MultiLineString
nlinestring(t::AbstractMultiLineStringTrait, geom) = ngeom(t, geom)
getlinestring(t::AbstractMultiLineStringTrait, geom) = getgeom(t, geom)
getlinestring(t::AbstractMultiLineStringTrait, geom, i) = getgeom(t, geom, i)
npoint(t::AbstractMultiLineStringTrait, geom) = sum(npoint(ls) for ls in getgeom(t, geom))
getpoint(t::AbstractMultiLineStringTrait, geom) = (p for p in getpoint(ls) for ls in getgeom(t, geom))

## MultiPolygon
npolygon(t::AbstractMultiPolygonTrait, geom) = ngeom(t, geom)
getpolygon(t::AbstractMultiPolygonTrait, geom) = getgeom(t, geom)
getpolygon(t::AbstractMultiPolygonTrait, geom, i) = getgeom(t, geom, i)
nring(t::AbstractMultiPolygonTrait, geom) = sum(nring(p) for p in getpolygon(t, geom))
getring(t::AbstractMultiPolygonTrait, geom) = (r for r in getring(p) for p in getpolygon(t, geom))
npoint(t::AbstractMultiPolygonTrait, geom) = sum(npoint(r) for r in getring(t, geom))
getpoint(t::AbstractMultiPolygonTrait, geom) = (p for p in getpoint(r) for r in getring(t, geom))

## Surface
npatch(t::AbstractPolyHedralSurfaceTrait, geom)::Integer = ngeom(t, geom)
getpatch(t::AbstractPolyHedralSurfaceTrait, geom) = getgeom(t, geom)
getpatch(t::AbstractPolyHedralSurfaceTrait, geom, i::Integer) = getgeom(t, geom, i)

## Default iterator
getgeom(t::AbstractGeometryTrait, geom) = (getgeom(t, geom, i) for i in 1:ngeom(t, geom))
getcoord(t::AbstractPointTrait, geom) = (getcoord(t, geom, i) for i in 1:ncoord(t, geom))

## Npoints
npoint(::LineTrait, _) = 2
npoint(::TriangleTrait, _) = 3
npoint(::RectangleTrait, _) = 4
npoint(::QuadTrait, _) = 4
npoint(::PentagonTrait, _) = 5
npoint(::HexagonTrait, _) = 6

issimple(::AbstractCurveTrait, geom) =
    allunique([getpoint(t, geom, i) for i in 1:npoint(geom)-1]) && allunique([getpoint(t, geom, i) for i in 2:npoint(t, geom)])
isclosed(t::AbstractCurveTrait, geom) = getpoint(t, geom, 1) == getpoint(t, geom, npoint(t, geom))
isring(t::AbstractCurveTrait, geom) = issimple(t, geom) && isclosed(t, geom)

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(t::AbstractMultiCurveTrait, geom) = all(i -> issimple(getgeom(t, geom, i)), 1:ngeom(t, geom))
isclosed(t::AbstractMultiCurveTrait, geom) = all(i -> isclosed(getgeom(t, geom, i)), 1:ngeom(t, geom))

issimple(t::AbstractMultiPointTrait, geom) = allunique((getgeom(t, geom, i) for i in 1:ngeom(t, geom)))
getpoint(t::AbstractMultiPointTrait, geom) = getgeom(t, geom)
getpoint(t::AbstractMultiPointTrait, geom, i) = getgeom(t, geom, i)

crs(::AbstractGeometryTrait, geom) = nothing
extent(::AbstractGeometryTrait, geom) = nothing

# Backwards compatibility
function coordinates(t::AbstractPointTrait, geom)
    collect(getcoord(t, geom))
end
function coordinates(t::AbstractGeometryTrait, geom)
    collect(coordinates.(getgeom(t, geom)))
end

# Subtraits

"""
    subtrait(t::AbstractGeometryTrait)

Gets the expected, possible abstract, (sub)trait for subgeometries (retrieved with [`getgeom`](@ref)) of trait `t`.
This follows the [Type hierarchy](@ref) of Simple Features.

# Examples
```jldoctest; setup = :(using GeoInterface)
julia> GeoInterface.subtrait(GeoInterface.LineStringTrait())
GeoInterface.PointTrait
julia> GeoInterface.subtrait(GeoInterface.PolygonTrait())  # Any of LineStringTrait, LineTrait, LinearRingTrait
GeoInterface.AbstractLineStringTrait
```
```jldoctest; setup = :(using GeoInterface)
# `nothing` is returned when there's no subtrait or when it's not known beforehand
julia> isnothing(GeoInterface.subtrait(GeoInterface.PointTrait()))
true
julia> isnothing(GeoInterface.subtrait(GeoInterface.GeometryCollectionTrait()))
true
```
"""
subtrait(::AbstractPointTrait) = nothing
subtrait(::AbstractCurveTrait) = AbstractPointTrait
subtrait(::AbstractCurvePolygonTrait) = AbstractCurveTrait
subtrait(::AbstractPolygonTrait) = AbstractLineStringTrait
subtrait(::AbstractPolyHedralSurfaceTrait) = AbstractPolygonTrait
subtrait(::TINTrait) = TriangleTrait
subtrait(::AbstractMultiPointTrait) = AbstractPointTrait
subtrait(::AbstractMultiLineStringTrait) = AbstractLineStringTrait
subtrait(::AbstractMultiPolygonTrait) = AbstractPolygonTrait
subtrait(::AbstractMultiSurfaceTrait) = AbstractSurfaceTrait
subtrait(::AbstractGeometryCollectionTrait) = nothing
subtrait(::AbstractGeometryTrait) = nothing  # fallback
