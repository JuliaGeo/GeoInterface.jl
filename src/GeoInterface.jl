__precompile__()

module GeoInterface

    using Compat

    export  AbstractPosition, Position,
            AbstractGeometry, AbstractGeometryCollection, GeometryCollection,
            AbstractPoint, Point,
            AbstractMultiPoint, MultiPoint,
            AbstractLineString, LineString,
            AbstractMultiLineString, MultiLineString,
            AbstractPolygon, Polygon,
            AbstractMultiPolygon, MultiPolygon,
            AbstractFeature, Feature,
            AbstractFeatureCollection, FeatureCollection,

            geotype, # methods
            xcoord, ycoord, zcoord, hasz,
            coordinates,
            geometries,
            geometry, bbox, crs, properties,
            features

    @compat abstract type AbstractPosition{T <: Real} <: AbstractVector{T} end
    geotype(::AbstractPosition) = :Position
    xcoord(::AbstractPosition) = error("xcoord(::AbstractPosition) not defined.")
    ycoord(::AbstractPosition) = error("ycoord(::AbstractPosition) not defined.")
    # optional
    zcoord(::AbstractPosition) = error("zcoord(::AbstractPosition) not defined.")
    hasz(::AbstractPosition) = false
    coordinates(p::AbstractPosition) = hasz(p) ? Float64[xcoord(p),ycoord(p),zcoord(p)] : Float64[xcoord(p),ycoord(p)]
    # (Array-like indexing # http://julia.readthedocs.org/en/latest/manual/arrays/#arrays)
    Base.eltype{T <: Real}(p::AbstractPosition{T}) = T
    Base.ndims(AbstractPosition) = 1
    Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
    Base.size(p::AbstractPosition) = (length(p),)
    Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
    Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? xcoord(p) : (i==2) ? ycoord(p) : (i==3) ? zcoord(p) : nothing
    Base.convert(::Type{Vector{Float64}}, p::AbstractPosition) = coordinates(p)
    # Base.linearindexing{T <: AbstractPosition}(::Type{T}) = LinearFast()

    @compat abstract type AbstractGeometry end
    coordinates(obj::AbstractGeometry) = error("coordinates(::AbstractGeometry) not defined.")

        @compat abstract type AbstractPoint <: AbstractGeometry end
        geotype(::AbstractPoint) = :Point

        @compat abstract type AbstractMultiPoint <: AbstractGeometry end
        geotype(::AbstractMultiPoint) = :MultiPoint

        @compat abstract type AbstractLineString <: AbstractGeometry end
        geotype(::AbstractLineString) = :LineString

        @compat abstract type AbstractMultiLineString <: AbstractGeometry end
        geotype(::AbstractMultiLineString) = :MultiLineString

        @compat abstract type AbstractPolygon <: AbstractGeometry end
        geotype(::AbstractPolygon) = :Polygon

        @compat abstract type AbstractMultiPolygon <: AbstractGeometry end
        geotype(::AbstractMultiPolygon) = :MultiPolygon

        @compat abstract type AbstractGeometryCollection <: AbstractGeometry end
        geotype(::AbstractGeometryCollection) = :GeometryCollection
        geometries(obj::AbstractGeometryCollection) = error("geometries(::AbstractGeometryCollection) not defined.")

    @compat abstract type AbstractFeature end
    geotype(::AbstractFeature) = :Feature
    geometry(obj::AbstractFeature) = error("geometry(::AbstractFeature) not defined.")
    # optional
    properties(obj::AbstractFeature) = Dict{String,Any}()
    bbox(obj::AbstractFeature) = nothing
    crs(obj::AbstractFeature) = nothing

    @compat abstract type AbstractFeatureCollection end
    geotype(::AbstractFeatureCollection) = :FeatureCollection
    features(obj::AbstractFeatureCollection) = error("features(::AbstractFeatureCollection) not defined.")
    # optional
    bbox(obj::AbstractFeatureCollection) = nothing
    crs(obj::AbstractFeatureCollection) = nothing

    include("geotypes.jl")
end
