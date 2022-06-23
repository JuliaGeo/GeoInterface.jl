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

# Any named tuple with a `:geometry` field is a feature
_is_namedtuple_feature(::Type{<:NamedTuple{K}}) where K = :geometry in K
_is_namedtuple_feature(nt::NamedTuple) = _is_namedtuple_feature(typeof(nt))

GeoInterface.isfeature(T::Type{<:NamedTuple}) = _is_namedtuple_feature(T)
GeoInterface.trait(nt::NamedTuple) = _is_namedtuple_feature(nt) ? FeatureTrait() : nothing
GeoInterface.geometry(nt::NamedTuple) = _is_namedtuple_feature(nt) ? nt.geometry : nothing
GeoInterface.properties(nt::NamedTuple) = _is_namedtuple_feature(nt) ? _nt_properties(nt) : nothing

# Use Val to force constant propagation through `reduce`
function _nt_properties(nt::NamedTuple{K}) where K
    keys = reduce(K; init=()) do acc, k
        k == :geometry ? acc : (acc..., k)
    end
    return NamedTuple{keys}(nt)
end

const MaybeArrayFeatureCollection = AbstractArray{<:NamedTuple}

_is_array_featurecollection(::Type{<:AbstractArray{T}}) where {T<:NamedTuple} = _is_namedtuple_feature(T)
_is_array_featurecollection(A::AbstractArray{<:NamedTuple}) = _is_array_featurecollection(typeof(A))

GeoInterface.isfeaturecollection(T::Type{<:MaybeArrayFeatureCollection}) = _is_array_featurecollection(T)
GeoInterface.trait(fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? FeatureCollectionTrait() : nothing
GeoInterface.nfeature(::FeatureCollectionTrait, fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? Base.length(fc) : nothing
GeoInterface.getfeature(::FeatureCollectionTrait, fc::MaybeArrayFeatureCollection, i::Integer) = _is_array_featurecollection(fc) ? fc[i] : nothing
GeoInterface.geometrycolumns(fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? (:geometry,) : nothing
