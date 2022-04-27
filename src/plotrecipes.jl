# Dispatch on any AbstractGeometry
RecipesBase.@recipe function f(geom::AbstractGeometry)
    label --> :none
    if plotattributes[:plot_object].n == 0
        aspect_ratio --> 1
    end
    geomtype(geom), geom
end

RecipesBase.@recipe function f(geom::Vector{<:Union{Missing,AbstractGeometry}})
    label --> :none
    if plotattributes[:plot_object].n == 0
        aspect_ratio --> 1
    end
    for g in skipmissing(geom)
        @series begin
            geomtype(g), g
        end
    end
end

RecipesBase.@recipe function f(trait::Union{PointTrait,MultiPointTrait}, geom)
    seriestype --> :scatter
    _plotcoords(trait, geom)
end

RecipesBase.@recipe function f(trait::Union{LineStringTrait,MultiLineStringTrait}, geom)
    seriestype --> :path
    _plotcoords(trait, geom)
end

RecipesBase.@recipe function f(trait::Union{PolygonTrait,MultiPolygonTrait}, geom)
    seriestype --> :shape
    _plotcoords(trait, geom)
end

RecipesBase.@recipe f(::GeometryCollectionTrait, collection) = geometries(collection)

# Convert coordinates to the form used by Plots.jl
_plotcoords(::PointTrait, geom) = [tuple(coordinates(geom)...)]
function _plotcoords(::MultiPointTrait, geom)
    coords = coordinates(geom)
    return first.(coords), last.(coords)
end
function _plotcoords(::LineStringTrait, geom)
    coords = coordinates(geom)
    return first.(coords), last.(coords)
end
function _plotcoords(::MultiLineStringTrait, geom)
    x, y = Float64[], Float64[]
    for line in coordinates(geom)
        append!(x, first.(line)); push!(x, NaN)
        append!(y, last.(line)); push!(y, NaN)
    end
    return x, y
end
function _plotcoords(::PolygonTrait, geom)
    ring = first(coordinates(geom)) # currently doesn't plot holes
    return first.(ring), last.(ring)
end
function _plotcoords(::MultiPolygonTrait, geom)
    x, y = Float64[], Float64[]
    for poly in coordinates(geom)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        append!(x, first.(ring)); push!(x, NaN)
        append!(y, last.(ring)); push!(y, NaN)
    end
    return x, y
end
