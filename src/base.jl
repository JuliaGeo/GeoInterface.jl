# Implementation of GeoInterface for Base Types


# AbstractVector{<:Real} length 2 - 4 (where length checking is possible and efficient)

GeoInterface.isgeometry(::Type{<:AbstractVector{<:Real}}) = true
GeoInterface.geomtrait(::AbstractVector{<:Real}) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::AbstractVector{<:Real}) = Base.length(geom) # TODO should this error for length > 4 ?
GeoInterface.getcoord(::PointTrait, geom::AbstractVector{<:Real}, i) = getindex(geom, i)
GeoInterface.is3d(::PointTrait, geom::AbstractVector{<:Real}) = Base.length(geom) in (3, 4)
GeoInterface.ismeasured(::PointTrait, geom::AbstractVector{<:Real}) = Base.length(geom) == 4 # Measured must have Z

# x/y/z/m methods were 100x slower without these custom definitions
# Also allow @inbounds to make them slightly faster when you know the sizes
Base.@propagate_inbounds function GeoInterface.x(::PointTrait, geom::AbstractVector{<:Real})
    @boundscheck Base.length(geom) in (2, 3, 4) || _xy_error(Base.length(geom))
    @inbounds geom[begin]
end
Base.@propagate_inbounds function GeoInterface.y(::PointTrait, geom::AbstractVector{<:Real})
    @boundscheck Base.length(geom) in (2, 3, 4) || _xy_error(Base.length(geom))
    @inbounds geom[begin + 1]
end
Base.@propagate_inbounds function GeoInterface.z(::PointTrait, geom::AbstractVector{<:Real})
    @boundscheck Base.length(geom) in (3, 4) || _z_error(Base.length(geom))
    @inbounds geom[begin + 2]
end
Base.@propagate_inbounds function GeoInterface.m(::PointTrait, geom::AbstractVector{<:Real})
    @boundscheck Base.length(geom) == 4 || _m_error(Base.length(geom))
    @inbounds geom[end]
end

@noinline _xy_error(l) = throw(ArgumentError("Length of point must be 2, 3 or 4 to use `GeoInterface.x(point)` or `GeoInterface.y(point)`, got $l"))
@noinline _z_error(l) = throw(ArgumentError("Length of point must be 3 or 4 to use `GeoInterface.z(point)`, got $l"))
@noinline _m_error(l) = throw(ArgumentError("Length of point must be 4 to use `GeoInterface.m(point)`, got $l"))


# Tuple length 2 - 4

const PointTuple2 = Tuple{<:Real,<:Real}
const PointTuple3 = Tuple{<:Real,<:Real,<:Real}
const PointTuple4 = Tuple{<:Real,<:Real,<:Real,<:Real}
const PointTuple = Union{PointTuple2,PointTuple3,PointTuple4}

GeoInterface.isgeometry(::Type{<:PointTuple}) = true
GeoInterface.geomtrait(::PointTuple) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::PointTuple) = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::PointTuple, i) = getindex(geom, i)
GeoInterface.is3d(::PointTrait, geom::PointTuple2) = false
GeoInterface.is3d(::PointTrait, geom::Union{PointTuple3,PointTuple4}) = true
GeoInterface.ismeasured(::PointTrait, geom::Union{PointTuple2,PointTuple3}) = false
GeoInterface.ismeasured(::PointTrait, geom::PointTuple4) = true

GeoInterface.x(::PointTrait, geom::PointTuple) = geom[1]
GeoInterface.y(::PointTrait, geom::PointTuple) = geom[2]
GeoInterface.z(::PointTrait, geom::PointTuple2) = _z_error(Base.length(geom))
GeoInterface.z(::PointTrait, geom::Union{PointTuple3,PointTuple4}) = geom[3]
GeoInterface.m(::PointTrait, geom::PointTuple4) = geom[4]
GeoInterface.m(::PointTrait, geom::Union{PointTuple2,PointTuple3}) = _m_error(Base.length(geom))

function GeoInterface.convert(::Type{Tuple}, ::PointTrait, geom) 
    if is3d(geom)
        if ismeasured(geom)
            x(geom), y(geom), z(geom), m(geom)
        else
            x(geom), y(geom), z(geom)
        end
    elseif ismeasured(geom)
        x(geom), y(geom), m(geom)
    else
        x(geom), y(geom)
    end
end

function GeoInterface.convert(::Type{NamedTuple}, ::PointTrait, geom) 
    if is3d(geom)
        if ismeasured(geom)
            (X=x(geom), Y=y(geom), Z=z(geom), M=m(geom))
        else
            (X=x(geom), Y=y(geom), Z=z(geom))
        end
    elseif ismeasured(geom)
        (X=x(geom), Y=y(geom), M=m(geom))
    else
        (X=x(geom), Y=y(geom))
    end
end


# NamedTuple 
# with X/Y/Z/M names in any order

# Define all possible NamedTuple points
const NamedTuplePointXY = Union{
    NamedTuple{(:X, :Y),<:PointTuple2},
    NamedTuple{(:Y, :X),<:PointTuple2},
}

const NamedTuplePointZ = Union{
    NamedTuple{(:X, :Y, :Z),<:PointTuple3},
    NamedTuple{(:X, :Z, :Y),<:PointTuple3},
    NamedTuple{(:Z, :Y, :X),<:PointTuple3},
    NamedTuple{(:Z, :X, :Y),<:PointTuple3},
    NamedTuple{(:Y, :X, :Z),<:PointTuple3},
    NamedTuple{(:Y, :Z, :X),<:PointTuple3},
}
const NamedTuplePointM = Union{
    NamedTuple{(:X, :Y, :M),<:PointTuple3},
    NamedTuple{(:X, :M, :Y),<:PointTuple3},
    NamedTuple{(:M, :Y, :X),<:PointTuple3},
    NamedTuple{(:M, :X, :Y),<:PointTuple3},
    NamedTuple{(:Y, :X, :Z),<:PointTuple3},
    NamedTuple{(:Y, :Z, :X),<:PointTuple3},
}
const NamedTuplePointZM = Union{
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

const NamedTuplePoint = Union{NamedTuplePointXY,NamedTuplePointZ,NamedTuplePointM,NamedTuplePointZM}

_keys(::Type{<:NamedTuple{K}}) where K = K
GeoInterface.isgeometry(::Type{T}) where {T<:NamedTuplePoint} = true
GeoInterface.geomtrait(::NamedTuplePoint) = PointTrait()
GeoInterface.ncoord(::PointTrait, geom::NamedTuplePoint) = Base.length(geom)
GeoInterface.getcoord(::PointTrait, geom::NamedTuplePoint, i) = getindex(geom, i)
GeoInterface.coordnames(::PointTrait, geom::NamedTuplePoint) = _keys(typeof(geom))
GeoInterface.x(::PointTrait, geom::NamedTuplePoint) = geom.X
GeoInterface.y(::PointTrait, geom::NamedTuplePoint) = geom.Y
GeoInterface.z(::PointTrait, geom::Union{NamedTuplePointZ,NamedTuplePointZM}) = geom.Z
GeoInterface.z(::PointTrait, geom::NamedTuplePointXY) = throw(ArgumentError("NamedTuple point has no Z field"))
GeoInterface.m(::PointTrait, geom::Union{NamedTuplePointXY,NamedTuplePointZ}) = throw(ArgumentError("NamedTuple point has no M field"))


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
