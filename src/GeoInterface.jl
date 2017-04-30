__precompile__()

module GeoInterface

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

    abstract AbstractPosition{T <: Real} <: AbstractVector{T}
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

    abstract AbstractGeometry
    coordinates(obj::AbstractGeometry) = error("coordinates(::AbstractGeometry) not defined.")

        abstract AbstractPoint <: AbstractGeometry
        geotype(::AbstractPoint) = :Point

        abstract AbstractMultiPoint <: AbstractGeometry
        geotype(::AbstractMultiPoint) = :MultiPoint

        abstract AbstractLineString <: AbstractGeometry
        geotype(::AbstractLineString) = :LineString

        abstract AbstractMultiLineString <: AbstractGeometry
        geotype(::AbstractMultiLineString) = :MultiLineString

        abstract AbstractPolygon <: AbstractGeometry
        geotype(::AbstractPolygon) = :Polygon

        abstract AbstractMultiPolygon <: AbstractGeometry
        geotype(::AbstractMultiPolygon) = :MultiPolygon

        abstract AbstractGeometryCollection <: AbstractGeometry
        geotype(::AbstractGeometryCollection) = :GeometryCollection
        geometries(obj::AbstractGeometryCollection) = error("geometries(::AbstractGeometryCollection) not defined.")

    abstract AbstractFeature
    geotype(::AbstractFeature) = :Feature
    geometry(obj::AbstractFeature) = error("geometry(::AbstractFeature) not defined.")
    # optional
    properties(obj::AbstractFeature) = Dict{String,Any}()
    bbox(obj::AbstractFeature) = nothing
    crs(obj::AbstractFeature) = nothing

    abstract AbstractFeatureCollection
    geotype(::AbstractFeatureCollection) = :FeatureCollection
    features(obj::AbstractFeatureCollection) = error("features(::AbstractFeatureCollection) not defined.")
    # optional
    bbox(obj::AbstractFeatureCollection) = nothing
    crs(obj::AbstractFeatureCollection) = nothing

    include("geotypes.jl")
end
