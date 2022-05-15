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
    GeoInterface.geomtype(::MyPoint) = GeoInterface.PointTrait()
    GeoInterface.ncoord(::GeoInterface.PointTrait, geom::MyPoint) = 2
    GeoInterface.getcoord(::GeoInterface.PointTrait, geom::MyPoint, i) = [1, 2][i]

    GeoInterface.isgeometry(::MyCurve) = true
    GeoInterface.geomtype(::MyCurve) = GeoInterface.LineStringTrait()
    GeoInterface.ngeom(::GeoInterface.LineStringTrait, geom::MyCurve) = 2
    GeoInterface.getgeom(::GeoInterface.LineStringTrait, geom::MyCurve, i) = MyPoint()
    Base.convert(::Type{MyCurve}, ::GeoInterface.LineStringTrait, geom) = geom

    GeoInterface.isgeometry(::MyPolygon) = true
    GeoInterface.geomtype(::MyPolygon) = GeoInterface.PolygonTrait()
    GeoInterface.ngeom(::GeoInterface.PolygonTrait, geom::MyPolygon) = 2
    GeoInterface.getgeom(::GeoInterface.PolygonTrait, geom::MyPolygon, i) = MyCurve()


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
        @test !isnothing(convert(MyCurve, geom))

        @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        @test_throws MethodError GeoInterface.area(geom)
        point = GeoInterface.getpoint(geom, 1)
        @test GeoInterface.y(point) == 2
    end

    @testset "Polygon" begin
        geom = MyPolygon()
        @test testgeometry(geom)

        @test GeoInterface.nring(geom) == 2
        @test GeoInterface.nhole(geom) == 1
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        lines = GeoInterface.getring(geom)
        line = GeoInterface.gethole(geom, 1)
        line = GeoInterface.getexterior(geom)
        @test GeoInterface.npoint(geom) == 4
        @test collect(GeoInterface.getpoint(geom)) == [MyPoint(), MyPoint(), MyPoint(), MyPoint()]
    end

end

@testset "Defaults" begin
    @test GeoInterface.subtrait(GeoInterface.TINTrait()) == GeoInterface.TriangleTrait
end

@testset "Feature" begin
    struct Row end
    struct Point end

    GeoInterface.isgeometry(::Point) = true
    GeoInterface.geomtype(::Point) = GeoInterface.PointTrait()
    GeoInterface.ncoord(::GeoInterface.PointTrait, geom::Point) = 2
    GeoInterface.getcoord(::GeoInterface.PointTrait, geom::Point, i) = [1, 2][i]

    GeoInterface.isfeature(::Row) = true
    GeoInterface.geometry(r::Row) = Point()
    GeoInterface.properties(r::Row) = (; test=1)

    @test GeoInterface.testfeature(Row())

end
