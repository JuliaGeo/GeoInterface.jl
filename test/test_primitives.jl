struct MyCurve end
struct MyPoint end

@testset "Developer" begin
    # Implement interface

    GeoInterface.isgeometry(::MyPoint) = true
    GeoInterface.isgeometry(::MyCurve) = true
    GeoInterface.geomtype(::MyPoint) = GeoInterface.PointTrait()
    GeoInterface.geomtype(::MyCurve) = GeoInterface.LineStringTrait()
    GeoInterface.ncoord(::GeoInterface.PointTrait, geom::MyPoint) = 2
    GeoInterface.getcoord(::GeoInterface.PointTrait, geom::MyPoint, i) = [1, 2][i]
    GeoInterface.ngeom(::GeoInterface.LineStringTrait, geom::MyCurve) = 2
    GeoInterface.getgeom(::GeoInterface.LineStringTrait, geom::MyCurve, i) = MyPoint()
    GeoInterface.convert(::Type{MyCurve}, ::GeoInterface.LineStringTrait, geom) = geom

    # Test validity
    geom = MyCurve()
    @test testgeometry(geom)
    @test !isnothing(GeoInterface.convert(MyCurve, geom))

    # Check functions
    @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
    @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
    @test_throws MethodError GeoInterface.area(geom)
    point = GeoInterface.getgeom(geom, 1)
    @test GeoInterface.y(point) == 2


end
