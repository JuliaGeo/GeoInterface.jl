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
getgeom(::AbstractPointTrait, geom, i) = nothing

## LineStrings
npoint(c::AbstractCurveTrait, geom) = ngeom(c, geom)
getpoint(c::AbstractCurveTrait, geom, i) = getgeom(c, geom, i)
startpoint(c::AbstractCurveTrait, geom) = getpoint(c, geom, 1)
endpoint(c::AbstractCurveTrait, geom) = getpoint(c, geom, length(geom))

## Polygons
nring(p::AbstractPolygonTrait, geom) = ngeom(p, geom)
getring(p::AbstractPolygonTrait, geom, i) = getgeom(p, geom, i)
getexterior(p::AbstractPolygonTrait, geom) = getring(p, geom, 1)
nhole(p::AbstractPolygonTrait, geom) = nring(p, geom) - 1
gethole(p::AbstractPolygonTrait, geom, i) = getring(p, geom, i + 1)

## MultiLineString
nlinestring(p::AbstractMultiLineStringTrait, geom) = ngeom(p, geom)
getlinestring(p::AbstractMultiLineStringTrait, geom, i) = getgeom(p, geom, i)

## MultiPolygon
npolygon(p::AbstractMultiPolygonTrait, geom) = ngeom(p, geom)
getpolygon(p::AbstractMultiPolygonTrait, geom, i) = getgeom(p, geom, i)

## Surface
npatch(p::AbstractPolyHedralSurfaceTrait, geom)::Integer = ngeom(p, geom)
getpatch(p::AbstractPolyHedralSurfaceTrait, geom, i::Integer) = getgeom(p, geom, i)


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
    collect(getcoord(geom, i) for i in 1:ncoord(geom))
end
function coordinates(::AbstractGeometryTrait, geom)
    collect(coordinates(getgeom(geom, i)) for i in 1:ngeom(geom))
end
