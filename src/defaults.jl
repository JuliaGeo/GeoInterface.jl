# Defaults for many of the interface functions are defined here as fallback.
# Methods here should take a type as first argument and should already be defined
# in the `interface.jl` first as a generic f(geom) method.

## Coords
# Four options in SF, xy, xyz, xym, xyzm
const default_coord_names = (:X, :Y, :Z, :M) 

coordnames(::Type{<:AbstractGeometry}, geom) = default_coord_names[1:ncoord(geom)]

# Maybe hardcode dimension order? At least for X and Y?
x(::Type{<:AbstractPoint}, geom) = getcoord(geom, findfirst(coordnames(geom), :X))
y(::Type{<:AbstractPoint}, geom) = getcoord(geom, findfirst(coordnames(geom), :Y))
z(::Type{<:AbstractPoint}, geom) = getcoord(geom, findfirst(coordnames(geom), :Z))
m(::Type{<:AbstractPoint}, geom) = getcoord(geom, findfirst(coordnames(geom), :M))

is3d(::Type{<:AbstractPoint}, geom) = :Z in coordnames(geom)
ismeasured(::Type{<:AbstractPoint}, geom) = :M in coordnames(geom)

## Points
ngeom(::Type{<:AbstractPoint}, geom)::Integer = 0
getgeom(::Type{<:AbstractPoint}, geom, i) = nothing

## LineStrings
npoint(c::Type{<:AbstractCurve}, geom) = ngeom(c, geom)
getpoint(c::Type{<:AbstractCurve}, geom, i) = getgeom(c, geom, i)
startpoint(c::Type{<:AbstractCurve}, geom) = getpoint(c, geom, 1)
endpoint(c::Type{<:AbstractCurve}, geom) = getpoint(c, geom, length(geom))

## Polygons
nring(p::Type{<:AbstractPolygon}, geom) = ngeom(p, geom)
getring(p::Type{<:AbstractPolygon}, geom, i) = getgeom(p, geom, i)
getexterior(p::Type{<:AbstractPolygon}, geom) = getring(p, geom, 1)
nhole(p::Type{<:AbstractPolygon}, geom) = nring(p, geom) - 1
gethole(p::Type{<:AbstractPolygon}, geom, i) = getring(p, geom, i + 1)

## MultiLineString
nlinestring(p::Type{<:AbstractMultiLineString}, geom) = ngeom(p, geom)
getlinestring(p::Type{<:AbstractMultiLineString}, geom, i) = getgeom(p, geom, i)

## MultiPolygon
npolygon(p::Type{<:AbstractMultiPolygon}, geom) = ngeom(p, geom)
getpolygon(p::Type{<:AbstractMultiPolygon}, geom, i) = getgeom(p, geom, i)

## Surface
npatch(p::Type{<:AbstractPolyHedralSurface}, geom)::Integer = ngeom(p, geom)
getpatch(p::Type{<:AbstractPolyHedralSurface}, geom, i::Integer) = getgeom(p, geom, i)


## Npoints
npoint(::Type{Line}, _) = 2
npoint(::Type{Triangle}, _) = 3
npoint(::Type{Rectangle}, _) = 4
npoint(::Type{Quad}, _) = 4
npoint(::Type{Pentagon}, _) = 5
npoint(::Type{Hexagon}, _) = 6

issimple(::Type{<:AbstractCurve}, geom) = allunique([getpoint(geom, i) for i in 1:npoint(geom)-1]) && allunique([getpoint(geom, i) for i in 2:npoint(geom)])
isclosed(::Type{<:AbstractCurve}, geom) = getpoint(geom, 1) == getpoint(geom, npoint(geom))
isring(x::AbstractCurve, geom) = issimple(x, geom) && isclosed(x, geom)

# TODO Only simple if it's also not intersecting itself, except for its endpoints
issimple(::Type{<:AbstractMultiCurve}, geom) = all(i -> issimple(getgeom(geom, i)), 1:ngeom(geom))
isclosed(::Type{<:AbstractMultiCurve}, geom) = all(i -> isclosed(getgeom(geom, i)), 1:ngeom(geom))

issimple(::Type{MultiPoint}, geom) = allunique((getgeom(geom, i) for i in 1:ngeom(geom)))

crs(::Type{<:AbstractGeometry}, geom) = nothing
extent(::Type{<:AbstractGeometry}, geom) = nothing

# Backwards compatibility
function coordinates(::Type{Point}, geom)
    collect(getcoord(geom, i) for i in 1:ncoord(geom))
end
function coordinates(::Type{<:AbstractGeometry}, geom)
    collect(coordinates(getgeom(geom, i)) for i in 1:ngeom(geom))
end
