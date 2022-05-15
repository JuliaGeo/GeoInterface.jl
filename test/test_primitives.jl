using GeoInterface
using Test

@testset "Developer" begin
    # Implement interface
    struct MyPoint end
    struct MyCurve end
    struct MyPolygon end
    struct MyMultiPoint end
    struct MyMultiCurve end
    struct MyMultiPolygon end
    struct MyCollection end

    GeoInterface.isgeometry(::MyPoint) = true
    GeoInterface.geomtype(::MyPoint) = PointTrait()
    GeoInterface.ncoord(::PointTrait, geom::MyPoint) = 2
    GeoInterface.getcoord(::PointTrait, geom::MyPoint, i) = [1, 2][i]

    GeoInterface.isgeometry(::MyCurve) = true
    GeoInterface.geomtype(::MyCurve) = LineStringTrait()
    GeoInterface.ngeom(::LineStringTrait, geom::MyCurve) = 2
    GeoInterface.getgeom(::LineStringTrait, geom::MyCurve, i) = MyPoint()
    Base.convert(T::Type{MyCurve}, geom::X) where {X} = Base.convert(T, geomtype(geom), geom)
    Base.convert(::Type{MyCurve}, ::LineStringTrait, geom::MyCurve) = geom

    GeoInterface.isgeometry(::MyPolygon) = true
    GeoInterface.geomtype(::MyPolygon) = PolygonTrait()
    GeoInterface.ngeom(::PolygonTrait, geom::MyPolygon) = 2
    GeoInterface.getgeom(::PolygonTrait, geom::MyPolygon, i) = MyCurve()

    GeoInterface.isgeometry(::MyMultiPoint) = true
    GeoInterface.geomtype(::MyMultiPoint) = MultiPointTrait()
    GeoInterface.ngeom(::MultiPointTrait, geom::MyMultiPoint) = 2
    GeoInterface.getgeom(::MultiPointTrait, geom::MyMultiPoint, i) = MyPoint()

    GeoInterface.isgeometry(::MyMultiCurve) = true
    GeoInterface.geomtype(::MyMultiCurve) = MultiCurveTrait()
    GeoInterface.ngeom(::MultiCurveTrait, geom::MyMultiCurve) = 2
    GeoInterface.getgeom(::MultiCurveTrait, geom::MyMultiCurve, i) = MyCurve()

    GeoInterface.isgeometry(::MyMultiPolygon) = true
    GeoInterface.geomtype(::MyMultiPolygon) = MultiPolygonTrait()
    GeoInterface.ngeom(::MultiPolygonTrait, geom::MyMultiPolygon) = 2
    GeoInterface.getgeom(::MultiPolygonTrait, geom::MyMultiPolygon, i) = MyPolygon()

    GeoInterface.isgeometry(::MyCollection) = true
    GeoInterface.geomtype(::MyCollection) = GeometryCollectionTrait()
    GeoInterface.ngeom(::GeometryCollectionTrait, geom::MyCollection) = 2
    GeoInterface.getgeom(::GeometryCollectionTrait, geom::MyCollection, i) = MyCurve()


    @testset "Point" begin
        geom = MyPoint()
        @test testgeometry(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test ncoord(geom) === 2
    end

    @testset "LineString" begin
        geom = MyCurve()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        @test_throws MethodError GeoInterface.area(geom)
        point = GeoInterface.getpoint(geom, 1)
        @test GeoInterface.y(point) == 2
    end

    @testset "Polygon" begin
        geom = MyPolygon()
        @test testgeometry(geom)
        # Test that half a implementation yields an error

        @test GeoInterface.nring(geom) == 2
        @test GeoInterface.nhole(geom) == 1
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        lines = GeoInterface.getring(geom)
        line = GeoInterface.gethole(geom, 1)
        line = GeoInterface.getexterior(geom)
        @test GeoInterface.npoint(geom) == 4
        @test collect(GeoInterface.getpoint(geom)) == [MyPoint(), MyPoint(), MyPoint(), MyPoint()]
    end

    @testset "MultiPoint" begin
        geom = MyMultiPoint()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2
        points = GeoInterface.getpoint(geom)
        point = GeoInterface.getpoint(geom, 1)
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        @test collect(points) == [MyPoint(), MyPoint()]
    end

    @testset "MultiLineString" begin
        geom = MyMultiCurve()
        @test testgeometry(geom)

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
        polygons = GeoInterface.getpolygon(geom)
        polygon = GeoInterface.getpolygon(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[[1, 2], [1, 2]], [[1, 2], [1, 2]]], [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]]
        @test collect(polygons) == [MyPolygon(), MyPolygon()]
    end

    @testset "GeometryCollection" begin
        geom = MyCollection()
        @test testgeometry(geom)

        @test GeoInterface.ngeom(geom) == 2
        geoms = GeoInterface.getgeom(geom)
        thing = GeoInterface.getgeom(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        @test collect(geoms) == [MyCurve(), MyCurve()]
    end

end

@testset "Defaults" begin
    @test GeoInterface.subtrait(TINTrait()) == TriangleTrait
end

@testset "Feature" begin
    struct Row end
    struct Point end

    GeoInterface.isgeometry(::Point) = true
    GeoInterface.geomtype(::Point) = PointTrait()
    GeoInterface.ncoord(::PointTrait, geom::Point) = 2
    GeoInterface.getcoord(::PointTrait, geom::Point, i) = [1, 2][i]

    GeoInterface.isfeature(::Row) = true
    GeoInterface.geometry(r::Row) = Point()
    GeoInterface.properties(r::Row) = (; test=1)

    @test GeoInterface.testfeature(Row())

end

@testset "Conversion" begin
    struct XCurve end
    struct XPolygon end

    Base.convert(T::Type{XCurve}, geom::X) where {X} = Base.convert(T, geomtype(geom), geom)
    Base.convert(::Type{XCurve}, ::LineStringTrait, geom::XCurve) = geom  # fast fallthrough
    Base.convert(::Type{XCurve}, ::LineStringTrait, geom) = geom

    Base.convert(T::Type{XPolygon}, geom::X) where {X} = Base.convert(T, geomtype(geom), geom)

    geom = MyCurve()
    @test !isnothing(convert(MyCurve, geom))

    @test_throws Exception convert(MyPolygon, geom)
end
