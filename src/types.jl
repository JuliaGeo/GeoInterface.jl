"An AbstractTrait type for all geometries, features and feature collections."
abstract type AbstractTrait end
"An AbstractGeometryTrait type for all geometries."
abstract type AbstractGeometryTrait <: AbstractTrait end

"An AbstractGeometryCollectionTrait type for all geometrycollections."
abstract type AbstractGeometryCollectionTrait <: AbstractGeometryTrait end
"A GeometryCollection is a collection of `Geometry`s."
struct GeometryCollectionTrait <: AbstractGeometryCollectionTrait end

"An AbstractPointTrait for all points."
abstract type AbstractPointTrait <: AbstractGeometryTrait end
"A single point."
struct PointTrait <: AbstractPointTrait end

"An AbstractCurveTrait type for all curves."
abstract type AbstractCurveTrait <: AbstractGeometryTrait end
"An AbstractLineString type for all linestrings."
abstract type AbstractLineStringTrait <: AbstractCurveTrait end
"A LineStringTrait is a collection of straight lines between its `PointTrait`s."
struct LineStringTrait <: AbstractLineStringTrait end
"A LineTrait is [`LineStringTrait`](@ref) with just two points."
struct LineTrait <: AbstractLineStringTrait end
"A LinearRingTrait is a [`LineStringTrait`](@ref) with the same begin and endpoint."
struct LinearRingTrait <: AbstractLineStringTrait end

"A CircularStringTrait is a curve, with an odd number of points.
A single segment consists of three points, where the first and last are the beginning and end,
while the second is halfway the curve."
struct CircularStringTrait <: AbstractCurveTrait end
"A CompoundCurveTrait is a curve that combines straight [`LineStringTrait`](@ref)s and curved [`CircularStringTrait`](@ref)s."
struct CompoundCurveTrait <: AbstractCurveTrait end

"An AbstractSurfaceTrait type for all surfaces."
abstract type AbstractSurfaceTrait <: AbstractGeometryTrait end
"An AbstractCurvePolygonTrait type for all curved polygons."
abstract type AbstractCurvePolygonTrait <: AbstractSurfaceTrait end
"An [`AbstractCurvePolygonTrait`](@ref) that can contain either circular or straight curves as rings."
struct CurvePolygonTrait <: AbstractCurvePolygonTrait end
"An AbstractPolygonTrait type for all polygons."
abstract type AbstractPolygonTrait <: AbstractCurvePolygonTrait end
"An [`AbstractSurfaceTrait`](@ref) with straight rings either as exterior or interior(s)."
struct PolygonTrait <: AbstractPolygonTrait end
"A [`PolygonTrait`](@ref) that is triangular."
struct TriangleTrait <: AbstractPolygonTrait end
"A [`PolygonTrait`](@ref) that is rectangular and could be described by the minimum and maximum vertices."
struct RectangleTrait <: AbstractPolygonTrait end
"A [`PolygonTrait`](@ref) with four vertices."
struct QuadTrait <: AbstractPolygonTrait end
"A [`PolygonTrait`](@ref) with five vertices."
struct PentagonTrait <: AbstractPolygonTrait end
"A [`PolygonTrait`](@ref) with six vertices."
struct HexagonTrait <: AbstractPolygonTrait end

"An AbstractPolyhedralSurfaceTrait type for all polyhedralsurfaces."
abstract type AbstractPolyhedralSurfaceTrait <: AbstractSurfaceTrait end
"A PolyhedralSurfaceTrait is a connected surface consisting of [`PolygonTrait`](@ref)s."
struct PolyhedralSurfaceTrait <: AbstractPolyhedralSurfaceTrait end
"A TINTrait is a [`PolyhedralSurfaceTrait`](@ref) consisting of [`TriangleTrait`](@ref)s."
struct TINTrait <: AbstractPolyhedralSurfaceTrait end  # Surface consisting of Triangles

"An AbstractMultiPointTrait type for all multipoints."
abstract type AbstractMultiPointTrait <: AbstractGeometryCollectionTrait end
"A MultiPointTrait is a collection of [`PointTrait`](@ref)s."
struct MultiPointTrait <: AbstractMultiPointTrait end

"An AbstractMultiCurveTrait type for all multicurves."
abstract type AbstractMultiCurveTrait <: AbstractGeometryCollectionTrait end
"A MultiCurveTrait is a collection of [`CircularStringTrait`](@ref)s."
struct MultiCurveTrait <: AbstractMultiCurveTrait end
"An AbstractMultiLineStringTrait type for all multilinestrings."
abstract type AbstractMultiLineStringTrait <: AbstractMultiCurveTrait end
"A MultiLineStringTrait is a collection of [`LineStringTrait`](@ref)s."
struct MultiLineStringTrait <: AbstractMultiLineStringTrait end

"An AbstractMultiSurfaceTrait type for all multisurfaces."
abstract type AbstractMultiSurfaceTrait <: AbstractGeometryCollectionTrait end
"A MultiSurfaceTrait is a collection of [`AbstractSurfaceTrait`](@ref)s."
struct MultiSurfaceTrait <: AbstractMultiSurfaceTrait end
"An AbstractMultiPolygonTrait type for all multipolygons."
abstract type AbstractMultiPolygonTrait <: AbstractMultiSurfaceTrait end
"A MultiPolygonTrait is a collection of [`PolygonTrait`](@ref)s."
struct MultiPolygonTrait <: AbstractMultiPolygonTrait end


"An AbstractFeatureTrait for all features"
abstract type AbstractFeatureTrait <: AbstractTrait end
"A FeatureTrait holds `geometries`, `properties` and an `extent`"
struct FeatureTrait <: AbstractFeatureTrait end

"An AbstractFeatureCollectionTrait for all feature collections"
abstract type AbstractFeatureCollectionTrait <: AbstractTrait end
"A FeatureCollectionTrait holds objects of `FeatureTrait`"
struct FeatureCollectionTrait <: AbstractFeatureCollectionTrait end

"An AbstractRasterTrait for all rasters"
abstract type AbstractRasterTrait <: AbstractTrait end
struct RasterTrait <: AbstractRasterTrait end
