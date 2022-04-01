# All Geometries
"""
    GeoInterface.isgeometry(x) => Bool

Check if an object `x` is a geometry and thus implicitely supports GeoInterface methods.
It is recommended that for users implementing `MyType`, they define only
`isgeometry(::Type{MyType})`. `isgeometry(::MyType)` will then automatically delegate to this
method.
"""
isgeometry(x::T) where {T} = isgeometry(T)
isgeometry(::Type{T}) where {T} = false

"""
    GeoInterface.geomtype(geom) => T <: AbstractGeometry

Returns the geometry type, such as [`GeoInterface.Polygon`](@ref) or [`GeoInterface.Point`](@ref).
"""
geomtype(geom) = nothing

# All types
"""
    ncoord(geom) -> Integer

Return the number of coordinate dimensions (such as 3 for X,Y,Z) for the geometry.
Note that SF distinguishes between dimensions, spatial dimensions and topological dimensions, which we do not.
"""
ncoord(geom) = ncoord(geomtype(geom), geom)

"""
    isempty(geom) -> Bool

Return `true` when the geometry is empty.
"""
isempty(geom) = ngeom(geom) == 0

"""
    issimple(geom) -> Bool

Return `true` when the geometry is simple, i.e. doesn't cross or touch itself.
"""
issimple(geom) = issimple(geomtype(geom), geom)

# Point
getcoord(geom, i::Integer) = getcoord(geomtype(geom), geom, i)

# Curve, LineString, MultiPoint
npoint(geom) = npoint(geomtype(geom), geom)
getpoint(geom, i::Integer) = getpoint(geomtype(geom), geom, i)

# Curve
startpoint(geom) = getpoint(geom, 1)
isclosed(geom) = isclosed(geomtype(geom), geom)
isring(geom) = isclosed(geom) && issimple(geom)
length(geom) = length(geomtype(geom), geom)
endpoint(geom) = getcoord(geom, length(geom))

# Surface
area(geom) = area(geomtype(geom), geom)
centroid(geom) = centroid(geomtype(geom), geom)
pointonsurface(geom) = pointonsurface(geomtype(geom), geom)
boundary(geom) = boundary(geomtype(geom), geom)

# Polygon/Triangle
nring(geom) = nring(geomtype(geom), geom) # TODO If this is more than one, it has interior rings (holes)
getring(geom) = getring(geomtype(geom), geom)

"""Returns the exterior ring of this Polygon as a `LineString`."""
getexterior(geom) = getexterior(geomtype(geom), geom)  # getring(geom, 1)
"""Returns the number of interior rings in this Polygon."""
nhole(geom)::Integer = nhole(geomtype(geom), geom)  # nrings - 1
"""Returns the Nth interior ring for this Polygon as a `LineString`."""
gethole(geom, i::Integer) = gethole(geomtype(geom), geom, i)  # getring + 1

# PolyHedralSurface
"""Returns the number of including polygons."""
npatch(geom)::Integer = npatch(geomtype(geom), geom)
"""Returns a polygon in this surface, the order is arbitrary."""
getpatch(geom, i::Integer) = getpatch(geomtype(geom), geom, i)
"""Returns the collection of polygons in this surface that bounds the given polygon “p” for any polygon “p” in the surface."""
boundingpolygons(geom) = nothing

# GeometryCollection
ngeom(geom) = ngeom(geomtype(geom), geom)
getgeom(geom, i::Integer) = getgeom(geomtype(geom), geom, i)

# MultiLineString
nlinestring(geom) = nlinestring(geomtype(geom), geom)
getlinestring(geom, i::Integer) = getlinestring(geomtype(geom), geom, i)

# MultiPolygon
npolygon(geom) = npolygon(geomtype(geom), geom)
getpolygon(geom, i::Integer) = getpolygon(geomtype(geom), geom, i)

# Other methods
"""
    crs(geom) -> T <: GeoFormatTypes.CoordinateReferenceSystemFormat

Retrieve Coordinate Reference System for given geom.
In SF this is defined as `SRID`.
"""
crs(geom) = nothing


# DE-9IM, see https://en.wikipedia.org/wiki/DE-9IM
equals(a, b)::Bool = equals(geomtype(a), geomtype(b), a, b)
disjoint(a, b)::Bool = disjoint(geomtype(a), geomtype(b), a, b)
touches(a, b)::Bool = touches(geomtype(a), geomtype(b), a, b)
within(a, b)::Bool = within(geomtype(a), geomtype(b), a, b)
overlaps(a, b)::Bool = overlaps(geomtype(a), geomtype(b), a, b)
crosses(a, b)::Bool = crosses(geomtype(a), geomtype(b), a, b)
intersects(a, b)::Bool = intersects(geomtype(a), geomtype(b), a, b)
contains(a, b)::Bool = contains(geomtype(a), geomtype(b), a, b)
relate(a, b)::Bool = relate(geomtype(a), geomtype(b), a, b)

# Set theory
symdifference(a, b) = difference(geomtype(a), geomtype(b), a, b)
difference(a, b, inverse=false) = difference(geomtype(a), geomtype(b), a, b, inverse)
intersection(a, b, inverse=false) = intersection(geomtype(a), geomtype(b), a, b, inverse)
union(a, b) = union(geomtype(a), geomtype(b), a, b)
