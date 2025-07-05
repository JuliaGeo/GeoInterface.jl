using GeoInterface
using GeoInterface.Wrappers
using RecipesBase
using Plots
using Test

# We just check if plot actually runs
@testset "Plots.plot" begin
    linearring2 = LinearRing([Point(1.0, 2.0), Point(2.0, 3.0), Point(2.0, 1.0), Point(1.0, 2.0)])
    polygon2 = Polygon([linearring2])
    feature2 = Feature(polygon2)
    # 2d
    Plots.plot(Point(1.0, 2.0))
    plot(linearring2)
    plot(MultiPoint([Point(1.0, 2.0), Point(2.0, 3.0)]))
    plot(polygon2)
    plot(MultiPolygon([polygon]))
    # TODO this needs to handle mixed objects properly
    plot(GeometryCollection([polygon]))
    plot(feature2)
    plot(FeatureCollection([feature2]))
    # 3d
    linearring3 = LinearRing([Point(1.0, 2.0, 3.0), Point(2.0, 3.0, 4.0), Point(2.0, 1.0, 4.0), Point(1.0, 2.0, 3.0)])
    polygon3 = Polygon([linearring3])
    feature3 = Feature(polygon3)
    plot(Point(1.0, 2.0, 3.0))
    plot(linearring3)
    plot(MultiPoint([Point(1.0, 2.0, 3.0), Point(5.0, 4.0, 2.0)]))
    plot(polygon3)
    plot(MultiPolygon([polygon3]))
    plot(GeometryCollection(polygon3))
    plot(feature3)
    plot(FeatureCollection([feature3]))
end
