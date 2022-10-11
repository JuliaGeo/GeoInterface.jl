import GeoInterfaceMakie
using Test
import LibGEOS

GeoInterfaceMakie.@enable(LibGEOS.AbstractGeometry)

using LibGEOS
import GeoInterface as GI
using Makie
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
    for (i,geom) in enumerate(geoms)
        Makie.plot!(Axis(fig[i,1], title="$(GI.geomtrait(geom))"), geom)
    end
    fig
end
