using GeoInterface
using Extents
using Test

# Implement interface
struct MyPoint end
struct MyEmptyPoint end
struct MyCurve end
struct MyPolygon end
struct MyTriangle end
struct MyMultiPoint end
struct MyMultiCurve end
struct MyMultiPolygon end
struct MyTIN end
struct MyCollection end
struct MyFeature{G,P}
    geometry::G
    properties::P
end
struct MyFeatureCollection{G}
    geoms::G
end

GeoInterface.isgeometry(::MyPoint) = true
GeoInterface.geomtrait(::MyPoint) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::MyPoint) = 2
GeoInterface.getcoord(::PointTrait, geom::MyPoint, i) = [1, 2][i]

GeoInterface.isgeometry(::MyEmptyPoint) = true
GeoInterface.geomtrait(::MyEmptyPoint) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::MyEmptyPoint) = 0
GeoInterface.isempty(::PointTrait, geom::MyEmptyPoint) = true

GeoInterface.isgeometry(::MyCurve) = true
GeoInterface.geomtrait(::MyCurve) = LineStringTrait()
GeoInterface.ngeom(::LineStringTrait, geom::MyCurve) = 2
GeoInterface.getgeom(::LineStringTrait, geom::MyCurve, i) = MyPoint()
GeoInterface.ncoord(t::LineStringTrait, geom::MyCurve) = 2

GeoInterface.isgeometry(::MyPolygon) = true
GeoInterface.geomtrait(::MyPolygon) = PolygonTrait()
GeoInterface.ngeom(::PolygonTrait, geom::MyPolygon) = 2
GeoInterface.getgeom(::PolygonTrait, geom::MyPolygon, i) = MyCurve()
GeoInterface.ncoord(t::PolygonTrait, geom::MyPolygon) = 2

GeoInterface.isgeometry(::MyTriangle) = true
GeoInterface.geomtrait(::MyTriangle) = TriangleTrait()
GeoInterface.ngeom(::TriangleTrait, geom::MyTriangle) = 3
GeoInterface.getgeom(::TriangleTrait, geom::MyTriangle, i) = MyCurve()
GeoInterface.ncoord(t::TriangleTrait, geom::MyTriangle) = 2

GeoInterface.isgeometry(::MyMultiPoint) = true
GeoInterface.geomtrait(::MyMultiPoint) = MultiPointTrait()
GeoInterface.ngeom(::MultiPointTrait, geom::MyMultiPoint) = 2
GeoInterface.getgeom(::MultiPointTrait, geom::MyMultiPoint, i) = MyPoint()
GeoInterface.ncoord(t::MultiPointTrait, geom::MyMultiPoint) = 2

GeoInterface.isgeometry(::MyMultiCurve) = true
GeoInterface.geomtrait(::MyMultiCurve) = MultiCurveTrait()
GeoInterface.ngeom(::MultiCurveTrait, geom::MyMultiCurve) = 2
GeoInterface.getgeom(::MultiCurveTrait, geom::MyMultiCurve, i) = MyCurve()
GeoInterface.ncoord(t::MultiCurveTrait, geom::MyMultiCurve) = 2

GeoInterface.isgeometry(::MyMultiPolygon) = true
GeoInterface.geomtrait(::MyMultiPolygon) = MultiPolygonTrait()
GeoInterface.ngeom(::MultiPolygonTrait, geom::MyMultiPolygon) = 2
GeoInterface.getgeom(::MultiPolygonTrait, geom::MyMultiPolygon, i) = MyPolygon()
GeoInterface.ncoord(t::MultiPolygonTrait, geom::MyMultiPolygon) = 2

GeoInterface.isgeometry(::MyTIN) = true
GeoInterface.geomtrait(::MyTIN) = PolyhedralSurfaceTrait()
GeoInterface.ngeom(::PolyhedralSurfaceTrait, geom::MyTIN) = 2
GeoInterface.getgeom(::PolyhedralSurfaceTrait, geom::MyTIN, i) = MyTriangle()
GeoInterface.ncoord(t::PolyhedralSurfaceTrait, geom::MyTIN) = 2

GeoInterface.isgeometry(::MyCollection) = true
GeoInterface.geomtrait(::MyCollection) = GeometryCollectionTrait()
GeoInterface.ngeom(::GeometryCollectionTrait, geom::MyCollection) = 2
GeoInterface.getgeom(::GeometryCollectionTrait, geom::MyCollection, i) = MyCurve()
GeoInterface.ncoord(t::GeometryCollectionTrait, geom::MyCollection) = 2

GeoInterface.isfeature(::Type{<:MyFeature}) = true
GeoInterface.trait(feature::MyFeature) = FeatureTrait()
GeoInterface.geometry(f::MyFeature) = f.geometry
GeoInterface.properties(f::MyFeature) = f.properties
GeoInterface.extent(::FeatureTrait, f::MyFeature) = Extent(X=(1, 1), Y=(2, 2))

GeoInterface.isfeaturecollection(fc::Type{<:MyFeatureCollection}) = true
GeoInterface.trait(fc::MyFeatureCollection) = FeatureCollectionTrait()
GeoInterface.nfeature(::FeatureCollectionTrait, fc::MyFeatureCollection) = length(fc.geoms)
GeoInterface.getfeature(::FeatureCollectionTrait, fc::MyFeatureCollection) = fc.geoms
GeoInterface.getfeature(::FeatureCollectionTrait, fc::MyFeatureCollection, i::Integer) = fc.geoms[i]

@testset "Developer" begin

    @testset "Point" begin
        geom = MyPoint()
        @test testgeometry(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
        @test ncoord(geom) === 2
        @test collect(getcoord(geom)) == [1, 2]
        @test GeoInterface.coordinates(geom) == [1, 2]
        @test getcoord(geom, 1) === 1
        @test GeoInterface.coordnames(geom) == (:X, :Y)
        @test !GeoInterface.isempty(geom)
        @test !GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test GeoInterface.extent(geom) == Extents.Extent(X=(1, 1), Y=(2, 2))
        @test GeoInterface.bbox(geom) == Extents.Extent(X=(1, 1), Y=(2, 2))
        @test isnothing(GeoInterface.extent(geom, fallback=false))

        geom = MyEmptyPoint()
        @test GeoInterface.coordnames(geom) == ()
        @test GeoInterface.isempty(geom)

        @test isnothing(GeoInterface.crs(geom))
    end

    @testset "LineString" begin
        geom = MyCurve()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
        @test GeoInterface.ncoord(geom) == 2
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        points = GeoInterface.getpoint(geom)
        point = GeoInterface.getpoint(geom, 1)
        pointa = GeoInterface.startpoint(geom)
        pointb = GeoInterface.endpoint(geom)
        @test GeoInterface.y(point) == 2

        @test_throws MethodError GeoInterface.length(geom)

        @test GeoInterface.issimple(geom)
        @test GeoInterface.isclosed(geom)
        @test GeoInterface.isring(geom)

    end

    @testset "Polygon" begin
        geom = MyPolygon()
        @test testgeometry(geom)
        # Test that half a implementation yields an error

        @test GeoInterface.nring(geom) == 2
        @test GeoInterface.nhole(geom) == 1
        @test GeoInterface.ncoord(geom) == 2
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        lines = GeoInterface.getring(geom)
        line = GeoInterface.getring(geom, 1)
        lines = GeoInterface.gethole(geom)
        line = GeoInterface.gethole(geom, 1)
        line = GeoInterface.getexterior(geom)
        @test GeoInterface.npoint(geom) == 4
        @test collect(GeoInterface.getpoint(geom)) == [MyPoint(), MyPoint(), MyPoint(), MyPoint()]

        @test_throws MethodError GeoInterface.area(geom)

        geom = MyTriangle()
        @test testgeometry(geom)
        @test GeoInterface.nring(geom) == 1
        @test GeoInterface.nhole(geom) == 0
        @test GeoInterface.npoint(geom) == 3
    end

    @testset "MultiPoint" begin
        geom = MyMultiPoint()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2
        @test GeoInterface.ncoord(geom) == 2
        points = GeoInterface.getpoint(geom)
        point = GeoInterface.getpoint(geom, 1)
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        @test collect(points) == [MyPoint(), MyPoint()]

        @test !GeoInterface.issimple(geom)
    end

    @testset "MultiLineString" begin
        geom = MyMultiCurve()
        @test testgeometry(geom)

        @test GeoInterface.ncoord(geom) == 2
        @test GeoInterface.nlinestring(geom) == 2
        lines = GeoInterface.getlinestring(geom)
        line = GeoInterface.getlinestring(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        @test collect(lines) == [MyCurve(), MyCurve()]
    end

    @testset "MultiPolygon" begin
        geom = MyMultiPolygon()
        @test testgeometry(geom)

        @test GeoInterface.npolygon(geom) == 2
        @test GeoInterface.ncoord(geom) == 2
        polygons = GeoInterface.getpolygon(geom)
        polygon = GeoInterface.getpolygon(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[[1, 2], [1, 2]], [[1, 2], [1, 2]]], [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]]
        @test GeoInterface.extent(geom) == Extents.Extent(X=(1, 1), Y=(2, 2))
        @test collect(polygons) == [MyPolygon(), MyPolygon()]
    end

    @testset "Surface" begin
        geom = MyTIN()
        @test testgeometry(geom)

        @test GeoInterface.npatch(geom) == 2
        polygons = GeoInterface.getpatch(geom)
        polygon = GeoInterface.getpatch(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[[1, 2], [1, 2]], [[1, 2], [1, 2]], [[1, 2], [1, 2]]], [[[1, 2], [1, 2]], [[1, 2], [1, 2]], [[1, 2], [1, 2]]]]
        @test collect(polygons) == [MyTriangle(), MyTriangle()]
    end

    @testset "GeometryCollection" begin
        geom = MyCollection()
        @test testgeometry(geom)

        @test GeoInterface.ngeom(geom) == 2
        @test GeoInterface.ncoord(geom) == 2
        geoms = GeoInterface.getgeom(geom)
        thing = GeoInterface.getgeom(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        @test collect(geoms) == [MyCurve(), MyCurve()]
    end

end

@testset "Defaults" begin
    @test GeoInterface.subtrait(TINTrait()) == TriangleTrait
    @test GeoInterface.nring(QuadTrait(), ()) == 1
    @test GeoInterface.npoint(QuadTrait(), ()) == 4
end

@testset "Feature" begin
    feature = MyFeature((1, 2), (a=10, b=20))
    @test GeoInterface.testfeature(feature)
    @test GeoInterface.extent(feature) == Extents.Extent(X=(1, 1), Y=(2, 2))
end

@testset "FeatureCollection" begin
    features = MyFeatureCollection(
        [MyFeature(MyPoint(), (a="1", b="2")), MyFeature(MyPolygon(), (a="3", b="4")), MyFeature(nothing, (a="5", b="6"))]
    )
    @test GeoInterface.testfeaturecollection(features)
    @test GeoInterface.extent(features) == Extents.Extent(X=(1, 1), Y=(2, 2))
end

@testset "Conversion" begin
    struct XCurve end
    struct XPolygon end

    geom = MyCurve()
    @test GeoInterface.convert(MyCurve, geom) === geom
    @test_throws Exception GeoInterface.convert(MyPolygon, geom)
    @test GeoInterface.convert(MyCurve)(geom) == geom
    @test_throws Exception GeoInterface.convert(MyPolygon)(geom)
    
end

@testset "Operations" begin
    struct XGeom end

    GeoInterface.isgeometry(::XGeom) = true
    GeoInterface.geomtrait(::XGeom) = PointTrait()
    GeoInterface.ncoord(::PointTrait, geom::XGeom) = 2
    GeoInterface.getcoord(::PointTrait, geom::XGeom, i) = [1, 2][i]

    GeoInterface.equals(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.disjoint(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.intersects(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.touches(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.within(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.contains(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.overlaps(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.crosses(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true

    GeoInterface.relate(::PointTrait, ::PointTrait, ::XGeom, ::XGeom, matrix) = true

    GeoInterface.symdifference(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.difference(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.intersection(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.union(::PointTrait, ::PointTrait, ::XGeom, a::XGeom) = a

    GeoInterface.distance(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = rand()

    GeoInterface.buffer(::PointTrait, a::XGeom, distance) = a
    GeoInterface.convexhull(::PointTrait, a::XGeom) = a

    GeoInterface.astext(::PointTrait, ::XGeom) = "POINT (1 2)"
    GeoInterface.asbinary(::PointTrait, ::XGeom) = [0x0, 0x0]

    geom = XGeom()

    @test GeoInterface.equals(geom, geom)
    @test GeoInterface.disjoint(geom, geom)
    @test GeoInterface.intersects(geom, geom)
    @test GeoInterface.touches(geom, geom)
    @test GeoInterface.within(geom, geom)
    @test GeoInterface.contains(geom, geom)
    @test GeoInterface.overlaps(geom, geom)
    @test GeoInterface.crosses(geom, geom)

    @test GeoInterface.relate(geom, geom, ["a"])

    @test GeoInterface.isgeometry(GeoInterface.symdifference(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.difference(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.intersection(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.union(geom, geom))

    @test GeoInterface.distance(geom, geom) isa Number

    @test GeoInterface.isgeometry(GeoInterface.buffer(geom, 1.0))
    @test GeoInterface.isgeometry(GeoInterface.convexhull(geom))

    @test GeoInterface.astext(geom) isa String
    @test GeoInterface.asbinary(geom) isa Vector{UInt8}
end

@testset "Base Implementations" begin

    @testset "Vector" begin
        geom = [1, 2]
        @test !GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test testgeometry(geom)
        @test collect(GeoInterface.getcoord(geom)) == geom
        @test GeoInterface.ncoord(geom) == 2
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.y(geom) == 2
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
        @test GeoInterface.extent(geom) == Extents.Extent(X=(1, 1), Y=(2, 2))
        geom = [1, 2, 3]
        @test testgeometry(geom)
        @test collect(GeoInterface.getcoord(geom)) == geom
        @test GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.y(geom) == 2
        @test GeoInterface.z(geom) == 3
        @test_throws ArgumentError GeoInterface.m(geom)
        geom = [1, 2, 3, 4]
        @test testgeometry(geom)
        @test collect(GeoInterface.getcoord(geom)) == geom
        @test GeoInterface.is3d(geom)
        @test GeoInterface.ismeasured(geom)
        @test GeoInterface.ncoord(geom) == 4
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.y(geom) == 2
        @test GeoInterface.z(geom) == 3
        @test GeoInterface.m(geom) == 4
        geom = [1, 2, 3, 4, 5]
        @test !GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test_throws ArgumentError GeoInterface.x(geom)
        @test_throws ArgumentError GeoInterface.y(geom)
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
    end

    @testset "Tuple" begin
        geom = (1, 2.0f0)
        @test GeoInterface.trait(geom) isa PointTrait
        @test GeoInterface.geomtrait(geom) isa PointTrait
        @test testgeometry(geom)
        @test !GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2.0f0
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
        @test GeoInterface.ncoord(geom) == 2
        @test collect(GeoInterface.getcoord(geom)) == [1, 2]
        geom = (1, 2, 3.0)
        @test GeoInterface.trait(geom) isa PointTrait
        @test GeoInterface.geomtrait(geom) isa PointTrait
        @test testgeometry(geom)
        @test GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test GeoInterface.z(geom) === 3.0
        @test_throws ArgumentError GeoInterface.m(geom)
        @test GeoInterface.ncoord(geom) == 3
        @test collect(GeoInterface.getcoord(geom)) == [1, 2, 3]
        geom = (1, 2, 3, 4.0)
        @test GeoInterface.trait(geom) isa PointTrait
        @test GeoInterface.geomtrait(geom) isa PointTrait
        @test testgeometry(geom)
        @test GeoInterface.is3d(geom)
        @test GeoInterface.ismeasured(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test GeoInterface.z(geom) === 3
        @test GeoInterface.m(geom) === 4.0
        @test GeoInterface.ncoord(geom) == 4
        @test collect(GeoInterface.getcoord(geom)) == [1, 2, 3, 4]
        geom = (1, 2, 3, 4.0, 5)
        @test GeoInterface.isgeometry(geom) == false
        @test GeoInterface.trait(geom) isa Nothing
        @test GeoInterface.geomtrait(geom) isa Nothing
        @test_throws MethodError GeoInterface.x(geom)
        @test_throws MethodError GeoInterface.y(geom)
        @test_throws MethodError GeoInterface.z(geom)
        @test_throws MethodError GeoInterface.m(geom)
        @test_throws MethodError GeoInterface.ncoord(geom) == 4
        @test_throws MethodError GeoInterface.getcoord(geom)
    end

    @testset "NamedTuple" begin
        geom = (; X=1, Y=2.0)
        @test GeoInterface.is3d(geom) == false
        @test GeoInterface.ismeasured(geom) == false
        @test GeoInterface.trait(geom) isa PointTrait
        @test GeoInterface.geomtrait(geom) isa PointTrait
        @test testgeometry(geom)
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.y(geom) == 2.0
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
        @test collect(GeoInterface.getcoord(geom)) == [1, 2]

        geom = (; X=1.0, Y=2.0, Z=0x03)
        @test testgeometry(geom)
        @test GeoInterface.is3d(geom)
        @test GeoInterface.ismeasured(geom) == false
        @test GeoInterface.coordnames(geom) == (:X, :Y, :Z)
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.y(geom) == 2.0
        @test GeoInterface.z(geom) == 0x03
        @test_throws ArgumentError GeoInterface.m(geom)

        geom = (; X=1, Y=2, Z=3.0f0, M=4.0)
        @test GeoInterface.trait(geom) isa PointTrait
        @test GeoInterface.geomtrait(geom) isa PointTrait
        @test GeoInterface.is3d(geom)
        @test GeoInterface.ismeasured(geom)
        @test GeoInterface.coordnames(geom) == (:X, :Y, :Z, :M)
        @test GeoInterface.ncoord(geom) == 4
        @test testgeometry(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test GeoInterface.z(geom) === 3.0f0
        @test GeoInterface.m(geom) === 4.0
        @test GeoInterface.ncoord(geom) == 4
        @test GeoInterface.getcoord(geom, 1) === 1
        @test GeoInterface.getcoord(geom, 2) === 2
        @test GeoInterface.getcoord(geom, 3) === 3.0f0
        @test GeoInterface.getcoord(geom, 4) === 4.0
        @test collect(GeoInterface.getcoord(geom)) == [1, 2, 3, 4]

        geom = (; Z=3, X=1, Y=2, M=4)
        @test testgeometry(geom)
        @test collect(GeoInterface.getcoord(geom)) == [3, 1, 2, 4]
        @test GeoInterface.coordnames(geom) == (:Z, :X, :Y, :M)

        geom = (; A=0, X=1, Y=2, Z=3.0f0, M=4.0)
        @test GeoInterface.trait(geom) isa Nothing
        @test GeoInterface.geomtrait(geom) isa Nothing
        @test_throws MethodError GeoInterface.x(geom)
        @test_throws MethodError GeoInterface.y(geom)
        @test_throws MethodError GeoInterface.z(geom)
        @test_throws MethodError GeoInterface.m(geom)
        @test_throws MethodError GeoInterface.ncoord(geom) == 4
        @test_throws MethodError GeoInterface.getcoord(geom)
    end

    @testset "NamedTupleFeature" begin
        feature = (; geometry=(1, 2), a="x", b="y", c="z")
        GeoInterface.geometry(feature) = (1, 2)
        @test GeoInterface.properties(feature) == (a="x", b="y", c="z")
        @test GeoInterface.testfeature(feature)
        @test GeoInterface.testfeaturecollection([feature, feature])
    end


end

@testset "extent and crs fallback to nothing on unknown objects" begin
    @test isnothing(GeoInterface.crs(nothing))
    @test isnothing(GeoInterface.extent(nothing))
end

module ConvertTestModule
using GeoInterface
struct TestPolygon end
geointerface_geomtype(::GeoInterface.PolygonTrait) = TestPolygon

GeoInterface.isgeometry(::TestPolygon) = true
GeoInterface.geomtrait(::TestPolygon) = PolygonTrait()
GeoInterface.ngeom(::PolygonTrait, geom::TestPolygon) = 2
GeoInterface.getgeom(::PolygonTrait, geom::TestPolygon, i) = TestCurve()
GeoInterface.convert(::Type{<:TestPolygon}, ::PolygonTrait, geom) = TestPolygon()
end

module BadModule
end

@test GeoInterface.convert(ConvertTestModule, MyPolygon()) == ConvertTestModule.TestPolygon()
@test GeoInterface.convert(ConvertTestModule)(MyPolygon()) == ConvertTestModule.TestPolygon()
@test_throws ArgumentError GeoInterface.convert(BadModule, MyPolygon()) == ConvertTestModule.TestPolygon()
@test_throws ArgumentError GeoInterface.convert(BadModule)(MyPolygon()) == ConvertTestModule.TestPolygon()


struct ExtentPolygon end
GeoInterface.geomtrait(::ExtentPolygon) = PolygonTrait()
Extents.extent(::ExtentPolygon) = Extent(X=(1, 2), Y=(3, 4))

@testset "Extents.jl extent fallback" begin
    @test GeoInterface.extent(ExtentPolygon()) == Extent(X=(1, 2), Y=(3, 4))
    @test isnothing(GeoInterface.extent(1))
    @test isnothing(GeoInterface.extent(nothing, 1))
end
