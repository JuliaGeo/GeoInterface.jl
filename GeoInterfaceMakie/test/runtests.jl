import GeoInterfaceMakie
using Test
import LibGEOS
using LibGEOS
import GeoInterface as GI
using Makie

GeoInterfaceMakie.@enable(LibGEOS.AbstractGeometry)

@testset "points" begin
    points = GeoInterfaceMakie.points
    pt = LibGEOS.Point(1,2,3)
    @test points(pt) == [Point3f(1,2,3)]

    unitsquare = readgeom("POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))")
    @test points(unitsquare) == [
        Point2f(0.0, 0.0),
        Point2f(0.0, 1.0),
        Point2f(1.0, 1.0),
        Point2f(1.0, 0.0),
        Point2f(0.0, 0.0),
    ]
end

@testset "Makie plotting LibGEOS MultiLineString shows additional lines #83" begin
    mls = readgeom("MULTILINESTRING ((0 0,3 0,3 3,0 3,0 0),(1 1,2 1,2 2,1 2,1 1))")
    expected = [[0.0, 0.0], [3.0, 0.0], [3.0, 3.0], [0.0, 3.0], [0.0, 0.0], 
                [NaN, NaN], 
                [1.0, 1.0], [2.0, 1.0], [2.0, 2.0], [1.0, 2.0], [1.0, 1.0]]

    @test isequal(Makie.convert_arguments(Makie.Lines, mls), (expected,))
end

@testset "smoketest 2d" begin
    unitsquare = readgeom("POLYGON((0 0, 0 1, 1 1, 1 0, 0 0))")
    bigsquare = readgeom("POLYGON((0 0, 11 0, 11 11, 0 11, 0 0))")
    smallsquare = readgeom("POLYGON((5 5, 8 5, 8 8, 5 8, 5 5))")
    fig = Figure()
    geoms = [
        unitsquare,
        GI.difference(bigsquare, smallsquare),
        boundary(unitsquare),
        GI.union(smallsquare, unitsquare),
        readgeom("POINT(1 0)"),
        readgeom("MULTIPOINT(1 2, 2 3, 3 4)"),
    ]
    for (i, geom) in enumerate(geoms)
        Makie.plot!(Axis(fig[i,1], title="$(GI.geomtrait(geom))"), geom)
        Makie.plot!(Axis(fig[i,1], title="$(GI.geomtrait(geom))"), [geom])
    end
    fig
end
