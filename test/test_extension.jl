using GeoInterface

@testset "WellKnownGeometry extension (1.9+ only)" begin
    if isdefined(Base, :get_extension)
        using WellKnownGeometry
        p = GeoInterface.Wrappers.Point(1.0, 2.0)
        @test GeoInterface.astext(p).val == "POINT (1.0 2.0)"
        @test GeoInterface.asbinary(p).val == [0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40]
    end
end
