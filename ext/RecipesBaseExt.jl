module RecipesBaseExt

using GeoInterface, RecipesBase

const GI = GeoInterface


RecipesBase.@recipe function f(t::Union{GI.PointTrait,GI.MultiPointTrait}, geom)
    seriestype --> :scatter
    GeoInterface._coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.AbstractLineStringTrait,GI.MultiLineStringTrait}, geom)
    seriestype --> :path
    GeoInterface._coordvecs(t, geom)
end

RecipesBase.@recipe function f(t::Union{GI.PolygonTrait,GI.MultiPolygonTrait,GI.LinearRingTrait}, geom)
    seriestype --> :shape
    GeoInterface._coordvecs(t, geom)
end

RecipesBase.@recipe f(::GI.GeometryCollectionTrait, collection) = collect(getgeom(collection))

# Features
RecipesBase.@recipe f(t::GI.FeatureTrait, feature) = GI.geometry(feature)

RecipesBase.@recipe f(t::GI.FeatureCollectionTrait, fc) = collect(GI.getfeature(fc))

# Enable Plots.jl for GeoInterface wrappers
@enable GeoInterface.Wrappers.WrapperGeometry

end
