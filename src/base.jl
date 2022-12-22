# Implementation of GeoInterface for Base Types


const PointTuple2 = Tuple{<:Real,<:Real}
const PointTuple3 = Tuple{<:Real,<:Real,<:Real}
const PointTuple4 = Tuple{<:Real,<:Real,<:Real,<:Real}
const PointTuple = Union{PointTuple2,PointTuple3,PointTuple4}

GeoInterface.isgeometry(::Type{<:AbstractVector{<:Real}}) = true
GeoInterface.geomtrait(::AbstractVector{<:Real}) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::AbstractVector{<:Real}) = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::AbstractVector{<:Real}, i) = getindex(geom, i)

GeoInterface.isgeometry(::Type{<:PointTuple}) = true
GeoInterface.geomtrait(::PointTuple) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::PointTuple) = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::PointTuple, i) = getindex(geom, i)

for (i, pointtype) in enumerate((PointTuple2, PointTuple3, PointTuple4))
    keys = default_coord_names[1:i+1]
    sig = NamedTuple{keys,<:pointtype}
    @eval GeoInterface.isgeometry(::Type{<:$sig}) = true
    @eval GeoInterface.geomtrait(::$sig) = PointTrait()
    @eval GeoInterface.ncoord(::PointTrait, geom::$sig) = $i + 1
    @eval GeoInterface.getcoord(::PointTrait, geom::$sig, i) = getindex(geom, i)
end


const NamedTuplePoints = Union{
    NamedTuple{(:X, :Y),<:PointTuple2},
    NamedTuple{(:Y, :X),<:PointTuple2},
    NamedTuple{(:X, :Y, :Z),<:PointTuple3},
    NamedTuple{(:X, :Z, :Y),<:PointTuple3},
    NamedTuple{(:Z, :Y, :X),<:PointTuple3},
    NamedTuple{(:Z, :X, :Y),<:PointTuple3},
    NamedTuple{(:Y, :X, :Z),<:PointTuple3},
    NamedTuple{(:Y, :Z, :X),<:PointTuple3},
    NamedTuple{(:X, :Y, :M),<:PointTuple3},
    NamedTuple{(:X, :M, :Y),<:PointTuple3},
    NamedTuple{(:M, :Y, :X),<:PointTuple3},
    NamedTuple{(:M, :X, :Y),<:PointTuple3},
    NamedTuple{(:Y, :X, :Z),<:PointTuple3},
    NamedTuple{(:Y, :Z, :X),<:PointTuple3},
    NamedTuple{(:X, :Y, :Z, :M),<:PointTuple4},
    NamedTuple{(:X, :Y, :M, :Z),<:PointTuple4},
    NamedTuple{(:X, :Z, :Y, :M),<:PointTuple4},
    NamedTuple{(:X, :Z, :M, :Y),<:PointTuple4},
    NamedTuple{(:X, :M, :Z, :Y),<:PointTuple4},
    NamedTuple{(:X, :M, :Y, :Z),<:PointTuple4},
    NamedTuple{(:Y, :X, :Z, :M),<:PointTuple4},
    NamedTuple{(:Y, :X, :M, :Z),<:PointTuple4},
    NamedTuple{(:Y, :Z, :X, :M),<:PointTuple4},
    NamedTuple{(:Y, :Z, :M, :X),<:PointTuple4},
    NamedTuple{(:Y, :M, :Z, :X),<:PointTuple4},
    NamedTuple{(:Y, :M, :X, :Z),<:PointTuple4},
    NamedTuple{(:Z, :Y, :X, :M),<:PointTuple4},
    NamedTuple{(:Z, :Y, :M, :X),<:PointTuple4},
    NamedTuple{(:Z, :X, :Y, :M),<:PointTuple4},
    NamedTuple{(:Z, :X, :M, :Y),<:PointTuple4},
    NamedTuple{(:Z, :M, :X, :Y),<:PointTuple4},
    NamedTuple{(:Z, :M, :Y, :X),<:PointTuple4},
    NamedTuple{(:M, :Y, :Z, :X),<:PointTuple4},
    NamedTuple{(:M, :Y, :X, :Z),<:PointTuple4},
    NamedTuple{(:M, :Z, :Y, :X),<:PointTuple4},
    NamedTuple{(:M, :Z, :X, :Y),<:PointTuple4},
    NamedTuple{(:M, :X, :Z, :Y),<:PointTuple4},
    NamedTuple{(:M, :X, :Y, :Z),<:PointTuple4},
}

_keys(::Type{<:NamedTuple{K}}) where K = K
# Custom coordinate order/names NamedTuple
GeoInterface.isgeometry(::Type{T}) where {T<:NamedTuplePoints} = all(in(default_coord_names), _keys(T))
GeoInterface.geomtrait(::NamedTuplePoints) where {Keys} = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::NamedTuplePoints) where {Keys} = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::NamedTuplePoints, i) where {Keys} = getindex(geom, i)
GeoInterface.coordnames(::PointTrait, geom::NamedTuplePoints) = _keys(typeof(geom))
GeoInterface.x(::PointTrait, geom::NamedTuplePoints, i) where {Keys} = geom.X
GeoInterface.y(::PointTrait, geom::NamedTuplePoints, i) where {Keys} = geom.Y
GeoInterface.z(::PointTrait, geom::NamedTuplePoints, i) where {Keys} = geom.Z
GeoInterface.m(::PointTrait, geom::NamedTuplePoints, i) where {Keys} = geom.M

# Default features using NamedTuple and AbstractArray

# Any named tuple with a `:geometry` field is a feature
_is_namedtuple_feature(::Type{<:NamedTuple{K}}) where K = :geometry in K
_is_namedtuple_feature(nt::NamedTuple) = _is_namedtuple_feature(typeof(nt))

GeoInterface.isfeature(T::Type{<:NamedTuple}) = _is_namedtuple_feature(T)
GeoInterface.trait(nt::NamedTuple) = _is_namedtuple_feature(nt) ? FeatureTrait() : geomtrait(nt)
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
GeoInterface.trait(fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? FeatureCollectionTrait() : geomtrait(fc)
GeoInterface.nfeature(::FeatureCollectionTrait, fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? Base.length(fc) : nothing
GeoInterface.getfeature(::FeatureCollectionTrait, fc::MaybeArrayFeatureCollection, i::Integer) = _is_array_featurecollection(fc) ? fc[i] : nothing
GeoInterface.geometrycolumns(fc::MaybeArrayFeatureCollection) = _is_array_featurecollection(fc) ? (:geometry,) : nothing
