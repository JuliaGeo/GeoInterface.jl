
# Array-like indexing # http://julia.readthedocs.org/en/latest/manual/arrays/#arrays)
Base.eltype(p::AbstractPosition{T}) where {T <: Real} = T
Base.ndims(AbstractPosition) = 1
Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
Base.size(p::AbstractPosition) = (length(p),)
Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? xcoord(p) : (i==2) ? ycoord(p) : (i==3) ? zcoord(p) : nothing

# Generalise this...
Base.convert(T::Type{<:Vector{<:Float64}}, p::AbstractPosition) = coordinates(p)
# Base.linearindexing{T <: AbstractPosition}(::Type{T}) = LinearFast()

xcoord(::AbstractPosition) = error("xcoord(::AbstractPosition) not defined.")
ycoord(::AbstractPosition) = error("ycoord(::AbstractPosition) not defined.")

# optional
zcoord(::AbstractPosition) = error("zcoord(::AbstractPosition) not defined.")
hasz(::AbstractPosition) = false

# (x, y, [z, ...]) - meaning of additional elements undefined.
# In an object's contained geometries, Positions must have uniform dimensions.
xcoord(p::Position) = p[1]
ycoord(p::Position) = p[2]
zcoord(p::Position) = hasz(p) ? p[3] : zero(T)

hasz(p::Position) = length(p) >= 3

coordinates(obj::Position) = obj


# This should be done at compile time
coordinates(p::AbstractPosition) = hasz(p) ? [xcoord(p), ycoord(p), zcoord(p)] : [xcoord(p), ycoord(p)]

coordinates(obj::AbstractGeometry) = error("coordinates(::AbstractGeometry) not defined.")

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


geometry(feature::Feature) = feature.geometry
properties(feature::Feature) = feature.properties
bbox(feature::Feature) = get(feature.properties, "bbox", nothing)
crs(feature::Feature) = get(feature.properties, "crs", nothing)

features(fc::FeatureCollection) = fc.features
bbox(fc::FeatureCollection) = fc.bbox
crs(fc::FeatureCollection) = fc.crs

# optional
properties(obj::AbstractFeature) = Dict{String,Any}()
bbox(obj::AbstractFeature) = nothing

features(obj::AbstractFeatureCollection) = error("features(::AbstractFeatureCollection) not defined.")
# optional
bbox(obj::AbstractFeatureCollection) = nothing

crs(obj::AbstractFeature) = nothing
crs(obj::AbstractFeatureCollection) = nothing

# Why plural? why not just geometry for everything?
geometries(obj::AbstractGeometryCollection) = error("geometries(::AbstractGeometryCollection) not defined.")
geometries(collection::GeometryCollection) = collection.geometries
geometry(obj::AbstractFeature) = error("geometry(::AbstractFeature) not defined.")
