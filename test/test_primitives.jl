struct MyCurve end

@testset "Primitives" begin
    # Implement interface
    GeoInterfaceRFC.geomtype(::MyCurve) = GeoInterfaceRFC.LineString()
    GeoInterfaceRFC.ncoord(::GeoInterfaceRFC.LineString, geom::MyCurve) = 2
    GeoInterfaceRFC.ngeom(::GeoInterfaceRFC.LineString, geom::MyCurve) = 2
    GeoInterfaceRFC.getgeom(::GeoInterfaceRFC.LineString, geom::MyCurve, i) = [[1,2],[2,3]][i]

    # Test validity
    geom = MyCurve()
    @test test_interface_for_geom(geom)

    # Check functions
    @test GeoInterfaceRFC.npoint(geom) == 2  # defaults to ngeom
    @test_throws MethodError GeoInterfaceRFC.area(geom)

end
