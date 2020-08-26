abstract type AbstractGeometry end
# """The general `Geometry` type."""
# struct Geometry <: AbstractGeometry end  # commented out as it won't be used directly

abstract type AbstractGeometryCollection <: AbstractGeometry end
"""A `GeometryCollection` is a collection of `Geometry`s."""
struct GeometryCollection <: AbstractGeometryCollection end

abstract type AbstractPoint <: AbstractGeometry end
"""A simple `Point`."""
struct Point <: AbstractPoint end

abstract type AbstractCurve <: AbstractGeometry end
abstract type AbstractLineString <: AbstractCurve end
"""A `LineString` is a collection of straight lines between its `Point`s."""
struct LineString <: AbstractLineString end
"""A Line is `LineString` with just two points."""
struct Line <: AbstractLineString end
"""A LinearRing is a `LineString` with the same begin and endpoint."""
struct LinearRing <: AbstractLineString end

"""A `CircularString` is a curve, with an odd number of points.
A single segment consists of three points, where the first and last are the beginning and end,
while the second is halfway the curve."""
struct CircularString <: AbstractCurve end
"""A `CompoundCurve` is a curve that combines straight `LineString`s and curved `CircularString`s."""
struct CompoundCurve <: AbstractCurve end

abstract type AbstractSurface <: AbstractGeometry end
abstract type AbstractCurvePolygon <: AbstractSurface end
"""A `Polygon` that can contain either circular or straight curves as rings."""
struct CurvePolygon <: AbstractCurvePolygon end
abstract type AbstractPolygon <: AbstractCurvePolygon end
"""A `Polygon` with straight rings either as exterior or interior(s)."""
struct Polygon <: AbstractPolygon end
"""A `Polygon` with straight rings either as exterior or interior(s)."""
struct Triangle <: AbstractPolygon end

"""A `Polygon` that is rectangular and could be described by the minimum and maximum vertices."""
struct Rectangle <: AbstractPolygon end
"""A `Polygon` with four vertices."""
struct Quad <: AbstractPolygon end
"""A `Polygon` with five vertices."""
struct Pentagon <: AbstractPolygon end
"""A `Polygon` with six vertices."""
struct Hexagon <: AbstractPolygon end

abstract type AbstractPolyHedralSurface <: AbstractSurface end
"""A `PolyHedralSurface` is a connected surface consisting of Polygons."""
struct PolyHedralSurface <: AbstractPolyHedralSurface end
"""A `TIN` is a `PolyHedralSurface` consisting of `Triangle`s."""
struct TIN <: AbstractPolyHedralSurface end  # Surface consisting of Triangles

abstract type AbstractMultiPoint <: AbstractGeometryCollection end
"""A `MultiPoint` is a collection of `Point`s."""
struct MultiPoint <: AbstractMultiPoint end

abstract type AbstractMultiCurve <: AbstractGeometryCollection end
"""A `MultiCurve` is a collection of `Curve`s."""
struct MultiCurve <: AbstractMultiCurve end
abstract type AbstractMultiLineString <: AbstractMultiCurve end
"""A `MultiPoint` is a collection of `Point`s."""
struct MultiLineString <: AbstractMultiLineString end

abstract type AbstractMultiSurface <: AbstractGeometryCollection end
abstract type AbstractMultiPolygon <: AbstractMultiSurface end
"""A `MultiPolygon` is a collection of `Polygon`s."""
struct MultiPolygon <: AbstractMultiPolygon end
