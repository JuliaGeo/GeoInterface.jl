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
    GeoInterface.isfeature(x) => Bool

Check if an object `x` is a feature and thus implicitely supports some GeoInterface methods.
A feature is a combination of a geometry and properties, not unlike a row in a table.
It is recommended that for users implementing `MyType`, they define only
`isfeature(::Type{MyType})`. `isfeature(::MyType)` will then automatically delegate to this
method.
Ensures backwards compatibility with the older GeoInterface.
"""
isfeature(x::T) where {T} = isfeature(T)
isfeature(::Type{T}) where {T} = false

"""
    GeoInterface.geometry(feat) => geom

Retrieve the geometry of `feat`. It is expected that `isgeometry(geom) === true`.
Ensures backwards compatibility with the older GeoInterface.
"""
geometry(feat) = nothing

"""
    GeoInterface.properties(feat) => properties

Retrieve the properties of `feat`. This can be any Iterable that behaves like an AbstractRow.
Ensures backwards compatibility with the older GeoInterface.
"""
properties(feat) = nothing

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
    coordnames(geom) -> Tuple{Symbol}

Return the names of coordinate dimensions (such for (:X,:Y,:Z)) for the geometry.
"""
coordnames(geom) = coordnames(geomtype(geom), geom)

"""
    isempty(geom) -> Bool

Return `true` when the geometry is empty.
"""
isempty(geom) = isempty(geomtype(geom), geom)

"""
    issimple(geom) -> Bool

Return `true` when the geometry is simple, i.e. doesn't cross or touch itself.
"""
issimple(geom) = issimple(geomtype(geom), geom)

"""
    getcoord(geom, i) -> Number

Return the `i`th coordinate for a given `geom`.
Note that this is only valid for individual [`AbstractPoint`]s.
"""
getcoord(geom, i::Integer) = getcoord(geomtype(geom), geom, i)
"""
    getcoord(geom) -> iterator
"""
getcoord(geom) = getcoord(geomtype(geom), geom)

# Curve, LineString, MultiPoint
"""
    npoint(geom) -> Int

Return the number of points in given `geom`.
Note that this is only valid for [`AbstractCurve`](@ref)s and [`AbstractMultiPoint`](@ref)s.
"""
npoint(geom) = npoint(geomtype(geom), geom)

"""
    getpoint(geom, i::Integer) -> Point

Return the `i`th Point in given `geom`.
Note that this is only valid for [`AbstractCurve`](@ref)s and [`AbstractMultiPoint`](@ref)s.
"""
getpoint(geom, i::Integer) = getpoint(geomtype(geom), geom, i)

"""
    getpoint(geom) -> iterator

Returns an iterator over all points in `geom`.
"""
getpoint(geom) = getpoint(geomtype(geom), geom)

# Curve
"""
    startpoint(geom) -> Point

Return the first point in the `geom`.
Note that this is only valid for [`AbstractCurve`](@ref)s.
"""
startpoint(geom) = startpoint(geomtype(geom), geom)

"""
    endpoint(geom) -> Point

Return the last point in the `geom`.
Note that this is only valid for [`AbstractCurve`](@ref)s.
"""
endpoint(geom) = endpoint(geomtype(geom), geom)

"""
    isclosed(geom) -> Bool

Return whether the `geom` is closed, i.e. whether
the `startpoint` is the same as the `endpoint`.
Note that this is only valid for [`AbstractCurve`](@ref)s.
"""
isclosed(geom) = isclosed(geomtype(geom), geom)

"""
    isring(geom) -> Bool

Return whether the `geom` is a ring, i.e. whether
the `geom` [`isclosed`](@ref) and [`issimple`](@ref).
Note that this is only valid for [`AbstractCurve`](@ref)s.
"""
isring(geom) = isclosed(geom) && issimple(geom)

"""
    length(geom) -> Number

Return the length of `geom` in its 2d coordinate system.
Note that this is only valid for [`AbstractCurve`](@ref)s.
"""
length(geom) = length(geomtype(geom), geom)

# Surface
"""
    area(geom) -> Number

Return the area of `geom` in its 2d coordinate system.
Note that this is only valid for [`AbstractSurface`](@ref)s.
"""
area(geom) = area(geomtype(geom), geom)

"""
    centroid(geom) -> Point

The mathematical centroid for this Surface as a Point.
The result is not guaranteed to be on this Surface.
Note that this is only valid for [`AbstractSurface`](@ref)s.
"""
centroid(geom) = centroid(geomtype(geom), geom)

"""
    pointonsurface(geom) -> Point

A Point guaranteed to be on this geometry (as opposed to [`centroid`](@ref)).
Note that this is only valid for [`AbstractSurface`](@ref)s.
"""
pointonsurface(geom) = pointonsurface(geomtype(geom), geom)

"""
    boundary(geom) -> Curve

Return the boundary of `geom`.
Note that this is only valid for [`AbstractSurface`](@ref)s.
"""
boundary(geom) = boundary(geomtype(geom), geom)

# Polygon/Triangle
"""
    nring(geom) -> Integer

Return the number of rings in given `geom`.
Note that this is only valid for [`AbstractPolygon`](@ref)s and
[`AbstractMultiPolygon`](@ref)s
"""
nring(geom) = nring(geomtype(geom), geom)

"""
    getring(geom, i::Integer) -> Int

Return the `i`th ring for a given `geom`.

Note that this is only valid for [`AbstractPolygon`](@ref)s.
"""
getring(geom, i::Integer) = getring(geomtype(geom), geom, i)

"""
    getring(geom) -> iterator

Returns an iterator over all rings in `geom`.
Note that this is only valid for [`AbstractPolygon`](@ref)s and
[`AbstractMultiPolygon`](@ref)s in single-argument form.
"""
getring(geom) = getring(geomtype(geom), geom)

"""
    getexterior(geom) -> Curve

Returns the exterior ring of a Polygon as a `AbstractCurve`.
Note that this is only valid for [`AbstractPolygon`](@ref)s.
"""
getexterior(geom) = getexterior(geomtype(geom), geom)

"""
    nhole(geom) -> Integer

Returns the number of holes for this given `geom`.
Note that this is only valid for [`AbstractPolygon`](@ref)s.
"""
nhole(geom)::Integer = nhole(geomtype(geom), geom)

"""
    gethole(geom, i::Integer) -> Curve

Returns the `i`th interior ring for this given `geom`.
Note that this is only valid for [`AbstractPolygon`](@ref)s.
"""
gethole(geom, i::Integer) = gethole(geomtype(geom), geom, i)

"""
    gethole(geom) -> iterator

Returns an iterator over all holes in `geom`.
Note that this is only valid for [`AbstractPolygon`](@ref)s.
"""
gethole(geom) = gethole(geomtype(geom), geom)

# PolyHedralSurface
"""
    npatch(geom)

Returns the number of patches for the given `geom`.
Note that this is only valid for [`AbstractPolyHedralSurface`](@ref)s.
"""
npatch(geom)::Integer = npatch(geomtype(geom), geom)

"""
    getpatch(geom, i::Integer) -> AbstractPolygon

Returns the `i`th patch for the given `geom`.
Note that this is only valid for [`AbstractPolyHedralSurface`](@ref)s.
"""
getpatch(geom, i::Integer) = getpatch(geomtype(geom), geom, i)

"""
    getpatch(geom) -> iterator

Returns an iterator over all patches in `geom`.
Note that this is only valid for [`AbstractPolyHedralSurface`](@ref)s.
"""
getpatch(geom) = getpatch(geomtype(geom), geom)

"""
    boundingpolygons(geom, i) -> AbstractMultiPolygon

Returns the collection of polygons in this surface that bounds the `i`th patch in the given `geom`.
"""
boundingpolygons(geom, i) = boundingpolygons(geomtype(geom), geom, i)

# GeometryCollection
"""
    ngeom(geom) -> Integer

Returns the number of geometries for the given `geom`.
"""
ngeom(geom) = ngeom(geomtype(geom), geom)

"""
    getgeom(geom, i::Integer) -> AbstractGeometry

Returns the `i`th geometry for the given `geom`.
"""
getgeom(geom, i::Integer) = getgeom(geomtype(geom), geom, i)

"""
    getgeom(geom) -> iterator

Returns an iterator over all geometry components in `geom`.
"""
getgeom(geom) = getgeom(geomtype(geom), geom)

# MultiLineString
"""
    nlinestring(geom) -> Integer

Returns the number of curves for the given `geom`.
Note that this is only valid for [`AbstractMultiLineString`](@ref)s.
"""
nlinestring(geom) = nlinestring(geomtype(geom), geom)

"""
    getlinestring(geom, i::Integer) -> AbstractCurve

Returns the `i`th linestring for the given `geom`.
Note that this is only valid for [`AbstractMultiLineString`](@ref)s.
"""
getlinestring(geom, i::Integer) = getlinestring(geomtype(geom), geom, i)

"""
    getlinestring(geom) -> iterator

Returns an iterator over all linestrings in a geometry.
Note that this is only valid for [`AbstractMultiLineString`](@ref)s.
"""
getlinestring(geom) = getlinestring(geomtype(geom), geom)

# MultiPolygon
"""
    npolygon(geom) -> Integer

Returns the number of polygons for the given `geom`.
Note that this is only valid for [`AbstractMultiPolygon`](@ref)s.
"""
npolygon(geom) = npolygon(geomtype(geom), geom)

"""
    getpolygon(geom, i::Integer) -> AbstractCurve

Returns the `i`th polygon for the given `geom`.
Note that this is only valid for [`AbstractMultiPolygon`](@ref)s.
"""
getpolygon(geom, i::Integer) = getpolygon(geomtype(geom), geom, i)

"""
    getpolygon(geom) -> iterator

Returns an iterator over all polygons in a geometry.
Note that this is only valid for [`AbstractMultiPolygon`](@ref)s.
"""
getpolygon(geom) = getpolygon(geomtype(geom), geom)

"""
    getring(geom, i::Integer) -> AbstractCurve

A specific ring `i` in a polygon or multipolygon (exterior and holes).
Note that this is only valid for [`AbstractPolygon`](@ref)s and
[`AbstractMultiPolygon`](@ref)s.
"""
getring(geom, i::Integer) = getring(geomtype(geom), geom, i)

"""
    getring(geom) -> iterable

Returns an iterator over all rings in a geometry.
Note that this is only valid for [`AbstractPolygon`](@ref)s and
[`AbstractMultiPolygon`](@ref)s.
"""
getring(geom) = getring(geomtype(geom), geom)

# Other methods
"""
    crs(geom) -> T <: GeoFormatTypes.CoordinateReferenceSystemFormat

Retrieve Coordinate Reference System for given geom.
In SF this is defined as `SRID`.
"""
crs(geom) = crs(geomtype(geom), geom)

"""
    extent(geom) -> T <: Extents.Extent

Retrieve the extent (bounding box) for given geom.
In SF this is defined as `envelope`.
"""
extent(geom) = extent(geomtype(geom), geom)

"""
    bbox(geom) -> T <: Extents.Extent

Alias for [`extent`](@ref), for compatibility with
GeoJSON and the Python geointerface.
Ensures backwards compatibility with the older GeoInterface.
"""
bbox(geom) = extent(geom)

# DE-9IM, see https://en.wikipedia.org/wiki/DE-9IM
"""
    equals(a, b) -> Bool

Returns whether `a` and `b` are equal.
Equivalent to ([`within`](@ref) && [`contains`](@ref)).
"""
equals(a, b)::Bool = equals(geomtype(a), geomtype(b), a, b)

"""
    disjoint(a, b) -> Bool

Returns whether `a` and `b` are disjoint.
Inverse of [`intersects`](@ref).
"""
disjoint(a, b)::Bool = disjoint(geomtype(a), geomtype(b), a, b)

"""
    intersects(a, b) -> Bool

Returns whether `a` and `b` intersect.
Inverse of [`disjoint`](@ref).
"""
intersects(a, b)::Bool = intersects(geomtype(a), geomtype(b), a, b)

"""
    touches(a, b) -> Bool

Returns whether `a` and `b` touch.
"""
touches(a, b)::Bool = touches(geomtype(a), geomtype(b), a, b)

"""
    within(a, b) -> Bool

Returns whether `a` is within `b`.
The order of arguments is important.
Equivalent to [`contains`](@ref) with reversed arguments.
"""
within(a, b)::Bool = within(geomtype(a), geomtype(b), a, b)

"""
    contains(a, b) -> Bool

Returns whether `a` contains `b`.
The order of arguments is important.
Equivalent to [`within`](@ref) with reversed arguments.
"""
contains(a, b)::Bool = contains(geomtype(a), geomtype(b), a, b)

"""
    overlaps(a, b) -> Bool

Returns whether `a` and `b` overlap. Also called `covers` in DE-9IM.
"""
overlaps(a, b)::Bool = overlaps(geomtype(a), geomtype(b), a, b)

"""
    crosses(a, b) -> Bool

Returns whether `a` and `b` cross.
"""
crosses(a, b)::Bool = crosses(geomtype(a), geomtype(b), a, b)

"""
    relate(a, b, relationmatrix::String) -> Bool

Returns whether `a` and `b` relate, based on the provided relation matrix.
"""
relate(a, b, relationmatrix)::Bool = relate(geomtype(a), geomtype(b), a, b, relationmatrix)

# Set theory
"""
    symdifference(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set symmetric difference of `a` with `b`.
"""
symdifference(a, b) = symdifference(geomtype(a), geomtype(b), a, b)

"""
    difference(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set difference of `a` with `b`
"""
difference(a, b) = difference(geomtype(a), geomtype(b), a, b)

"""
    intersection(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set intersection of `a` with `b`
"""
intersection(a, b) = intersection(geomtype(a), geomtype(b), a, b)

"""
    union(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set union of `a` with `b`
"""
union(a, b) = union(geomtype(a), geomtype(b), a, b)

# Spatial analysis
"""
    distance(a, b) -> Number

Returns the shortest distance between `a` with `b`.
"""
distance(a, b) = distance(geomtype(a), geomtype(b), a, b)

"""
    buffer(geom, distance) -> AbstractGeometry

Returns a geometric object that represents a buffer of the given `geom` with `distance`.
"""
buffer(geom, distance) = buffer(geomtype(geom), geom, distance)

"""
    convexhull(geom) -> AbstractCurve

Returns a geometric object that represents the convex hull of the given `geom`.
"""
convexhull(geom) = convexhull(geomtype(geom), geom)

"""
    x(geom) -> Number

Return the :X coordinate of the given `geom`.
Note that this is only valid for [`AbstractPoint`](@ref)s.
"""
x(geom) = x(geomtype(geom), geom)

"""
    y(geom) -> Number

Return the :Y coordinate of the given `geom`.
Note that this is only valid for [`AbstractPoint`](@ref)s.
"""
y(geom) = y(geomtype(geom), geom)

"""
    z(geom) -> Number

Return the :Z coordinate of the given `geom`.
Note that this is only valid for [`AbstractPoint`](@ref)s.
"""
z(geom) = z(geomtype(geom), geom)

"""
    m(geom) -> Number

Return the :M coordinate of the given `geom`.
Note that this is only valid for [`AbstractPoint`](@ref)s.
"""
m(geom) = m(geomtype(geom), geom)

"""
    is3d(geom) -> Bool

Return whether the given `geom` has a :Z coordinate.
"""
is3d(geom) = is3d(geomtype(geom), geom)
"""
    ismeasured(geom) -> Bool

Return whether the given `geom` has a :M coordinate.
"""
ismeasured(geom) = ismeasured(geomtype(geom), geom)

"""
    coordinates(geom) -> Vector

Return (an iterator of) point coordinates.
Ensures backwards compatibility with the older GeoInterface.
"""
coordinates(geom) = coordinates(geomtype(geom), geom)

"""
    convert(type::CustomGeom, geom)

Convert `geom` into the `CustomGeom` type if both geom as the CustomGeom package
have implemented GeoInterface.
"""
convert(T, geom) = convert(T, geomtype(geom), geom)

"""
    astext(geom) -> WKT

Convert `geom` into Well Known Text (WKT) representation, such as `POINT (30 10)`.
"""
astext(geom) = astext(geomtype(geom), geom)

"""
    asbinary(geom) -> WKB

Convert `geom` into Well Known Binary (WKB) representation, such as `000000000140000000000000004010000000000000`.
"""
asbinary(geom) = asbinary(geomtype(geom), geom)
