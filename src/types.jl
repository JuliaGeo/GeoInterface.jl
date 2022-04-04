"""An AbstractGeometry type for all geometries."""
abstract type AbstractGeometry end

"""An AbstractGeometryCollection type for all geometrycollections."""
abstract type AbstractGeometryCollection <: AbstractGeometry end
"""A [`GeometryCollection`](@ref) is a collection of `Geometry`s."""
struct GeometryCollection <: AbstractGeometryCollection end

"""A abstract [`Point`](@ref)."""
abstract type AbstractPoint <: AbstractGeometry end
"""A simple [`Point`](@ref)."""
struct Point <: AbstractPoint end

"""An AbstractCurve type for all curves."""
abstract type AbstractCurve <: AbstractGeometry end
"""An AbstractLineString type for all linestrings."""
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

"""An AbstractSurface type for all surfaces."""
abstract type AbstractSurface <: AbstractGeometry end
"""An AbstractCurvePolygon type for all curved polygons."""
abstract type AbstractCurvePolygon <: AbstractSurface end
"""A [`Polygon`](@ref) that can contain either circular or straight curves as rings."""
struct CurvePolygon <: AbstractCurvePolygon end
"""An AbstractPolygon type for all polygons."""
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

"""An AbstractPolyHedralSurface type for all polyhedralsurfaces."""
abstract type AbstractPolyHedralSurface <: AbstractSurface end
"""A [`PolyHedralSurface`](@ref) is a connected surface consisting of Polygons."""
struct PolyHedralSurface <: AbstractPolyHedralSurface end
"""A [`TIN`](@ref) is a [`PolyHedralSurface`](@ref) consisting of [`Triangle`](@ref)s."""
struct TIN <: AbstractPolyHedralSurface end  # Surface consisting of Triangles

"""An AbstractMultiPoint type for all multipoints."""
abstract type AbstractMultiPoint <: AbstractGeometryCollection end
"""A [`MultiPoint`](@ref) is a collection of [`Point`](@ref)s."""
struct MultiPoint <: AbstractMultiPoint end

"""An AbstractMultiCurve type for all multicurves."""
abstract type AbstractMultiCurve <: AbstractGeometryCollection end
"""A [`MultiCurve`](@ref) is a collection of [`CircularString`](@ref)s."""
struct MultiCurve <: AbstractMultiCurve end
"""An AbstractMultiLineString type for all multilinestrings."""
abstract type AbstractMultiLineString <: AbstractMultiCurve end
"""A [`MultiPoint`](@ref) is a collection of [`Point`](@ref)s."""
struct MultiLineString <: AbstractMultiLineString end

"""An AbstractMultiSurface type for all multisurfaces."""
abstract type AbstractMultiSurface <: AbstractGeometryCollection end
"""An AbstractMultiPolygon type for all multipolygons."""
abstract type AbstractMultiPolygon <: AbstractMultiSurface end
"""A [`MultiPolygon`](@ref) is a collection of [`Polygon`](@ref)s."""
struct MultiPolygon <: AbstractMultiPolygon end
