using Test, GeoFormatTypes, Extents
import GeoInterface as GI
using GeoInterface.Wrappers

# checks that our string display for geoms in regular/compact form is as expected
function test_display(geom, expected_str, expected_compact_str)
    # checks non-compact string repr
    generated_str = sprint() do io
        show(IOContext(io, :displaysize => (24, 80)), MIME"text/plain"(), geom)  
    end
    @test expected_str == generated_str
    # checks compact string repr
    generated_compact_str = sprint() do io
        show(IOContext(io, :displaysize => (24, 80), :compact => true), MIME"text/plain"(), geom)
    end
    @test expected_compact_str == generated_compact_str
end

# Point
point = GI.Point(1, 2)
@test point === GI.Point(point) 
GI.getcoord(point, 1)
@test !GI.ismeasured(point)
@test !GI.is3d(point)
@test GI.ncoord(point) == 2
@test GI.coordtype(point) == Int
@test GI.extent(point) == Extent(X=(1, 1), Y=(2, 2))
@test point == GI.Point(point)
@test (GI.x(point), GI.y(point)) == (1, 2)
@test_throws ArgumentError GI.z(point)
@test_throws ArgumentError GI.m(point)
@test_throws ArgumentError GI.Point(1, 2, 3, 4, 5)
@test GI.testgeometry(point)
@test GI.convert(GI, (1, 2)) isa GI.Point
test_display(point, "Point{false, false}((1, 2))", "Point((1,2))")
point_crs = GI.Point(point; crs=EPSG(4326))
@test parent(point_crs) === parent(point)
@test GI.crs(point_crs) === EPSG(4326)
test_display(point_crs, "Point{false, false}((1, 2), crs = \"EPSG:4326\")", "Point((1,2))")

# 3D Point
pointz = GI.Point(1, 2, 3)
@test !GI.ismeasured(pointz)
@test GI.is3d(pointz)
@test GI.ncoord(pointz) == 3
@test GI.coordtype(pointz) == Int
@test (GI.x(pointz), GI.y(pointz), GI.z(pointz)) == (1, 2, 3)
@test GI.testgeometry(pointz)
@test GI.convert(GI, pointz) === pointz
@test GI.extent(pointz) == Extents.Extent(X=(1, 1), Y=(2, 2), Z=(3, 3))
test_display(pointz, "Point{true, false}((1, 2, 3))", "Point((1,2,3))")

# 3D measured point
pointzm = GI.Point(; X=1, Y=2, Z=3, M=4)
@test pointzm == GI.Point(1, 2, 3, 4)
@test pointzm != GI.Point(1, 2, 3)
@test GI.ismeasured(pointzm)
@test GI.is3d(pointzm)
@test GI.ncoord(pointzm) == 4
@test GI.coordtype(pointzm) == Int
@test pointzm == GI.Point(pointzm)
@test point != GI.Point(pointzm)
@test (GI.x(pointzm), GI.y(pointzm), GI.z(pointzm), GI.m(pointzm)) == (1, 2, 3, 4)
@test GI.testgeometry(pointzm)
@test GI.convert(GI, pointzm) === pointzm
pointzm_crs = GI.Point(; X=1, Y=2, Z=3, M=4, crs=EPSG(4326))
@test parent(pointzm_crs) === parent(pointzm)
@test GI.crs(pointzm_crs) === EPSG(4326)
test_display(pointzm, "Point{true, true}((1, 2, 3, 4))", "Point((1,2,3,4))")

# Measured point
pointm = GI.Point((X=1, Y=2, M=3))
@test_throws MethodError GI.Point(; X=1, Y=2, T=3)
@test GI.ismeasured(pointm)
@test !GI.is3d(pointm)
@test GI.ncoord(pointm) == 3
@test GI.coordtype(pointm) == Int
@test pointm == GI.Point(pointm)
@test point != GI.Point(pointm)
@test (GI.x(pointm), GI.y(pointm), GI.m(pointm)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointm)
@test GI.testgeometry(pointm)
test_display(pointm, "Point{false, true}((1, 2, 3))", "Point((1,2,3))")
pointm_crs = GI.Point((X=1, Y=2, M=3); crs=EPSG(4326))
@test parent(pointm_crs) === parent(pointm)
@test GI.crs(pointm_crs) === EPSG(4326)
test_display(pointm_crs, "Point{false, true}((1, 2, 3), crs = \"EPSG:4326\")", "Point((1,2,3))")

# Forced measured point with a tuple
pointtm = GI.Point{false,true}(1, 2, 3)
@test_throws ArgumentError GI.Point{false,true}(1, 2, 3, 4)
@test GI.ismeasured(pointtm)
@test !GI.is3d(pointtm)
@test GI.ncoord(pointtm) == 3
@test GI.coordtype(pointtm) == Int
@test (GI.x(pointtm), GI.y(pointtm), GI.m(pointtm)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointtm)
@test GI.testgeometry(pointtm)
test_display(pointtm, "Point{false, true}((1, 2, 3))", "Point((1,2,3))")
pointtm_crs = GI.Point{false,true}(1, 2, 3; crs=EPSG(4326))
@test parent(pointtm_crs) === parent(pointtm)
@test GI.crs(pointtm_crs) === EPSG(4326)
test_display(pointtm_crs, "Point{false, true}((1, 2, 3), crs = \"EPSG:4326\")", "Point((1,2,3))")

# Point made from an array
pointa = GI.Point([1, 2])
@test !GI.ismeasured(pointa)
@test !GI.is3d(pointa)
@test GI.ncoord(pointa) == 2
@test GI.coordtype(pointa) == Int
@test (GI.x(pointa), GI.y(pointa)) == (1, 2)
@test GI.testgeometry(pointa)
test_display(pointa, "Point{false, false}((1, 2))", "Point((1,2))")

pointaz = GI.Point([1, 2, 3])
@test !GI.ismeasured(pointaz)
@test GI.is3d(pointaz)
@test GI.ncoord(pointaz) == 3
@test (GI.x(pointaz), GI.y(pointaz), GI.z(pointaz)) == (1, 2, 3)
@test GI.testgeometry(pointaz)
test_display(pointaz, "Point{true, false}((1, 2, 3))", "Point((1,2,3))")

pointazm = GI.Point([1, 2, 3, 4])
@test GI.ismeasured(pointazm)
@test GI.is3d(pointazm)
@test GI.ncoord(pointazm) == 4
@test (GI.x(pointazm), GI.y(pointazm), GI.z(pointazm), GI.m(pointazm)) == (1, 2, 3, 4)
@test GI.testgeometry(pointazm)
test_display(pointazm, "Point{true, true}((1, 2, 3, 4))", "Point((1,2,3,4))")

# We can force a vector point to be measured
pointam = GI.Point{false,true}([1, 2, 3])
@test GI.ismeasured(pointam)
@test !GI.is3d(pointam)
@test GI.ncoord(pointam) == 3
@test (GI.x(pointam), GI.y(pointam), GI.m(pointam)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointam)
@test GI.testgeometry(pointam)
test_display(pointam, "Point{false, true}((1, 2, 3))", "Point((1,2,3))")
@test_throws ArgumentError GI.Point(1, 2, 3, 4, 5)

# Line
line = GI.Line([(1, 2), (3, 4)])
@test line == GI.Line(line)
@test GI.getgeom(line, 1) === (1, 2)
@test GI.getgeom(line) == [(1, 2), (3, 4)]
@test GI.testgeometry(line)
@test !GI.is3d(line)
@test GI.ncoord(line) == 2
@test GI.extent(line) == Extent(X=(1, 3), Y=(2, 4))
test_display(line, "Line{false, false}([(1, 2), (3, 4)])", "Line([(1,2),(3,4)])")
@test_throws ArgumentError GI.Line(point)
@test_throws ArgumentError GI.Line([(1, 2)])
@test_throws ArgumentError GI.Line([line, line])
line_crs = GI.Line(line; crs=EPSG(4326))
@test parent(line_crs) === parent(line)
@test GI.crs(line_crs) === EPSG(4326)
test_display(line_crs, "Line{false, false}([(1, 2), (3, 4)], crs = \"EPSG:4326\")", "Line([(1,2),(3,4)])")

# LineString
linestring = GI.LineString([(1, 2), (3, 4)])
@test linestring === GI.LineString(linestring)
@test GI.getgeom(linestring, 1) === (1, 2)
@test GI.getgeom(linestring) == [(1, 2), (3, 4)]
@test GI.testgeometry(linestring)
@test !GI.is3d(linestring)
@test GI.ncoord(linestring) == 2
@test GI.coordtype(linestring) == Int
test_display(linestring, "LineString{false, false}([(1, 2), (3, 4)])", "LineString([(1,2),(3,4)])")
@test @inferred(GI.extent(linestring)) == Extent(X=(1, 3), Y=(2, 4))
@test_throws ArgumentError GI.LineString([(1, 2)])
linestring_crs = GI.LineString(linestring; crs=EPSG(4326))
@test parent(linestring_crs) === parent(linestring)
@test GI.crs(linestring_crs) === EPSG(4326)
test_display(linestring_crs, "LineString{false, false}([(1, 2), (3, 4)], crs = \"EPSG:4326\")", "LineString([(1,2),(3,4)])")

# LinearRing
linearring = GI.LinearRing([(1, 2), (3, 4), (5, 6), (1, 2)])
@test linearring === GI.LinearRing(linearring)
@test GI.getgeom(linearring, 1) === (1, 2)
@test GI.getgeom(linearring) == [(1, 2), (3, 4), (5, 6), (1, 2)]
@test GI.testgeometry(linearring)
@test !GI.is3d(linearring)
@test GI.ncoord(linearring) == 2
test_display(linearring, "LinearRing{false, false}([(1, 2), (3, 4), (5, 6), (1, 2)])", "LinearRing([(1,2),(3,4),(5,6),(1,2)])")
@test @inferred(GI.extent(linearring)) == Extent(X=(1, 5), Y=(2, 6))
@test_throws ArgumentError GI.LinearRing([(1, 2)])
linearring_crs = GI.LinearRing(linearring; crs=EPSG(4326))
@test parent(linearring_crs) === parent(linearring)
@test GI.crs(linearring_crs) === EPSG(4326)
test_display(linearring_crs, "LinearRing{false, false}([(1, 2), (3, 4), (5, 6), (1, 2)], crs = \"EPSG:4326\")", "LinearRing([(1,2),(3,4),(5,6),(1,2)])")

# Polygon
polygon = GI.Polygon([linearring, linearring])
@test GI.Polygon([linearring]) == GI.Polygon(linearring)
@test polygon == GI.Polygon(polygon)
@test GI.getgeom(polygon, 1) === linearring
@test collect(GI.getgeom(polygon)) == [linearring, linearring]
@test collect(GI.getpoint(polygon)) == vcat(collect(GI.getpoint(linearring)), collect(GI.getpoint(linearring)))
@test GI.testgeometry(polygon)
@test !GI.is3d(polygon)
@test GI.ncoord(polygon) == 2
@test @inferred(GI.extent(polygon)) == Extent(X=(1, 5), Y=(2, 6))
@test GI.convert(GI, MyPolygon()) isa GI.Polygon
@test GI.convert(GI, polygon) === polygon
test_display(polygon, "Polygon{false, false}([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])])",
                "Polygon([LinearRing([(1,2),(3,4),(5,6),(1,2)]),LinearRing([(1,2),(3,4),(5,6),(1,2)])])")
polygon_crs = GI.Polygon(polygon; crs=EPSG(4326))
@test parent(polygon_crs) === parent(polygon)
@test GI.crs(polygon_crs) === EPSG(4326)
test_display(polygon_crs, "Polygon{false, false}([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])], crs = \"EPSG:4326\")",
                "Polygon([LinearRing([(1,2),(3,4),(5,6),(1,2)]),LinearRing([(1,2),(3,4),(5,6),(1,2)])])")
# Make sure `linestring` is also ok in polygons
polygon = GI.Polygon([linestring, linestring])
@test GI.getgeom(polygon, 1) === linestring
@test collect(GI.getgeom(polygon)) == [linestring, linestring]
test_display(polygon, "Polygon{false, false}([LineString([(1, 2), (3, 4)]), LineString([(1, 2), (3, 4)])])",
                "Polygon([LineString([(1,2),(3,4)]),LineString([(1,2),(3,4)])])")

linearring3d = GI.LinearRing([(1, 2, 3), (3, 4, 5), (5, 6, 7), (1, 2, 3)])
polygon3d = GI.Polygon([linearring3d, linearring3d])
@test GI.is3d(polygon3d)
@test GI.ncoord(polygon3d) == 3
@test GI.extent(polygon3d) == Extents.Extent(X=(1, 5), Y=(2, 6), Z=(3, 7))
test_display(linearring3d, "LinearRing{true, false}([(1, 2, 3), (3, 4, 5), (5, 6, 7), (1, 2, 3)])", "LinearRing([(1,2,3),(3,4,5),(5,6,7),(1,2,3)])")

# MultiPoint
multipoint = GI.MultiPoint([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])
@test multipoint == GI.MultiPoint(multipoint)
@test GI.MultiPoint([(1, 2)]) == GI.MultiPoint((1, 2))
@test GI.getgeom(multipoint, 1) === (1, 2)
@test !GI.is3d(multipoint)
@test GI.ncoord(multipoint) == 2
@test @inferred(GI.extent(multipoint)) == Extent(X=(1, 9), Y=(2, 10))
@test_throws ArgumentError GI.MultiPoint([[(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)]])
@test GI.testgeometry(multipoint)
test_display(multipoint, "MultiPoint{false, false}([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])", "MultiPoint([(1,2),(3,4),(3,2),(1,4),(7,8),(9,10)])")
multipoint_crs = GI.MultiPoint(multipoint; crs=EPSG(4326))
@test parent(multipoint_crs) == parent(multipoint)
@test GI.crs(multipoint_crs) === EPSG(4326)
test_display(multipoint_crs, "MultiPoint{false, false}([(1, 2), (3, 4), (3, 2), … (1) … , (7, 8), (9, 10)], crs = \"EPSG:4326\")", "MultiPoint([(1,2),(3,4),(3,2),(1,4),(7,8),(9,10)])")

# GeometryCollection
geoms = [line, linestring, linearring, multipoint, (1, 2)]
collection = GI.GeometryCollection(geoms)
@test GI.GeometryCollection([line]) == GI.GeometryCollection(line)
@test collection == GI.GeometryCollection(collection)
@test GI.getgeom(collection) == geoms
@test GI.testgeometry(collection)
@test !GI.is3d(collection)
@test GI.ncoord(collection) == 2
@test GI.coordtype(collection) == Int
@test GI.extent(collection) == reduce(Extents.union, map(GI.extent, geoms))
test_display(collection, "GeometryCollection{false, false}([Line([(1, 2), (3, 4)]), … (3) … , (1, 2)])",
                    "GeometryCollection([Line([(1,2),(3,4)]),LineString([(1,2),(3,4)]),…(2)…,(1,2)])")
collection_crs = GI.GeometryCollection(collection; crs=EPSG(4326))
@test parent(collection_crs) == parent(collection)
@test GI.crs(collection_crs) === EPSG(4326)
test_display(collection_crs, "GeometryCollection{false, false}([Line([(1, 2), (3, 4)]), … (3) … , (1, 2)], crs = \"EPSG:4326\")",
                    "GeometryCollection([Line([(1,2),(3,4)]),LineString([(1,2),(3,4)]),…(2)…,(1,2)])")

# MultiCurve
multicurve = GI.MultiCurve([linestring, linearring])
@test collect(GI.getpoint(multicurve)) == vcat(collect(GI.getpoint(linestring)), collect(GI.getpoint(linearring)))
@test GI.MultiCurve([linestring]) == GI.MultiCurve(linestring)
@test multicurve == GI.MultiCurve(multicurve)
@test GI.getgeom(multicurve, 1) === linestring
@test !GI.is3d(multicurve)
@test GI.ncoord(multicurve) == 2
@test GI.coordtype(multicurve) == Int
@test GI.extent(multicurve) == Extent(X=(1, 5), Y=(2, 6))
@test_throws ArgumentError GI.MultiCurve([pointz, polygon])
@test GI.testgeometry(multicurve)
test_display(multicurve, "MultiCurve{false, false}([LineString([(1, 2), (3, 4)]), LinearRing([(1, 2), … (2) … , (1, 2)])])",
                        "MultiCurve([LineString([(1,2),(3,4)]),LinearRing([(1,2),(3,4),…(1)…,(1,2)])])")
multicurve_crs = GI.MultiCurve(multicurve; crs=EPSG(4326))
@test parent(multicurve_crs) == parent(multicurve)
@test GI.crs(multicurve_crs) === EPSG(4326)
test_display(multicurve_crs, "MultiCurve{false, false}([LineString([(1, 2), (3, 4)]), LinearRing([(1, 2), … (2) … , (1, 2)])], crs = \"EPSG:4326\")",
                        "MultiCurve([LineString([(1,2),(3,4)]),LinearRing([(1,2),(3,4),…(1)…,(1,2)])])")

# MultiPolygon
polygon = GI.Polygon([linearring, linearring])
multipolygon = GI.MultiPolygon([polygon])
@test multipolygon == GI.MultiPolygon(multipolygon)
@test multipolygon == GI.MultiPolygon(polygon)
@test GI.getgeom(multipolygon, 1) === polygon
@test !GI.is3d(multipolygon)
@test GI.ncoord(multipolygon) == 2
@test GI.coordtype(multipolygon) == Int
test_display(multipolygon, "MultiPolygon{false, false}([Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])])])",
                            "MultiPolygon([Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])])])")
# MultiPolygon extent does not infer, maybe due to nesting
@test GI.extent(multipolygon) == Extent(X=(1, 5), Y=(2, 6))
@test collect(GI.getpoint(multipolygon)) == collect(GI.getpoint(polygon))
@test_throws ArgumentError GI.MultiPolygon([[[[(1, 2), (3, 4), (3, 2), (1, 4)]]]])
@test GI.testgeometry(multipolygon)
multipolygon_crs = GI.MultiPolygon(multipolygon; crs=EPSG(4326))
@test parent(multipolygon_crs) == parent(multipolygon)
@test GI.crs(multipolygon_crs) === EPSG(4326)
test_display(multipolygon_crs, "MultiPolygon{false, false}([Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])])], crs = \"EPSG:4326\")",
                            "MultiPolygon([Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])])])")

# PolyhedralSurface
polyhedralsurface = GI.PolyhedralSurface([polygon, polygon])
@test polyhedralsurface == GI.PolyhedralSurface(polyhedralsurface)
@test GI.PolyhedralSurface(polygon) == GI.PolyhedralSurface(polygon)
@test !GI.is3d(polyhedralsurface)
@test GI.ncoord(polyhedralsurface) == 2
@test GI.coordtype(polyhedralsurface) == Int
@test @inferred(GI.extent(polyhedralsurface)) == Extent(X=(1, 5), Y=(2, 6))
@test GI.getgeom(polyhedralsurface, 1) === polygon
@test collect(GI.getgeom(polyhedralsurface)) == [polygon, polygon]
@test GI.getgeom(polyhedralsurface, 1) == polygon
@test collect(GI.getpoint(polyhedralsurface)) == vcat(collect(GI.getpoint(polygon)), collect(GI.getpoint(polygon)))
@test GI.testgeometry(polyhedralsurface)
test_display(polyhedralsurface, "PolyhedralSurface{false, false}([Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])]), Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])])])",
                                "PolyhedralSurface([Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])]),Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])])])")
polyhedralsurface_crs = GI.PolyhedralSurface(polyhedralsurface; crs=EPSG(4326))
@test parent(polyhedralsurface_crs) == parent(polyhedralsurface)
@test GI.crs(polyhedralsurface_crs) === EPSG(4326)
test_display(polyhedralsurface_crs, "PolyhedralSurface{false, false}([Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])]), Polygon([LinearRing([(1, 2), … (2) … , (1, 2)]), LinearRing([(1, 2), … (2) … , (1, 2)])])], crs = \"EPSG:4326\")",
                                "PolyhedralSurface([Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])]),Polygon([LinearRing([(1,2),…(2)…,(1,2)]),LinearRing([(1,2),…(2)…,(1,2)])])])")

# Round-trip coordinates
multipolygon_coords = [[[[1, 2], [3, 4], [3, 2], [1, 4]]]]
multipolygon = GI.MultiPolygon(multipolygon_coords)
@test GI.coordinates(multipolygon) == multipolygon_coords
@test GI.coordtype(multipolygon) == Int
test_display(multipolygon, "MultiPolygon{false, false}([Polygon([LinearRing([[1, 2], [3, 4], [3, 2], [1, 4]])])])",
                        "MultiPolygon([Polygon([LinearRing([[1,2],[3,4],[3,2],[1,4]])])])")

# Wrong parent type
@test_throws ArgumentError GI.Point(nothing)
@test_throws ArgumentError GI.Point(linestring)
@test_throws ArgumentError GI.LineString(1)
@test_throws ArgumentError GI.MultiPolygon(1)
@test_throws ArgumentError GI.MultiPolygon((1, 2))

# Feature
feature = GI.Feature(multipolygon; properties=(x=1, y=2, z=3))
@test feature === GI.Feature(feature) === GI.Feature(feature; properties=(a=1, b=2))
@test GI.geometry(feature) === multipolygon
@test GI.properties(feature) === (x=1, y=2, z=3)
@test GI.crs(feature) == nothing
@test GI.extent(feature) == GI.extent(multipolygon) 
@test GI.testfeature(feature)
test_display(feature, "Feature(MultiPolygon{false, false}([Polygon([LinearRing([[1, 2], [3, 4], [3, 2], [1, 4]])])]), properties = (x = 1, y = 2, z = 3))",
                    "Feature(MultiPolygon([Polygon([LinearRing([[1,2],[3,4],[3,2],[1,4]])])]),properties=(x=1,y=2,z=3))")
feature = GI.Feature(multipolygon; 
    properties=(x=1, y=2, z=3), crs=EPSG(4326), extent=extent(multipolygon)
)
test_display(feature, "Feature(MultiPolygon{false, false}([Polygon([LinearRing([[1, 2], [3, 4], [3, 2], [1, 4]])])]), properties = (x = 1, y = 2, z = 3), crs = \"EPSG:4326\")",
                    "Feature(MultiPolygon([Polygon([LinearRing([[1,2],[3,4],[3,2],[1,4]])])]),properties=(x=1,y=2,z=3))")
@test GI.geometry(feature) === multipolygon
@test GI.properties(feature) === (x=1, y=2, z=3)
@test GI.crs(feature) == EPSG(4326)
@test GI.extent(feature) == GI.extent(multipolygon) 
@test GI.testfeature(feature)
@test GI.coordtype(feature) == Int
@test_throws ArgumentError GI.Feature(:not_a_feature; properties=(x=1, y=2, z=3))
@test GI.properties(GI.Feature(multipolygon)) == NamedTuple()

# Feature Collection
fc_unwrapped = GI.FeatureCollection(feature; crs=EPSG(4326), extent=GI.extent(feature))
fc = GI.FeatureCollection(fc_unwrapped.parent; crs=EPSG(4326), extent=GI.extent(feature)) # so that `==` works since the underlying array is the same
@test fc_unwrapped == fc
@test GI.crs(fc) == GI.crs(GI.FeatureCollection(feature; crs=EPSG(4326), extent=GI.extent(feature)))
@test GI.extent(fc) == GI.extent(GI.FeatureCollection(feature; crs=EPSG(4326), extent=GI.extent(feature)))
@test fc === GI.FeatureCollection(fc)
@test GI.crs(fc) == EPSG(4326)
@test GI.extent(fc) == fc.extent
@test first(GI.getfeature(fc)) == GI.getfeature(fc, 1) === feature
@test GI.testfeaturecollection(fc)
test_display(fc, "FeatureCollection([Feature(MultiPolygon{false, false}([Polygon([LinearRing([[1, 2], [3, 4], [3, 2], [1, 4]])])]), properties = (x = 1, y = 2, z = 3), crs = \"EPSG:4326\")], crs = \"EPSG:4326\", extent = Extent(X = (1, 3), Y = (2, 4)))",
                "FeatureCollection([Feature(MultiPolygon([Polygon([LinearRing([[1,2],[3,4],[3,2],[1,4]])])]),properties=(x=1,y=2,z=3))])")
@test_throws ArgumentError GI.FeatureCollection([1])
vecfc = GI.FeatureCollection([(geometry=(1,2), a=1, b=2)])
@test GI.getfeature(vecfc, 1) == (geometry=(1,2), a=1, b=2)
@test GI.coordtype(vecfc) == Int



struct MaPointRappa
    x::Float64
    y::Float64
end

@testset "Wrapped geometry printing" begin

    GI.geomtrait(::MaPointRappa) = GI.PointTrait()
    GI.ncoord(::GI.PointTrait, ::MaPointRappa) = 2
    GI.x(::GI.PointTrait, p::MaPointRappa) = p.x
    GI.y(::GI.PointTrait, p::MaPointRappa) = p.y
    

    test_display(GI.Point(MaPointRappa(1.0, 2.0)), "Point{false, false}((1.0, 2.0))", "Point((1.0,2.0))")

    GI.geomtrait(::Vector{MaPointRappa}) = GI.LineStringTrait()
    GI.npoint(::GI.LineStringTrait, v::Vector{MaPointRappa}) = length(v)
    GI.getpoint(::GI.LineStringTrait, v::Vector{MaPointRappa}, i::Integer) = v[i]

    test_display(
        GI.LineString([MaPointRappa(1.0, 2.0), MaPointRappa(3.0, 4.0)]), 
        "LineString{false, false}([MaPointRappa(1.0, 2.0), MaPointRappa(3.0, 4.0)])", 
        "LineString([MaPointRappa(1.0, 2.0),MaPointRappa(3.0, 4.0)])" # FIXME: this should not show the point type!
    )
end

# TODO

# # Triangle
# triangle = GI.Triangle([[(1, 2, 3), (3, 4, 5), (3, 2, 1)]])
# @test triangle == GI.Triangle(triangle)
# @test GI.getgeom(triangle, 1) === (1, 2, 3)
# @test_throws ArgumentError GI.Triangle([[(1, 2, 3), (3, 4, 5), (3, 2, 1)]])
# @test GI.testgeometry(triangle)

#rectangle = GI.Rectangle([(1, 2), (3, 4), (3, 2)])

# # Quad
# quad = GI.Quad([(1, 2), (3, 4), (3, 2), (1, 4)])
# @test quad == GI.Quad(quad)
# @test GI.getgeom(quad, 1) === (1, 2)
# quad = GI.Quad([[(1, 2), (3, 4), (3, 2), (1, 4)]])
# @test quad == GI.Quad(quad)
# @test GI.getgeom(quad, 1) === (1, 2)
# @test_throws ArgumentError GI.Quad([[(1, 2), (3, 4), (3, 2)]])
# @test GI.testgeometry(quad)

# # Pentagon
# hex = GI.Pentagon([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8)])
# @test hex == GI.Pentagon(hex)
# @test GI.getgeom(hex, 1) === (1, 2)
# GI.Pentagon([[(1, 2), (3, 4), (3, 2), (1, 4), (7, 8)]])
# @test GI.testgeometry(hex)
# @test_throws ArgumentError GI.Pentagon([[(1, 2), (3, 4), (3, 2), (1, 4)]])

# # Hexagon
# hex = GI.Hexagon([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])
# @test hex == GI.Hexagon(hex)
# @test GI.getgeom(hex, 1) === (1, 2)
# GI.Hexagon([[(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)]])
# @test GI.testgeometry(hex)
# @test_throws ArgumentError GI.Hexagon([[(1, 2), (3, 4), (3, 2), (1, 4)]])

# # TIN
# tin = GI.TIN([triangle])
# @test tin == GI.TIN(tin)
# @test GI.getgeom(tin, 1) === triangle
# @test collect(GI.getpoint(tin)) == collect(GI.getpoint(triangle))
# @test_throws ArgumentError GI.TIN([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])
# @test GI.testgeometry(tin)
