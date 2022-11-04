module TestGeometry

using ..GeoInterface

# Implement interface
struct Point end
struct EmptyPoint end
struct Curve end
struct Polygon end
struct Triangle end
struct MultiPoint end
struct MultiCurve end
struct MultiPolygon end
struct TIN end
struct Collection end
struct Feature{G,P}
    geometry::G
    properties::P
end
struct FeatureCollection{G}
    geoms::G
end

GeoInterface.isgeometry(::Point) = true
GeoInterface.geomtrait(::Point) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::Point) = 2
GeoInterface.getcoord(::PointTrait, geom::Point, i) = [1, 2][i]

GeoInterface.isgeometry(::EmptyPoint) = true
GeoInterface.geomtrait(::EmptyPoint) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::EmptyPoint) = 0
GeoInterface.isempty(::PointTrait, geom::EmptyPoint) = true

GeoInterface.isgeometry(::Curve) = true
GeoInterface.geomtrait(::Curve) = LineStringTrait()
GeoInterface.ngeom(::LineStringTrait, geom::Curve) = 2
GeoInterface.getgeom(::LineStringTrait, geom::Curve, i) = Point()
Base.convert(T::Type{Curve}, geom::X) where {X} = Base.convert(T, geomtrait(geom), geom)
Base.convert(::Type{Curve}, ::LineStringTrait, geom::Curve) = geom

GeoInterface.isgeometry(::Polygon) = true
GeoInterface.geomtrait(::Polygon) = PolygonTrait()
GeoInterface.ngeom(::PolygonTrait, geom::Polygon) = 2
GeoInterface.getgeom(::PolygonTrait, geom::Polygon, i) = Curve()

GeoInterface.isgeometry(::Triangle) = true
GeoInterface.geomtrait(::Triangle) = TriangleTrait()
GeoInterface.ngeom(::TriangleTrait, geom::Triangle) = 3
GeoInterface.getgeom(::TriangleTrait, geom::Triangle, i) = Curve()

GeoInterface.isgeometry(::MultiPoint) = true
GeoInterface.geomtrait(::MultiPoint) = MultiPointTrait()
GeoInterface.ngeom(::MultiPointTrait, geom::MultiPoint) = 2
GeoInterface.getgeom(::MultiPointTrait, geom::MultiPoint, i) = Point()

GeoInterface.isgeometry(::MultiCurve) = true
GeoInterface.geomtrait(::MultiCurve) = MultiCurveTrait()
GeoInterface.ngeom(::MultiCurveTrait, geom::MultiCurve) = 2
GeoInterface.getgeom(::MultiCurveTrait, geom::MultiCurve, i) = Curve()

GeoInterface.isgeometry(::MultiPolygon) = true
GeoInterface.geomtrait(::MultiPolygon) = MultiPolygonTrait()
GeoInterface.ngeom(::MultiPolygonTrait, geom::MultiPolygon) = 2
GeoInterface.getgeom(::MultiPolygonTrait, geom::MultiPolygon, i) = Polygon()

GeoInterface.isgeometry(::TIN) = true
GeoInterface.geomtrait(::TIN) = PolyhedralSurfaceTrait()
GeoInterface.ngeom(::PolyhedralSurfaceTrait, geom::TIN) = 2
GeoInterface.getgeom(::PolyhedralSurfaceTrait, geom::TIN, i) = Triangle()

GeoInterface.isgeometry(::Collection) = true
GeoInterface.geomtrait(::Collection) = GeometryCollectionTrait()
GeoInterface.ngeom(::GeometryCollectionTrait, geom::Collection) = 2
GeoInterface.getgeom(::GeometryCollectionTrait, geom::Collection, i) = Curve()

GeoInterface.isfeature(::Type{<:Feature}) = true
GeoInterface.trait(feature::Feature) = FeatureTrait()
GeoInterface.geometry(f::Feature) = f.geometry
GeoInterface.properties(f::Feature) = f.properties
GeoInterface.extent(f::Feature) = nothing

GeoInterface.isfeaturecollection(fc::Type{<:FeatureCollection}) = true
GeoInterface.trait(fc::FeatureCollection) = FeatureCollectionTrait()
GeoInterface.nfeature(::FeatureCollectionTrait, fc::FeatureCollection) = length(fc.geoms)
GeoInterface.getfeature(::FeatureCollectionTrait, fc::FeatureCollection) = fc.geoms
GeoInterface.getfeature(::FeatureCollectionTrait, fc::FeatureCollection, i::Integer) = fc.geoms[i]

export Point, EmptyPoint, Curve, Polygon, Triangle, MultiPoint, MultiCurve, MultiPolygon, TIN, Collection, Feature, FeatureCollection

end # module
