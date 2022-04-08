# Defaults for many of the interface functions are defined here as fallback.
# Methods here should take a type as first argument and should already be defined
# in the `interface.jl` first as a generic f(geom) method.

## Coords
# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M) 

coordnames(::AbstractGeometry, geom) = default_coord_names[1:ncoord(geom)]

# Maybe hardcode dimension order? At least for X and Y?
x(::AbstractPoint, geom) = getcoord(geom, findfirst(coordnames(geom), :X))
y(::AbstractPoint, geom) = getcoord(geom, findfirst(coordnames(geom), :Y))
z(::AbstractPoint, geom) = getcoord(geom, findfirst(coordnames(geom), :Z))
m(::AbstractPoint, geom) = getcoord(geom, findfirst(coordnames(geom), :M))

is3d(::AbstractPoint, geom) = :Z in coordnames(geom)
ismeasured(::AbstractPoint, geom) = :M in coordnames(geom)

## Points
ngeom(::AbstractPoint, geom)::Integer = 0
getgeom(::AbstractPoint, geom, i) = nothing

## LineStrings
npoint(c::AbstractCurve, geom) = ngeom(c, geom)
getpoint(c::AbstractCurve, geom, i) = getgeom(c, geom, i)
startpoint(c::AbstractCurve, geom) = getpoint(c, geom, 1)
endpoint(c::AbstractCurve, geom) = getpoint(c, geom, length(geom))

## Polygons
nring(p::AbstractPolygon, geom) = ngeom(p, geom)
getring(p::AbstractPolygon, geom, i) = getgeom(p, geom, i)
getexterior(p::AbstractPolygon, geom) = getring(p, geom, 1)
nhole(p::AbstractPolygon, geom) = nring(p, geom) - 1
gethole(p::AbstractPolygon, geom, i) = getring(p, geom, i + 1)

## MultiLineString
nlinestring(p::AbstractMultiLineString, geom) = ngeom(p, geom)
getlinestring(p::AbstractMultiLineString, geom, i) = getgeom(p, geom, i)

## MultiPolygon
npolygon(p::AbstractMultiPolygon, geom) = ngeom(p, geom)
getpolygon(p::AbstractMultiPolygon, geom, i) = getgeom(p, geom, i)

## Surface
npatch(p::AbstractPolyHedralSurface, geom)::Integer = ngeom(p, geom)
getpatch(p::AbstractPolyHedralSurface, geom, i::Integer) = getgeom(p, geom, i)


## Npoints
npoint(::Line, _) = 2
npoint(::Triangle, _) = 3
npoint(::Rectangle, _) = 4
npoint(::Quad, _) = 4
npoint(::Pentagon, _) = 5
npoint(::Hexagon, _) = 6

issimple(::AbstractCurve, geom) = allunique([getpoint(geom, i) for i in 1:npoint(geom)-1]) && allunique([getpoint(geom, i) for i in 2:npoint(geom)])
isclosed(::AbstractCurve, geom) = getpoint(geom, 1) == getpoint(geom, npoint(geom))
isring(x::AbstractCurve, geom) = issimple(x, geom) && isclosed(x, geom)

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(::AbstractMultiCurve, geom) = all(i -> issimple(getgeom(geom, i)), 1:ngeom(geom))
isclosed(::AbstractMultiCurve, geom) = all(i -> isclosed(getgeom(geom, i)), 1:ngeom(geom))

issimple(::MultiPoint, geom) = allunique((getgeom(geom, i) for i in 1:ngeom(geom)))

crs(::AbstractGeometry, geom) = nothing
extent(::AbstractGeometry, geom) = nothing
