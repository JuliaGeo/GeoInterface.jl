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

        geotype,
        xcoord, ycoord, zcoord, hasz,
        coordinates,
        geometries,
        geometry, bbox, crs, properties,
        features

include("geotypes.jl")
include("features.jl")
include("operations.jl")
include("plotrecipes.jl")

end
