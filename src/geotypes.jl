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
const BBox = AbstractVector{Number}

const Position = AbstractVector{Number}


abstract type AbstractPosition{T <: Number} <: AbstractVector{T} end
geotype(::AbstractPosition) = :Position
# Array-like indexing # http://julia.readthedocs.org/en/latest/manual/arrays/#arrays)
Base.eltype(p::AbstractPosition{T}) where {T <: Real} = T
Base.ndims(AbstractPosition) = 1
Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
Base.size(p::AbstractPosition) = (length(p),)
Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? xcoord(p) : (i==2) ? ycoord(p) : (i==3) ? zcoord(p) : nothing


abstract type AbstractGeometry end

abstract type AbstractPoint <: AbstractGeometry end
geotype(::AbstractPoint) = :Point

abstract type AbstractMultiPoint <: AbstractGeometry end
geotype(::AbstractMultiPoint) = :MultiPoint

abstract type AbstractLineString <: AbstractGeometry end
geotype(::AbstractLineString) = :LineString

abstract type AbstractMultiLineString <: AbstractGeometry end
geotype(::AbstractMultiLineString) = :MultiLineString

abstract type AbstractPolygon <: AbstractGeometry end
geotype(::AbstractPolygon) = :Polygon

abstract type AbstractMultiPolygon <: AbstractGeometry end
geotype(::AbstractMultiPolygon) = :MultiPolygon

abstract type AbstractGeometryCollection <: AbstractGeometry end
geotype(::AbstractGeometryCollection) = :GeometryCollection

abstract type AbstractFeature end
geotype(::AbstractFeature) = :Feature

abstract type AbstractFeatureCollection end
geotype(::AbstractFeatureCollection) = :FeatureCollection


mutable struct Point <: AbstractPoint
    coordinates::Position
end
Point(x, y) = Point([x, y])
Point(x, y, z) = Point([x, y, z])
Point(point::AbstractPosition) = Point(coordinates(point))
Point(point::AbstractPoint) = Point(coordinates(point))


mutable struct MultiPoint{T<:AbstractVector{<:AbstractPosition}} <: AbstractMultiPoint
    coordinates::T
end
MultiPoint(point::AbstractPosition) = MultiPoint([point])
MultiPoint(point::AbstractPosition) = MultiPoint([coordinates(point)])
MultiPoint(point::AbstractPoint) = MultiPoint([coordinates(point)])

MultiPoint(points::AbstractVector{<:AbstractPosition}) = MultiPoint(coordinates(points))
MultiPoint(points::AbstractVector{<:AbstractPoint}) = MultiPoint(coordinates(points))
MultiPoint(points::AbstractMultiPoint) = MultiPoint(coordinates(points))
MultiPoint(line::AbstractLineString) = MultiPoint(coordinates(line))


mutable struct LineString{T<:AbstractVector{<:AbstractPosition}} <: AbstractLineString
    coordinates::T
end
LineString(points::AbstractVector{<:AbstractPosition}) = LineString(coordinates(points))
LineString(points::AbstractVector{<:AbstractPoint}) = LineString(coordinates(points))
LineString(points::AbstractMultiPoint) = LineString(coordinates(points))
LineString(line::AbstractLineString) = LineString(coordinates(line))


mutable struct MultiLineString{T<:AbstractVector{<:AbstractVector{<:AbstractPosition}}} <: AbstractMultiLineString
    coordinates::T
end
MultiLineString(line::AbstractVector{<:AbstractPosition}) =
    MultiLineString(Vector{Position}[line])
MultiLineString(line::AbstractVector{<:AbstractPosition}) =
    MultiLineString([coordinates(line)])
MultiLineString(line::AbstractVector{AbstractPoint}) =
    MultiLineString([coordinates(line)])
MultiLineString(line::AbstractLineString) = MultiLineString([coordinates(line)])

MultiLineString(lines::AbstractVector{<:AbstractVector{<:AbstractPosition}}) = MultiLineString(coordinates(lines))
MultiLineString(lines::AbstractVector{<:AbstractVector{<:AbstractPoint}}) = MultiLineString(coordinates(lines))
MultiLineString(lines::AbstractVector{<:AbstractLineString}) = MultiLineString([map(coordinates,lines)])
MultiLineString(lines::AbstractMultiLineString) = MultiLineString(coordinates(lines))
MultiLineString(poly::AbstractPolygon) = MultiLineString(coordinates(poly))


mutable struct Polygon{T<:AbstractVector{<:AbstractVector{<:AbstractPosition}}} <: AbstractPolygon
    coordinates::T
end
Polygon(line::AbstractVector{<:AbstractPosition}) = Polygon([line])
Polygon(line::AbstractVector{<:AbstractPosition}) = Polygon([coordinates(line)])
Polygon(line::AbstractVector{<:AbstractPoint}) = Polygon([coordinates(line)])
Polygon(line::AbstractLineString) = Polygon([coordinates(line)])

Polygon(lines::AbstractVector{<:AbstractVector{<:AbstractPosition}}) = Polygon(coordinates(lines))
Polygon(lines::AbstractVector{<:AbstractVector{<:AbstractPoint}}) = Polygon(coordinates(lines))
Polygon(lines::AbstractVector{<:AbstractLineString}) = Polygon(coordinates(lines))
Polygon(lines::AbstractMultiLineString) = Polygon(coordinates(lines))
Polygon(poly::AbstractPolygon) = Polygon(coordinates(poly))


mutable struct MultiPolygon{T<:Vector{Vector{Vector{Position}}}} <: AbstractMultiPolygon
    coordinates::T
end
# FIXME MultiPolygon(line::AbstractVector{T}) where T <: AbstractPosition = MultiPolygon(Vector{Vector{Position}}[Vector{Position}[line]])
MultiPolygon(line::AbstractVector{<:AbstractPosition}) =
    MultiPolygon([Vector{Position}[coordinates(line)]])
MultiPolygon(line::AbstractVector{<:AbstractPoint}) =
    MultiPolygon([Vector{Position}[coordinates(line)]])
MultiPolygon(line::AbstractLineString) = MultiPolygon([[coordinates(line)]])

MultiPolygon(poly::AbstractVector{<:AbstractVector{<:AbstractPosition}}) =
    MultiPolygon([coordinates(poly)])
MultiPolygon(poly::AbstractVector{<:AbstractVector{<:AbstractPoint}}) =
    MultiPolygon([coordinates(poly)])
MultiPolygon(poly::AbstractVector{<:AbstractLineString}) =
    MultiPolygon([coordinates(poly)])
MultiPolygon(poly::AbstractMultiLineString) = MultiPolygon([coordinates(poly)])
MultiPolygon(poly::AbstractPolygon) = MultiPolygon([coordinates(poly)])

MultiPolygon(polys::AbstractVector{<:AbstractVector{<:AbstractVector{<:AbstractPosition}}}) =
    MultiPolygon(coordinates(polys))
MultiPolygon(polys::AbstractVector{<:AbstractVector{<:AbstractVector{<:AbstractPoint}}}) =
    MultiPolygon(coordinates(polys))
MultiPolygon(polys::<:AbstractVector{<:AbstractVector{<:AbstractLineStringT}}) =
    MultiPolygon(coordinates(polys))
MultiPolygon(polys::AbstractVector{<:AbstractPolygonT}) = MultiPolygon(coordinates(polys))
MultiPolygon(polys::AbstractMultiPolygon) = MultiPolygon(coordinates(polys))


for geom in (:MultiPolygon, :Polygon, :MultiLineString, :LineString, :MultiPoint, :Point)
    @eval coordinates(obj::$geom) = obj.coordinates
end

mutable struct GeometryCollection{V} <: AbstractGeometryCollection
    geometries::V
end

mutable struct Feature{G<Union{Nothing,AbstractGeometry},
                       P<:Union{Nothing,Dict{String,Any}}} <: AbstractFeature
    geometry::G
    properties::P
end
Feature(geometry::Union{Nothing,GeoInterface.AbstractGeometry}) =
    Feature(geometry, Dict{String,Any}())
Feature(properties::Dict{String,Any}) = Feature(nothing, properties)


mutable struct FeatureCollection{T <: AbstractVector{<: AbstractFeature},
                                 B <: Union{Nothing, BBox},
                                 C <: Union{Nothing,CRS}} <: AbstractFeatureCollection
    features::T
    bbox::B
    crs::C
end
FeatureCollection(fc::AbstractFeatureCollection{<:AbstractFeature}) =
    FeatureCollection(fc, nothing, nothing)

