"""
A trait for defining custom trees of AbstractGeometry,
where some of the interface and plot recipes are free.
"""
abstract type AbstractGeometry end
isgeometry(::AbstractGeometry) = true

"""An AbstractGeometryTrait type for all geometries."""
abstract type AbstractGeometryTrait end

"""An AbstractGeometryCollectionTrait type for all geometrycollections."""
abstract type AbstractGeometryCollectionTrait <: AbstractGeometryTrait end
"""A [`GeometryCollection`](@ref) is a collection of `Geometry`s."""
struct GeometryCollectionTrait <: AbstractGeometryCollectionTrait end

"""A abstract [`PointTrait`](@ref)."""
abstract type AbstractPointTrait <: AbstractGeometryTrait end
"""A simple [`PointTrait`](@ref)."""
struct PointTrait <: AbstractPointTrait end

"""An AbstractCurveTrait type for all curves."""
abstract type AbstractCurveTrait <: AbstractGeometryTrait end
"""An AbstractLineString type for all linestrings."""
abstract type AbstractLineStringTrait <: AbstractCurveTrait end
"""A [`LineStringTrait`](@ref) is a collection of straight lines between its `PointTrait`s."""
struct LineStringTrait <: AbstractLineStringTrait end
"""A LineTrait is [`LineStringTrait`](@ref) with just two points."""
struct LineTrait <: AbstractLineStringTrait end
"""A LinearRingTrait is a [`LineStringTrait`](@ref) with the same begin and endpoint."""
struct LinearRingTrait <: AbstractLineStringTrait end

"""A [`CircularStringTrait`](@ref) is a curve, with an odd number of points.
A single segment consists of three points, where the first and last are the beginning and end,
while the second is halfway the curve."""
struct CircularStringTrait <: AbstractCurveTrait end
"""A [`CompoundCurveTrait`](@ref) is a curve that combines straight [`LineStringTrait`](@ref)s and curved [`CircularStringTrait`](@ref)s."""
struct CompoundCurveTrait <: AbstractCurveTrait end

"""An AbstractSurfaceTrait type for all surfaces."""
abstract type AbstractSurfaceTrait <: AbstractGeometryTrait end
"""An AbstractCurvePolygonTrait type for all curved polygons."""
abstract type AbstractCurvePolygonTrait <: AbstractSurfaceTrait end
"""A [`PolygonTrait`](@ref) that can contain either circular or straight curves as rings."""
struct CurvePolygonTrait <: AbstractCurvePolygonTrait end
"""An AbstractPolygonTrait type for all polygons."""
abstract type AbstractPolygonTrait <: AbstractCurvePolygonTrait end
"""A [`PolygonTrait`](@ref) with straight rings either as exterior or interior(s)."""
struct PolygonTrait <: AbstractPolygonTrait end
"""A [`PolygonTrait`](@ref) with straight rings either as exterior or interior(s)."""
struct TriangleTrait <: AbstractPolygonTrait end
"""A [`PolygonTrait`](@ref) that is rectangular and could be described by the minimum and maximum vertices."""
struct RectangleTrait <: AbstractPolygonTrait end
"""A [`PolygonTrait`](@ref) with four vertices."""
struct QuadTrait <: AbstractPolygonTrait end
"""A [`PolygonTrait`](@ref) with five vertices."""
struct PentagonTrait <: AbstractPolygonTrait end
"""A [`PolygonTrait`](@ref) with six vertices."""
struct HexagonTrait <: AbstractPolygonTrait end

"""An AbstractPolyHedralSurfaceTrait type for all polyhedralsurfaces."""
abstract type AbstractPolyHedralSurfaceTrait <: AbstractSurfaceTrait end
"""A [`PolyHedralSurfaceTrait`](@ref) is a connected surface consisting of PolygonsTraits."""
struct PolyHedralSurfaceTrait <: AbstractPolyHedralSurfaceTrait end
"""A [`TINTrait`](@ref) is a [`PolyHedralSurfaceTrait`](@ref) consisting of [`TriangleTrait`](@ref)s."""
struct TINTrait <: AbstractPolyHedralSurfaceTrait end  # Surface consisting of Triangles

"""An AbstractMultiPointTrait type for all multipoints."""
abstract type AbstractMultiPointTrait <: AbstractGeometryCollectionTrait end
"""A [`MultiPointTrait`](@ref) is a collection of [`PointTrait`](@ref)s."""
struct MultiPointTrait <: AbstractMultiPointTrait end

"""An AbstractMultiCurveTrait type for all multicurves."""
abstract type AbstractMultiCurveTrait <: AbstractGeometryCollectionTrait end
"""A [`MultiCurveTrait`](@ref) is a collection of [`CircularStringTrait`](@ref)s."""
struct MultiCurveTrait <: AbstractMultiCurveTrait end
"""An AbstractMultiLineStringTrait type for all multilinestrings."""
abstract type AbstractMultiLineStringTrait <: AbstractMultiCurveTrait end
"""A [`MultiLineStringTrait`](@ref) is a collection of [`LineStringTrait`](@ref)s."""
struct MultiLineStringTrait <: AbstractMultiLineStringTrait end

"""An AbstractMultiSurfaceTrait type for all multisurfaces."""
abstract type AbstractMultiSurfaceTrait <: AbstractGeometryCollectionTrait end
"""An AbstractMultiPolygonTrait type for all multipolygons."""
abstract type AbstractMultiPolygonTrait <: AbstractMultiSurfaceTrait end
"""A [`MultiPolygonTrait`](@ref) is a collection of [`PolygonTrait`](@ref)s."""
struct MultiPolygonTrait <: AbstractMultiPolygonTrait end
