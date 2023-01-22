using Test
import GeoInterface as GI

# Point
point = GI.Point(1, 2)
@test !GI.ismeasured(point)
@test !GI.is3d(point)
@test point == GI.Point(point)
@test (GI.x(point), GI.y(point)) == (1, 2)
@test_throws ArgumentError GI.z(point)
@test_throws ArgumentError GI.m(point)
@test_throws ArgumentError GI.Point(1, 2, 3, 4, 5)

# 3D Point
pointz = GI.Point(1, 2, 3)
@test !GI.ismeasured(pointz)
@test GI.is3d(pointz)
@test (GI.x(pointz), GI.y(pointz), GI.z(pointz)) == (1, 2, 3)

# 3D measured point
pointzm = GI.Point(1, 2, 3, 4)
@test GI.ismeasured(pointzm)
@test GI.is3d(pointzm)
@test pointzm == GI.Point(pointzm)
@test point != GI.Point(pointzm)
@test (GI.x(pointzm), GI.y(pointzm), GI.z(pointzm), GI.m(pointzm)) == (1, 2, 3, 4)

# Measured point
pointm = GI.Point((X=1, Y=2, M=3))
@test_throws MethodError GI.Point(; X=1, Y=2, T=3)
@test GI.ismeasured(pointm)
@test !GI.is3d(pointm)
@test pointm == GI.Point(pointm)
@test point != GI.Point(pointm)
@test (GI.x(pointm), GI.y(pointm), GI.m(pointm)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointm)

# Foreced measured point with a tuple
pointtm = GI.Point{false,true}((1, 2, 3))
@test GI.ismeasured(pointtm)
@test !GI.is3d(pointtm)
@test (GI.x(pointtm), GI.y(pointtm), GI.m(pointtm)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointm)

# Point made from an array
pointa = GI.Point([1, 2])
@test !GI.ismeasured(pointa)
@test !GI.is3d(pointa)
@test (GI.x(pointa), GI.y(pointa)) == (1, 2)

pointaz = GI.Point([1, 2, 3])
@test !GI.ismeasured(pointaz)
@test GI.is3d(pointaz)
@test (GI.x(pointaz), GI.y(pointaz), GI.z(pointaz)) == (1, 2, 3)

pointazm = GI.Point([1, 2, 3, 4])
@test GI.ismeasured(pointazm)
@test GI.is3d(pointazm)
@test (GI.x(pointazm), GI.y(pointazm), GI.z(pointazm), GI.m(pointazm)) == (1, 2, 3, 4)

# We can force a vector point to be measured
pointam = GI.Point{false,true}([1, 2, 3])
@test GI.ismeasured(pointam)
@test !GI.is3d(pointam)
@test (GI.x(pointam), GI.y(pointam), GI.m(pointam)) == (1, 2, 3)
@test_throws ArgumentError GI.z(pointam)

@test_throws ArgumentError GI.Point(1, 2, 3, 4, 5)

# Line
line = GI.Line([(1, 2), (3, 4)])
@test line == GI.Line(line)
@test GI.getgeom(line, 1) === (1, 2)
@test GI.getgeom(line) == [(1, 2), (3, 4)]

# LineString
linestring = GI.LineString([(1, 2), (3, 4)])
@test linestring == GI.LineString(linestring)
@test GI.getgeom(linestring, 1) === (1, 2)
@test GI.getgeom(linestring) == [(1, 2), (3, 4)]

# LinearRing
linearring = GI.LinearRing(GI.LinearRing([(1, 2), (3, 4), (5, 6), (1, 2)]))
@test linearring == GI.LinearRing(linearring)
@test GI.getgeom(linearring, 1) === (1, 2)
@test GI.getgeom(linearring) == [(1, 2), (3, 4), (5, 6), (1, 2)]

# Triangle
triangle = GI.Triangle([(1, 2, 3), (3, 4, 5), (3, 2, 1)])
@test triangle == GI.Triangle(triangle)
@test GI.getgeom(triangle, 1) === (1, 2, 3)
@test_throws ArgumentError GI.Triangle([[(1, 2, 3), (3, 4, 5), (3, 2, 1)]])

#rectangle = GI.Rectangle([(1, 2), (3, 4), (3, 2)])

# Quad
quad = GI.Quad([(1, 2), (3, 4), (3, 2), (1, 4)])
@test quad == GI.Quad(quad)
@test GI.getgeom(quad, 1) === (1, 2)
@test_throws ArgumentError GI.Quad([[(1, 2), (3, 4), (3, 2), (1, 4)]])

# Hex
hex = GI.Hexagon([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])
@test hex == GI.Hexagon(hex)
@test GI.getgeom(hex, 1) === (1, 2)
@test_throws ArgumentError GI.Hexagon([[(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)]])

# MultiPoint
multipoint = GI.MultiPoint([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])
@test multipoint == GI.MultiPoint(multipoint)
@test GI.getgeom(multipoint, 1) === (1, 2)
@test_throws ArgumentError GI.MultiPoint([[(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)]])

# TIN
tin = GI.TIN([triangle])
@test tin == GI.TIN(tin)
@test GI.getgeom(tin, 1) === triangle
@test collect(GI.getpoint(tin)) == collect(GI.getpoint(triangle))
@test_throws ArgumentError GI.TIN([(1, 2), (3, 4), (3, 2), (1, 4), (7, 8), (9, 10)])

# GeometryCollection
geoms = [line, linestring, linearring, triangle, quad, hex, multipoint, (1, 2)]
collection = GI.GeometryCollection(geoms)
@test collection == GI.GeometryCollection(collection)
@test GI.getgeom(collection) == geoms
@test collect(GI.getpoint(collection)) == vcat(map(collect ∘ GI.getpoint, geoms)...)

# MultiCurve
multicurve = GI.MultiCurve([linestring, linearring])
@test collect(GI.getpoint(multicurve)) == vcat(collect(GI.getpoint(linestring)), collect(GI.getpoint(linearring)))
@test multicurve == GI.MultiCurve(multicurve)
@test GI.getgeom(multicurve, 1) === linestring
@test_throws ArgumentError GI.MultiCurve([quad, pointz])

# Polygon
polygon = GI.Polygon([linearring, linearring])
@test polygon == GI.Polygon(polygon)
@test GI.getgeom(polygon, 1) === linearring
@test collect(GI.getgeom(polygon)) == [linearring, linearring]
@test collect(GI.getpoint(polygon)) == vcat(collect(GI.getpoint(linearring)), collect(GI.getpoint(linearring)))

# PolyhedralSurface
polyhedralsurface = GI.PolyhedralSurface([polygon, polygon])
@test polyhedralsurface == GI.PolyhedralSurface(polyhedralsurface)
@test GI.getgeom(polyhedralsurface, 1) === polygon
@test collect(GI.getgeom(polyhedralsurface)) == [polygon, polygon]
@test GI.getgeom(polyhedralsurface, 1) == polygon
@test collect(GI.getpoint(polyhedralsurface)) == vcat(collect(GI.getpoint(polygon)), collect(GI.getpoint(polygon)))

# MultiPolygon
multipolygon = GI.MultiPolygon([polygon])
@test multipolygon == GI.MultiPolygon(multipolygon)
@test GI.getgeom(multipolygon, 1) === polygon
@test collect(GI.getpoint(multipolygon)) == collect(GI.getpoint(polygon))
@test_throws ArgumentError GI.MultiPolygon([[[[(1, 2), (3, 4), (3, 2), (1, 4)]]]])

# Round-trip coordinates
multipolygon_coords = [[[[1, 2], [3, 4], [3, 2], [1, 4]]]]
multipolygon = GI.MultiPolygon(multipolygon_coords)
@test GI.coordinates(multipolygon) == multipolygon_coords
