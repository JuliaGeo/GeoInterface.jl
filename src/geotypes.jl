# Coordinate Reference System Objects
# (has keys "type" and "properties")
# TODO: Handle full CRS spec
typealias CRS Dict{String,Any}

# Bounding Boxes
# The value of the bbox member must be a 2*n array,
# where n is the number of dimensions represented in the contained geometries,
# with the lowest values for all axes followed by the highest values.

# The axes order of a bbox follows the axes order of geometries.
# In addition, the coordinate reference system for the bbox is assumed to match
# the coordinate reference system of the GeoJSON object of which it is a member.
typealias BBox Vector{Float64}

typealias Position Vector{Float64}
# (x, y, [z, ...]) - meaning of additional elements undefined.
# In an object's contained geometries, Positions must have uniform dimensions.

geotype(::Position) = :Position
@traitimpl TPosition{Position} begin
    x(p::Position) = p[1]
    y(p::Position) = p[2]
    z(p::Position) = hasz(p) ? p[3] : zero(T)
    hasz(p::Position) = length(p) >= 3
    coordinates(obj::Position) = obj
end

@traitfn dist_from_origin{X, Y; TPosition{X} }(p::X) = sqrt(x(p)^2 + y(p)^2 + z(p)^2)

coordinates(obj::Vector{Position}) = obj
coordinates{T <: AbstractPosition}(obj::Vector{T}) =                    Position[map(coordinates, obj)...]
coordinates{T <: AbstractPoint}(obj::Vector{T}) =                       Position[map(coordinates, obj)...]

coordinates(obj::Vector{Vector{Position}}) = obj
coordinates{T <: AbstractPosition}(obj::Vector{Vector{T}}) =            Vector{Position}[map(coordinates, obj)...]
coordinates{T <: AbstractPoint}(obj::Vector{Vector{T}}) =               Vector{Position}[map(coordinates, obj)...]
coordinates{T <: AbstractLineString}(obj::Vector{T}) =                  Vector{Position}[map(coordinates, obj)...]

coordinates(obj::Vector{Vector{Vector{Position}}}) = obj
coordinates{T <: AbstractPosition}(obj::Vector{Vector{Vector{T}}}) =    Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates{T <: AbstractPoint}(obj::Vector{Vector{Vector{T}}}) =       Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates{T <: AbstractLineString}(obj::Vector{Vector{T}}) =          Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates{T <: AbstractPolygon}(obj::Vector{T}) =                     Vector{Vector{Position}}[map(coordinates, obj)...]

type Point <: AbstractPoint
    coordinates::Position
end
Point(x::Float64,y::Float64) = Point([x,y])
Point(x::Float64,y::Float64,z::Float64) = Point([x,y,z])
Point(point::AbstractPosition) = Point(coordinates(point))
Point(point::AbstractPoint) = Point(coordinates(point))

type MultiPoint <: AbstractMultiPoint
    coordinates::Vector{Position}
end
MultiPoint(point::Position) = MultiPoint(Position[point])
MultiPoint(point::AbstractPosition) = MultiPoint(Position[coordinates(point)])
MultiPoint(point::AbstractPoint) = MultiPoint(Position[coordinates(point)])

MultiPoint{T <: AbstractPosition}(points::Vector{T}) = MultiPoint(coordinates(points))
MultiPoint{T <: AbstractPoint}(points::Vector{T}) = MultiPoint(coordinates(points))
MultiPoint(points::AbstractMultiPoint) = MultiPoint(coordinates(points))
MultiPoint(line::AbstractLineString) = MultiPoint(coordinates(line))

type LineString <: AbstractLineString
    coordinates::Vector{Position}
end
LineString{T <: AbstractPosition}(points::Vector{T}) = LineString(coordinates(points))
LineString{T <: AbstractPoint}(points::Vector{T}) = LineString(coordinates(points))
LineString(points::AbstractMultiPoint) = LineString(coordinates(points))
LineString(line::AbstractLineString) = LineString(coordinates(line))

type MultiLineString <: AbstractMultiLineString
    coordinates::Vector{Vector{Position}}
end
MultiLineString(line::Vector{Position}) = MultiLineString(Vector{Position}[line])
MultiLineString{T <: AbstractPosition}(line::Vector{T}) = MultiLineString(Vector{Position}[coordinates(line)])
MultiLineString{T <: AbstractPoint}(line::Vector{T}) = MultiLineString(Vector{Position}[coordinates(line)])
MultiLineString(line::AbstractLineString) = MultiLineString(Vector{Position}[coordinates(line)])

MultiLineString{T <: AbstractPosition}(lines::Vector{Vector{T}}) = MultiLineString(coordinates(lines))
MultiLineString{T <: AbstractPoint}(lines::Vector{Vector{T}}) = MultiLineString(coordinates(lines))
MultiLineString{T <: AbstractLineString}(lines::Vector{T}) = MultiLineString(Vector{Position}[map(coordinates,lines)])
MultiLineString(lines::AbstractMultiLineString) = MultiLineString(coordinates(line))
MultiLineString(poly::AbstractPolygon) = MultiLineString(coordinates(poly))

type Polygon <: AbstractPolygon
    coordinates::Vector{Vector{Position}}
end
Polygon(line::Vector{Position}) = Polygon(Vector{Position}[line])
Polygon{T <: AbstractPosition}(line::Vector{T}) = Polygon(Vector{Position}[coordinates(line)])
Polygon{T <: AbstractPoint}(line::Vector{T}) = Polygon(Vector{Position}[coordinates(line)])
Polygon(line::AbstractLineString) = Polygon(Vector{Position}[coordinates(line)])

Polygon{T <: AbstractPosition}(lines::Vector{Vector{T}}) = Polygon(coordinates(lines))
Polygon{T <: AbstractPoint}(lines::Vector{Vector{T}}) = Polygon(coordinates(lines))
Polygon{T <: AbstractLineString}(lines::Vector{T}) = Polygon(coordinates(lines))
Polygon(lines::AbstractMultiLineString) = Polygon(coordinates(lines))
Polygon(poly::AbstractPolygon) = Polygon(coordinates(poly))

type MultiPolygon <: AbstractMultiPolygon
    coordinates::Vector{Vector{Vector{Position}}}
end
MultiPolygon(line::Vector{Position}) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[line]])
MultiPolygon{T <: AbstractPosition}(line::Vector{T}) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])
MultiPolygon{T <: AbstractPoint}(line::Vector{T}) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])
MultiPolygon(line::AbstractLineString) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])

MultiPolygon{T <: AbstractPosition}(poly::Vector{Vector{T}}) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon{T <: AbstractPoint}(poly::Vector{Vector{T}}) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon{T <: AbstractLineString}(poly::Vector{T}) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::AbstractMultiLineString) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::AbstractPolygon) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])

MultiPolygon{T <: AbstractPosition}(polys::Vector{Vector{Vector{T}}}) = MultiPolygon(coordinates(polys))
MultiPolygon{T <: AbstractPoint}(polys::Vector{Vector{Vector{T}}}) = MultiPolygon(coordinates(polys))
MultiPolygon{T <: AbstractLineString}(polys::Vector{Vector{T}}) = MultiPolygon(coordinates(polys))
MultiPolygon{T <: AbstractPolygon}(polys::Vector{T}) = MultiPolygon(coordinates(polys))
MultiPolygon(polys::AbstractMultiPolygon) = MultiPolygon(coordinates(polys))

for geom in (:MultiPolygon, :Polygon, :MultiLineString, :LineString, :MultiPoint, :Point)
    @eval coordinates(obj::$geom) = obj.coordinates
end

type GeometryCollection <: AbstractGeometryCollection
    geometries::Vector
end
geometries(collection::GeometryCollection) = collection.geometries

type Feature <: AbstractFeature
    geometry::Union(Nothing, AbstractGeometry)
    properties::Union(Nothing, Dict{String,Any})
end
Feature(geometry::Union(Nothing,GeoInterface.AbstractGeometry)) = Feature(geometry, Dict{String,Any}())
Feature(properties::Dict{String,Any}) = Feature(nothing, properties)
geometry(feature::Feature) = feature.geometry
properties(feature::Feature) = feature.properties
bbox(feature::Feature) = get(feature.properties, "bbox", nothing)
crs(feature::Feature) = get(feature.properties, "crs", nothing)

type FeatureCollection{T <: AbstractFeature} <: AbstractFeatureCollection
    features::Vector{T}
    bbox::Union(Nothing, BBox)
    crs::Union(Nothing, CRS)
end
FeatureCollection{T <: AbstractFeature}(fc::Vector{T}) = FeatureCollection(fc, nothing, nothing)
features(fc::FeatureCollection) = fc.features
bbox(fc::FeatureCollection) = fc.bbox
crs(fc::FeatureCollection) = fc.crs

