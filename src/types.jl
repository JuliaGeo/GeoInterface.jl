abstract type AbstractGeometry end

abstract type AbstractGeometryCollection <: AbstractGeometry end
"""A [`GeometryCollection`](@ref) is a collection of `Geometry`s."""
struct GeometryCollection <: AbstractGeometryCollection end

abstract type AbstractPoint <: AbstractGeometry end
"""A simple [`Point`](@ref)."""
struct Point <: AbstractPoint end

abstract type AbstractCurve <: AbstractGeometry end
abstract type AbstractLineString <: AbstractCurve end
"""A [`LineString`](@ref) is a collection of straight lines between its `Point`s."""
struct LineString <: AbstractLineString end
"""A Line is [`LineString`](@ref) with just two points."""
struct Line <: AbstractLineString end
"""A LinearRing is a [`LineString`](@ref) with the same begin and endpoint."""
struct LinearRing <: AbstractLineString end

"""A [`CircularString`](@ref) is a curve, with an odd number of points.
A single segment consists of three points, where the first and last are the beginning and end,
while the second is halfway the curve."""
struct CircularString <: AbstractCurve end
"""A [`CompoundCurve`](@ref) is a curve that combines straight [`LineString`](@ref)s and curved [`CircularString`](@ref)s."""
struct CompoundCurve <: AbstractCurve end

abstract type AbstractSurface <: AbstractGeometry end
abstract type AbstractCurvePolygon <: AbstractSurface end
"""A [`Polygon`](@ref) that can contain either circular or straight curves as rings."""
struct CurvePolygon <: AbstractCurvePolygon end
abstract type AbstractPolygon <: AbstractCurvePolygon end
"""A [`Polygon`](@ref) with straight rings either as exterior or interior(s)."""
struct Polygon <: AbstractPolygon end
"""A [`Polygon`](@ref) with straight rings either as exterior or interior(s)."""
struct Triangle <: AbstractPolygon end

"""A [`Polygon`](@ref) that is rectangular and could be described by the minimum and maximum vertices."""
struct Rectangle <: AbstractPolygon end
"""A [`Polygon`](@ref) with four vertices."""
struct Quad <: AbstractPolygon end
"""A [`Polygon`](@ref) with five vertices."""
struct Pentagon <: AbstractPolygon end
"""A [`Polygon`](@ref) with six vertices."""
struct Hexagon <: AbstractPolygon end

abstract type AbstractPolyHedralSurface <: AbstractSurface end
"""A [`PolyHedralSurface`](@ref) is a connected surface consisting of Polygons."""
struct PolyHedralSurface <: AbstractPolyHedralSurface end
"""A [`TIN`](@ref) is a [`PolyHedralSurface`](@ref) consisting of [`Triangle`](@ref)s."""
struct TIN <: AbstractPolyHedralSurface end  # Surface consisting of Triangles

abstract type AbstractMultiPoint <: AbstractGeometryCollection end
"""A [`MultiPoint`](@ref) is a collection of [`Point`](@ref)s."""
struct MultiPoint <: AbstractMultiPoint end

abstract type AbstractMultiCurve <: AbstractGeometryCollection end
"""A [`MultiCurve`](@ref) is a collection of [`CircularString`](@ref)s."""
struct MultiCurve <: AbstractMultiCurve end
abstract type AbstractMultiLineString <: AbstractMultiCurve end
"""A [`MultiPoint`](@ref) is a collection of [`Point`](@ref)s."""
struct MultiLineString <: AbstractMultiLineString end

abstract type AbstractMultiSurface <: AbstractGeometryCollection end
abstract type AbstractMultiPolygon <: AbstractMultiSurface end
"""A [`MultiPolygon`](@ref) is a collection of [`Polygon`](@ref)s."""
struct MultiPolygon <: AbstractMultiPolygon end
