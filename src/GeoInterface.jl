__precompile__()

module GeoInterface

    using RecipesBase

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

    abstract type AbstractPosition{T <: Real} <: AbstractVector{T} end
    geotype(::AbstractPosition) = :Position
    xcoord(::AbstractPosition) = error("xcoord(::AbstractPosition) not defined.")
    ycoord(::AbstractPosition) = error("ycoord(::AbstractPosition) not defined.")
    # optional
    zcoord(::AbstractPosition) = error("zcoord(::AbstractPosition) not defined.")
    hasz(::AbstractPosition) = false
    coordinates(p::AbstractPosition) = hasz(p) ? Float64[xcoord(p),ycoord(p),zcoord(p)] : Float64[xcoord(p),ycoord(p)]
    # (Array-like indexing # http://julia.readthedocs.org/en/latest/manual/arrays/#arrays)
    Base.eltype(p::AbstractPosition{T}) where {T <: Real} = T
    Base.ndims(AbstractPosition) = 1
    Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
    Base.size(p::AbstractPosition) = (length(p),)
    Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
    Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? xcoord(p) : (i==2) ? ycoord(p) : (i==3) ? zcoord(p) : nothing
    Base.convert(::Type{Vector{Float64}}, p::AbstractPosition) = coordinates(p)
    # Base.linearindexing{T <: AbstractPosition}(::Type{T}) = LinearFast()

    abstract type AbstractGeometry end
    coordinates(obj::AbstractGeometry) = error("coordinates(::AbstractGeometry) not defined.")

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
        geometries(obj::AbstractGeometryCollection) = error("geometries(::AbstractGeometryCollection) not defined.")

    abstract type AbstractFeature end
    geotype(::AbstractFeature) = :Feature
    geometry(obj::AbstractFeature) = error("geometry(::AbstractFeature) not defined.")
    # optional
    properties(obj::AbstractFeature) = Dict{String,Any}()

    abstract type AbstractFeatureCollection end
    geotype(::AbstractFeatureCollection) = :FeatureCollection
    features(obj::AbstractFeatureCollection) = error("features(::AbstractFeatureCollection) not defined.")

    # optional
    bbox(obj) = nothing
    crs(obj) = nothing

    include("operations.jl")
    include("geotypes.jl")
    include("plotrecipes.jl")
end
