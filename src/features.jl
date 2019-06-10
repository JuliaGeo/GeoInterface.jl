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
const BBox = AbstractVector{<:Number}


mutable struct GeometryCollection{T} <: AbstractGeometryCollection
    geometries::T
end

# Why plural? why not just geometry for everything?
geometries(collection::GeometryCollection) = collection.geometries
geometries(obj::T) where T<:AbstractGeometryCollection = error("geometries(::$T) not defined.")


abstract type AbstractFeature end
geotype(::AbstractFeature) = :Feature

crs(obj::AbstractFeature) = nothing
# optional
properties(obj::AbstractFeature) = Dict{String,Any}()
bbox(obj::AbstractFeature) = nothing
# geometry(obj::T) where {T<:AbstractFeature} = error("geometry(::$T) not defined.")


mutable struct Feature{G<:Union{Nothing,AbstractGeometry},
                       P<:Union{Nothing,Dict{String,Any}}} <: AbstractFeature
    geometry::G
    properties::P
end
Feature(geometry::Union{Nothing,AbstractGeometry}) = Feature(geometry, Dict{String,Any}())
Feature(properties::Dict{String,Any}) = Feature(nothing, properties)

properties(feature::Feature) = feature.properties
bbox(feature::Feature) = get(feature.properties, "bbox", nothing)
crs(feature::Feature) = get(feature.properties, "crs", nothing)
geometry(feature::Feature) = feature.geometry



abstract type AbstractFeatureCollection end
geotype(::AbstractFeatureCollection) = :FeatureCollection

features(obj::T) where {T<:AbstractFeatureCollection} = error("features(::$T) not defined.")
bbox(obj::AbstractFeatureCollection) = nothing # optional
crs(obj::AbstractFeatureCollection) = nothing # optional


mutable struct FeatureCollection{T <: AbstractVector{<:AbstractFeature},
                                 B <: Union{Nothing,BBox},
                                 C <: Union{Nothing,CRS}} <: AbstractFeatureCollection
    features::T
    bbox::B
    crs::C
end
# FeatureCollection(fc::AbstractFeatureCollection) = FeatureCollection(fc, nothing, nothing)

features(fc::FeatureCollection) = fc.features
bbox(fc::FeatureCollection) = fc.bbox
crs(fc::FeatureCollection) = fc.crs

