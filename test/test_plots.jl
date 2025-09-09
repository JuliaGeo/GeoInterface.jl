using GeoInterface
using GeoInterface.Wrappers
using Plots
using Test

# We just check if plot actually runs
@testset "Plots.plot" begin
    linearring2 = LinearRing([Point(1.0, 2.0), Point(2.0, 3.0), Point(2.0, 1.0), Point(1.0, 2.0)])
    polygon2 = Polygon([linearring2])
    feature2 = Feature(polygon2)
    # 2d
    Plots.plot(Point(1.0, 2.0))
    Plots.plot(linearring2)
    Plots.plot(MultiPoint([Point(1.0, 2.0), Point(2.0, 3.0)]))
    Plots.plot(polygon2)
    Plots.plot(MultiPolygon([polygon]))
    # TODO this needs to handle mixed objects properly
    Plots.plot(GeometryCollection([polygon]))
    Plots.plot(feature2)
    Plots.plot(FeatureCollection([feature2]))
    # 3d
    linearring3 = LinearRing([Point(1.0, 2.0, 3.0), Point(2.0, 3.0, 4.0), Point(2.0, 1.0, 4.0), Point(1.0, 2.0, 3.0)])
    polygon3 = Polygon([linearring3])
    feature3 = Feature(polygon3)
    Plots.plot(Point(1.0, 2.0, 3.0))
    Plots.plot(linearring3)
    Plots.plot(MultiPoint([Point(1.0, 2.0, 3.0), Point(5.0, 4.0, 2.0)]))
    Plots.plot(polygon3)
    Plots.plot(MultiPolygon([polygon3]))
    Plots.plot(GeometryCollection(polygon3))
    Plots.plot(feature3)
    Plots.plot(FeatureCollection([feature3]))
end
