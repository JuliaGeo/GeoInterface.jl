shapecoords(geom::AbstractPoint) = [tuple(coordinates(geom)...)]
RecipesBase.@recipe f(geom::AbstractPoint) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom)
)

shapecoords(geom::AbstractVector{<:AbstractPoint}) = Tuple{Float64,Float64}[
    tuple(coordinates(g)...) for g in geom
]

function shapecoords(geom::AbstractMultiPoint)
    coords = coordinates(geom)
    x, y = Float64[], Float64[]
    for pt in coords
        push!(x, pt[1]); push!(x, NaN)
        append!(y, pt[2]); push!(y, NaN)
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiPoint) = (
    aspect_ratio := 1;
    seriestype --> :scatter;
    legend --> :false;
    shapecoords(geom)
)

function shapecoords(geom::Vector{<:AbstractMultiPoint})
    x = Float64[]; y = Float64[]
    for g in geom
        coords = coordinates(g)
        append!(x, first.(coords)); append!(y, last.(coords))
    end
    x, y
end

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

function shapecoords(geom::Vector{<:AbstractLineString})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for line in geom
        coords = coordinates(geom)
        push!(x, first.(coords)); push!(y, last.(coords))
    end
    x, y
end

function shapecoords(geom::AbstractMultiLineString)
    coords = coordinates(geom)
    x, y = Float64[], Float64[]
    for line in coords
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

function shapecoords(geom::Vector{<:AbstractMultiLineString})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for g in geom, line in coordinates(g)
        push!(x, first.(line)); push!(y, last.(line))
    end
    x, y
end

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

function shapecoords(geom::Vector{<:AbstractPolygon})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for g in geom
        ring = first(coordinates(g)) # currently doesn't plot holes
        push!(x, first.(ring)); push!(y, last.(ring))
    end
    x, y
end

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

function shapecoords(geom::Vector{<:AbstractMultiPolygon})
    x, y = Vector{Float64}[], Vector{Float64}[]
    for g in geom, poly in coordinates(g)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        push!(x, first.(ring)); push!(y, last.(ring))
    end
    x, y
end

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
