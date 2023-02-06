using GeoInterfaceRecipes
using GeoInterface
using Plots
using Test


abstract type MyAbstractGeom{N} end
# Implement interface
struct MyPoint{N} <: MyAbstractGeom{N} end
struct MyCurve{N} <: MyAbstractGeom{N} end
struct MyLinearRing{N} <: MyAbstractGeom{N} end
struct MyLineString{N} <: MyAbstractGeom{N} end
struct MyPolygon{N} <: MyAbstractGeom{N} end
struct MyMultiPoint{N} <: MyAbstractGeom{N} end
struct MyMultiCurve{N} <: MyAbstractGeom{N} end
struct MyMultiPolygon{N} <: MyAbstractGeom{N} end
struct MyCollection{N} <: MyAbstractGeom{N} end
struct MyFeature end
struct MyFeatureCollection end

GeoInterfaceRecipes.@enable_geo_plots MyAbstractGeom
GeoInterfaceRecipes.@enable_geo_plots MyFeature
GeoInterfaceRecipes.@enable_geo_plots MyFeatureCollection

GeoInterface.isgeometry(::MyAbstractGeom) = true
GeoInterface.is3d(::GeoInterface.AbstractGeometryTrait, ::MyAbstractGeom{N}) where {N} = N == 3
GeoInterface.ncoord(::GeoInterface.AbstractGeometryTrait, geom::MyAbstractGeom{N}) where {N} = N
GeoInterface.coordnames(::GeoInterface.AbstractGeometryTrait, ::MyAbstractGeom{2}) = (:X, :Y)
GeoInterface.coordnames(::GeoInterface.AbstractGeometryTrait, ::MyAbstractGeom{3}) = (:X, :Y, :Z)

GeoInterface.geomtrait(::MyPoint) = GeoInterface.PointTrait()
GeoInterface.getcoord(::GeoInterface.PointTrait, geom::MyPoint{2}, i::Integer) = (rand(1:10), rand(11:20))[i]
GeoInterface.getcoord(::GeoInterface.PointTrait, geom::MyPoint{3}, i::Integer) = (rand(1:10), rand(11:20), rand(21:30))[i]

GeoInterface.geomtrait(::MyCurve) = GeoInterface.LineStringTrait()
GeoInterface.ngeom(::GeoInterface.LineStringTrait, geom::MyCurve) = 3
GeoInterface.getgeom(::GeoInterface.LineStringTrait, geom::MyCurve{N}, i) where {N} = MyPoint{N}()
GeoInterface.convert(::Type{MyCurve}, ::GeoInterface.LineStringTrait, geom) = geom

GeoInterface.geomtrait(::MyLinearRing) = GeoInterface.LinearRingTrait()
GeoInterface.ngeom(::GeoInterface.LinearRingTrait, geom::MyLinearRing) = 3
GeoInterface.getgeom(::GeoInterface.LinearRingTrait, geom::MyLinearRing{N}, i) where {N} = MyPoint{N}()
GeoInterface.convert(::Type{MyLinearRing}, ::GeoInterface.LinearRingTrait, geom) = geom

GeoInterface.geomtrait(::MyLineString) = GeoInterface.LineStringTrait()
GeoInterface.ngeom(::GeoInterface.LineStringTrait, geom::MyLineString) = 3
GeoInterface.getgeom(::GeoInterface.LineStringTrait, geom::MyLineString{N}, i) where {N} = MyPoint{N}()
GeoInterface.convert(::Type{MyLineString}, ::GeoInterface.LineStringTrait, geom) = geom

GeoInterface.geomtrait(::MyPolygon) = GeoInterface.PolygonTrait()
GeoInterface.ngeom(::GeoInterface.PolygonTrait, geom::MyPolygon) = 2
GeoInterface.getgeom(::GeoInterface.PolygonTrait, geom::MyPolygon{N}, i) where {N} = MyCurve{N}()

GeoInterface.geomtrait(::MyMultiPolygon) = GeoInterface.MultiPolygonTrait()
GeoInterface.ngeom(::GeoInterface.MultiPolygonTrait, geom::MyMultiPolygon) = 2
GeoInterface.getgeom(::GeoInterface.MultiPolygonTrait, geom::MyMultiPolygon{N}, i) where {N} = MyPolygon{N}()

GeoInterface.geomtrait(::MyMultiPoint) = GeoInterface.MultiPointTrait()
GeoInterface.ngeom(::GeoInterface.MultiPointTrait, geom::MyMultiPoint) = 10
GeoInterface.getgeom(::GeoInterface.MultiPointTrait, geom::MyMultiPoint{N}, i) where {N} = MyPoint{N}()

GeoInterface.geomtrait(geom::MyCollection) = GeoInterface.GeometryCollectionTrait()
GeoInterface.ncoord(::GeoInterface.GeometryCollectionTrait, geom::MyCollection{N}) where {N} = N
GeoInterface.ngeom(::GeoInterface.GeometryCollectionTrait, geom::MyCollection) = 4
GeoInterface.getgeom(::GeoInterface.GeometryCollectionTrait, geom::MyCollection{N}, i) where {N} = MyMultiPolygon{N}()

GeoInterface.trait(::MyFeature) = FeatureTrait()
GeoInterface.trait(::MyFeatureCollection) = FeatureCollectionTrait()
GeoInterface.getfeature(::GeoInterface.FeatureCollectionTrait, geom::MyFeatureCollection, i) = MyFeature()
GeoInterface.getfeature(::GeoInterface.FeatureCollectionTrait, geom::MyFeatureCollection) = [MyFeature(), MyFeature()]
GeoInterface.geometry(geom::MyFeature) = rand((MyPolygon{2}(), MyMultiPolygon{2}()))
GeoInterface.nfeature(::GeoInterface.FeatureTrait, geom::MyFeature) = 1

@testset "plot" begin
    # We just check if they actually run
    # 2d
    plot(MyPoint{2}())
    plot(MyCurve{2}())
    plot(MyLinearRing{2}())
    plot(MyLineString{2}())
    plot(MyMultiPoint{2}())
    plot(MyPolygon{2}())
    plot(MyMultiPolygon{2}())
    plot(MyCollection{2}())
    # 3d
    plot(MyPoint{3}())
    plot(MyCurve{3}())
    plot(MyLinearRing{3}())
    plot(MyLineString{3}())
    plot(MyMultiPoint{3}())
    plot(MyPolygon{3}())
    plot(MyMultiPolygon{3}())
    plot(MyCollection{3}())
    plot(MyFeature())
    plot(MyFeatureCollection())
end
