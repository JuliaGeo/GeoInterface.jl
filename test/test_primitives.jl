struct MyCurve end

@testset "Developer" begin
    # Implement interface
    GeoInterface.isgeometry(::MyCurve) = true
    GeoInterface.geomtype(::MyCurve) = GeoInterface.LineString
    GeoInterface.ncoord(::Type{GeoInterface.LineString}, geom::MyCurve) = 2
    GeoInterface.ngeom(::Type{GeoInterface.LineString}, geom::MyCurve) = 2
    GeoInterface.getgeom(::Type{GeoInterface.LineString}, geom::MyCurve, i) = [[1, 2], [2, 3]][i]

    # Test validity
    geom = MyCurve()
    @test testgeometry(geom)

    # Check functions
    @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
    @test_throws MethodError GeoInterface.area(geom)

end
