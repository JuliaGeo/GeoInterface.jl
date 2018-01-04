shapecoords(geom::AbstractPoint) = [tuple(coordinates(geom)...)]
RecipesBase.@recipe f(geom::AbstractPoint) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::AbstractMultiPoint)
    coords = coordinates(geom)
    first.(coords), last.(coords)
end
RecipesBase.@recipe f(geom::AbstractMultiPoint) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::AbstractLineString)
    coords = coordinates(geom)
    first.(coords), last.(coords)
end
RecipesBase.@recipe f(geom::AbstractLineString) = (
    aspect_ratio := 1;
    seriestype --> :path;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::AbstractMultiLineString)
    x, y = Float64[], Float64[]
    for line in coordinates(geom)
        append!(x, first.(line)); push!(x, NaN)
        append!(y, last.(line)); push!(y, NaN)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiLineString) = (
    aspect_ratio := 1;
    seriestype --> :path;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::AbstractPolygon)
    ring = first(coordinates(geom)) # currently doesn't plot holes
    first.(ring), last.(ring)
end
RecipesBase.@recipe f(geom::AbstractPolygon) = (
    aspect_ratio := 1;
    seriestype --> :shape;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::AbstractMultiPolygon)
    x, y = Float64[], Float64[]
    for poly in coordinates(geom)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        append!(x, first.(ring)); push!(x, NaN)
        append!(y, last.(ring)); push!(y, NaN)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiPolygon) = (
    aspect_ratio := 1;
    seriestype --> :shape;
    legend --> :false;
    shapecoords(geom)
)

RecipesBase.@recipe function f(geom::Vector{<:AbstractGeometry})
    aspect_ratio := 1
    legend --> :false
    for g in geom
        @series begin
            if g isa AbstractPoint || g isa AbstractMultiPoint
                seriestype := :scatter
            elseif g isa AbstractLineString || g isa AbstractMultiLineString
                seriestype := :path
            elseif g isa AbstractPolygon || g isa AbstractMultiPolygon
                seriestype := :shape
            end
            shapecoords(g)
        end
    end
end

RecipesBase.@recipe f(feature::AbstractFeature) = geometry(feature)
RecipesBase.@recipe f(features::Vector{<:AbstractFeature}) = geometry.(features)
RecipesBase.@recipe f(collection::AbstractFeatureCollection) = features(collection)
RecipesBase.@recipe f(collection::AbstractGeometryCollection) = geometries(collection)
