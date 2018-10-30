# Coordinate Reference System Objects
# (has keys "type" and "properties")
# TODO: Handle full CRS spec
const CRS = Dict{String,Any}

# Bounding Boxes
# The value of the bbox member must be a 2*n array,
# where n is the number of dimensions represented in the contained geometries,
# with the lowest values for all axes followed by the highest values.

# The axes order of a bbox follows the axes order of geometries.
# In addition, the coordinate reference system for the bbox is assumed to match
# the coordinate reference system of the GeoJSON object of which it is a member.
const BBox = Vector{Float64}

const Position = Vector{Float64}
# (x, y, [z, ...]) - meaning of additional elements undefined.
# In an object's contained geometries, Positions must have uniform dimensions.
geotype(::Position) = :Position
xcoord(p::Position) = p[1]
ycoord(p::Position) = p[2]
zcoord(p::Position) = hasz(p) ? p[3] : zero(T)
hasz(p::Position) = length(p) >= 3
coordinates(obj::Position) = obj

coordinates(obj::Vector{Position}) = obj
coordinates(obj::Vector{T}) where {T <: AbstractPosition} =                    Position[map(coordinates, obj)...]
coordinates(obj::Vector{T}) where {T <: AbstractPoint} =                       Position[map(coordinates, obj)...]

coordinates(obj::Vector{Vector{Position}}) = obj
coordinates(obj::Vector{Vector{T}}) where {T <: AbstractPosition} =            Vector{Position}[map(coordinates, obj)...]
coordinates(obj::Vector{Vector{T}}) where {T <: AbstractPoint} =               Vector{Position}[map(coordinates, obj)...]
coordinates(obj::Vector{T}) where {T <: AbstractLineString} =                  Vector{Position}[map(coordinates, obj)...]

coordinates(obj::Vector{Vector{Vector{Position}}}) = obj
coordinates(obj::Vector{Vector{Vector{T}}}) where {T <: AbstractPosition} =    Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates(obj::Vector{Vector{Vector{T}}}) where {T <: AbstractPoint} =       Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates(obj::Vector{Vector{T}}) where {T <: AbstractLineString} =          Vector{Vector{Position}}[map(coordinates, obj)...]
coordinates(obj::Vector{T}) where {T <: AbstractPolygon} =                     Vector{Vector{Position}}[map(coordinates, obj)...]

mutable struct Point <: AbstractPoint
    coordinates::Position
end
Point(x::Float64,y::Float64) = Point([x,y])
Point(x::Float64,y::Float64,z::Float64) = Point([x,y,z])
Point(point::AbstractPosition) = Point(coordinates(point))
Point(point::AbstractPoint) = Point(coordinates(point))

mutable struct MultiPoint <: AbstractMultiPoint
    coordinates::Vector{Position}
end
MultiPoint(point::Position) = MultiPoint(Position[point])
MultiPoint(point::AbstractPosition) = MultiPoint(Position[coordinates(point)])
MultiPoint(point::AbstractPoint) = MultiPoint(Position[coordinates(point)])

MultiPoint(points::Vector{T}) where {T <: AbstractPosition} = MultiPoint(coordinates(points))
MultiPoint(points::Vector{T}) where {T <: AbstractPoint} = MultiPoint(coordinates(points))
MultiPoint(points::AbstractMultiPoint) = MultiPoint(coordinates(points))
MultiPoint(line::AbstractLineString) = MultiPoint(coordinates(line))

mutable struct LineString <: AbstractLineString
    coordinates::Vector{Position}
end
LineString(points::Vector{T}) where {T <: AbstractPosition} = LineString(coordinates(points))
LineString(points::Vector{T}) where {T <: AbstractPoint} = LineString(coordinates(points))
LineString(points::AbstractMultiPoint) = LineString(coordinates(points))
LineString(line::AbstractLineString) = LineString(coordinates(line))

mutable struct MultiLineString <: AbstractMultiLineString
    coordinates::Vector{Vector{Position}}
end
MultiLineString(line::Vector{Position}) = MultiLineString(Vector{Position}[line])
MultiLineString(line::Vector{T}) where {T <: AbstractPosition} = MultiLineString(Vector{Position}[coordinates(line)])
MultiLineString(line::Vector{T}) where {T <: AbstractPoint} = MultiLineString(Vector{Position}[coordinates(line)])
MultiLineString(line::AbstractLineString) = MultiLineString(Vector{Position}[coordinates(line)])

MultiLineString(lines::Vector{Vector{T}}) where {T <: AbstractPosition} = MultiLineString(coordinates(lines))
MultiLineString(lines::Vector{Vector{T}}) where {T <: AbstractPoint} = MultiLineString(coordinates(lines))
MultiLineString(lines::Vector{T}) where {T <: AbstractLineString} = MultiLineString(Vector{Position}[map(coordinates,lines)])
MultiLineString(lines::AbstractMultiLineString) = MultiLineString(coordinates(lines))
MultiLineString(poly::AbstractPolygon) = MultiLineString(coordinates(poly))

mutable struct Polygon <: AbstractPolygon
    coordinates::Vector{Vector{Position}}
end
Polygon(line::Vector{Position}) = Polygon(Vector{Position}[line])
Polygon(line::Vector{T}) where {T <: AbstractPosition} = Polygon(Vector{Position}[coordinates(line)])
Polygon(line::Vector{T}) where {T <: AbstractPoint} = Polygon(Vector{Position}[coordinates(line)])
Polygon(line::AbstractLineString) = Polygon(Vector{Position}[coordinates(line)])

Polygon(lines::Vector{Vector{T}}) where {T <: AbstractPosition} = Polygon(coordinates(lines))
Polygon(lines::Vector{Vector{T}}) where {T <: AbstractPoint} = Polygon(coordinates(lines))
Polygon(lines::Vector{T}) where {T <: AbstractLineString} = Polygon(coordinates(lines))
Polygon(lines::AbstractMultiLineString) = Polygon(coordinates(lines))
Polygon(poly::AbstractPolygon) = Polygon(coordinates(poly))

mutable struct MultiPolygon <: AbstractMultiPolygon
    coordinates::Vector{Vector{Vector{Position}}}
end
MultiPolygon(line::Vector{Position}) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[line]])
MultiPolygon(line::Vector{T}) where {T <: AbstractPosition} = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])
MultiPolygon(line::Vector{T}) where {T <: AbstractPoint} = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])
MultiPolygon(line::AbstractLineString) = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[coordinates(line)]])

MultiPolygon(poly::Vector{Vector{T}}) where {T <: AbstractPosition} = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::Vector{Vector{T}}) where {T <: AbstractPoint} = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::Vector{T}) where {T <: AbstractLineString} = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::AbstractMultiLineString) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])
MultiPolygon(poly::AbstractPolygon) = MultiPolygon(Vector{Vector{Position}}[coordinates(poly)])

MultiPolygon(polys::Vector{Vector{Vector{T}}}) where {T <: AbstractPosition} = MultiPolygon(coordinates(polys))
MultiPolygon(polys::Vector{Vector{Vector{T}}}) where {T <: AbstractPoint} = MultiPolygon(coordinates(polys))
MultiPolygon(polys::Vector{Vector{T}}) where {T <: AbstractLineString} = MultiPolygon(coordinates(polys))
MultiPolygon(polys::Vector{T}) where {T <: AbstractPolygon} = MultiPolygon(coordinates(polys))
MultiPolygon(polys::AbstractMultiPolygon) = MultiPolygon(coordinates(polys))

for geom in (:MultiPolygon, :Polygon, :MultiLineString, :LineString, :MultiPoint, :Point)
    @eval coordinates(obj::$geom) = obj.coordinates
end

mutable struct GeometryCollection <: AbstractGeometryCollection
    geometries::Vector
end
geometries(collection::GeometryCollection) = collection.geometries

mutable struct Feature <: AbstractFeature
    geometry::Union{Nothing, AbstractGeometry}
    properties::Union{Nothing, Dict{String,Any}}
end
Feature(geometry::Union{Nothing,GeoInterface.AbstractGeometry}) = Feature(geometry, Dict{String,Any}())
Feature(properties::Dict{String,Any}) = Feature(nothing, properties)
geometry(feature::Feature) = feature.geometry
properties(feature::Feature) = feature.properties
bbox(feature::Feature) = get(feature.properties, "bbox", nothing)
crs(feature::Feature) = get(feature.properties, "crs", nothing)

mutable struct FeatureCollection{T <: AbstractFeature} <: AbstractFeatureCollection
    features::Vector{T}
    bbox::Union{Nothing, BBox}
    crs::Union{Nothing, CRS}
end
FeatureCollection(fc::Vector{T}) where {T <: AbstractFeature} = FeatureCollection(fc, nothing, nothing)
features(fc::FeatureCollection) = fc.features
bbox(fc::FeatureCollection) = fc.bbox
crs(fc::FeatureCollection) = fc.crs
