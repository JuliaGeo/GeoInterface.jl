
abstract type AbstractPosition{T<:Number} <: AbstractVector{T} end
geotype(::AbstractPosition) = :Position

xcoord(::T) where T <: AbstractPosition = error("xcoord(::$T) not defined.")
ycoord(::T) where T <: AbstractPosition = error("ycoord(::$T) not defined.")
zcoord(::T) where T <: AbstractPosition = error("zcoord(::$T) not defined.") # optional

hasz(::AbstractPosition) = false

# (x, y, [z, ...]) - meaning of additional elements undefined.
# In an object's contained geometries, Positions must have uniform dimensions.


# Array interface
Base.eltype(p::AbstractPosition{T}) where T = T
Base.ndims(AbstractPosition) = 1
Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
Base.size(p::AbstractPosition) = (length(p),)
Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? xcoord(p) : (i==2) ? ycoord(p) : (i==3) ? zcoord(p) : nothing
# Base.linearindexing{T <: AbstractPosition}(::Type{T}) = LinearFast()


const Position = Vector{Float64} # Position isn't actually <: AbstractPosition
geotype(::Position) = :Position

xcoord(p::Position) = p[1]
ycoord(p::Position) = p[2]
zcoord(p::Position) = hasz(p) ? p[3] : zero(T)

hasz(p::Position) = length(p) >= 3

Base.convert(T::Type{Position}, p::AbstractPosition) = coordinates(p)

const AnyPosition = Vector{Any} # Position isn't actually <: AbstractPosition
const NumPosition = Vector{<:Number} # Position isn't actually <: AbstractPosition


abstract type AbstractGeometry end


abstract type AbstractPoint <: AbstractGeometry end
geotype(::AbstractPoint) = :Point

abstract type AbstractLineString <: AbstractGeometry end
geotype(::AbstractLineString) = :LineString

abstract type AbstractMultiPoint <: AbstractGeometry end
geotype(::AbstractMultiPoint) = :MultiPoint

abstract type AbstractMultiLineString <: AbstractGeometry end
geotype(::AbstractMultiLineString) = :MultiLineString

abstract type AbstractPolygon <: AbstractGeometry end
geotype(::AbstractPolygon) = :Polygon

abstract type AbstractMultiPolygon <: AbstractGeometry end
geotype(::AbstractMultiPolygon) = :MultiPolygon

abstract type AbstractGeometryCollection <: AbstractGeometry end
geotype(::AbstractGeometryCollection) = :GeometryCollection


# Define the common union types to keep methods DRY
# Position types are separated to avoid method ambiguities.

const Pos = Union{Position,AbstractPosition}
const ConvertPos = Union{AnyPosition}
const SinglePosVec = AbstractVector{<:Union{Pos}}
const DoublePosVec = AbstractVector{<:AbstractVector{<:Union{Pos,AnyPosition,NumPosition}}}

const SingleVec = Union{AbstractVector{<:ConvertPos},
                        AbstractVector{<:AbstractPoint}, AbstractLineString}

const DoubleVec = Union{AbstractVector{<:AbstractVector{<:ConvertPos}},
                        AbstractVector{<:AbstractVector{<:AbstractPoint}},
                        AbstractVector{<:AbstractLineString},
                        AbstractMultiLineString,
                        AbstractPolygon}

const TripleVec = Union{AbstractVector{<:AbstractVector{<:AbstractVector{<:AbstractPoint}}},
                        AbstractVector{<:AbstractVector{<:AbstractLineString}},
                        AbstractVector{<:AbstractMultiLineString},
                        AbstractVector{<:AbstractPolygon},
                        AbstractMultiPolygon}


mutable struct Point{T<:Pos} <: AbstractPoint
    coordinates::T
end
Point(x, y) = Point([promote_type([x, y])...])
Point(x, y, z) = Point(promote_type([x, y, z]))
Point(pos::AbstractPosition) = Point(coordinates(pos))
Point(pos::Union{AnyPosition,NumPosition}) = Point(coordinates(pos))
Point(point::AbstractPoint) = Point(coordinates(point))


mutable struct LineString{T<:AbstractVector{<:Pos}} <: AbstractLineString
    coordinates::T
end
LineString(x::Union{SingleVec,SinglePosVec}) = LineString(coordinates(x))


mutable struct MultiPoint{T<:AbstractVector{<:Pos}} <: AbstractMultiPoint
    coordinates::T
end
MultiPoint(x::SingleVec) = MultiPoint([coordinates(x)])
MultiPoint(x::Union{DoubleVec,DoublePosVec}) = MultiPoint(coordinates(x))


mutable struct MultiLineString{T<:AbstractVector{<:AbstractVector{<:Pos}}} <: AbstractMultiLineString
    coordinates::T
end
MultiLineString(x::Union{SingleVec,SinglePosVec}) = MultiLineString([coordinates(x)])
MultiLineString(x::DoubleVec) = MultiLineString(coordinates(x))

mutable struct Polygon{T<:AbstractVector{<:AbstractVector{<:Pos}}} <: AbstractPolygon
    coordinates::T
end
Polygon(x::Union{SingleVec,SinglePosVec}) = Polygon([coordinates(x)])
Polygon(x::DoubleVec) = Polygon(coordinates(x))


mutable struct MultiPolygon{T<:AbstractVector{<:AbstractVector{<:AbstractVector{<:Pos}}}} <: AbstractMultiPolygon
    coordinates::T
end
MultiPolygon(x::Union{SingleVec, SinglePosVec}) = MultiPolygon([[coordinates(x)]])
MultiPolygon(x::Union{DoubleVec, DoublePosVec}) = MultiPolygon([coordinates(x)])
MultiPolygon(x::TripleVec) = coordinates(x)


"""
Get the coordinates of an object, or nested vectors of coordinates for nested objects
"""
function coordinates end

coordinates(obj::Position) = obj
# Shouldn't this also return the AbstractPosition unmodified?
coordinates(p::AbstractPosition) = hasz(p) ? [xcoord(p), ycoord(p), zcoord(p)] : [xcoord(p), ycoord(p)]
coordinates(obj::AbstractVector{<:Any}) = begin
    coords = [obj...]
    eltype(coords) <: Number || error("Coordinates $obj are not in Number")
    coords
end
coordinates(obj::AbstractVector{<:Number}) = [promote_type(obj)...]
coordinates(obj::AbstractVector) = coordinates.(obj)
coordinates(obj::T) where T <: AbstractGeometry = error("coordinates(::$T) not defined.")

for geom in (:MultiPolygon, :Polygon, :MultiLineString, :LineString, :MultiPoint, :Point)
    @eval coordinates(obj::$geom) = obj.coordinates
end
