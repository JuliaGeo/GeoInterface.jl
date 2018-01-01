shapecoords(geom::AbstractPoint) = [tuple(coordinates(geom)...)]
RecipesBase.@recipe f(geom::AbstractPoint) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

shapecoords{T <: AbstractPoint}(geom::AbstractVector{T}) = Tuple{Float64,Float64}[tuple(coordinates(g)...) for g in geom]
RecipesBase.@recipe f{T <: AbstractPoint}(geom::AbstractVector{T}) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiPoint)
    coords = coordinates(geom)
    first.(coords), last.(coords)
end
RecipesBase.@recipe f(geom::AbstractMultiPoint) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

function shapecoords{T <: AbstractMultiPoint}(geom::Vector{T})
    x = Float64[]; y = Float64[]
    for g in geom
        coords = coordinates(g)
        append!(x, first.(coords)); append!(y, last.(coords))
    end
    x, y
end
RecipesBase.@recipe f{T <: AbstractMultiPoint}(geom::Vector{T}) = (seriestype --> :scatter; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractLineString)
    coords = coordinates(geom)
    first.(coords), last.(coords)
end
RecipesBase.@recipe f(geom::AbstractLineString) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords{T <: AbstractLineString}(geom::Vector{T})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for line in geom
        coords = coordinates(geom)
        push!(x, first.(coords)); push!(y, last.(coords))
    end
    x, y
end
RecipesBase.@recipe f{T <: AbstractLineString}(geom::Vector{T}) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiLineString)
    coords = coordinates(geom)
    x = Vector{Float64}[first.(line) for line in coords]
    y = Vector{Float64}[last.(line) for line in coords]
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiLineString) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords{T <: AbstractMultiLineString}(geom::Vector{T})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for g in geom, line in coordinates(g)
        push!(x, first.(line)); push!(y, last.(line))
    end
    x, y
end
RecipesBase.@recipe f{T <: AbstractMultiLineString}(geom::Vector{T}) = (seriestype --> :line; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractPolygon)
    ring = first(coordinates(geom)) # currently doesn't plot holes
    first.(ring), last.(ring)
end
RecipesBase.@recipe f(geom::AbstractPolygon) = (seriestype --> :shape; legend --> :false; shapecoords(geom))

function shapecoords{T <: AbstractPolygon}(geom::Vector{T})
    x = Vector{Float64}[]; y = Vector{Float64}[]
    for g in geom
        ring = first(coordinates(geom)) # currently doesn't plot holes
        push!(x, first.(ring)); push!(y, last.(ring))
    end
    x, y
end
RecipesBase.@recipe f{T <: AbstractPolygon}(geom::Vector{T}) = (seriestype --> :shape; legend --> :false; shapecoords(geom))

function shapecoords(geom::AbstractMultiPolygon)
    x, y = Vector{Float64}[], Vector{Float64}[]
    for poly in coordinates(geom)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        push!(x, first.(ring)); push!(y, last.(ring))
    end
    x, y
end
RecipesBase.@recipe f(geom::AbstractMultiPolygon) = (seriestype --> :shape; legend --> :false; shapecoords(geom))

function shapecoords{T <: AbstractMultiPolygon}(geom::Vector{T})
    x, y = Vector{Float64}[], Vector{Float64}[]
    for g in geom, poly in coordinates(g)
        ring = first(coordinates(poly)) # currently doesn't plot holes
        push!(x, first.(ring)); push!(y, last.(ring))
    end
    x, y
end
RecipesBase.@recipe f{T <: AbstractMultiPolygon}(geom::Vector{T}) = (seriestype --> :shape; legend --> :false; shapecoords(geom))
