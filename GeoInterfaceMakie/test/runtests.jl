import GeoInterfaceMakie
using Test
import LibGEOS
using LibGEOS
import GeoInterface as GI
using Makie

GeoInterfaceMakie.@enable(LibGEOS.AbstractGeometry)

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
    multipolygon = GI.union(smallsquare, unitsquare)
    point = readgeom("POINT(1 0)")
    multipoint = readgeom("MULTIPOINT(1 2, 2 3, 3 4)")
    geoms = [
        unitsquare,
        GI.difference(bigsquare, smallsquare),
        boundary(unitsquare),
        multipolygon, 
        point, 
        multipoint,
    ]
    fig = Figure()
    for (i, geom) in enumerate(geoms)
        Makie.plot!(Axis(fig[i, 1], title="$(GI.geomtrait(geom))"), geom)
        if geom == multipoint
            # `plot!` wont even work with the GeometryBasics version of this
            continue
        elseif geom == multipolygon
            # `plot!` wont work with the GeometryBasics version of this either
            # But `poly!` does
            Makie.poly!(Axis(fig[i, 2], title="Vector of $(GI.geomtrait(geom))"), [geom, geom])
        else
            Makie.plot!(Axis(fig[i, 2], title="Vector of $(GI.geomtrait(geom))"), [geom, geom])
        end
    end
    fig
end
