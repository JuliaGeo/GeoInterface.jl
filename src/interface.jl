# All Geometries
"""
    GeoInterface.isgeometry(x) => Bool

Check if an object `x` is a geometry and thus implicitly supports GeoInterface methods.
It is recommended that for users implementing `MyType`, they define only
`isgeometry(::Type{MyType})`. `isgeometry(::MyType)` will then automatically delegate to this
method.
"""
isgeometry(x::T) where {T} = isgeometry(T)
isgeometry(::Type{T}) where {T} = false

"""
    GeoInterface.isfeature(x) => Bool

Check if an object `x` is a feature and thus implicitly supports some GeoInterface methods.
A feature is a combination of a geometry and properties, not unlike a row in a table.
It is recommended that for users implementing `MyType`, they define only
`isfeature(::Type{MyType})`. `isfeature(::MyType)` will then automatically delegate to this
method.

Ensures backwards compatibility with GeoInterface version 0.
"""
isfeature(x::T) where {T} = isfeature(T)
isfeature(::Type{T}) where {T} = false

"""
    GeoInterface.geometry(feat) => geom

Retrieve the geometry of `feat`. It is expected that `isgeometry(geom) === true`.
Ensures backwards compatibility with GeoInterface version 0.
"""
geometry(feat) = nothing

"""
    GeoInterface.properties(feat) => properties

Retrieve the properties of `feat`. This can be any Iterable that behaves like an AbstractRow.
Ensures backwards compatibility with GeoInterface version 0.
"""
properties(feat) = nothing

"""
    GeoInterface.geomtrait(geom) => T <: AbstractGeometry

Returns the geometry type, such as [`PolygonTrait`](@ref) or [`PointTrait`](@ref).
"""
geomtrait(geom) = nothing

# All types
"""
    ncoord(geom) -> Integer

Return the number of coordinate dimensions (such as 3 for X,Y,Z) for the geometry.
Note that SF distinguishes between dimensions, spatial dimensions and topological dimensions, which we do not.
"""
ncoord(geom) = ncoord(geomtrait(geom), geom)

"""
    coordnames(geom) -> Tuple{Symbol}

Return the names of coordinate dimensions (such for (:X,:Y,:Z)) for the geometry.
"""
coordnames(geom) = coordnames(geomtrait(geom), geom)

"""
    isempty(geom) -> Bool

Return `true` when the geometry is empty.
"""
isempty(geom) = isempty(geomtrait(geom), geom)

"""
    issimple(geom) -> Bool

Return `true` when the geometry is simple, i.e. doesn't cross or touch itself.
"""
issimple(geom) = issimple(geomtrait(geom), geom)

"""
    getcoord(geom, i) -> Number

Return the `i`th coordinate for a given `geom`. A coordinate isa `Real`.
Note that this is only valid for individual [`AbstractPointTrait`](@ref)s.
"""
getcoord(geom, i::Integer) = getcoord(geomtrait(geom), geom, i)
"""
    getcoord(geom) -> iterator
"""
getcoord(geom) = getcoord(geomtrait(geom), geom)

# Curve, LineString, MultiPoint
"""
    npoint(geom) -> Int

Return the number of points in given `geom`.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s and [`AbstractMultiPointTrait`](@ref)s.
"""
npoint(geom) = npoint(geomtrait(geom), geom)

"""
    getpoint(geom, i::Integer) -> Point

Return the `i`th Point in given `geom`.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s and [`AbstractMultiPointTrait`](@ref)s.
"""
getpoint(geom, i::Integer) = getpoint(geomtrait(geom), geom, i)

"""
    getpoint(geom) -> iterator

Returns an iterator over all points in `geom`.
"""
getpoint(geom) = getpoint(geomtrait(geom), geom)

# Curve
"""
    startpoint(geom) -> Point

Return the first point in the `geom`.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s.
"""
startpoint(geom) = startpoint(geomtrait(geom), geom)

"""
    endpoint(geom) -> Point

Return the last point in the `geom`.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s.
"""
endpoint(geom) = endpoint(geomtrait(geom), geom)

"""
    isclosed(geom) -> Bool

Return whether the `geom` is closed, i.e. whether
the `startpoint` is the same as the `endpoint`.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s.
"""
isclosed(geom) = isclosed(geomtrait(geom), geom)

"""
    isring(geom) -> Bool

Return whether the `geom` is a ring, i.e. whether
the `geom` [`isclosed`](@ref) and [`issimple`](@ref).
Note that this is only valid for [`AbstractCurveTrait`](@ref)s.
"""
isring(geom) = isclosed(geom) && issimple(geom)

"""
    length(geom) -> Number

Return the length of `geom` in its 2d coordinate system.
Note that this is only valid for [`AbstractCurveTrait`](@ref)s.
"""
length(geom) = length(geomtrait(geom), geom)

# Surface
"""
    area(geom) -> Number

Return the area of `geom` in its 2d coordinate system.
Note that this is only valid for [`AbstractSurfaceTrait`](@ref)s.
"""
area(geom) = area(geomtrait(geom), geom)

"""
    centroid(geom) -> Point

The mathematical centroid for this Surface as a Point.
The result is not guaranteed to be on this Surface.
Note that this is only valid for [`AbstractSurfaceTrait`](@ref)s.
"""
centroid(geom) = centroid(geomtrait(geom), geom)

"""
    pointonsurface(geom) -> Point

A Point guaranteed to be on this geometry (as opposed to [`centroid`](@ref)).
Note that this is only valid for [`AbstractSurfaceTrait`](@ref)s.
"""
pointonsurface(geom) = pointonsurface(geomtrait(geom), geom)

"""
    boundary(geom) -> Curve

Return the boundary of `geom`.
Note that this is only valid for [`AbstractSurfaceTrait`](@ref)s.
"""
boundary(geom) = boundary(geomtrait(geom), geom)

# Polygon/Triangle
"""
    nring(geom) -> Integer

Return the number of rings in given `geom`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s and
[`AbstractMultiPolygonTrait`](@ref)s
"""
nring(geom) = nring(geomtrait(geom), geom)

"""
    getring(geom, i::Integer) -> AbstractCurve

A specific ring `i` in a polygon or multipolygon (exterior and holes).
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s and
[`AbstractMultiPolygonTrait`](@ref)s.
"""
getring(geom, i::Integer) = getring(geomtrait(geom), geom, i)

"""
    getring(geom) -> iterator

Returns an iterator over all rings in `geom`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s and
[`AbstractMultiPolygonTrait`](@ref)s in single-argument form.
"""
getring(geom) = getring(geomtrait(geom), geom)

"""
    getexterior(geom) -> Curve

Returns the exterior ring of a Polygon as a `AbstractCurve`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s.
"""
getexterior(geom) = getexterior(geomtrait(geom), geom)

"""
    nhole(geom) -> Integer

Returns the number of holes for this given `geom`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s.
"""
nhole(geom)::Integer = nhole(geomtrait(geom), geom)

"""
    gethole(geom, i::Integer) -> Curve

Returns the `i`th interior ring for this given `geom`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s.
"""
gethole(geom, i::Integer) = gethole(geomtrait(geom), geom, i)

"""
    gethole(geom) -> iterator

Returns an iterator over all holes in `geom`.
Note that this is only valid for [`AbstractPolygonTrait`](@ref)s.
"""
gethole(geom) = gethole(geomtrait(geom), geom)

# PolyhedralSurface
"""
    npatch(geom)

Returns the number of patches for the given `geom`.
Note that this is only valid for [`AbstractPolyhedralSurfaceTrait`](@ref)s.
"""
npatch(geom)::Integer = npatch(geomtrait(geom), geom)

"""
    getpatch(geom, i::Integer) -> AbstractPolygon

Returns the `i`th patch for the given `geom`.
Note that this is only valid for [`AbstractPolyhedralSurfaceTrait`](@ref)s.
"""
getpatch(geom, i::Integer) = getpatch(geomtrait(geom), geom, i)

"""
    getpatch(geom) -> iterator

Returns an iterator over all patches in `geom`.
Note that this is only valid for [`AbstractPolyhedralSurfaceTrait`](@ref)s.
"""
getpatch(geom) = getpatch(geomtrait(geom), geom)

"""
    boundingpolygons(geom, i) -> AbstractMultiPolygon

Returns the collection of polygons in this surface that bounds the `i`th patch in the given `geom`.
"""
boundingpolygons(geom, i) = boundingpolygons(geomtrait(geom), geom, i)

# GeometryCollection
"""
    ngeom(geom) -> Integer

Returns the number of geometries for the given `geom`.
"""
ngeom(geom) = ngeom(geomtrait(geom), geom)

"""
    getgeom(geom, i::Integer) -> AbstractGeometry

Returns the `i`th geometry for the given `geom`.
"""
getgeom(geom, i::Integer) = getgeom(geomtrait(geom), geom, i)

"""
    getgeom(geom) -> iterator

Returns an iterator over all geometry components in `geom`.
"""
getgeom(geom) = getgeom(geomtrait(geom), geom)

# MultiLineString
"""
    nlinestring(geom) -> Integer

Returns the number of curves for the given `geom`.
Note that this is only valid for [`AbstractMultiLineStringTrait`](@ref)s.
"""
nlinestring(geom) = nlinestring(geomtrait(geom), geom)

"""
    getlinestring(geom, i::Integer) -> AbstractCurve

Returns the `i`th linestring for the given `geom`.
Note that this is only valid for [`AbstractMultiLineStringTrait`](@ref)s.
"""
getlinestring(geom, i::Integer) = getlinestring(geomtrait(geom), geom, i)

"""
    getlinestring(geom) -> iterator

Returns an iterator over all linestrings in a geometry.
Note that this is only valid for [`AbstractMultiLineStringTrait`](@ref)s.
"""
getlinestring(geom) = getlinestring(geomtrait(geom), geom)

# MultiPolygon
"""
    npolygon(geom) -> Integer

Returns the number of polygons for the given `geom`.
Note that this is only valid for [`AbstractMultiPolygonTrait`](@ref)s.
"""
npolygon(geom) = npolygon(geomtrait(geom), geom)

"""
    getpolygon(geom, i::Integer) -> AbstractCurve

Returns the `i`th polygon for the given `geom`.
Note that this is only valid for [`AbstractMultiPolygonTrait`](@ref)s.
"""
getpolygon(geom, i::Integer) = getpolygon(geomtrait(geom), geom, i)

"""
    getpolygon(geom) -> iterator

Returns an iterator over all polygons in a geometry.
Note that this is only valid for [`AbstractMultiPolygonTrait`](@ref)s.
"""
getpolygon(geom) = getpolygon(geomtrait(geom), geom)

# Other methods
"""
    crs(geom) -> T <: GeoFormatTypes.CoordinateReferenceSystemFormat

Retrieve Coordinate Reference System for given geom.
In SF this is defined as `SRID`.
"""
crs(geom) = crs(geomtrait(geom), geom)

"""
    extent(geom) -> T <: Extents.Extent

Retrieve the extent (bounding box) for given geom.
In SF this is defined as `envelope`.
"""
extent(geom) = extent(geomtrait(geom), geom)

"""
    bbox(geom) -> T <: Extents.Extent

Alias for [`extent`](@ref), for compatibility with
GeoJSON and the Python geointerface.
Ensures backwards compatibility with GeoInterface version 0.
"""
bbox(geom) = extent(geom)

# DE-9IM, see https://en.wikipedia.org/wiki/DE-9IM
"""
    equals(a, b) -> Bool

Returns whether `a` and `b` are equal.
Equivalent to ([`within`](@ref) && [`contains`](@ref)).
"""
equals(a, b)::Bool = equals(geomtrait(a), geomtrait(b), a, b)

"""
    disjoint(a, b) -> Bool

Returns whether `a` and `b` are disjoint.
Inverse of [`intersects`](@ref).
"""
disjoint(a, b)::Bool = disjoint(geomtrait(a), geomtrait(b), a, b)

"""
    intersects(a, b) -> Bool

Returns whether `a` and `b` intersect.
Inverse of [`disjoint`](@ref).
"""
intersects(a, b)::Bool = intersects(geomtrait(a), geomtrait(b), a, b)

"""
    touches(a, b) -> Bool

Returns whether `a` and `b` touch.
"""
touches(a, b)::Bool = touches(geomtrait(a), geomtrait(b), a, b)

"""
    within(a, b) -> Bool

Returns whether `a` is within `b`.
The order of arguments is important.
Equivalent to [`contains`](@ref) with reversed arguments.
"""
within(a, b)::Bool = within(geomtrait(a), geomtrait(b), a, b)

"""
    contains(a, b) -> Bool

Returns whether `a` contains `b`.
The order of arguments is important.
Equivalent to [`within`](@ref) with reversed arguments.
"""
contains(a, b)::Bool = contains(geomtrait(a), geomtrait(b), a, b)

"""
    overlaps(a, b) -> Bool

Returns whether `a` and `b` overlap. Also called `covers` in DE-9IM.
"""
overlaps(a, b)::Bool = overlaps(geomtrait(a), geomtrait(b), a, b)

"""
    crosses(a, b) -> Bool

Returns whether `a` and `b` cross.
"""
crosses(a, b)::Bool = crosses(geomtrait(a), geomtrait(b), a, b)

"""
    relate(a, b, relationmatrix::String) -> Bool

Returns whether `a` and `b` relate, based on the provided relation matrix.
"""
relate(a, b, relationmatrix)::Bool = relate(geomtrait(a), geomtrait(b), a, b, relationmatrix)

# Set theory
"""
    symdifference(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set symmetric difference of `a` with `b`.
"""
symdifference(a, b) = symdifference(geomtrait(a), geomtrait(b), a, b)

"""
    difference(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set difference of `a` with `b`
"""
difference(a, b) = difference(geomtrait(a), geomtrait(b), a, b)

"""
    intersection(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set intersection of `a` with `b`
"""
intersection(a, b) = intersection(geomtrait(a), geomtrait(b), a, b)

"""
    union(a, b) -> AbstractGeometry

Returns a geometric object that represents the Point set union of `a` with `b`
"""
union(a, b) = union(geomtrait(a), geomtrait(b), a, b)

# Spatial analysis
"""
    distance(a, b) -> Number

Returns the shortest distance between `a` with `b`.
"""
distance(a, b) = distance(geomtrait(a), geomtrait(b), a, b)

"""
    buffer(geom, distance) -> AbstractGeometry

Returns a geometric object that represents a buffer of the given `geom` with `distance`.
"""
buffer(geom, distance) = buffer(geomtrait(geom), geom, distance)

"""
    convexhull(geom) -> AbstractCurve

Returns a geometric object that represents the convex hull of the given `geom`.
"""
convexhull(geom) = convexhull(geomtrait(geom), geom)

"""
    x(geom) -> Number

Return the :X coordinate of the given `geom`.
Note that this is only valid for [`AbstractPointTrait`](@ref)s.
"""
x(geom) = x(geomtrait(geom), geom)

"""
    y(geom) -> Number

Return the :Y coordinate of the given `geom`.
Note that this is only valid for [`AbstractPointTrait`](@ref)s.
"""
y(geom) = y(geomtrait(geom), geom)

"""
    z(geom) -> Number

Return the :Z coordinate of the given `geom`.
Note that this is only valid for [`AbstractPointTrait`](@ref)s.
"""
z(geom) = z(geomtrait(geom), geom)

"""
    m(geom) -> Number

Return the :M coordinate of the given `geom`.
Note that this is only valid for [`AbstractPointTrait`](@ref)s.
"""
m(geom) = m(geomtrait(geom), geom)

"""
    is3d(geom) -> Bool

Return whether the given `geom` has a :Z coordinate.
"""
is3d(geom) = is3d(geomtrait(geom), geom)
"""
    ismeasured(geom) -> Bool

Return whether the given `geom` has a :M coordinate.
"""
ismeasured(geom) = ismeasured(geomtrait(geom), geom)

"""
    coordinates(geom) -> Vector

Return (an iterator of) point coordinates.
Ensures backwards compatibility with GeoInterface version 0.
"""
coordinates(geom) = coordinates(geomtrait(geom), geom)

"""
    convert(type::CustomGeom, geom)

Convert `geom` into the `CustomGeom` type if both geom as the CustomGeom package
have implemented GeoInterface.
"""
convert(T, geom) = convert(T, geomtrait(geom), geom)

"""
    astext(geom) -> WKT

Convert `geom` into Well Known Text (WKT) representation, such as `POINT (30 10)`.
"""
astext(geom) = astext(geomtrait(geom), geom)

"""
    asbinary(geom) -> WKB

Convert `geom` into Well Known Binary (WKB) representation, such as `000000000140000000000000004010000000000000`.
"""
asbinary(geom) = asbinary(geomtrait(geom), geom)
