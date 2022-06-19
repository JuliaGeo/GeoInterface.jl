# Implementation of GeoInterface for Base Types

GeoInterface.isgeometry(::Type{<:AbstractVector{<:Real}}) = true
GeoInterface.geomtrait(::AbstractVector{<:Real}) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::AbstractVector{<:Real}) = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::AbstractVector{<:Real}, i) = getindex(geom, i)

GeoInterface.isgeometry(::Type{<:NTuple{N,<:Real}}) where {N} = true
GeoInterface.geomtrait(::NTuple{N,<:Real}) where {N} = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::NTuple{N,<:Real}) where {N} = N
GeoInterface.getcoord(::PointTrait, geom::NTuple{N,<:Real}, i) where {N} = getindex(geom, i)

for i in 2:4
    sig = NamedTuple{default_coord_names[1:i],NTuple{i,T}} where {T<:Real}
    GeoInterface.isgeometry(::Type{<:sig}) = true
    GeoInterface.geomtrait(::sig) = PointTrait()
    GeoInterface.ncoord(::PointTrait, geom::sig) = i
    GeoInterface.getcoord(::PointTrait, geom::sig, i) = getindex(geom, i)
end

# Custom coordinate order/names NamedTuple
GeoInterface.isgeometry(::Type{<:NamedTuple{Keys,NTuple{N,T}}}) where {Keys,N,T<:Real} = all(in(default_coord_names), Keys)
GeoInterface.geomtrait(::NamedTuple{Keys,NTuple{N,T}}) where {Keys,N,T<:Real} = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::NamedTuple{Keys,NTuple{N,T}}) where {Keys,N,T<:Real} = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::NamedTuple{Keys,NTuple{N,T}}, i) where {Keys,N,T<:Real} = getindex(geom, i)
GeoInterface.coordnames(::PointTrait, geom::NamedTuple{Keys,NTuple{N,T}}) where {Keys,N,T<:Real} = Keys


# Default features using NamedTuple and AbstractArray

const NamedTupleFeature = NamedTuple{(:geometry, :properties)}

GeoInterface.isfeature(::Type{<:NamedTupleFeature}) = true
GeoInterface.trait(::NamedTupleFeature) = FeatureTrait()
GeoInterface.geometry(f::NamedTupleFeature) = f.geometry
GeoInterface.properties(f::NamedTupleFeature) = f.properties

const ArrayFeatureCollection = AbstractArray{<:NamedTupleFeature}

GeoInterface.isfeaturecollection(::Type{<:ArrayFeatureCollection}) = true
GeoInterface.trait(::ArrayFeatureCollection) = FeatureCollectionTrait()
GeoInterface.nfeature(::FeatureCollectionTrait, fc::ArrayFeatureCollection) = Base.length(fc)
GeoInterface.getfeature(::FeatureCollectionTrait, fc::ArrayFeatureCollection, i::Integer) = fc[i]
GeoInterface.geometrycolumns(fc::ArrayFeatureCollection) = (:geometry,)
