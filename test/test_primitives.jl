using GeoInterface
using GeoInterface.TestGeometry
using Test

@testset "Developer" begin

    @testset "Point" begin
        geom = Point()
        @test testgeometry(geom)
        @test GeoInterface.x(geom) === 1
        @test GeoInterface.y(geom) === 2
        @test_throws ArgumentError GeoInterface.z(geom)
        @test_throws ArgumentError GeoInterface.m(geom)
        @test ncoord(geom) === 2
        @test collect(getcoord(geom)) == [1, 2]
        @test getcoord(geom, 1) === 1
        @test GeoInterface.coordnames(geom) == (:X, :Y)
        @test !GeoInterface.isempty(geom)
        @test !GeoInterface.is3d(geom)
        @test !GeoInterface.ismeasured(geom)

        geom = EmptyPoint()
        @test GeoInterface.coordnames(geom) == ()
        @test GeoInterface.isempty(geom)

        @test isnothing(GeoInterface.crs(geom))
        @test isnothing(GeoInterface.extent(geom))
        @test isnothing(GeoInterface.bbox(geom))
    end

    @testset "LineString" begin
        geom = Curve()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2  # defaults to ngeom
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        points = GeoInterface.getpoint(geom)
        point = GeoInterface.getpoint(geom, 1)
        pointa = GeoInterface.startpoint(geom)
        pointb = GeoInterface.endpoint(geom)
        @test GeoInterface.y(point) == 2

        @test_throws MethodError GeoInterface.length(geom)

        @test GeoInterface.issimple(geom)
        @test GeoInterface.isclosed(geom)
        @test GeoInterface.isring(geom)

    end

    @testset "Polygon" begin
        geom = Polygon()
        @test testgeometry(geom)
        # Test that half a implementation yields an error

        @test GeoInterface.nring(geom) == 2
        @test GeoInterface.nhole(geom) == 1
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        lines = GeoInterface.getring(geom)
        line = GeoInterface.getring(geom, 1)
        lines = GeoInterface.gethole(geom)
        line = GeoInterface.gethole(geom, 1)
        line = GeoInterface.getexterior(geom)
        @test GeoInterface.npoint(geom) == 4
        @test collect(GeoInterface.getpoint(geom)) == [Point(), Point(), Point(), Point()]

        @test_throws MethodError GeoInterface.area(geom)

        geom = Triangle()
        @test testgeometry(geom)
        @test GeoInterface.nring(geom) == 1
        @test GeoInterface.nhole(geom) == 0
        @test GeoInterface.npoint(geom) == 3
    end

    @testset "MultiPoint" begin
        geom = MultiPoint()
        @test testgeometry(geom)

        @test GeoInterface.npoint(geom) == 2
        points = GeoInterface.getpoint(geom)
        point = GeoInterface.getpoint(geom, 1)
        @test GeoInterface.coordinates(geom) == [[1, 2], [1, 2]]
        @test collect(points) == [Point(), Point()]

        @test !GeoInterface.issimple(geom)
    end

    @testset "MultiLineString" begin
        geom = MultiCurve()
        @test testgeometry(geom)

        @test GeoInterface.nlinestring(geom) == 2
        lines = GeoInterface.getlinestring(geom)
        line = GeoInterface.getlinestring(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        @test collect(lines) == [Curve(), Curve()]
    end

    @testset "MultiPolygon" begin
        geom = MultiPolygon()
        @test testgeometry(geom)

        @test GeoInterface.npolygon(geom) == 2
        polygons = GeoInterface.getpolygon(geom)
        polygon = GeoInterface.getpolygon(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[[1, 2], [1, 2]], [[1, 2], [1, 2]]], [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]]
        @test collect(polygons) == [Polygon(), Polygon()]
    end

    @testset "Surface" begin
        geom = TIN()
        @test testgeometry(geom)

        @test GeoInterface.npatch(geom) == 2
        polygons = GeoInterface.getpatch(geom)
        polygon = GeoInterface.getpatch(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[[1, 2], [1, 2]], [[1, 2], [1, 2]], [[1, 2], [1, 2]]], [[[1, 2], [1, 2]], [[1, 2], [1, 2]], [[1, 2], [1, 2]]]]
        @test collect(polygons) == [Triangle(), Triangle()]
    end

    @testset "GeometryCollection" begin
        geom = Collection()
        @test testgeometry(geom)

        @test GeoInterface.ngeom(geom) == 2
        geoms = GeoInterface.getgeom(geom)
        thing = GeoInterface.getgeom(geom, 1)
        @test GeoInterface.coordinates(geom) == [[[1, 2], [1, 2]], [[1, 2], [1, 2]]]
        @test collect(geoms) == [Curve(), Curve()]
    end

end

@testset "Defaults" begin
    @test GeoInterface.subtrait(TINTrait()) == TriangleTrait
    @test GeoInterface.nring(QuadTrait(), ()) == 1
    @test GeoInterface.npoint(QuadTrait(), ()) == 4
end

@testset "Feature" begin
    feature = Feature((1, 2), (a=10, b=20))
    @test GeoInterface.testfeature(feature)
end

@testset "FeatureCollection" begin
    features = FeatureCollection(
        [Feature(Point(), (a="1", b="2")), Feature(Polygon(), (a="3", b="4"))]
    )
    @test GeoInterface.testfeaturecollection(features)
end

@testset "Conversion" begin
    struct XCurve end
    struct XPolygon end

    Base.convert(T::Type{XCurve}, geom::X) where {X} = Base.convert(T, geomtrait(geom), geom)
    Base.convert(::Type{XCurve}, ::LineStringTrait, geom::XCurve) = geom  # fast fallthrough
    Base.convert(::Type{XCurve}, ::LineStringTrait, geom) = geom

    geom = Curve()
    @test !isnothing(convert(Curve, geom))

    Base.convert(T::Type{XPolygon}, geom::X) where {X} = Base.convert(T, geomtype(geom), geom)
    @test_throws Exception convert(Polygon, geom)
end

@testset "Operations" begin
    struct XGeom end

    GeoInterface.isgeometry(::XGeom) = true
    GeoInterface.geomtrait(::XGeom) = PointTrait()
    GeoInterface.ncoord(::PointTrait, geom::XGeom) = 2
    GeoInterface.getcoord(::PointTrait, geom::XGeom, i) = [1, 2][i]

    GeoInterface.equals(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.disjoint(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.intersects(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.touches(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.within(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.contains(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.overlaps(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true
    GeoInterface.crosses(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = true

    GeoInterface.relate(::PointTrait, ::PointTrait, ::XGeom, ::XGeom, matrix) = true

    GeoInterface.symdifference(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.difference(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.intersection(::PointTrait, ::PointTrait, a::XGeom, ::XGeom) = a
    GeoInterface.union(::PointTrait, ::PointTrait, ::XGeom, a::XGeom) = a

    GeoInterface.distance(::PointTrait, ::PointTrait, ::XGeom, ::XGeom) = rand()

    GeoInterface.buffer(::PointTrait, a::XGeom, distance) = a
    GeoInterface.convexhull(::PointTrait, a::XGeom) = a

    GeoInterface.astext(::PointTrait, ::XGeom) = "POINT (1 2)"
    GeoInterface.asbinary(::PointTrait, ::XGeom) = [0x0, 0x0]

    geom = XGeom()

    @test GeoInterface.equals(geom, geom)
    @test GeoInterface.disjoint(geom, geom)
    @test GeoInterface.intersects(geom, geom)
    @test GeoInterface.touches(geom, geom)
    @test GeoInterface.within(geom, geom)
    @test GeoInterface.contains(geom, geom)
    @test GeoInterface.overlaps(geom, geom)
    @test GeoInterface.crosses(geom, geom)

    @test GeoInterface.relate(geom, geom, ["a"])

    @test GeoInterface.isgeometry(GeoInterface.symdifference(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.difference(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.intersection(geom, geom))
    @test GeoInterface.isgeometry(GeoInterface.union(geom, geom))

    @test GeoInterface.distance(geom, geom) isa Number

    @test GeoInterface.isgeometry(GeoInterface.buffer(geom, 1.0))
    @test GeoInterface.isgeometry(GeoInterface.convexhull(geom))

    @test GeoInterface.astext(geom) isa String
    @test GeoInterface.asbinary(geom) isa Vector{UInt8}
end

@testset "Base Implementations" begin

    @testset "Vector" begin
        geom = [1, 2]
        @test testgeometry(geom)
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.ncoord(geom) == 2
        @test collect(GeoInterface.getcoord(geom)) == geom
    end

    @testset "Tuple" begin
        geom = (1, 2)
        @test testgeometry(geom)
        @test GeoInterface.x(geom) == 1
        @test GeoInterface.ncoord(geom) == 2
        @test collect(GeoInterface.getcoord(geom)) == [1, 2]
    end

    @testset "NamedTuple" begin
        geom = (; X=1, Y=2)
        @test testgeometry(geom)
        @test GeoInterface.x(geom) == 1
        @test collect(GeoInterface.getcoord(geom)) == [1, 2]

        geom = (; X=1, Y=2, Z=3)
        @test testgeometry(geom)
        geom = (; X=1, Y=2, Z=3, M=4)
        @test testgeometry(geom)
        geom = (; Z=3, X=1, Y=2, M=4)
        @test testgeometry(geom)

        @test GeoInterface.x(geom) == 1
        @test GeoInterface.m(geom) == 4
        @test GeoInterface.ncoord(geom) == 4
        @test collect(GeoInterface.getcoord(geom)) == [3, 1, 2, 4]

    end

    @testset "NamedTupleFeature" begin
        feature = (; geometry=(1, 2), a="x", b="y", c="z")
        GeoInterface.geometry(feature) = (1, 2)
        @test GeoInterface.properties(feature) == (a="x", b="y", c="z")
        @test GeoInterface.testfeature(feature)
        @test GeoInterface.testfeaturecollection([feature, feature])
    end
end
