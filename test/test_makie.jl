import GeoInterface as GI

using Makie
using Test
using GeoInterface.Wrappers
using GeoInterface: Point
using CairoMakie

@testset "Makie plotting MultiLineString shows additional lines #83" begin
    mls = MultiLineString([LineString([(0, 0), (3, 0), (3, 3), (0, 3), (0, 0)]), LineString([(1, 1), (2, 1), (2, 2), (1, 2), (1, 1)])])
    expected = [[0.0, 0.0], [3.0, 0.0], [3.0, 3.0], [0.0, 3.0], [0.0, 0.0], 
                [NaN, NaN], 
                [1.0, 1.0], [2.0, 1.0], [2.0, 2.0], [1.0, 2.0], [1.0, 1.0]]

    converted = Makie.convert_arguments(Makie.Lines, mls)
    @test isequal(converted, (expected,))
end

@testset "smoketest 2d" begin
    # Set up test geometries
    unitsquare = Polygon(LineString([(0, 0), (0, 1), (1, 1), (1, 0), (0, 0)]))
    Makie.plot(unitsquare)
    bigsquare = Polygon(LineString([(0, 0), (11, 0), (11, 11), (0, 11), (0, 0)]))
    smallsquare = Polygon(LineString([(5, 5), (8, 5), (8, 8), (5, 8), (5, 5)]))
    multipolygon = MultiPolygon([smallsquare, unitsquare])
    point = Point(1, 0)
    multipoint = MultiPoint([(1, 2), (2, 3), (3, 4)])
    geoms = [
        unitsquare,
        multipolygon, 
        point, 
        multipoint,
    ]

    # Plot them all onto one figure
    fig = Figure()
    for (i, geom) in enumerate(geoms)
        # plot a geometry into an axis
        Makie.plot(fig[i, 1], geom; axis=(; type=Axis, title="$(GI.geomtrait(geom))"))
        geom isa MultiPoint && continue
        # plot a vector of the same geometry into the axis
        @test_nowarn Makie.plot(fig[i, 2], [geom, geom]; axis=(; type=Axis, title="Vector of $(GI.geomtrait(geom))"))
    end
    @test_nowarn Makie.update_state_before_display!(fig)
    @test_nowarn Makie.colorbuffer(fig.scene)
    fig
end

@testset "Make sure that Makie can plot NaN-based geometry correctly" begin
    f, a, p = poly(Makie.GeometryBasics.Polygon([Point2f(NaN)]))
    @test_nowarn Makie.update_state_before_display!(f)
    @test_nowarn Makie.colorbuffer(f.scene)
    @test a.finallimits[] == Makie.Rect2d(Vec2(0.0, 0.0), Vec2(10.0, 10.0))
    # Hide all decorations so the scene should ideally be completely white
    hidedecorations!(a)
    hidespines!(a)
    # Rasterize the figure's scene to an image
    img = Makie.colorbuffer(f.scene)
    # Test that everything is white, i.e., there is no color.
    # This means that nothing was plotted, which is good.
    @test all(==(Makie.ARGB32(1,1,1,1)), img)
end

@testset "Mixed geometry types work" begin
    poly = GI.Polygon([GI.LinearRing([(0, 0), (1, 0), (1, 1), (0, 0)])])
    multipoly = GI.MultiPolygon([poly, poly])
    @test_nowarn Makie.plot([poly, multipoly])
    @test_nowarn Makie.plot([GI.GeometryCollection([poly, multipoly]), multipoly])
end

@testset "handle missing values" begin
    # First test that missing values get the right dispatches
    points = [GI.Point(1.0, 2.0), GI.Point(3.0, 4.0), missing]
    @test_nowarn Makie.plot(points)
    lines = [GI.LineString(Point2d[(1, 2), (3, 4)]), GI.LineString(Point2d[(5, 4), (5, 6)]), missing]
    @test_nowarn Makie.plot(lines)
    polys = [GI.Polygon([GI.LinearRing([(1, 2), (3, 4), (5, 5), (1, 2)])]), GI.Polygon([GI.LinearRing([(7, 8), (9, 10), (11, 11), (7, 8)])]), missing]
    @test_nowarn Makie.plot(polys)
    # Now we test that appropriate "missing" (i.e., NaN) polygons 
    # are inserted in the correct place, so that we have the same
    # number of elements post conversion as pre conversion.  This
    # allows colors to be propagated correctly through the array.
    @test_nowarn Makie.poly(polys; color = 1:length(polys))
end
