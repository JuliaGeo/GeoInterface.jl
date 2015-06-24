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
            x, y, z, hasz,
            coordinates,
            geometries,
            geometry, bbox, crs, properties,
            features

    abstract AbstractPosition{T <: Real} <: AbstractVector{T}
    geotype(::AbstractPosition) = :Position
    x(::AbstractPosition) = error("x(::AbstractPosition) not defined.")
    y(::AbstractPosition) = error("y(::AbstractPosition) not defined.")
    # optional
    z(::AbstractPosition) = error("z(::AbstractPosition) not defined.")
    hasz(::AbstractPosition) = false
    coordinates(p::AbstractPosition) = hasz(p) ? Float64[x(p),y(p),z(p)] : Float64[x(p),y(p)]
    # (Array-like indexing # http://julia.readthedocs.org/en/latest/manual/arrays/#arrays)
    Base.eltype{T <: Real}(p::AbstractPosition{T}) = T
    Base.ndims(AbstractPosition) = 1
    Base.length(p::AbstractPosition) = hasz(p) ? 3 : 2
    Base.size(p::AbstractPosition) = (length(p),)
    Base.size(p::AbstractPosition, n::Int) = (n == 1) ? length(p) : 1
    Base.getindex(p::AbstractPosition, i::Int) = (i==1) ? x(p) : (i==2) ? y(p) : (i==3) ? z(p) : nothing
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
